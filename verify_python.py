"""
Python-level functional verifier (no Gurobi needed).

Replays exactly the LOP + CT + CLA emitted by `verilog_gen.py`:
    - LOP : 4 LUT6_2  ->  r[0], r[1], r[2], C1, C0
    - CT  : pure-LUT compressors (Table I idx 0..11)
            + LUT-CarryChain compressors (Table II Type I/II/III)
              -- restored exact carry-chain 4:2 semantics:
                 local bits x0/x1/x2 plus same-weight CI are reduced as
                 x0+x1+x2+CI = sum_cur + 2*(carry_explicit + carry_chain)
                 where carry_explicit = majority(x0,x1,x2) and
                 carry_chain = CI when parity(x0,x1,x2)=1 else 0.
    - CLA : per-col LUT6_2 (P/G), CARRY4 chain with CYINIT = C1, C0 added
            as an extra IGP at col R_LO+1
    - r[2W-1] = final CARRY4.CO

Cross-check `simulate_multiplier(W, S, result, a, b) == a * b` for all
(a,b) pairs (or deterministic samples for larger W).
"""

import sys
from compressors import (all_compressors, PURE_LUT_COMPRESSORS,
                         LUT_CARRY_COMPRESSORS,
                         chain_base_kid, chain_oip_count,
                         CHAIN_KIDS_ALL)
from verilog_gen import compute_init
from signed_support import pp_inverted, correction_bits


# --------------------------------------------------------------- LUT helpers
def _lut(init, inputs):
    idx = 0
    for i, b in enumerate(inputs):
        idx |= (b & 1) << i
    return (init >> idx) & 1


def _eval_lut6_2(init64, inputs5):
    """We tie I5='1'b1' so O6 reads INIT[63:32]."""
    init_o5 = init64 & 0xFFFFFFFF
    init_o6 = (init64 >> 32) & 0xFFFFFFFF
    return _lut(init_o5, inputs5), _lut(init_o6, inputs5)


# --------------------------------------------------------------- LOP
def lop_outputs(a, b):
    """Mirrors verilog_gen._emit_lop functionally.  Returns
    (r0, r1, r2, C1, C0)."""
    a0b1 = a[0] & b[1]
    a1b0 = a[1] & b[0]
    r0 = a[0] & b[0]
    r1 = a0b1 ^ a1b0
    if len(a) >= 3 and len(b) >= 3:
        a0b2 = a[0] & b[2]
        a1b1 = a[1] & b[1]
        a2b0 = a[2] & b[0]
        lc1  = a0b1 & a1b0
        s2   = a0b2 + a1b1 + a2b0 + lc1
        r2 = s2 & 1
        C1 = (s2 >> 1) & 1
        C0 = (s2 >> 2) & 1
    else:
        r2 = 0; C1 = 0; C0 = 0
    return r0, r1, r2, C1, C0


# --------------------------------------------------------------- CARRY4 chain
def _carry4_chain(p_bits, g_bits, cyinit_first=0):
    """Behavioural model of cascaded CARRY4s.  Returns (sum_bits, final_co).
    For the first stage CYINIT carries the LOP carry (C1)."""
    n = len(p_bits)
    out = [0] * n
    cy = cyinit_first
    final_co = cyinit_first
    for i in range(n):
        out[i] = p_bits[i] ^ cy
        cy = cy if p_bits[i] else g_bits[i]
        final_co = cy
    return out, final_co


# ----------------------------------------- LUT-CarryChain group reconstruction
def _group_lutcarry_chains(comp_list_at_step):
    """Given the chain compressors (any cI*/cII*/cIII* variant) at a single
    step, group them into contiguous (head, body*, tail) chains and return
    (pure_list, chains)."""
    pure = []
    by_col = {}
    for c in comp_list_at_step:
        if c['kid'] in CHAIN_KIDS_ALL:
            by_col.setdefault(c['col'], []).append(c)
        else:
            pure.append(c)
    chains = []
    if not by_col:
        return pure, chains
    cols = sorted(by_col)
    active = []
    for col in range(cols[0], cols[-1] + 1):
        cells = by_col.get(col, [])
        cIs   = [c for c in cells if chain_base_kid(c['kid']) == 'cI']
        cIIs  = [c for c in cells if chain_base_kid(c['kid']) == 'cII']
        cIIIs = [c for c in cells if chain_base_kid(c['kid']) == 'cIII']
        if active:
            if len(cIIs) + len(cIIIs) != len(active):
                raise ValueError('chain count mismatch at col %d' % col)
            new_active = []
            for idx, ch in enumerate(active):
                if idx < len(cIIIs):
                    ch.append(cIIIs[idx])
                    chains.append(ch)
                else:
                    ch.append(cIIs[idx - len(cIIIs)])
                    new_active.append(ch)
            active = new_active
        elif cIIs or cIIIs:
            raise ValueError('cII/cIII without active chain at col %d' % col)
        for h in cIs:
            active.append([h])
    if active:
        raise ValueError('unterminated chain(s)')
    return pure, chains


# ----------------------------------------- ILP-state derivation (no Gurobi)
def derive_state_vectors(Wa, Wb, S, comps):
    """Walk OIPV/IGPV evolution for an Wa x Wb multiplier."""
    nCols = Wa + Wb - 4
    R_LO = 3
    OIPV = [[0] * nCols for _ in range(S + 1)]
    IGPV = [[0] * nCols for _ in range(S + 1)]
    for j in range(nCols):
        OIPV[0][j] = max(0, min(j + 4, Wa, Wb, Wa + Wb - 4 - j))
    if min(Wa, Wb) >= 3:
        IGPV[0][1] = 1
    by_step = {}
    for c in comps:
        by_step.setdefault(c['step'], []).append(c)
    def spec(kid):
        if kid.startswith('p'):
            return PURE_LUT_COMPRESSORS[int(kid[1:])]
        return LUT_CARRY_COMPRESSORS[kid[1:]]
    for s in range(S):
        for j in range(nCols):
            OIPV[s + 1][j] = OIPV[s][j]
            IGPV[s + 1][j] = IGPV[s][j]
        for c in by_step.get(s, []):
            sp = spec(c['kid'])
            j = c['col'] - R_LO
            OIPV[s + 1][j] -= sp['oip_c']
            IGPV[s + 1][j] -= sp['igp_c']
            # IGP_N goes the same direction as gen_n: a compressor at col j
            # consumes igp_n IGPs from col j+1 (matches graph_gen.py's
            # `q[k] * Compressor[k, i-1, j-1]` term subtracted from
            # Inter[i, j], which means a compressor at col j-1 consumes from
            # col j, i.e. compressor at col r consumes from r+1).
            if j + 1 < nCols:
                IGPV[s + 1][j + 1] -= sp['igp_n']
            IGPV[s + 1][j] += sp['gen_c']
            if j + 1 < nCols:
                IGPV[s + 1][j + 1] += sp['gen_n']
            if j + 2 < nCols:
                IGPV[s + 1][j + 2] += sp['gen_2n']
    return OIPV, IGPV


def check_termination(OIPV, IGPV):
    nCols = len(OIPV[0])
    issues = []
    for j in range(nCols):
        if OIPV[-1][j] + IGPV[-1][j] > 2:
            issues.append('col %d sum %d+%d>2' % (j, OIPV[-1][j], IGPV[-1][j]))
        if OIPV[-1][j] < 0:
            issues.append('col %d OIP<0' % j)
        if IGPV[-1][j] < 0:
            issues.append('col %d IGP<0' % j)
    # ILP enforces OIP-pair only for j>=2 (skips abs col 3 vs 4 boundary).
    # Mirror that exactly so dataset records produced by ilp_solver re-validate.
    for j in range(2, nCols):
        if OIPV[-1][j] + OIPV[-1][j - 1] > 1:
            issues.append('col %d+%d OIP-pair %d+%d>1' %
                          (j, j - 1, OIPV[-1][j], OIPV[-1][j - 1]))
    return issues


# --------------------------------------------------------------- main sim
def simulate_multiplier(Wa, Wb, S, result, a_int, b_int):
    if isinstance(Wa, dict):  # back-compat: old call simulate_multiplier(result, a, b)
        raise TypeError('simulate_multiplier signature changed; pass Wa, Wb, S, result, a, b')
    Tot = Wa + Wb
    sign_a = bool(result.get('sign_a', False))
    sign_b = bool(result.get('sign_b', False))
    a = [(a_int >> i) & 1 for i in range(Wa)]
    b = [(b_int >> i) & 1 for i in range(Wb)]
    use_lc = any(c['kid'].startswith('c') for c in result['comps'])
    comps = all_compressors(use_lut_carry=use_lc)

    # ---- LOP
    r0, r1, r2, C1, C0 = lop_outputs(a, b)
    r = [0] * Tot
    r[0], r[1], r[2] = r0, r1, r2

    # ---- CT
    R_LO, R_HI = result['R_LO'], result['R_HI']
    oip_q = {col: [] for col in range(Tot)}
    for col in range(Tot):
        for bj in range(Wb):
            ai = col - bj
            if 0 <= ai < Wa:
                inv = pp_inverted(ai, bj, Wa, Wb, sign_a, sign_b)
                oip_q[col].append((a[ai], b[bj], inv))

    ipool = {}
    def pool_pop(step, col):
        for s in range(step, -1, -1):
            key = (s, col)
            if key in ipool and ipool[key]:
                return ipool[key].pop(0)
        return 0
    def pool_add(step, col, v):
        ipool.setdefault((step, col), []).append(v)

    if min(Wa, Wb) >= 3 and 4 < Tot:
        pool_add(0, 4, C0)

    # Baugh-Wooley constant correction IGPs (signed); the top correction bit
    # (MSB) is applied after the CLA below.  Unsigned -> no correction.
    corr_cols, msb_correction = correction_bits(Wa, Wb, sign_a, sign_b)
    for col in corr_cols:
        pool_add(0, col, 1)

    by_step = {}
    for c in result['comps']:
        by_step.setdefault(c['step'], []).append(c)

    for step in sorted(by_step):
        pure_list, chains = _group_lutcarry_chains(by_step[step])
        work_items = []
        for idx, c in enumerate(pure_list):
            work_items.append(('pure', c['col'], idx, c))
        for idx, ch in enumerate(chains):
            work_items.append(('chain', ch[0]['col'], idx, ch))
        work_items.sort(key=lambda x: (x[1], 0 if x[0] == 'pure' else 1, x[2]))

        for kind, _, _, obj in work_items:
            if kind == 'pure':
                c = obj
                spec = comps[c['kid']]
                s, col = c['step'], c['col']
                pin_kinds, pin_vals = [], []
                for _ in range(spec['oip_c']):
                    if oip_q[col]:
                        pa, pb, inv = oip_q[col].pop(0)
                    else:
                        pa, pb, inv = 0, 0, False
                    pin_kinds.append('OIP_INV' if inv else 'OIP'); pin_vals += [pa, pb]
                for _ in range(spec['igp_c']):
                    pin_kinds.append('IGP'); pin_vals.append(pool_pop(s, col))
                # IGP_N is the "next-order" IGP: a compressor at col r consumes
                # q IGPs from col r+1 (matches graph_gen.py's
                # `q[k] * Compressor[k, i-1, j-1]` term subtracted from
                # Inter[i, j]).  verilog_gen.py uses the same convention
                # (`igp_pool.pop(s, r + 1)`).  The pin kind must also be
                # 'IGP_N' so compute_init() weights it correctly (an IGP at
                # col r+1 contributes 2 to the LUT "ones" sum because col r+1
                # has weight 2 in col-r units).  Earlier this verifier popped
                # from col-1 AND labelled the pin 'IGP' -- two bugs that only
                # cancelled for compressors with q=0.
                for _ in range(spec['igp_n']):
                    pin_kinds.append('IGP_N')
                    pin_vals.append(pool_pop(s, col + 1))

                modes = (['sum']    * spec['gen_c']
                       + ['carry']  * spec['gen_n']
                       + ['carry2'] * spec['gen_2n'])

                if spec['kind'] == 'LUT6_2':
                    while len(pin_vals) < 5: pin_vals.append(0)
                    pin_vals = pin_vals[:5]
                    num_lut = (len(modes) + 1) // 2
                    outs = []
                    for li in range(num_lut):
                        m_o5 = modes[2*li]   if 2*li     < len(modes) else 'sum'
                        m_o6 = modes[2*li+1] if 2*li + 1 < len(modes) else m_o5
                        init_o5 = compute_init(pin_kinds, m_o5, lut_input_width=5)
                        init_o6 = compute_init(pin_kinds, m_o6, lut_input_width=5)
                        init64 = ((init_o6 & 0xFFFFFFFF) << 32) | (init_o5 & 0xFFFFFFFF)
                        O5, O6 = _eval_lut6_2(init64, pin_vals)
                        outs.append(O5)
                        if 2*li + 1 < len(modes):
                            outs.append(O6)
                else:
                    while len(pin_vals) < 6: pin_vals.append(0)
                    pin_vals = pin_vals[:6]
                    outs = []
                    for m in modes:
                        init = compute_init(pin_kinds, m, lut_input_width=6)
                        outs.append(_lut(init, pin_vals))

                idx = 0
                for _ in range(spec['gen_c']):
                    pool_add(s + 1, col, outs[idx]); idx += 1
                for _ in range(spec['gen_n']):
                    if col + 1 < Tot:
                        pool_add(s + 1, col + 1, outs[idx])
                    idx += 1
                for _ in range(spec['gen_2n']):
                    if col + 2 < Tot:
                        pool_add(s + 1, col + 2, outs[idx])
                    idx += 1
            else:
                # Paper-exact Table-II 3-input adder chain (Fig.5(a)) with
                # OIP/IGP mixed-input variants (cI_o*/cII_o*/cIII_o*).
                # Per cell at col k:
                #   The 3 PPs at col k come from:
                #     n_oip OIP pairs (popped from oip_q[col], AND-ed)
                #     (3 - n_oip) IGPs (popped from pool at (step, col))
                #   par3 = parity3(local 3 PPs)
                #   maj3 = majority3(local 3 PPs)        -> p_k, becomes next p_prev
                #   S = par3 XOR p_prev      (LUT6_2.O6 / LUT6 par for o2)
                #   DI = p_prev              (routed to CARRY4 stage k)
                #   sum_bit = S XOR chain_cin    (CARRY4.O = bit_k of result)
                #   chain_cout = S ? chain_cin : DI  (CARRY4.CO -> next stage's CI)
                # Chain head: p_prev = head_seed (the 4th IGP popped from col j),
                #             chain_cin = 0
                # Chain tail (cIII*): emit chain_cout AND maj3 to col+1 of pool.
                chain = obj
                head_col = chain[0]['col']
                p_prev = pool_pop(step, head_col)   # head seed = 4th IGP at col j
                chain_cin = 0                       # CYINIT for chain head = 0
                last = None
                for cell in chain:
                    col = cell['col']
                    n_oip = chain_oip_count(cell['kid'])
                    n_igp = 3 - n_oip
                    pp_vals = []
                    for _ in range(n_oip):
                        if oip_q[col]:
                            pa, pb, inv = oip_q[col].pop(0)
                        else:
                            pa, pb, inv = 0, 0, False
                        pp_vals.append((pa & pb) ^ (1 if inv else 0))
                    for _ in range(n_igp):
                        pp_vals.append(pool_pop(step, col))
                    x0, x1, x2 = pp_vals
                    par3 = (x0 ^ x1 ^ x2) & 1
                    maj3 = 1 if (x0 + x1 + x2) >= 2 else 0
                    Sval = par3 ^ p_prev    # CARRY4.S; do NOT shadow outer S
                    DIval = p_prev
                    sum_bit = Sval ^ chain_cin
                    chain_cout = chain_cin if Sval else DIval
                    pool_add(step + 1, col, sum_bit)
                    last = (col, chain_cout, maj3)
                    # Set up next cell
                    p_prev = maj3
                    chain_cin = chain_cout
                # Tail: emit chain_cout + maj3 (last cell's) to col+1
                if last is not None:
                    col_t, co_t, maj_t = last
                    if col_t + 1 < Tot:
                        pool_add(step + 1, col_t + 1, co_t)
                        pool_add(step + 1, col_t + 1, maj_t)

    # ---- CLA
    nbits = R_HI - R_LO + 1
    cla_p, cla_g = [0] * nbits, [0] * nbits

    for i, col in enumerate(range(R_LO, R_HI + 1)):
        ins_kinds, ins_vals = [], []
        for _ in range(result['OIPV'][-1][i]):
            if oip_q[col]:
                pa, pb, inv = oip_q[col].pop(0)
            else:
                pa, pb, inv = 0, 0, False
            ins_kinds.append('OIP_INV' if inv else 'OIP'); ins_vals += [pa, pb]
        for _ in range(result['IGPV'][-1][i]):
            ins_kinds.append('IGP'); ins_vals.append(pool_pop(S, col))
        if not ins_vals:
            continue
        init_o5 = compute_init(ins_kinds, 'g', lut_input_width=5)
        init_o6 = compute_init(ins_kinds, 'p', lut_input_width=5)
        while len(ins_vals) < 5:
            ins_vals.append(0)
        cla_g[i], cla_p[i] = _eval_lut6_2(
            ((init_o6 & 0xFFFFFFFF) << 32) | (init_o5 & 0xFFFFFFFF),
            ins_vals[:5])

    sum_bits, final_co = _carry4_chain(cla_p, cla_g, cyinit_first=C1)
    for i, col in enumerate(range(R_LO, R_HI + 1)):
        r[col] = sum_bits[i]
    r[Tot - 1] = (1 - final_co) if msb_correction else final_co

    val = 0
    for i in range(Tot):
        val |= (r[i] & 1) << i
    return val


# ---------------------------------------------------------- hand-crafted tests
def _build_result(*args):
    """Two call shapes accepted:
        _build_result(W, S, comps)               -- legacy symmetric
        _build_result(Wa, Wb, S, comps)          -- asymmetric
    """
    if len(args) == 3:
        Wa, S, comps = args
        Wb = Wa
    elif len(args) == 4:
        Wa, Wb, S, comps = args
    else:
        raise TypeError('_build_result expects (W, S, comps) or (Wa, Wb, S, comps)')
    OIPV, IGPV = derive_state_vectors(Wa, Wb, S, comps)
    issues = check_termination(OIPV, IGPV)
    if issues:
        raise AssertionError('schedule violates termination: %s' % issues)
    nCols = Wa + Wb - 4
    return {
        'Wa': Wa, 'Wb': Wb, 'W': Wa, 'S': S,
        'R_LO': 3, 'R_HI': 3 + nCols - 1, 'nCols': nCols,
        'comps': comps, 'OIPV': OIPV, 'IGPV': IGPV,
        'cost': sum((PURE_LUT_COMPRESSORS[int(c['kid'][1:])]['cost'] if c['kid'].startswith('p')
                     else LUT_CARRY_COMPRESSORS[c['kid'][1:]]['cost']) for c in comps),
        'status': 2, 'mipgap': 0.0, 'objval': 0.0,
    }


def make_4x4_pure_result():
    """Pure-LUT W=4, S=2 schedule, automatically state-checked.

    This matches the current solver optimum from `run.py --W 4 --S 2`.
    """
    comps = [
        {'step': 0, 'col': 3, 'kid': 'p3'},
        {'step': 0, 'col': 4, 'kid': 'p4'},
        {'step': 1, 'col': 4, 'kid': 'p1'},
        {'step': 1, 'col': 5, 'kid': 'p2'},
    ]
    return _build_result(4, 2, comps)


def make_4x4_lutcarry_result():
    """Carry-enabled W=4, S=2 optimum under the restored Table-II model.

    Even after restoring correct carry arithmetic, this tiny case still solves to
    a pure-LUT optimum.  Keep this fixture so the verifier checks that enabling
    carry mode does not break small baselines that legitimately choose zero carry
    cells.
    """
    comps = [
        {'step': 0, 'col': 3, 'kid': 'p3'},
        {'step': 0, 'col': 4, 'kid': 'p4'},
        {'step': 1, 'col': 4, 'kid': 'p1'},
        {'step': 1, 'col': 5, 'kid': 'p2'},
    ]
    return _build_result(4, 2, comps)


def make_8x8_s5_lutcarry_result():
    """Real carry-enabled solve result for W=8, S=5 under the restored model.

    This fixture intentionally contains a cI -> cIII chain so the Python
    verifier exercises the Table-II carry path end-to-end without requiring a
    local Gurobi installation.  OIPV / IGPV are copied from an actual solve so
    the fixture stays aligned with the solver's state bookkeeping.
    """
    comps = [
        {'step': 0, 'col': 3, 'kid': 'p3'},
        {'step': 0, 'col': 4, 'kid': 'p4'},
        {'step': 0, 'col': 4, 'kid': 'p4'},
        {'step': 0, 'col': 7, 'kid': 'p3'},
        {'step': 0, 'col': 9, 'kid': 'p3'},
        {'step': 1, 'col': 5, 'kid': 'p2'},
        {'step': 1, 'col': 5, 'kid': 'p2'},
        {'step': 1, 'col': 7, 'kid': 'p2'},
        {'step': 1, 'col': 8, 'kid': 'p2'},
        {'step': 1, 'col': 9, 'kid': 'p2'},
        {'step': 1, 'col': 10, 'kid': 'p2'},
        {'step': 2, 'col': 4, 'kid': 'p10'},
        {'step': 2, 'col': 5, 'kid': 'p2'},
        {'step': 2, 'col': 6, 'kid': 'p2'},
        {'step': 2, 'col': 6, 'kid': 'p2'},
        {'step': 2, 'col': 7, 'kid': 'p2'},
        {'step': 2, 'col': 8, 'kid': 'p2'},
        {'step': 2, 'col': 9, 'kid': 'p1'},
        {'step': 2, 'col': 10, 'kid': 'p2'},
        {'step': 2, 'col': 11, 'kid': 'p2'},
        {'step': 3, 'col': 6, 'kid': 'cI'},
        {'step': 3, 'col': 7, 'kid': 'cIII'},
        {'step': 3, 'col': 8, 'kid': 'p1'},
        {'step': 3, 'col': 8, 'kid': 'p2'},
        {'step': 3, 'col': 10, 'kid': 'p1'},
        {'step': 3, 'col': 11, 'kid': 'p2'},
        {'step': 3, 'col': 12, 'kid': 'p2'},
        {'step': 4, 'col': 6, 'kid': 'p2'},
        {'step': 4, 'col': 7, 'kid': 'p1'},
        {'step': 4, 'col': 8, 'kid': 'p10'},
        {'step': 4, 'col': 9, 'kid': 'p11'},
        {'step': 4, 'col': 11, 'kid': 'p11'},
        {'step': 4, 'col': 13, 'kid': 'p2'},
    ]
    return {
        'W': 8, 'S': 5, 'R_LO': 3, 'R_HI': 14, 'nCols': 12,
        'comps': comps,
        'OIPV': [
            [4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1],
            [1, 1, 6, 7, 5, 7, 3, 5, 4, 3, 2, 1],
            [1, 1, 2, 7, 3, 5, 1, 3, 4, 3, 2, 1],
            [1, 1, 0, 3, 1, 3, 0, 1, 2, 3, 2, 1],
            [1, 1, 0, 3, 1, 0, 0, 0, 0, 1, 2, 1],
            [1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1],
        ],
        'IGPV': [
            [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [1, 4, 2, 0, 1, 1, 1, 1, 0, 0, 0, 0],
            [1, 4, 2, 2, 1, 2, 2, 2, 1, 0, 0, 0],
            [1, 1, 2, 4, 3, 3, 2, 3, 2, 1, 0, 0],
            [1, 1, 2, 1, 2, 4, 4, 2, 3, 2, 1, 0],
            [1, 1, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1],
        ],
        'cost': 40,
        'status': 2, 'mipgap': 0.0, 'objval': 0.0,
    }


def make_4x4_result():
    return make_4x4_pure_result()


def make_W8_chain_result():
    """Hand-crafted W=8, S=5 schedule that DOES use a cI -> cIII chain at
    step 2, cols 6..7.  Auto-computes OIPV/IGPV via derive_state_vectors;
    _build_result aborts if termination is violated, so this is a real
    end-to-end check of the paper-exact Table-II chain semantics.

    Generated by a greedy planner that:
      step 0 : applies p3 / p2 to spread OIPs into IGPs across all CT cols
      step 1 : applies p0/p1/p2 to combine OIPs+IGPs into more IGPs
      step 2 : runs the chain (cI@col6 -> cIII@col7) AND p0 at neighbours
      step 3+: cleans up residual high-IGP columns down to <=2 per col
    """
    comps = [
        {'step': 0, 'col': 3,  'kid': 'p3'},
        {'step': 0, 'col': 4,  'kid': 'p3'},
        {'step': 0, 'col': 4,  'kid': 'p2'},
        {'step': 0, 'col': 5,  'kid': 'p3'},
        {'step': 0, 'col': 5,  'kid': 'p3'},
        {'step': 0, 'col': 6,  'kid': 'p3'},
        {'step': 0, 'col': 6,  'kid': 'p3'},
        {'step': 0, 'col': 7,  'kid': 'p3'},
        {'step': 0, 'col': 7,  'kid': 'p3'},
        {'step': 0, 'col': 8,  'kid': 'p3'},
        {'step': 0, 'col': 8,  'kid': 'p3'},
        {'step': 0, 'col': 9,  'kid': 'p3'},
        {'step': 0, 'col': 9,  'kid': 'p3'},
        {'step': 0, 'col': 10, 'kid': 'p3'},
        {'step': 0, 'col': 11, 'kid': 'p3'},
        {'step': 0, 'col': 12, 'kid': 'p3'},
        {'step': 1, 'col': 4,  'kid': 'p0'},
        {'step': 1, 'col': 5,  'kid': 'p0'},
        {'step': 1, 'col': 6,  'kid': 'p1'},
        {'step': 1, 'col': 7,  'kid': 'p2'},
        {'step': 1, 'col': 7,  'kid': 'p0'},
        {'step': 1, 'col': 8,  'kid': 'p1'},
        {'step': 1, 'col': 9,  'kid': 'p0'},
        {'step': 1, 'col': 10, 'kid': 'p2'},
        {'step': 1, 'col': 11, 'kid': 'p1'},
        {'step': 1, 'col': 13, 'kid': 'p2'},
        {'step': 2, 'col': 6,  'kid': 'cI'},
        {'step': 2, 'col': 7,  'kid': 'cIII'},
        {'step': 2, 'col': 5,  'kid': 'p0'},
        {'step': 2, 'col': 8,  'kid': 'p0'},
        {'step': 2, 'col': 9,  'kid': 'p0'},
        {'step': 2, 'col': 10, 'kid': 'p0'},
        {'step': 2, 'col': 12, 'kid': 'p0'},
        {'step': 3, 'col': 8,  'kid': 'p0'},
        {'step': 3, 'col': 10, 'kid': 'p0'},
        {'step': 3, 'col': 11, 'kid': 'p0'},
        {'step': 4, 'col': 8,  'kid': 'p0'},
        {'step': 4, 'col': 9,  'kid': 'p0'},
    ]
    return _build_result(8, 5, comps)


# ---------------------------------------------------------- exhaustive driver
def _run_test(label, res):
    W = res['W']
    fail = 0
    samples = []
    for a in range(1 << W):
        for b in range(1 << W):
            got = simulate_multiplier(W, res['S'], res, a, b)
            exp = a * b
            if got != exp:
                fail += 1
                if len(samples) < 6:
                    samples.append((a, b, got, exp))
    if fail == 0:
        print("PASS [%s] : all %d (a,b) pairs matched a*b for W=%d." %
              (label, (1 << W) ** 2, W))
        return True
    for (a, b, got, exp) in samples:
        print("FAIL [%s]: %d * %d = %d  (expected %d)" %
              (label, a, b, got, exp))
    print("FAIL [%s] : %d / %d pairs did not match." %
          (label, fail, (1 << W) ** 2))
    return False


def _run_test_samples(label, res, sample_points):
    fail = 0
    samples = []
    for a, b in sample_points:
        got = simulate_multiplier(res['W'], res['S'], res, a, b)
        exp = a * b
        if got != exp:
            fail += 1
            if len(samples) < 6:
                samples.append((a, b, got, exp))
    if fail == 0:
        print("PASS [%s] : all %d sampled (a,b) pairs matched a*b for W=%d." %
              (label, len(sample_points), res['W']))
        return True
    for (a, b, got, exp) in samples:
        print("FAIL [%s]: %d * %d = %d  (expected %d)" %
              (label, a, b, got, exp))
    print("FAIL [%s] : %d / %d sampled pairs did not match." %
          (label, fail, len(sample_points)))
    return False


def _run_tableii_cell_truth_test():
    """Exhaustively verify the paper-exact Table-II cell arithmetic.

    Each cell at column k computes par3 = parity3(x0,x1,x2),
    maj3 = majority3(x0,x1,x2), S = par3 XOR p_prev, DI = p_prev,
    sum = S XOR ci, co = ci if S else DI.  We check the standard FA balance
    par3 + p_prev + ci = sum + 2*co AND the CSA balance x0+x1+x2 = par3 + 2*maj3.
    """
    fail = []
    for x0 in (0, 1):
        for x1 in (0, 1):
            for x2 in (0, 1):
                for p_prev in (0, 1):
                    for ci in (0, 1):
                        par3 = (x0 ^ x1 ^ x2) & 1
                        maj3 = 1 if (x0 + x1 + x2) >= 2 else 0
                        S = par3 ^ p_prev
                        DI = p_prev
                        sbit = S ^ ci
                        co = ci if S else DI
                        lhs = par3 + p_prev + ci
                        rhs = sbit + 2 * co
                        if lhs != rhs:
                            fail.append(("FA", x0, x1, x2, p_prev, ci, lhs, rhs))
                        pop_lhs = x0 + x1 + x2
                        pop_rhs = par3 + 2 * maj3
                        if pop_lhs != pop_rhs:
                            fail.append(("CSA", x0, x1, x2, p_prev, ci, pop_lhs, pop_rhs))
    if not fail:
        print("PASS [Table-II cell arithmetic] : 32 FA cases + 8 CSA cases matched.")
        return True
    for entry in fail[:6]:
        print("FAIL [Table-II cell arithmetic]:", entry)
    print("FAIL [Table-II cell arithmetic] : %d cases mismatched." % len(fail))
    return False



if __name__ == "__main__":
    ok = True
    ok &= _run_tableii_cell_truth_test()
    for label, fixture in (
        ('4x4 pure-LUT',       make_4x4_pure_result),
        ('4x4 carry-enabled',  make_4x4_lutcarry_result),
        ('W=4 4x4 (alias)',    make_4x4_result),
        ('W=8 chain',          make_W8_chain_result),
        ('W=8 S=5 LUT-carry',  make_8x8_s5_lutcarry_result),
    ):
        try:
            ok &= _run_test(label, fixture())
        except Exception as e:
            print('FAIL [%s] : %s' % (label, e))
            ok = False
    sys.exit(0 if ok else 1)
