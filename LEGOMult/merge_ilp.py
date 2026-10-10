"""
merge_ilp.py  --  STEP 2 of the two-step flow.

"Merge the three": take the partial-product rows produced by ALL tiles of the
Step-1 cover -- the DSP result bits, the Booth-Array residual partial products,
and the LUT-tile AND/NAND original-input PPs -- assemble them into one bit-heap,
and solve the SOURCE LUT+CARRY4 compressor-tree ILP to reduce the heap to <=2
rows per column (then a final CARRY4 CLA forms the product).

The compressor library (compressors.py) and the ILP formulation are exactly the
ones used by the original monolithic solver (ilp_solver.solve_ct); the only
change is the INITIAL heap, which here comes from the tiling instead of the
WaxWb AND-array, and the absence of the fixed LOP carve-out (columns 0..2 are
covered by tiles like any other).

build_heap()     : tiles -> per-column OIP cells + IGP BitExprs + correction
solve_merge()    : LUT+CARRY4 compressor-tree ILP over the heap (Gurobi)
greedy_merge()   : Gurobi-free full/half-adder reduction (fallback, same format)
heap_value()     : golden integer value of the heap for given (a,b)
"""

from compressors import (all_compressors, chain_base_kid, chain_oip_count,
                         CHAIN_KIDS_HEAD, CHAIN_KIDS_BODY, CHAIN_KIDS_TAIL,
                         CHAIN_KIDS_ALL)
from tiles import tile_heap_bits, BitExpr


# =============================================================================
#  Heap construction from a tiling
# =============================================================================
class Heap(object):
    """Merged bit-heap.

      nCols   : number of columns (= Wa+Wb)
      oip     : list per column of (kind, i, j); kind in {'OIP','OIP_INV'}.
                Each is an AND/NAND of operand bits a[i],b[j] (a LUT-tile cell).
      igp     : list per column of BitExpr single-bit rows (Booth/DSP/const).
      const   : integer correction already folded into igp as constant bits.
    """
    def __init__(self, nCols):
        self.nCols = nCols
        self.oip = [[] for _ in range(nCols)]
        self.igp = [[] for _ in range(nCols)]
        self.const = 0

    def oip_heights(self):
        return [len(c) for c in self.oip]

    def igp_heights(self):
        return [len(c) for c in self.igp]

    def total_heights(self):
        return [len(self.oip[j]) + len(self.igp[j]) for j in range(self.nCols)]

    def max_height(self):
        return max(self.total_heights()) if self.nCols else 0

    def as_all_igp(self):
        """Return a copy where every OIP cell (a[i]&b[j] / NAND) is realised as
        a single IGP BitExpr.  Value-preserving; used by the greedy fallback and
        its RTL pre-stage (one AND/NAND LUT per cell)."""
        h = Heap(self.nCols)
        h.const = self.const
        for col in range(self.nCols):
            for be in self.igp[col]:
                h.igp[col].append(be)
            for (kind, i, j) in self.oip[col]:
                if kind == 'OIP_INV':
                    be = BitExpr([('a', i), ('b', j)],
                                 (lambda v: 1 - (v[0] & v[1])), "NAND")
                else:
                    be = BitExpr([('a', i), ('b', j)],
                                 (lambda v: v[0] & v[1]), "AND")
                h.igp[col].append(be)
        return h


def build_heap(tiles, Wa, Wb, sign_a, sign_b):
    nCols = Wa + Wb
    M = 1 << nCols
    heap = Heap(nCols)
    total_const = 0
    for t in tiles:
        oip, igp, const = tile_heap_bits(t, Wa, Wb, sign_a, sign_b)
        for (col, spec) in oip:
            if 0 <= col < nCols:
                heap.oip[col].append(spec)
        for (col, be) in igp:
            if 0 <= col < nCols:
                heap.igp[col].append(be)
        total_const += const
    # fold the accumulated correction (mod M) into constant '1' IGP bits
    c = total_const % M
    heap.const = c
    for p in range(nCols):
        if (c >> p) & 1:
            heap.igp[p].append(BitExpr([], (lambda v: 1), "corr1"))
    return heap


def heap_value(heap, a, b, Wa, Wb, sign_a, sign_b, dsp_wires=None):
    """Golden integer value of the heap (mod 2^nCols) for operands a,b.

    DSP opaque wires are supplied from the true slice products if not given."""
    nCols = heap.nCols
    M = 1 << nCols
    if dsp_wires is None:
        dsp_wires = {}
    total = 0
    for col in range(nCols):
        for (kind, i, j) in heap.oip[col]:
            ab = ((a >> i) & 1) & ((b >> j) & 1)
            val = (1 - ab) if kind == 'OIP_INV' else ab
            total += val << col
        for be in heap.igp[col]:
            total += be.eval(a, b, dsp_wires) << col
    return total % M


# =============================================================================
#  ILP : LUT+CARRY4 compressor-tree over an arbitrary heap (generalised
#  ilp_solver.solve_ct -- no LOP carve-out, init from the tiling).
# =============================================================================
def _kid_sort_key(kid):
    if kid.startswith('p'):
        return (0, int(kid[1:]))
    base = chain_base_kid(kid)
    return (1, {'cI': 0, 'cII': 1, 'cIII': 2}.get(base, 99),
            chain_oip_count(kid), kid)


def solve_merge(heap, S=None, use_lut_carry=True,
                alpha_lut=1.0, gamma_carry=0.0, max_chain=None,
                threads=8, time_limit=600, mip_gap=1e-3, verbose=True,
                max_extra_steps=6):
    """Solve the compressor-tree ILP for the merged heap, auto-escalating the
    number of reduction steps S until a feasible tree is found.  Returns a
    result dict (comps, final residue OIPV/IGPV, costs).

    max_chain bounds the LENGTH of any carry chain, in cells.  It is the delay
    handle: the objective counts LUTs and knows nothing about time, so without
    it the solver is free to run one chain across the whole heap to save a cell,
    and carry propagation along that chain is what the critical path is made of.
    Tightening it forces shallower chains, which usually costs steps and LUTs --
    sweeping it traces an area-delay front that is optimised at every point
    rather than sampled.  None leaves chains unbounded (the original model).
    Chains always span at least two columns, so values below 2 are meaningless.
    """
    if S is None:
        S = max(2, heap.max_height().bit_length() + 1)
    if max_chain is not None and max_chain < 2:
        raise ValueError("max_chain must be >= 2 (a chain spans >= 2 columns)")
    last = None
    for extra in range(max_extra_steps + 1):
        res = _solve_merge_once(heap, S + extra, use_lut_carry, alpha_lut,
                                gamma_carry, threads, time_limit, mip_gap,
                                verbose, max_chain)
        if res is not None:
            return res
        last = S + extra
    raise RuntimeError("merge ILP not solved up to S=%d (heap max height %d, "
                       "max_chain=%s): infeasible, OR the model exceeds the "
                       "restricted-license size limit -- use a full Gurobi "
                       "license, or --merge greedy"
                       % (last, heap.max_height(), max_chain))


def _solve_merge_once(heap, S, use_lut_carry, alpha_lut, gamma_carry,
                      threads, time_limit, mip_gap, verbose, max_chain=None):
    import gurobipy as gp
    from gurobipy import GRB

    nCols = heap.nCols
    oip0 = heap.oip_heights()
    igp0 = heap.igp_heights()

    comps = all_compressors(use_lut_carry=use_lut_carry)
    K = sorted(comps.keys(), key=_kid_sort_key)
    m_v = [comps[k]['oip_c'] for k in K]
    p_v = [comps[k]['igp_c'] for k in K]
    q_v = [comps[k]['igp_n'] for k in K]
    u_v = [comps[k]['gen_c'] for k in K]
    v_v = [comps[k]['gen_n'] for k in K]
    z_v = [comps[k]['gen_2n'] for k in K]
    cost_v = [comps[k]['cost'] for k in K]
    is_chain_v = [1 if k in CHAIN_KIDS_ALL else 0 for k in K]
    nK = len(K)

    model = gp.Model("merge_ct_%dcols_S%d" % (nCols, S))
    model.setParam("OutputFlag", 1 if verbose else 0)
    model.setParam("Threads", threads)
    model.setParam("TimeLimit", time_limit)
    model.setParam("MIPGap", mip_gap)
    model.setParam("MIPFocus", 2)

    Input = model.addVars(S + 1, nCols, vtype=GRB.INTEGER, lb=0, name="Input")
    Inter = model.addVars(S + 1, nCols, vtype=GRB.INTEGER, lb=0, name="Inter")
    Comp = model.addVars(nK, S, nCols, vtype=GRB.INTEGER, lb=0, name="Comp")

    lut_term = gp.quicksum(cost_v[k] * Comp[k, i, j]
                           for k in range(nK) for i in range(S)
                           for j in range(nCols))
    chain_term = gp.quicksum(is_chain_v[k] * Comp[k, i, j]
                             for k in range(nK) for i in range(S)
                             for j in range(nCols))
    model.setObjective(alpha_lut * lut_term + gamma_carry * chain_term,
                       GRB.MINIMIZE)

    # initial heap from the tiling
    for j in range(nCols):
        model.addConstr(Input[0, j] == oip0[j], name="init_oip_%d" % j)
        model.addConstr(Inter[0, j] == igp0[j], name="init_igp_%d" % j)

    for i in range(1, S + 1):
        for j in range(nCols):
            model.addConstr(
                Input[i, j] == Input[i - 1, j]
                - gp.quicksum(m_v[k] * Comp[k, i - 1, j] for k in range(nK)),
                name="oip_iter_%d_%d" % (i, j))
            consumed_p = gp.quicksum(p_v[k] * Comp[k, i - 1, j] for k in range(nK))
            consumed_q = gp.quicksum(q_v[k] * Comp[k, i - 1, j - 1] for k in range(nK)) if j >= 1 else 0
            generated_u = gp.quicksum(u_v[k] * Comp[k, i - 1, j] for k in range(nK))
            generated_v = gp.quicksum(v_v[k] * Comp[k, i - 1, j - 1] for k in range(nK)) if j >= 1 else 0
            generated_z = gp.quicksum(z_v[k] * Comp[k, i - 1, j - 2] for k in range(nK)) if j >= 2 else 0
            model.addConstr(
                Inter[i, j] == Inter[i - 1, j] - consumed_p - consumed_q
                + generated_u + generated_v + generated_z,
                name="igp_iter_%d_%d" % (i, j))
            model.addConstr(Inter[i - 1, j] - consumed_p - consumed_q >= 0,
                            name="igp_avail_%d_%d" % (i, j))

    for j in range(nCols):
        model.addConstr(Input[S, j] + Inter[S, j] <= 2, name="term_pp_%d" % j)
    for j in range(2, nCols):
        model.addConstr(Input[S, j] + Input[S, j - 1] <= 1, name="term_oip_%d" % j)

    # NOTE: unlike the monolithic solver (which offloads the top columns to the
    # CLA and forbids compressors there), the merge result is taken mod
    # 2^nCols (= the Wa+Wb-bit product), so compressors ARE allowed in every
    # column; any carry generated past column nCols-1 is the modular overflow
    # and is simply discarded (the gen-into-col guards below drop it).  This
    # matches the verified greedy reduction.

    # chain topology (Table II)
    head_idx = [K.index(kid) for kid in CHAIN_KIDS_HEAD if kid in K]
    body_idx = [K.index(kid) for kid in CHAIN_KIDS_BODY if kid in K]
    tail_idx = [K.index(kid) for kid in CHAIN_KIDS_TAIL if kid in K]
    if use_lut_carry and head_idx and body_idx and tail_idx:
        active = model.addVars(S, nCols, vtype=GRB.INTEGER, lb=0, name='active_chain')
        for i in range(S):
            for j in range(nCols):
                I_cnt = gp.quicksum(Comp[k, i, j] for k in head_idx)
                II_cnt = gp.quicksum(Comp[k, i, j] for k in body_idx)
                III_cnt = gp.quicksum(Comp[k, i, j] for k in tail_idx)
                if j == 0:
                    model.addConstr(II_cnt + III_cnt == 0, name='ccf_%d' % i)
                    model.addConstr(active[i, j] == I_cnt, name='cca_%d_%d' % (i, j))
                else:
                    model.addConstr(II_cnt + III_cnt == active[i, j - 1], name='ccm_%d_%d' % (i, j))
                    model.addConstr(active[i, j] == active[i, j - 1] + I_cnt - III_cnt, name='ccb_%d_%d' % (i, j))
            model.addConstr(active[i, nCols - 1] == 0, name='cct_%d' % i)

        # ---- chain-length bound : the delay handle -----------------------
        # Chains are interchangeable in this aggregate model, so "no chain is
        # longer than D cells" is exactly "every chain opened at or before
        # column j is closed by column j+D-1", which counts heads against
        # tails over a sliding window.  Linear, and S*nCols constraints.
        if max_chain is not None:
            for i in range(S):
                heads = [gp.quicksum(Comp[k, i, c] for k in head_idx)
                         for c in range(nCols)]
                tails = [gp.quicksum(Comp[k, i, c] for k in tail_idx)
                         for c in range(nCols)]
                for j in range(nCols):
                    end = min(j + max_chain - 1, nCols - 1)
                    if end >= nCols - 1:
                        break          # implied by active[i, nCols-1] == 0
                    model.addConstr(
                        gp.quicksum(heads[c] for c in range(j + 1))
                        <= gp.quicksum(tails[c] for c in range(end + 1)),
                        name='chainlen_%d_%d' % (i, j))
    elif max_chain is not None:
        raise ValueError("max_chain requires the LUT+carry chain library "
                         "(use_lut_carry=True)")

    try:
        model.optimize()
    except gp.GurobiError as e:
        # e.g. restricted-license model-size limit in the sandbox; the real
        # flow uses a full Gurobi license.  Signal "no solution at this S".
        if verbose:
            print("[merge] gurobi optimize error: %s" % str(e)[:120])
        return None
    if model.SolCount == 0:
        return None

    flat = []
    for s in range(S):
        for j in range(nCols):
            for k in range(nK):
                cnt = int(round(Comp[k, s, j].X))
                for _ in range(cnt):
                    flat.append({'step': s, 'col': j, 'kid': K[k]})
    Input_v = [[int(round(Input[s, j].X)) for j in range(nCols)] for s in range(S + 1)]
    Inter_v = [[int(round(Inter[s, j].X)) for j in range(nCols)] for s in range(S + 1)]
    ct_cost = sum(comps[c['kid']]['cost'] for c in flat)
    n_chain = sum(1 for c in flat if c['kid'] in CHAIN_KIDS_ALL)
    lens = chain_lengths(flat)
    longest = max(lens) if lens else 0
    if max_chain is not None and longest > max_chain:
        raise AssertionError("chain-length bound violated: %d > %d"
                             % (longest, max_chain))
    return {
        'nCols': nCols, 'S': S, 'comps': flat,
        'OIPV': Input_v, 'IGPV': Inter_v,
        'ct_cost': ct_cost, 'n_chain_cells': n_chain,
        'max_chain': max_chain, 'longest_chain': longest,
        'chain_depth': sum(_step_longest(flat, s) for s in range(S)),
        'objval': model.ObjVal, 'mipgap': model.MIPGap, 'status': model.Status,
        'method': 'ilp',
    }


def chain_lengths(flat):
    """Length in cells of every carry chain in a solved schedule.

    Chains are rebuilt the way the emitter rebuilds them: within one step, walk
    the columns left to right, a head opens a chain and a tail closes the one
    that has been open longest.  The aggregate ILP variables do not name chains,
    so this is what "the longest chain" actually means in the emitted netlist.
    """
    out = []
    by_step = {}
    for c in flat:
        if c['kid'] in CHAIN_KIDS_ALL:
            by_step.setdefault(c['step'], []).append(c)
    for step, cells in by_step.items():
        open_at = []
        for col in sorted(set(c['col'] for c in cells)):
            here = [c for c in cells if c['col'] == col]
            for c in here:
                if c['kid'] in CHAIN_KIDS_HEAD:
                    open_at.append(col)
            for c in here:
                if c['kid'] in CHAIN_KIDS_TAIL and open_at:
                    out.append(col - open_at.pop(0) + 1)
    return out


def _step_longest(flat, step):
    lens = chain_lengths([c for c in flat if c['step'] == step])
    return max(lens) if lens else 0


# =============================================================================
#  Gurobi-free fallback : full/half-adder carry-save reduction.
#  All heap bits are treated as IGP (the RTL pre-realises every LUT-tile AND
#  cell as a single LUT first), then reduced with p0 (3:2 FA) and p6 (2:2 HA).
# =============================================================================
def greedy_merge(heap, max_steps=64):
    nCols = heap.nCols
    # work on integer column heights; start all-IGP (OIP folded in)
    height = heap.total_heights()[:]
    comps = []
    step = 0
    # state vectors recorded as all-IGP for the residue
    while max(height) > 2 and step < max_steps:
        carry_in = [0] * nCols                  # carries produced into next step
        new_height = [0] * nCols
        for j in range(nCols):
            n = height[j]
            # full adders first
            nf = n // 3
            rem = n - 3 * nf
            nh = 0
            if rem == 2:
                nh = 1
                rem = 0
            # FA: consume 3 -> sum@j(next), carry@j+1(next)
            for _ in range(nf):
                comps.append({'step': step, 'col': j, 'kid': 'p0'})
                new_height[j] += 1            # sum stays in column j
                if j + 1 < nCols:
                    carry_in[j + 1] += 1
            # HA: consume 2 -> sum@j, carry@j+1
            for _ in range(nh):
                comps.append({'step': step, 'col': j, 'kid': 'p6'})
                new_height[j] += 1
                if j + 1 < nCols:
                    carry_in[j + 1] += 1
            # leftover single bit passes through
            new_height[j] += rem
        height = [new_height[j] + carry_in[j] for j in range(nCols)]
        step += 1
    S = step
    # build residue state (all IGP)
    OIPV = [[0] * nCols for _ in range(S + 1)]
    IGPV = [[0] * nCols for _ in range(S + 1)]   # filled lazily; only last row used
    IGPV[S] = height[:]
    ct_cost = len(comps)
    return {
        'nCols': nCols, 'S': S, 'comps': comps,
        'OIPV': OIPV, 'IGPV': IGPV,
        'ct_cost': ct_cost, 'n_chain_cells': 0,
        'objval': float(ct_cost), 'mipgap': 0.0, 'status': 'greedy',
        'method': 'greedy',
    }


# =============================================================================
#  Validity / value check of a merge schedule (integer level)
# =============================================================================
def simulate_merge_state(heap, result):
    """Re-derive Input/Inter state from the schedule and check termination.
    Returns (ok, OIPV, IGPV)."""
    comps_lib = all_compressors(use_lut_carry=True)
    nCols = heap.nCols
    S = result['S']
    oip = [heap.oip_heights()[:]] + [[0] * nCols for _ in range(S)]
    igp = [heap.igp_heights()[:]] + [[0] * nCols for _ in range(S)]
    by = {}
    for c in result['comps']:
        by.setdefault((c['step'], c['col']), []).append(c['kid'])
    for s in range(S):
        for j in range(nCols):
            oip[s + 1][j] = oip[s][j]
            igp[s + 1][j] = igp[s][j]
    for s in range(S):
        # apply consumption/generation
        cons_oip = [0] * nCols
        cons_igp = [0] * nCols
        gen_igp = [0] * nCols
        for j in range(nCols):
            for kid in by.get((s, j), []):
                sp = comps_lib[kid]
                cons_oip[j] += sp['oip_c']
                cons_igp[j] += sp['igp_c']
                if j + 1 < nCols:
                    cons_igp[j + 1] += sp['igp_n']   # igp_n consumed from col j+1
                gen_igp[j] += sp['gen_c']
                if j + 1 < nCols:
                    gen_igp[j + 1] += sp['gen_n']
                if j + 2 < nCols:
                    gen_igp[j + 2] += sp['gen_2n']
        for j in range(nCols):
            oip[s + 1][j] = oip[s][j] - cons_oip[j]
            igp[s + 1][j] = igp[s][j] - cons_igp[j] + gen_igp[j]
    ok = True
    for j in range(nCols):
        if oip[S][j] < 0 or igp[S][j] < 0:
            ok = False
        if oip[S][j] + igp[S][j] > 2:
            ok = False
    return ok, oip, igp


if __name__ == "__main__":
    import sys
    from tiling_ilp import solve_tiling, summarize_tiling
    Wa = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    Wb = int(sys.argv[2]) if len(sys.argv) > 2 else Wa
    L = int(sys.argv[3]) if len(sys.argv) > 3 else 4
    md = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    sa = sb = True
    tiles, tinfo = solve_tiling(Wa, Wb, sign_a=sa, sign_b=sb, booth_level=L,
                                max_dsp=md, use_gurobi=False, verbose=False)
    print(summarize_tiling(tiles, Wa, Wb, tinfo))
    heap = build_heap(tiles, Wa, Wb, sa, sb)
    print("heap heights:", heap.total_heights(), "max", heap.max_height())
    res = greedy_merge(heap)
    ok, _, _ = simulate_merge_state(heap.as_all_igp(), res)
    print("greedy merge: S=%d comps=%d residue-valid=%s"
          % (res['S'], len(res['comps']), ok))
