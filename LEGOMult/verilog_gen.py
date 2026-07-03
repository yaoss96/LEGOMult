"""
Verilog generator for the ILP-Driven FPGA Multiplier.

Style is matched to the user reference `mult_*_*.v` (under PythonProject/):
the generated Verilog contains ONLY `LUT6_2` (and occasionally `LUT6`) +
`CARRY4` primitives -- no gate operators (`&`, `|`, `^`) and no `assign`
expressions other than direct wire/port renaming.

Top-level structure (matches paper Fig.4):

    LOP  : 4 x LUT6_2  ->  r[0], r[1], r[2], C1, C0
                          (C1 -> CARRY4.CI ;  C0 -> CLA col 4 input)
    CT   : ILP solution -> N x LUT6_2 / LUT6
    CLA  : (2W-4) x LUT6_2  +  ceil((2W-4)/4) x CARRY4
           result MSB r[2W-1] = last CARRY4.CO[ ... ]
"""

from compressors import (PURE_LUT_COMPRESSORS, all_compressors,
                         compressor_paper_label,
                         chain_base_kid, chain_oip_count,
                         CHAIN_KIDS_HEAD, CHAIN_KIDS_BODY, CHAIN_KIDS_TAIL,
                         CHAIN_KIDS_ALL)
from signed_support import pp_inverted, correction_bits, validate_sign_widths


def _kid_sort_key(kid):
    if kid.startswith('p'):
        return (0, int(kid[1:]))
    base = chain_base_kid(kid)
    return (1, {'cI': 0, 'cII': 1, 'cIII': 2}.get(base, 99),
            chain_oip_count(kid), kid)


# =============================================================================
# Generic INIT computers
# =============================================================================
def compute_lut_init(input_names, expr_fn, lut_width=6):
    """Generic INIT calculator: enumerate the 2^lut_width truth table,
    invoking `expr_fn(bit_dict)` where bit_dict maps each input_name to its
    value at that table entry.  Returns the INIT integer."""
    init = 0
    for n in range(1 << lut_width):
        bd = {nm: (n >> i) & 1 for i, nm in enumerate(input_names)}
        if expr_fn(bd):
            init |= (1 << n)
    return init


def compute_init(input_pin_kinds, mode, lut_input_width=6):
    """Sum-style INIT calculator (back-compat shim used by CT/CLA emitters).

        input_pin_kinds: list of 'OIP' / 'OIP_INV' / 'IGP' for the LUT pins
            OIP     -> AND-of-2 bits   (occupies 2 LUT pins)
            OIP_INV -> NAND-of-2 bits  (occupies 2 LUT pins; signed PP)
            IGP     -> 1 bit           (occupies 1 LUT pin)
        mode in {'sum','carry','carry2','p','g'}
    """
    table_size = 1 << lut_input_width
    init = 0
    for n in range(table_size):
        pin_idx = 0
        ones = 0
        for kind in input_pin_kinds:
            if kind in ('OIP', 'OIP_INV'):
                if pin_idx + 1 >= lut_input_width:
                    break
                ba = (n >> pin_idx) & 1
                bb = (n >> (pin_idx + 1)) & 1
                and_bit = ba & bb
                ones += (1 - and_bit) if kind == 'OIP_INV' else and_bit
                pin_idx += 2
            elif kind in ('IGP', 'IGP_C'):
                if pin_idx >= lut_input_width:
                    break
                ones += (n >> pin_idx) & 1
                pin_idx += 1
            elif kind == 'IGP_N':
                if pin_idx >= lut_input_width:
                    break
                ones += 2 * ((n >> pin_idx) & 1)
                pin_idx += 1
            else:
                raise ValueError('bad pin kind ' + str(kind))
        if   mode == 'sum'    : bit = ones & 1
        elif mode == 'carry'  : bit = (ones >> 1) & 1
        elif mode == 'carry2' : bit = (ones >> 2) & 1
        elif mode == 'p'      : bit = ones & 1
        elif mode == 'g'      : bit = 1 if ones >= 2 else 0
        else: raise ValueError("bad mode " + mode)
        if bit:
            init |= (1 << n)
    return init


# =============================================================================
# Per-column OIP queue
# =============================================================================
class PPManager(object):
    """Per-column queue of (a_i, b_j, inverted) signal names; supports asymmetric
    Wa x Wb and signed operands.  `inverted` flags a Baugh-Wooley NAND partial
    product (signed PP), which the consuming LUT realises via its INIT."""
    def __init__(self, Wa, Wb=None, sign_a=False, sign_b=False):
        if Wb is None:
            Wb = Wa
        self.Wa = Wa
        self.Wb = Wb
        self.W = Wa  # back-compat alias
        self.sign_a = sign_a
        self.sign_b = sign_b
        self.q = {}
        for r in range(Wa + Wb):
            self.q[r] = []
            for j in range(Wb):
                i = r - j
                if 0 <= i < Wa:
                    inv = pp_inverted(i, j, Wa, Wb, sign_a, sign_b)
                    self.q[r].append(("a[%d]" % i, "b[%d]" % j, inv))

    def pop(self, col):
        if col in self.q and self.q[col]:
            return self.q[col].pop(0)
        return ("1'b0", "1'b0", False)


class IGPPool(object):
    def __init__(self):
        self.pool = {}

    def add(self, step, col, name):
        self.pool.setdefault((step, col), []).append(name)

    def pop(self, step, col):
        for s in range(step, -1, -1):
            key = (s, col)
            if key in self.pool and self.pool[key]:
                return self.pool[key].pop(0)
        return "1'b0"


# =============================================================================
# Verilog emission
# =============================================================================
_HEADER = ("// =====================================================\n"
           "// ILP-Driven FPGA Multiplier  (auto-generated)\n"
           "// Wa = {Wa} bits, Wb = {Wb} bits, S = {S} CT steps\n"
           "// CT compressors used:\n{CMP}"
           "// =====================================================\n"
           "module {MODNAME} (\n"
           "  input  [{Wam1}:0] a,\n"
           "  input  [{Wbm1}:0] b,\n"
           "  output [{Tm1}:0] r\n"
           ");\n")


# -------------------------------------------------------------- LOP (4 LUT6_2)
def _emit_lop(f, Wa, Wb=None):
    if Wb is None: Wb = Wa
    W = min(Wa, Wb)  # LOP requires both axes >= 3
    """Emit the 4 fixed LOP LUT6_2 instances.  Outputs the 5 signals:
        r[0], r[1], r[2], C1 (carry to CARRY4.CI), C0 (carry to col 4 LUT)
    using ONLY LUT6_2 primitives -- no gate operators.

    Functional definitions:
        r[0]  = a0 & b0
        r[1]  = (a0 & b1) ^ (a1 & b0)
        lc1   = (a0 & b1) & (a1 & b0)               (carry order-1 -> 2)
        s2    = (a0 & b2) + (a1 & b1) + (a2 & b0) + lc1     (4-bit sum)
        r[2]  = bit_0(s2)
        C1    = bit_1(s2)                            (carry to col 3)
        C0    = bit_2(s2)                            (super-carry to col 4)
    """
    f.write("\n  // ---- LOP : 4 LUT6_2 (paper Fig.4) ----\n")
    f.write("  wire C1, C0;\n")

    # ---- f0 : O5 = r[0], O6 = r[1].   pins: I0=a0, I1=b0, I2=a1, I3=b1
    fn_r0 = lambda d: d['a0'] & d['b0']
    fn_r1 = lambda d: (d['a0'] & d['b1']) ^ (d['a1'] & d['b0'])
    init_o5 = compute_lut_init(['a0', 'b0', 'a1', 'b1'], fn_r0, lut_width=5)
    init_o6 = compute_lut_init(['a0', 'b0', 'a1', 'b1'], fn_r1, lut_width=5)
    init64  = ((init_o6 & 0xFFFFFFFF) << 32) | (init_o5 & 0xFFFFFFFF)
    f.write("  LUT6_2 #(.INIT(64'h%016X)) u_lop_f0 (\n"
            "    .O6(r[1]), .O5(r[0]),\n"
            "    .I0(a[0]), .I1(b[0]), .I2(a[1]), .I3(b[1]),\n"
            "    .I4(1'b0), .I5(1'b1));\n" % init64)

    if W < 3:
        f.write("  assign C1 = 1'b0;\n  assign C0 = 1'b0;\n  assign r[2] = 1'b0;\n")
        return

    # 6-input LUTs (use full LUT6_2 with I5 from operands).  Common pin map:
    #   I0=a0  I1=b1  I2=a1  I3=b0  I4=a2  I5=b2
    pin_names = ['a0', 'b1', 'a1', 'b0', 'a2', 'b2']
    def s2_value(d):
        a0b2 = d['a0'] & d['b2']
        a1b1 = d['a1'] & d['b1']
        a2b0 = d['a2'] & d['b0']
        lc1  = (d['a0'] & d['b1']) & (d['a1'] & d['b0'])
        return a0b2 + a1b1 + a2b0 + lc1

    # ---- f1 : O6 = r[2] = bit_0(s2)
    init_r2 = compute_lut_init(pin_names, lambda d: s2_value(d) & 1,        lut_width=6)
    f.write("  LUT6_2 #(.INIT(64'h%016X)) u_lop_f1 (\n"
            "    .O6(r[2]), .O5(),\n"
            "    .I0(a[0]), .I1(b[1]), .I2(a[1]), .I3(b[0]),\n"
            "    .I4(a[2]), .I5(b[2]));\n" % init_r2)

    # ---- f2 : O6 = C1 = bit_1(s2)
    init_c1 = compute_lut_init(pin_names, lambda d: (s2_value(d) >> 1) & 1, lut_width=6)
    f.write("  LUT6_2 #(.INIT(64'h%016X)) u_lop_f2 (\n"
            "    .O6(C1), .O5(),\n"
            "    .I0(a[0]), .I1(b[1]), .I2(a[1]), .I3(b[0]),\n"
            "    .I4(a[2]), .I5(b[2]));\n" % init_c1)

    # ---- f3 : O6 = C0 = bit_2(s2)
    init_c0 = compute_lut_init(pin_names, lambda d: (s2_value(d) >> 2) & 1, lut_width=6)
    f.write("  LUT6_2 #(.INIT(64'h%016X)) u_lop_f3 (\n"
            "    .O6(C0), .O5(),\n"
            "    .I0(a[0]), .I1(b[1]), .I2(a[1]), .I3(b[0]),\n"
            "    .I4(a[2]), .I5(b[2]));\n" % init_c0)


# -------------------------------------------------------------- CT compressor
def _emit_compressor(f, comp, spec, pp_mgr, igp_pool, uid):
    s, r = comp['step'], comp['col']
    pin_kinds, pin_signals = [], []
    for _ in range(spec['oip_c']):
        a, b, inv = pp_mgr.pop(r)
        pin_kinds += ['OIP_INV' if inv else 'OIP']; pin_signals += [a, b]
    for _ in range(spec['igp_c']):
        pin_kinds += ['IGP_C']; pin_signals.append(igp_pool.pop(s, r))
    for _ in range(spec['igp_n']):
        pin_kinds += ['IGP_N']; pin_signals.append(igp_pool.pop(s, r + 1))

    out_modes = (['sum']    * spec['gen_c']
               + ['carry']  * spec['gen_n']
               + ['carry2'] * spec['gen_2n'])
    if not out_modes:
        return

    if spec['kind'] == 'LUT6_2':
        while len(pin_signals) < 5: pin_signals.append("1'b0")
        pin_signals = pin_signals[:5] + ["1'b1"]               # I5='1'b1'
        num_lut = (len(out_modes) + 1) // 2
        out_wires = []
        for li in range(num_lut):
            m_o5 = out_modes[2*li]   if 2*li     < len(out_modes) else 'sum'
            m_o6 = out_modes[2*li+1] if 2*li + 1 < len(out_modes) else m_o5
            init_o5 = compute_init(pin_kinds, m_o5, lut_input_width=5)
            init_o6 = compute_init(pin_kinds, m_o6, lut_input_width=5)
            init_full = ((init_o6 & 0xFFFFFFFF) << 32) | (init_o5 & 0xFFFFFFFF)
            wo5 = "w_%s_l%d_o5" % (uid, li)
            wo6 = "w_%s_l%d_o6" % (uid, li)
            f.write("  wire %s, %s;\n" % (wo5, wo6))
            f.write("  LUT6_2 #(.INIT(64'h%016X)) u_%s_l%d (\n"
                    "    .O5(%s), .O6(%s),\n"
                    "    .I0(%s), .I1(%s), .I2(%s), .I3(%s),\n"
                    "    .I4(%s), .I5(%s));\n"
                    % (init_full, uid, li, wo5, wo6,
                       pin_signals[0], pin_signals[1], pin_signals[2],
                       pin_signals[3], pin_signals[4], pin_signals[5]))
            if 2*li     < len(out_modes): out_wires.append(wo5)
            if 2*li + 1 < len(out_modes): out_wires.append(wo6)
    else:                                                        # LUT6
        while len(pin_signals) < 6: pin_signals.append("1'b0")
        pin_signals = pin_signals[:6]
        out_wires = []
        for li, mode in enumerate(out_modes):
            init = compute_init(pin_kinds, mode, lut_input_width=6)
            wo = "w_%s_l%d" % (uid, li)
            f.write("  wire %s;\n" % wo)
            f.write("  LUT6 #(.INIT(64'h%016X)) u_%s_l%d (\n"
                    "    .O(%s),\n"
                    "    .I0(%s), .I1(%s), .I2(%s), .I3(%s),\n"
                    "    .I4(%s), .I5(%s));\n"
                    % (init, uid, li, wo,
                       pin_signals[0], pin_signals[1], pin_signals[2],
                       pin_signals[3], pin_signals[4], pin_signals[5]))
            out_wires.append(wo)

    idx = 0
    for _ in range(spec['gen_c']):
        igp_pool.add(s + 1, r, out_wires[idx]); idx += 1
    for _ in range(spec['gen_n']):
        if r + 1 <= pp_mgr.Wa + pp_mgr.Wb - 1:
            igp_pool.add(s + 1, r + 1, out_wires[idx])
        idx += 1
    for _ in range(spec['gen_2n']):
        if r + 2 <= pp_mgr.Wa + pp_mgr.Wb - 1:
            igp_pool.add(s + 1, r + 2, out_wires[idx])
        idx += 1


def _build_lutcarry_chains(comps):
    """Reconstruct contiguous cI -> cII* -> cIII chains per step from the flat
    compressor list produced by the ILP solver.

    Variants ('cI_o1', 'cII_o2', etc.) are recognised: chain topology only
    cares about base type (head/body/tail), but each cell carries its full
    variant-suffixed kid in the returned chain list so the emitter can pick
    the right LUT INIT and consume the right OIP/IGP mix.
    """
    by_step = {}
    non_chain = []
    for c in comps:
        if c['kid'] in CHAIN_KIDS_ALL:
            base = chain_base_kid(c['kid'])
            entry = by_step.setdefault(c['step'], {}).setdefault(
                c['col'], {'cI': [], 'cII': [], 'cIII': []})
            entry[base].append(c['kid'])
        else:
            non_chain.append(c)

    chains = []
    for step in sorted(by_step):
        cols = sorted(by_step[step])
        active = []
        for col in range(cols[0], cols[-1] + 1):
            cnts = by_step[step].get(col,
                                     {'cI': [], 'cII': [], 'cIII': []})
            nI = len(cnts['cI'])
            nII = len(cnts['cII'])
            nIII = len(cnts['cIII'])

            if active:
                if nII + nIII != len(active):
                    raise ValueError(
                        'broken LUT-carry chain structure at step=%d col=%d: '
                        'active=%d II=%d III=%d'
                        % (step, col, len(active), nII, nIII))
                # Tails first (close oldest active chains), then bodies.
                new_active = []
                kid_pool_iii = list(cnts['cIII'])
                kid_pool_ii  = list(cnts['cII'])
                for idx, ch in enumerate(active):
                    if idx < nIII:
                        kid = kid_pool_iii.pop(0)
                        ch.append({'step': step, 'col': col, 'kid': kid})
                        chains.append(ch)
                    else:
                        kid = kid_pool_ii.pop(0)
                        ch.append({'step': step, 'col': col, 'kid': kid})
                        new_active.append(ch)
                active = new_active
            elif nII or nIII:
                raise ValueError('LUT-carry continuation without active chain '
                                 'at step=%d col=%d' % (step, col))

            for kid in cnts['cI']:
                active.append([{'step': step, 'col': col, 'kid': kid}])

        if active:
            raise ValueError('unterminated LUT-carry chains at step=%d (%d active left)'
                             % (step, len(active)))

    non_chain.sort(key=lambda x: (x['step'], x['col'], _kid_sort_key(x['kid'])))
    chains.sort(key=lambda ch: (ch[0]['step'], ch[0]['col'], len(ch)))
    return non_chain, chains


def _chain_lut_init(n_oip, oip_inv=None):
    """LUT INIT data for a chain cell with n_oip OIP same-col operands.

    `oip_inv` (optional) is a length-n_oip list of booleans; oip_inv[k]=True
    means the k-th OIP is a signed (NAND) partial product, so its in-LUT AND is
    complemented before entering the parity/majority logic.

    Pin layout (extra = head_seed for cI* / p_prev for cII*/cIII*):
        n_oip=0 :  I0..I2 = 3 IGPs,            I3 = extra,   I4=1, I5=1
        n_oip=1 :  I0,I1 = OIP, I2,I3 = 2 IGPs, I4 = extra,   I5=1
        n_oip=2 :  I0,I1 = OIP1, I2,I3 = OIP2,  I4 = IGP,     I5 = extra

    For n_oip <= 1: single LUT6_2 emits O5=maj3 (routing wire) and
    O6=par3 XOR extra (sum input to CARRY4).  INIT[31:0] = maj3 truth (= O5;
    also = O6's I5=0 truth, harmlessly because instance hardwires I5='b1).
    INIT[63:32] = (par3 XOR extra) truth read by O6 when I5='b1.

    For n_oip == 2: I5 = extra is variable, so a single LUT6_2 cannot honour
    both O5 = maj3 and O6 = par3 XOR I5 (would force O6 at I5=0 to equal
    maj3 instead of par3).  So we emit TWO LUT6 cells -- one for par3 XOR
    extra (uses all 6 inputs), one for maj3 (uses I0..I4).

    Returns:
      ('one', init_full_64bit)
      ('two', init_par_64bit, init_maj_64bit)
    """
    n_igp = 3 - n_oip
    extra_idx = 2 * n_oip + n_igp   # 3, 4, or 5
    if oip_inv is None:
        oip_inv = [False] * n_oip

    def _ps_and_extra(n):
        ps = []
        idx = 0
        for k in range(n_oip):
            a = (n >> idx) & 1
            b = (n >> (idx + 1)) & 1
            ps.append((a & b) ^ (1 if oip_inv[k] else 0))
            idx += 2
        for _ in range(n_igp):
            ps.append((n >> idx) & 1)
            idx += 1
        extra = (n >> extra_idx) & 1
        return ps, extra

    if n_oip < 2:
        init_o5 = 0
        init_o6 = 0
        for n in range(32):              # I0..I4 = 5 inputs
            ps, extra = _ps_and_extra(n)
            if (ps[0] + ps[1] + ps[2]) >= 2:
                init_o5 |= (1 << n)
            if ((ps[0] ^ ps[1] ^ ps[2]) ^ extra) & 1:
                init_o6 |= (1 << n)
        init_full = ((init_o6 & 0xFFFFFFFF) << 32) | (init_o5 & 0xFFFFFFFF)
        return ('one', init_full)
    else:
        init_par = 0
        init_maj = 0
        for n in range(64):              # I0..I5 = 6 inputs
            ps, extra = _ps_and_extra(n)
            if ((ps[0] ^ ps[1] ^ ps[2]) ^ extra) & 1:
                init_par |= (1 << n)
            if (ps[0] + ps[1] + ps[2]) >= 2:
                init_maj |= (1 << n)
        return ('two', init_par, init_maj)


def _emit_lutcarry_chain(f, chain, pp_mgr, igp_pool, uid):
    """Emit one contiguous cI[*] -> cII[*]* -> cIII[*] carry chain using
    paper Fig.5(a) "three-input adder" semantics, with mixed OIP/IGP inputs.

    Per cell at column k:
      - n_oip OIPs (each 2 LUT pins) + (3 - n_oip) IGPs (1 pin each)
        + p_prev (from prev cell's maj_wire, or head_seed for the head).
      - For n_oip <= 1: one LUT6_2 (O5 = p_curr, O6 = sum-into-CARRY).
      - For n_oip == 2: one LUT6 par + one LUT6 maj (cost = 2 LUTs).
      - One CARRY4 stage producing sum bit and routed carry.

    Type I (chain head) additionally consumes a 4th same-col IGP as head_seed,
    which is routed to:
      (a) the LUT's `extra` input (XOR'd into par3 for sum-into-CARRY)
      (b) CARRY4.DI[0] of the head's stage (matching the FA running-carry).

    Type III (chain tail) exports BOTH the chain's final running CO and the
    tail cell's maj_wire (= p_tail) to the col+1 IGP pool, matching the paper's
    Cout + Cout2 (Table II gen_n=2).
    """
    step = chain[0]['step']
    L = len(chain)
    nCY = (L + 3) // 4

    if chain_base_kid(chain[0]['kid']) != 'cI':
        raise ValueError('chain head must be cI[_o*], got %s' % chain[0]['kid'])
    if chain_base_kid(chain[-1]['kid']) != 'cIII':
        raise ValueError('chain tail must be cIII[_o*], got %s' % chain[-1]['kid'])
    for mid in chain[1:-1]:
        if chain_base_kid(mid['kid']) != 'cII':
            raise ValueError('chain body must be cII[_o*], got %s' % mid['kid'])
    for k in range(1, L):
        if chain[k]['col'] != chain[k - 1]['col'] + 1:
            raise ValueError('chain not on consecutive columns: %s'
                             % [c['col'] for c in chain])

    # head_seed is always 1 IGP popped from col j.  OIP-as-CYINIT would
    # require an extra AND-LUT, which we don't model.
    head_seed = igp_pool.pop(step, chain[0]['col'])

    cell_data = []
    p_prev_wire = head_seed
    for cell in chain:
        col = cell['col']
        kid = cell['kid']
        n_oip = chain_oip_count(kid)
        n_igp_at_lut = 3 - n_oip   # head_seed already popped; same for body/tail

        oip_signals = []
        oip_inv = []
        for _ in range(n_oip):
            a, b, inv = pp_mgr.pop(col)
            oip_signals.extend([a, b])
            oip_inv.append(inv)
        igp_signals = [igp_pool.pop(step, col) for _ in range(n_igp_at_lut)]
        # Pin layout: [OIPs (2 wires each)] [IGPs (1 each)] [extra=p_prev]
        pin_signals = oip_signals + igp_signals + [p_prev_wire]
        # Pad up to 6 wires.  For n_oip<2 the LUT6_2 instance hard-ties
        # I5='b1 by reading pin_signals[5]=='1'b1' below.
        while len(pin_signals) < 6:
            pin_signals.append("1'b1")
        pin_signals = pin_signals[:6]

        cell_uid = '%s_c%d' % (uid, col)
        kind, *init_data = _chain_lut_init(n_oip, oip_inv)
        maj_wire = 'w_%s_maj' % cell_uid
        par_wire = 'w_%s_par' % cell_uid
        f.write('  wire %s, %s;\n' % (maj_wire, par_wire))
        if kind == 'one':
            init_full, = init_data
            f.write("  LUT6_2 #(.INIT(64'h%016X)) u_%s_lut (\n"
                    "    .O5(%s), .O6(%s),\n"
                    "    .I0(%s), .I1(%s), .I2(%s), .I3(%s),\n"
                    "    .I4(%s), .I5(%s));\n"
                    % (init_full, cell_uid, maj_wire, par_wire,
                       pin_signals[0], pin_signals[1], pin_signals[2],
                       pin_signals[3], pin_signals[4], pin_signals[5]))
        else:  # 'two'
            init_par, init_maj = init_data
            f.write("  LUT6 #(.INIT(64'h%016X)) u_%s_par (\n"
                    "    .O(%s),\n"
                    "    .I0(%s), .I1(%s), .I2(%s), .I3(%s),\n"
                    "    .I4(%s), .I5(%s));\n"
                    % (init_par, cell_uid, par_wire,
                       pin_signals[0], pin_signals[1], pin_signals[2],
                       pin_signals[3], pin_signals[4], pin_signals[5]))
            f.write("  LUT6 #(.INIT(64'h%016X)) u_%s_maj (\n"
                    "    .O(%s),\n"
                    "    .I0(%s), .I1(%s), .I2(%s), .I3(%s),\n"
                    "    .I4(%s), .I5(1'b0));\n"
                    % (init_maj, cell_uid, maj_wire,
                       pin_signals[0], pin_signals[1], pin_signals[2],
                       pin_signals[3], pin_signals[4]))

        cell_data.append({
            'col': col, 'kid': kid,
            'maj_wire': maj_wire, 'par_wire': par_wire,
            'p_prev': p_prev_wire, 'cell_uid': cell_uid,
        })
        # Next cell's p_prev = this cell's maj_wire (LUT O5 / dedicated maj-LUT).
        p_prev_wire = maj_wire

    # Emit CARRY4s, packing 4 cells per instance.
    cy_co_wires = []
    for c in range(nCY):
        idx0 = c * 4
        idxN = min(idx0 + 4, L)
        slc = idxN - idx0
        cy_co = 'cy_co_%s_%d' % (uid, c)
        cy_o  = 'cy_o_%s_%d'  % (uid, c)
        f.write('  wire [3:0] %s, %s;\n' % (cy_co, cy_o))
        s_terms = []
        d_terms = []
        for k in range(4):
            if k < slc:
                cd = cell_data[idx0 + k]
                s_terms.append(cd['par_wire'])
                d_terms.append(cd['p_prev'])
            else:
                s_terms.append("1'b0")
                d_terms.append("1'b0")
        s_concat = '{ %s, %s, %s, %s }' % (s_terms[3], s_terms[2], s_terms[1], s_terms[0])
        d_concat = '{ %s, %s, %s, %s }' % (d_terms[3], d_terms[2], d_terms[1], d_terms[0])
        if c == 0:
            ci_port    = "1'b0"
            cyinit_port = "1'b0"
        else:
            ci_port    = '%s[3]' % cy_co_wires[-1]
            cyinit_port = "1'b0"
        f.write("  CARRY4 u_%s_cy_%d (\n"
                "    .CO(%s), .O(%s),\n"
                "    .CI(%s), .CYINIT(%s),\n"
                "    .DI(%s), .S(%s));\n"
                % (uid, c, cy_co, cy_o, ci_port, cyinit_port, d_concat, s_concat))
        cy_co_wires.append(cy_co)
        for k in range(slc):
            cd = cell_data[idx0 + k]
            sum_wire = 'w_%s_sum' % cd['cell_uid']
            f.write('  wire %s;\n' % sum_wire)
            f.write('  assign %s = %s[%d];\n' % (sum_wire, cy_o, k))
            cd['sum_wire'] = sum_wire
            cd['chain_co'] = '%s[%d]' % (cy_co, k)

    # Emit IGPs to next-step pool:
    #   - Every cell : sum bit at its own col      -> gen_c     (paper Table II)
    #   - Tail (cIII): chain CO + LUT.O5 to col+1  -> gen_n = 2 (paper Table II)
    #   - Head/body  : NOTHING extra to col+1      -> gen_n = 0 (paper Table II)
    for cd in cell_data:
        igp_pool.add(step + 1, cd['col'], cd['sum_wire'])
    tail = cell_data[-1]
    if tail['col'] + 1 <= pp_mgr.Wa + pp_mgr.Wb - 1:
        igp_pool.add(step + 1, tail['col'] + 1, tail['chain_co'])
        igp_pool.add(step + 1, tail['col'] + 1, tail['maj_wire'])


# -------------------------------------------------------------- CLA stage
def _emit_cla(f, Wa, Wb, S, ipool, ppmgr, oipv_last, igpv_last, R_LO, R_HI,
              msb_correction=False):
    W = min(Wa, Wb)
    """Emit the CLA: per-col LUT6_2 (P/G) + CARRY4 chain.  Carry chain CI of
    the FIRST CARRY4 is wired to LOP's C1.  C0 is added as an extra IGP at
    col R_LO+1 (i.e. col 4 for any W>=3)."""
    f.write("\n  // ---- CLA : LUT6_2 (P/G) + CARRY4 chain ----\n")
    nbits = R_HI - R_LO + 1                                       # = 2W-4
    f.write("  wire [%d:0] cla_p, cla_g;\n" % (nbits - 1))

    has_signal = [False] * nbits
    for i, r in enumerate(range(R_LO, R_HI + 1)):
        ins_kinds, ins_sigs = [], []
        for _ in range(oipv_last[i]):
            a, b, inv = ppmgr.pop(r)
            ins_kinds.append('OIP_INV' if inv else 'OIP'); ins_sigs += [a, b]
        for _ in range(igpv_last[i]):
            ins_kinds.append('IGP'); ins_sigs.append(ipool.pop(S, r))

        if not ins_sigs:
            # No PPs at this column -> P=0, G=0.  Encode as a pass-through
            # LUT6_2 with INIT=0 (still no gate operators).
            f.write("  LUT6_2 #(.INIT(64'h0000000000000000)) u_cla_z%d (\n"
                    "    .O5(cla_g[%d]), .O6(cla_p[%d]),\n"
                    "    .I0(1'b0), .I1(1'b0), .I2(1'b0), .I3(1'b0),\n"
                    "    .I4(1'b0), .I5(1'b1));\n" % (i, i, i))
            continue
        has_signal[i] = True

        init_o5 = compute_init(ins_kinds, 'g', lut_input_width=5)
        init_o6 = compute_init(ins_kinds, 'p', lut_input_width=5)
        init_full = ((init_o6 & 0xFFFFFFFF) << 32) | (init_o5 & 0xFFFFFFFF)
        while len(ins_sigs) < 5:
            ins_sigs.append("1'b0")
        ins_sigs = ins_sigs[:5] + ["1'b1"]
        f.write("  LUT6_2 #(.INIT(64'h%016X)) u_cla_%d (\n"
                "    .O5(cla_g[%d]), .O6(cla_p[%d]),\n"
                "    .I0(%s), .I1(%s), .I2(%s), .I3(%s),\n"
                "    .I4(%s), .I5(%s));\n"
                % (init_full, i, i, i,
                   ins_sigs[0], ins_sigs[1], ins_sigs[2],
                   ins_sigs[3], ins_sigs[4], ins_sigs[5]))

    # CARRY4 chain.  CI of FIRST CARRY4 = C1 (LOP carry into col 3).
    nC4 = (nbits + 3) // 4
    final_co = "C1"
    for c in range(nC4):
        f.write("  wire [3:0] cy_co_%d, cy_o_%d;\n" % (c, c))
        idx0 = c * 4
        idxN = min(idx0 + 4, nbits)
        slc = idxN - idx0
        if slc < 4:
            di_sig = "{ %d'b0, cla_g[%d:%d] }" % (4 - slc, idxN - 1, idx0)
            si_sig = "{ %d'b0, cla_p[%d:%d] }" % (4 - slc, idxN - 1, idx0)
        else:
            di_sig = "cla_g[%d:%d]" % (idxN - 1, idx0)
            si_sig = "cla_p[%d:%d]" % (idxN - 1, idx0)
        if c == 0:
            ci_port    = "1'b0"
            cyinit_port = "C1" if W >= 3 else "1'b0"
        else:
            ci_port    = "cy_co_%d[3]" % (c - 1)
            cyinit_port = "1'b0"
        f.write("  CARRY4 u_cy_%d (\n"
                "    .CO(cy_co_%d), .O(cy_o_%d),\n"
                "    .CI(%s), .CYINIT(%s),\n"
                "    .DI(%s), .S(%s));\n"
                % (c, c, c, ci_port, cyinit_port, di_sig, si_sig))
        for k in range(slc):
            global_bit = R_LO + idx0 + k
            f.write("  assign r[%d] = cy_o_%d[%d];\n" % (global_bit, c, k))
        final_co = "cy_co_%d[%d]" % (c, slc - 1)

    # MSB of result (r[Wa+Wb-1]) = final CARRY chain CO, optionally inverted for
    # the Baugh-Wooley signed correction (the top correction bit lands here).
    # The inversion is folded into a final LUT6's INIT (XNOR) so no separate
    # inverter LUT sits in series on the critical path.
    if not msb_correction:
        f.write("  assign r[%d] = %s;\n" % (Wa + Wb - 1, final_co))
    else:
        XNOR_INIT = (~0x6996966996696996) & 0xFFFFFFFFFFFFFFFF  # ~XOR6 truth
        f.write("  LUT6 #(.INIT(64'h%016X)) u_msb_final (\n"
                "    .O(r[%d]),\n"
                "    .I0(%s), .I1(1'b0), .I2(1'b0), .I3(1'b0),\n"
                "    .I4(1'b0), .I5(1'b0));\n"
                % (XNOR_INIT, Wa + Wb - 1, final_co))


# -------------------------------------------------------------- top-level
def emit_verilog(result, filename):
    Wa = result.get('Wa', result['W'])
    Wb = result.get('Wb', Wa)
    S  = result['S']
    sign_a = bool(result.get('sign_a', False))
    sign_b = bool(result.get('sign_b', False))
    validate_sign_widths(Wa, Wb, sign_a, sign_b)
    R_LO, R_HI = result['R_LO'], result['R_HI']
    ppmgr = PPManager(Wa, Wb, sign_a, sign_b)
    ipool = IGPPool()
    if min(Wa, Wb) >= 3:
        # Match the ILP boundary condition: the LOP stage contributes one
        # initial IGP (C0) into absolute col 4 before CT compression starts.
        ipool.add(0, 4, "C0")
    # Baugh-Wooley sign correction: constant '1' initial IGPs at the low
    # correction columns; the MSB correction (col Wa+Wb-1) inverts the final
    # CLA carry-out (see _emit_cla).  Unsigned -> no correction bits.
    corr_cols, msb_correction = correction_bits(Wa, Wb, sign_a, sign_b)
    for col in corr_cols:
        ipool.add(0, col, "1'b1")
    use_lut_carry = any(c['kid'].startswith('c') for c in result['comps'])
    comps = all_compressors(use_lut_carry=use_lut_carry)

    cmp_summary = {}
    for c in result['comps']:
        cmp_summary[c['kid']] = cmp_summary.get(c['kid'], 0) + 1
    summary_str = "".join("//   %-5s : %3d   (%s; %s)\n" %
                          (k, v, compressor_paper_label(k), comps[k]['name'])
                          for k, v in sorted(cmp_summary.items(),
                                             key=lambda x: _kid_sort_key(x[0])))

    modname = ("ilp_mult_%db" % Wa) if Wa == Wb else ("ilp_mult_%dx%d" % (Wa, Wb))
    with open(filename, 'w') as f:
        f.write(_HEADER.format(Wa=Wa, Wb=Wb, S=S,
                               Wam1=Wa-1, Wbm1=Wb-1,
                               Tm1=Wa+Wb-1,
                               MODNAME=modname,
                               CMP=summary_str))
        _emit_lop(f, Wa, Wb)

        f.write("\n  // ---- CT : ILP-optimized compressor tree ----\n")
        pure_comps, carry_chains = _build_lutcarry_chains(result['comps'])
        by_step = {}
        for i, c in enumerate(pure_comps):
            by_step.setdefault(c['step'], []).append(('pure', c['col'], i, c))
        for i, ch in enumerate(carry_chains):
            by_step.setdefault(ch[0]['step'], []).append(('chain', ch[0]['col'], i, ch))

        for step in sorted(by_step):
            for kind, col, i, obj in sorted(by_step[step], key=lambda x: (x[1], 0 if x[0] == 'pure' else 1, x[2])):
                if kind == 'pure':
                    spec = comps[obj['kid']]
                    uid = "s%d_c%d_n%d" % (obj['step'], obj['col'], i)
                    _emit_compressor(f, obj, spec, ppmgr, ipool, uid)
                else:
                    uid = "lc_s%d_c%d_n%d" % (obj[0]['step'], obj[0]['col'], i)
                    _emit_lutcarry_chain(f, obj, ppmgr, ipool, uid)

        _emit_cla(f, Wa, Wb, S, ipool, ppmgr,
                  result['OIPV'][-1], result['IGPV'][-1], R_LO, R_HI,
                  msb_correction)

        f.write("\nendmodule\n")
    print("Verilog written: %s" % filename)
