"""
ILP solver for the Compressor Tree (CT) stage of an FPGA multiplier,
generalised to support asymmetric Wa-bit x Wb-bit multipliers.

Implements the formulation in graph_gen.py (the user's reference) which
matches paper "ILP-Driven FPGA Multiplier Synthesis" Sec III.A:

    column index j = 0 .. nCols-1            (CT covers cols r = 3..Wa+Wb-2)
    step    index i = 0 .. S
    Input[i,j]   - # OIPs   uncompressed at step i, col j
    Inter[i,j]   - # IGPs   uncompressed at step i, col j
    Comp[k,i,j]  - # times compressor k is used at step i, col j

    Initial:  Input[0, j] = min(j+4, Wa, Wb, Wa+Wb-4-j)
              Inter[0, j] = 1 if (j == 1 and min(Wa,Wb) >= 3) else 0
    Termination:
              Input[S, j] + Inter[S, j] <= 2
              Input[S, j] + Input[S, j-1] <= 1      (CLA pin budget)

Total LUT cost = sum cost_k * Comp + 4 (LOP) + (Wa+Wb-4) (CLA).

Asymmetric support requires Wa, Wb >= 3 (LOP block needs both axes >= 3).

The solver also accepts a weighted objective:
    obj = alpha_lut * sum(cost_k * Comp[k,i,j])           # CT LUT cost
        + gamma_carry * sum(Comp[k,i,j] for chain kids)   # CARRY4 cell count
        + (4 + Wa+Wb-4)                                   # LOP + CLA constants
The constants don't affect the optimisation but stay in objval for clarity.
"""

from compressors import (all_compressors, compressor_paper_label,
                         chain_base_kid, chain_oip_count,
                         CHAIN_KIDS_HEAD, CHAIN_KIDS_BODY, CHAIN_KIDS_TAIL,
                         CHAIN_KIDS_ALL)
from signed_support import correction_bits, validate_sign_widths


def _kid_sort_key(kid):
    if kid.startswith('p'):
        return (0, int(kid[1:]))
    base = chain_base_kid(kid)
    carry_order = {'cI': 0, 'cII': 1, 'cIII': 2}
    return (1, carry_order.get(base, 99), chain_oip_count(kid), kid)


def solve_ct(Wa, Wb=None, S=None,
             use_lut_carry=False,
             sign_a=False, sign_b=False,
             alpha_lut=1.0, gamma_carry=0.0,
             threads=8, time_limit=600, mip_gap=1e-4,
             mip_focus=2,
             verbose=True):
    """Solve the CT-generation ILP for Wa x Wb multiplier with S CT steps.

    Backward-compat: if Wb is None, assume Wb=Wa (square multiplier).

    Args:
        Wa, Wb         : multiplier widths.  Both must be >= 3 (>= 4 if signed).
        S              : number of CT compression steps.
        use_lut_carry  : enable Table II chain compressors (cI/cII/cIII *).
        sign_a, sign_b : treat operand a / b as signed (two's complement) via
                         Baugh-Wooley.  Signed axes inject constant correction
                         IGPs into the initial bit-heap; verilog_gen / verify
                         apply the matching NAND PPs and MSB inversion.
        alpha_lut      : weight on total LUT cost (compressor LUTs only).
        gamma_carry    : weight on # chain cells (proxy for CARRY4 packing).
                         Set > 0 to bias the solve away from chains, < 0 to
                         encourage them.

    Returns: result dict with comps list, OIPV/IGPV state, costs, etc.
    """
    if Wb is None:
        Wb = Wa
    if Wa < 3 or Wb < 3:
        raise ValueError("solve_ct requires Wa>=3 and Wb>=3, got Wa=%d Wb=%d"
                         % (Wa, Wb))
    validate_sign_widths(Wa, Wb, sign_a, sign_b)
    if S is None:
        S = max(2, max(Wa, Wb) // 2)

    import gurobipy as gp
    from gurobipy import GRB

    comps = all_compressors(use_lut_carry=use_lut_carry)
    K = sorted(comps.keys(), key=_kid_sort_key)

    nCols = Wa + Wb - 4                            # j = 0 .. nCols-1
    R_LO  = 3
    R_HI  = R_LO + nCols - 1                       # = Wa + Wb - 2

    m_v = [comps[k]['oip_c']  for k in K]
    p_v = [comps[k]['igp_c']  for k in K]
    q_v = [comps[k]['igp_n']  for k in K]
    u_v = [comps[k]['gen_c']  for k in K]
    v_v = [comps[k]['gen_n']  for k in K]
    z_v = [comps[k]['gen_2n'] for k in K]
    cost_v = [comps[k]['cost'] for k in K]
    is_chain_v = [1 if k in CHAIN_KIDS_ALL else 0 for k in K]
    nK = len(K)

    model = gp.Model("ILP_FPGA_Mult_W%dx%d_S%d" % (Wa, Wb, S))
    model.setParam("OutputFlag", 1 if verbose else 0)
    model.setParam("Threads", threads)
    model.setParam("TimeLimit", time_limit)
    model.setParam("MIPGap", mip_gap)
    model.setParam("MIPFocus", mip_focus)

    Input = model.addVars(S + 1, nCols, vtype=GRB.INTEGER, lb=0, name="Input")
    Inter = model.addVars(S + 1, nCols, vtype=GRB.INTEGER, lb=0, name="Inter")
    Comp  = model.addVars(nK, S, nCols, vtype=GRB.INTEGER, lb=0, name="Comp")

    lut_term = gp.quicksum(cost_v[k] * Comp[k, i, j]
                           for k in range(nK)
                           for i in range(S)
                           for j in range(nCols))
    chain_term = gp.quicksum(is_chain_v[k] * Comp[k, i, j]
                             for k in range(nK)
                             for i in range(S)
                             for j in range(nCols))
    fixed_const = 4 + (Wa + Wb - 4)               # LOP + CLA

    model.setObjective(
        alpha_lut * lut_term + gamma_carry * chain_term + fixed_const,
        GRB.MINIMIZE)

    # Baugh-Wooley signed correction: constant '1' IGPs at fixed columns raise
    # those columns' initial height so the CT compresses them too.  Unsigned ->
    # empty.  The MSB correction (col Wa+Wb-1) lies outside the CT region and is
    # realised downstream by inverting the final CLA carry-out.
    corr_cols, _msb_correction = correction_bits(Wa, Wb, sign_a, sign_b)
    corr_per_col = {}
    for c in corr_cols:
        corr_per_col[c - R_LO] = corr_per_col.get(c - R_LO, 0) + 1

    # Initial state.  CT starts at absolute col 3 (j=0).  LOP injects
    # super-carry C0 into absolute col 4 (j=1).
    for j in range(nCols):
        height = min(j + 4, Wa, Wb, Wa + Wb - 4 - j)
        model.addConstr(Input[0, j] == max(0, height),
                        name="init_Input_j%d" % j)
        init_lop = 1 if (j == 1 and min(Wa, Wb) >= 3) else 0
        init_inter = init_lop + corr_per_col.get(j, 0)
        model.addConstr(Inter[0, j] == init_inter, name="init_Inter_j%d" % j)

    # Iterations
    for i in range(1, S + 1):
        for j in range(nCols):
            model.addConstr(
                Input[i, j] == Input[i - 1, j]
                - gp.quicksum(m_v[k] * Comp[k, i - 1, j] for k in range(nK)),
                name="Input_iter_i%d_j%d" % (i, j))

            consumed_p     = gp.quicksum(p_v[k] * Comp[k, i - 1, j] for k in range(nK))
            consumed_q     = gp.quicksum(q_v[k] * Comp[k, i - 1, j - 1] for k in range(nK)) if j >= 1 else 0
            generated_u    = gp.quicksum(u_v[k] * Comp[k, i - 1, j] for k in range(nK))
            generated_v    = gp.quicksum(v_v[k] * Comp[k, i - 1, j - 1] for k in range(nK)) if j >= 1 else 0
            generated_z    = gp.quicksum(z_v[k] * Comp[k, i - 1, j - 2] for k in range(nK)) if j >= 2 else 0

            model.addConstr(
                Inter[i, j] == Inter[i - 1, j]
                - consumed_p - consumed_q
                + generated_u + generated_v + generated_z,
                name="Inter_iter_i%d_j%d" % (i, j))
            model.addConstr(
                Inter[i - 1, j] - consumed_p - consumed_q >= 0,
                name="Inter_avail_i%d_j%d" % (i, j))

    # Termination
    for j in range(nCols):
        model.addConstr(Input[S, j] + Inter[S, j] <= 2,
                        name="term_pp_j%d" % j)
    for j in range(2, nCols):
        model.addConstr(Input[S, j] + Input[S, j - 1] <= 1,
                        name="term_oip_j%d" % j)

    # No compressor at the highest col (j == nCols-1)
    for k in range(nK):
        for i in range(S):
            model.addConstr(Comp[k, i, nCols - 1] == 0,
                            name="no_comp_top_k%d_i%d" % (k, i))
    if nCols >= 2:
        for k_idx, kid in enumerate(K):
            if kid in ('p7', 'p8', 'p9', 'p10', 'p11'):
                for i in range(S):
                    model.addConstr(Comp[k_idx, i, nCols - 2] == 0,
                                    name="no_high_2nd_top_%s_i%d" % (kid, i))

    # Optional Table II chain topology (variant-agnostic).
    head_idx = [K.index(kid) for kid in CHAIN_KIDS_HEAD if kid in K]
    body_idx = [K.index(kid) for kid in CHAIN_KIDS_BODY if kid in K]
    tail_idx = [K.index(kid) for kid in CHAIN_KIDS_TAIL if kid in K]
    if use_lut_carry and head_idx and body_idx and tail_idx:
        active = model.addVars(S, nCols, vtype=GRB.INTEGER, lb=0,
                               name='active_chain')
        for i in range(S):
            for j in range(nCols):
                I_cnt   = gp.quicksum(Comp[k, i, j] for k in head_idx)
                II_cnt  = gp.quicksum(Comp[k, i, j] for k in body_idx)
                III_cnt = gp.quicksum(Comp[k, i, j] for k in tail_idx)
                if j == 0:
                    model.addConstr(II_cnt + III_cnt == 0,
                                    name='cc_firstcol_i%d' % i)
                    model.addConstr(active[i, j] == I_cnt,
                                    name='cc_active_i%d_j%d' % (i, j))
                else:
                    model.addConstr(II_cnt + III_cnt == active[i, j - 1],
                                    name='cc_match_i%d_j%d' % (i, j))
                    model.addConstr(active[i, j] == active[i, j - 1] + I_cnt - III_cnt,
                                    name='cc_balance_i%d_j%d' % (i, j))
            model.addConstr(active[i, nCols - 1] == 0,
                            name='cc_terminate_i%d' % i)

    model.optimize()
    if model.SolCount == 0:
        raise RuntimeError("No feasible CT found for Wa=%d Wb=%d S=%d." % (Wa, Wb, S))

    # Harvest
    flat_comps = []
    for s in range(S):
        for j in range(nCols):
            for k in range(nK):
                cnt = int(round(Comp[k, s, j].X))
                for _ in range(cnt):
                    flat_comps.append({'step': s,
                                       'col':  R_LO + j,
                                       'kid':  K[k]})

    Input_v = [[int(round(Input[s, j].X)) for j in range(nCols)] for s in range(S + 1)]
    Inter_v = [[int(round(Inter[s, j].X)) for j in range(nCols)] for s in range(S + 1)]

    # Achieved metrics
    ct_lut_cost = sum(comps[c['kid']]['cost'] for c in flat_comps)
    n_chain_cells = sum(1 for c in flat_comps if c['kid'] in CHAIN_KIDS_ALL)
    total_lut = ct_lut_cost + 4 + (Wa + Wb - 4)

    return {
        'Wa'             : Wa,
        'Wb'             : Wb,
        'W'              : Wa,                # alias for back-compat callers
        'S'              : S,
        'sign_a'         : sign_a,
        'sign_b'         : sign_b,
        'R_LO'           : R_LO,
        'R_HI'           : R_HI,
        'nCols'          : nCols,
        'comps'          : flat_comps,
        'OIPV'           : Input_v,
        'IGPV'           : Inter_v,
        'cost'           : ct_lut_cost,       # CT LUT count only
        'total_lut'      : total_lut,         # CT + LOP + CLA
        'n_chain_cells'  : n_chain_cells,
        'alpha_lut'      : alpha_lut,
        'gamma_carry'    : gamma_carry,
        'status'         : model.Status,
        'mipgap'         : model.MIPGap,
        'objval'         : model.ObjVal,
    }


def pretty_print(result, comps_dict):
    Wa, Wb, S = result['Wa'], result['Wb'], result['S']
    print("\n=========  ILP CT result   W%dx%d  S=%d  =========" % (Wa, Wb, S))
    print("Status : %s   ObjVal=%.2f   MIPGap=%.4f" %
          (result['status'], result['objval'], result['mipgap']))
    print("CT  LUT cost                                 : %d" % result['cost'])
    print("LOP LUT cost (4 LUT6_2)                      : 4")
    print("CLA LUT cost (= Wa+Wb-4)                     : %d" % (Wa + Wb - 4))
    print("Total Area[LUT]                              : %d" % result['total_lut'])
    print("Chain cells used                             : %d" % result['n_chain_cells'])
    print("Weights (alpha_lut, gamma_carry)             : (%.3f, %.3f)" %
          (result['alpha_lut'], result['gamma_carry']))

    print("\n--- final-step PP residue (must be <=2 per col) ---")
    print("  col :", " ".join("%3d" % r
          for r in range(result['R_LO'], result['R_HI'] + 1)))
    print("  OIP :", " ".join("%3d" % v for v in result['OIPV'][-1]))
    print("  IGP :", " ".join("%3d" % v for v in result['IGPV'][-1]))

    print("\n--- compressor usage by step / column ---")
    by_step = {}
    for c in result['comps']:
        by_step.setdefault(c['step'], []).append(c)
    for s in sorted(by_step):
        print("  step %d:" % s)
        cells = {}
        for c in by_step[s]:
            cells.setdefault(c['col'], []).append(c['kid'])
        for col in sorted(cells):
            print("    col %2d :" % col,
                  ", ".join("%s(%s)" % (k, comps_dict[k]['name'])
                            for k in cells[col]))


if __name__ == "__main__":
    import sys
    Wa = int(sys.argv[1]) if len(sys.argv) >= 2 else 4
    Wb = int(sys.argv[2]) if len(sys.argv) >= 3 else Wa
    Sv = int(sys.argv[3]) if len(sys.argv) >= 4 else 2
    res = solve_ct(Wa, Wb, Sv, use_lut_carry=True)
    pretty_print(res, all_compressors(use_lut_carry=True))
