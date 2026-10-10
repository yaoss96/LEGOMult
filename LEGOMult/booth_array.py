"""
booth_array.py  --  self-contained structural radix-4 Booth-Array sub-multiplier.

A Booth tile of multiplicand width w and Booth-encoded multiplier height h
(level L = #digits) is realised as the paper's array (Fig. 2/3): one LUT6 per
multiplicand bit per level performs the Booth select AND adds the running
partial sum (the "Type-A" LUT), with a CARRY4 carrying each level's addition.
The array therefore *internally* compresses its L radix-4 rows and outputs a
SINGLE result vector  booth_<i0>_<j0>[w+h-1:0] = (signed) X * (signed) Y, which
then enters the Step-2 merge exactly like a DSP output row.

Cost is ~ L*(w+1) LUT6 (paper Table III).  The accumulation algorithm is the
one verified exhaustively in this module's __main__ (vs. slice_x*slice_y for
every sign mode), and the emitted netlist is checked with verilog_sim.
"""

from tiles import _booth_flags, booth_digits_needed, slice_value
from carry_prim import (carry_width, n_chunks, msb_index, emit_carry,
                       decl_bus)


# --------------------------------------------------------------------------- #
#  symbolic operand-bit access
# --------------------------------------------------------------------------- #
def _xe_sig(n, xname, w, x_signed):
    if 0 <= n < w:
        return "%s[%d]" % (xname, n)
    if n >= w:
        return "%s[%d]" % (xname, w - 1) if x_signed else "1'b0"
    return "1'b0"


def _ye_sig(k, yname, h, y_signed):
    if 0 <= k <= h - 1:
        return "%s[%d]" % (yname, k)
    if k >= h:
        return "%s[%d]" % (yname, h - 1) if y_signed else "1'b0"
    return "1'b0"


#  Row width.  A level's row is the two's-complement value d*X with the Booth
#  digit d in {-2..2}, folded Baugh-Wooley: the MSB is emitted complemented and
#  the constant -2^k it leaves behind is collected into C_corr.  How wide that
#  row has to be depends on the multiplicand:
#
#    signed    |d*X| <= 2^(w-1)*2 = 2^w, so w+1 bits suffice and the row's MSB
#              IS its sign bit -- one cell per level
#    unsigned  2X alone already needs w+1 bits, so the sign needs a cell of its
#              own on top -- w+2 cells per level
#
#  The emitter used to take the unsigned width in both modes, which spent one
#  LUT per level computing a sign-extension bit the signed row already carries.
_NARROW_SIGNED_ROW = True


def row_top(w, x_signed):
    """Index of the row's most significant (sign) bit within the level."""
    return w if (x_signed and _NARROW_SIGNED_ROW) else w + 1


def set_narrow_signed_row(on):
    """Toggle the narrow signed row; present so the two can be measured."""
    global _NARROW_SIGNED_ROW
    _NARROW_SIGNED_ROW = bool(on)


def _is_const(sig):
    return sig in ("1'b0", "1'b1")


def _const_val(sig):
    return 1 if sig == "1'b1" else 0


# --------------------------------------------------------------------------- #
#  one Type-A LUT : S = acc XOR addend, addend = Booth-select (maybe inverted)
# --------------------------------------------------------------------------- #
def _emit_typeA_lut(f, acc_sig, yh, ym, yl, xen, xenm1, invert, wname):
    """Emit a LUT6 computing S = acc_sig XOR addend and return its output wire.
    addend = z?0:((s? xenm1 : xen) XOR c)  (then XOR invert)."""
    syms = [acc_sig, yh, ym, yl, xen, xenm1]
    roles = ['acc', 'yh', 'ym', 'yl', 'xen', 'xenm1']
    # distinct non-constant signals -> LUT inputs (in first-seen order)
    inputs, idx_of = [], {}
    for s in syms:
        if not _is_const(s) and s not in idx_of:
            idx_of[s] = len(inputs)
            inputs.append(s)
    if len(inputs) > 6:
        raise ValueError("Type-A LUT needs >6 inputs")

    def role_val(role, sig, code):
        if _is_const(sig):
            return _const_val(sig)
        return (code >> idx_of[sig]) & 1

    init = 0
    for code in range(1 << 6):
        accv = role_val('acc', acc_sig, code)
        yhv = role_val('yh', yh, code)
        ymv = role_val('ym', ym, code)
        ylv = role_val('yl', yl, code)
        xenv = role_val('xen', xen, code)
        xnmv = role_val('xenm1', xenm1, code)
        z, c, s = _booth_flags(yhv, ymv, ylv)
        addend = 0 if z else ((xnmv if s else xenv) ^ c)
        if invert:
            addend ^= 1
        if (accv ^ addend) & 1:
            init |= (1 << code)
    pins = list(inputs) + ["1'b0"] * (6 - len(inputs))
    f.write("  wire %s;\n" % wname)
    f.write("  LUT6 #(.INIT(64'h%016X)) u_%s (.O(%s), "
            ".I0(%s), .I1(%s), .I2(%s), .I3(%s), .I4(%s), .I5(%s));\n"
            % (init, wname, wname, pins[0], pins[1], pins[2], pins[3],
               pins[4], pins[5]))
    return wname


# --------------------------------------------------------------------------- #
#  emit the whole array into an open module file
# --------------------------------------------------------------------------- #
def _emit_cm(f, yh, ym, yl, wname):
    """Negative-digit flag c_m = (-2*yh+ym+yl < 0) = yh AND NOT(ym AND yl)."""
    syms = [yh, ym, yl]
    inputs, idx = [], {}
    for s in syms:
        if not _is_const(s) and s not in idx:
            idx[s] = len(inputs); inputs.append(s)
    if not inputs:
        yhv = _const_val(yh); ymv = _const_val(ym); ylv = _const_val(yl)
        return "1'b1" if (-2 * yhv + ymv + ylv) < 0 else "1'b0"
    init = 0
    for code in range(1 << 6):
        def rv(s):
            return _const_val(s) if _is_const(s) else (code >> idx[s]) & 1
        if (-2 * rv(yh) + rv(ym) + rv(yl)) < 0:
            init |= (1 << code)
    pins = list(inputs) + ["1'b0"] * (6 - len(inputs))
    f.write("  wire %s;\n" % wname)
    f.write("  LUT6 #(.INIT(64'h%016X)) u_%s (.O(%s), "
            ".I0(%s), .I1(%s), .I2(%s), .I3(%s), .I4(%s), .I5(%s));\n"
            % (init, wname, wname, pins[0], pins[1], pins[2], pins[3], pins[4], pins[5]))
    return wname


def _emit_typeA_cm_lut(f, acc0, yh, ym, yl, x0, sw, cw):
    """One LUT6_2 for the level's n=0 bit: O6 = acc0 XOR boothsel(n=0),
    O5 = c_m (negative-digit flag).  Pins fixed I0=yh,I1=ym,I2=yl,I3=x0,
    I4=acc0,I5=1'b1 so O6 (high 32) and O5 (low 32) are independent."""
    o5 = o6 = 0
    for code in range(32):
        yhv = code & 1; ymv = (code >> 1) & 1; ylv = (code >> 2) & 1
        x0v = (code >> 3) & 1; accv = (code >> 4) & 1
        z, c, s = _booth_flags(yhv, ymv, ylv)
        bsel0 = 0 if z else ((0 if s else x0v) ^ c)   # n=0: sel=s?xe(-1)=0:xe(0)=x0
        if c:
            o5 |= (1 << code)
        if (accv ^ bsel0) & 1:
            o6 |= (1 << code)
    init = ((o6 & 0xFFFFFFFF) << 32) | (o5 & 0xFFFFFFFF)
    f.write("  wire %s, %s;\n" % (sw, cw))
    f.write("  LUT6_2 #(.INIT(64'h%016X)) u_%s (.O5(%s), .O6(%s), "
            ".I0(%s), .I1(%s), .I2(%s), .I3(%s), .I4(%s), .I5(1'b1));\n"
            % (init, sw, cw, sw, yh, ym, yl, x0, acc0))
    return sw, cw


# How many level groups a band is split into.  1 is the original serial array.
# Set once per run (run_tiled --booth-groups); the emitters read it rather than
# threading a parameter through every call site, as carry_prim does for the
# carry primitive.
_GROUPS = 1


def set_groups(g):
    global _GROUPS
    _GROUPS = max(1, int(g))


def groups_setting():
    return _GROUPS


def _emit_vec_add(f, A, B, nb, tag):
    """Emit A + B over nb bits on the carry chain and return the sum wires.

    Both operands are already signals, so the chain needs one LUT6 per bit for
    the propagate A^B and takes A straight onto DI.  Used to recombine the
    partial sums of the level groups; see emit_booth_array.
    """
    out = [None] * nb
    CW = carry_width()
    prev_co = None
    for c in range(n_chunks(nb)):
        base = c * CW
        sb, db = [], []
        for k in range(CW):
            p = base + k
            if p >= nb:
                sb.append("1'b0"); db.append("1'b0"); continue
            # CARRY4 semantics: O = S ^ CI and CO = S ? CI : DI, so S is the
            # propagate A^B and DI is the generate source A.  Constants come
            # from the low bits of a group that starts above level 0, so they
            # are worth folding out rather than spending a LUT on.
            a, b = A[p], B[p]
            if _is_const(a) and _is_const(b):
                sb.append("1'b1" if (_const_val(a) ^ _const_val(b)) else "1'b0")
            elif _is_const(a) or _is_const(b):
                sig = b if _is_const(a) else a
                cst = _const_val(a) if _is_const(a) else _const_val(b)
                if cst:                       # A^1 == ~A
                    wx = "gx_%s_%d" % (tag, p)
                    f.write("  wire %s;\n" % wx)
                    f.write("  LUT6 #(.INIT(64'h5555555555555555)) u_%s "
                            "(.O(%s), .I0(%s), .I1(1'b0), .I2(1'b0), "
                            ".I3(1'b0), .I4(1'b0), .I5(1'b0));\n"
                            % (wx, wx, sig))
                    sb.append(wx)
                else:
                    sb.append(sig)
            else:
                wx = "gx_%s_%d" % (tag, p)
                f.write("  wire %s;\n" % wx)
                f.write("  LUT6 #(.INIT(64'h6666666666666666)) u_%s (.O(%s), "
                        ".I0(%s), .I1(%s), .I2(1'b0), .I3(1'b0), .I4(1'b0), "
                        ".I5(1'b0));\n" % (wx, wx, a, b))
                sb.append(wx)
            db.append(a)
        co = "aco_%s_%d" % (tag, c)
        ow = "aos_%s_%d" % (tag, c)
        decl_bus(f, co, ow)
        ci = "1'b0" if c == 0 else "%s[%d]" % (prev_co, msb_index())
        emit_carry(f, "acy_%s_%d" % (tag, c), co, ow, ci, "1'b0", db, sb)
        for k in range(CW):
            p = base + k
            if p < nb:
                out[p] = "%s[%d]" % (ow, k)
        prev_co = co
    return out


def emit_booth_array(f, xname, yname, w, h, x_signed, y_signed, out_base,
                     groups=None):
    """Emit the Booth array; declare wire [nb-1:0] out_base and drive it with
    X*Y.  xname/yname are the multiplicand/multiplier bus names (already sliced
    to [w-1:0]/[h-1:0] by the caller).  Returns nb = w+h.

    groups splits the L levels into that many contiguous groups, accumulates
    each group on its own carry chain and then recombines the group sums in a
    binary tree.  groups=1 is the original array and emits the identical
    netlist.

    Why the knob exists: the Type-A LUT fuses the Booth select with the XOR
    into the running sum, so one level costs one LUT per bit -- but it also
    makes the levels strictly serial, and a band's internal ripple is what the
    measured critical path of a wide multiplier is mostly made of.  Splitting
    into G groups keeps the fused cost inside a group and pays only G-1 extra
    LUTs per bit for the recombination, while the depth falls from L adds to
    L/G + ceil(log2 G).
    """
    L = booth_digits_needed(h, y_signed)
    nb = h + w
    top = row_top(w, x_signed)
    const = 0
    for m in range(L):
        const -= (1 << (2 * m + top))
    const &= (1 << nb) - 1

    G = max(1, min(int(_GROUPS if groups is None else groups), L))
    bounds = [(L * g) // G for g in range(G + 1)]
    sums = []
    for g in range(G):
        levels = list(range(bounds[g], bounds[g + 1]))
        if not levels:
            continue
        # the whole sign correction rides on the first group; addition is
        # associative mod 2^nb, so where it is injected does not matter
        if g == 0:
            acc = ["1'b1" if (const >> p) & 1 else "1'b0" for p in range(nb)]
        else:
            acc = ["1'b0"] * nb
        for m in levels:
            acc = _emit_level(f, m, acc, xname, yname, w, h, x_signed,
                              y_signed, nb, out_base)
        sums.append(acc)

    while len(sums) > 1:
        nxt = []
        for i in range(0, len(sums) - 1, 2):
            nxt.append(_emit_vec_add(f, sums[i], sums[i + 1], nb,
                                     "%s_m%d_%d" % (out_base, len(sums), i)))
        if len(sums) % 2:
            nxt.append(sums[-1])
        sums = nxt
    acc = sums[0]

    f.write("  wire [%d:0] %s;\n" % (nb - 1, out_base))
    for p in range(nb):
        f.write("  assign %s[%d] = %s;\n" % (out_base, p, acc[p]))
    return nb


# Two adjacent row bits share one LUT6 wherever they are together a function
# of five inputs or fewer.  See _emit_level for when that happens.
_PAIR_CELLS = True


def set_pair_cells(on):
    global _PAIR_CELLS
    _PAIR_CELLS = bool(on)


def _distinct(*sigs):
    """The non-constant signals among sigs, in first-seen order."""
    out = []
    for s in sigs:
        if not _is_const(s) and s not in out:
            out.append(s)
    return out


def _rowbit_val(yhv, ymv, ylv, xenv, xnmv, invert):
    z, c, s = _booth_flags(yhv, ymv, ylv)
    v = 0 if z else ((xnmv if s else xenv) ^ c)
    return v ^ (1 if invert else 0)


def _cm_signal(f, yh, ym, yl, wname):
    """The negative-digit flag as a signal, without a LUT where possible.

    The flag is a function of the Booth window, and at the array's first and
    last digit part of that window is constant, which collapses it to a
    constant or to one of the window bits.
    """
    ins = _distinct(yh, ym, yl)

    def val(sig, code):
        return _const_val(sig) if _is_const(sig) else (code >> ins.index(sig)) & 1

    table = []
    for code in range(1 << max(1, len(ins))):
        _, c, _ = _booth_flags(val(yh, code), val(ym, code), val(yl, code))
        table.append(c)
    if all(v == table[0] for v in table):
        return "1'b1" if table[0] else "1'b0"
    for k, sig in enumerate(ins):
        if all(table[code] == ((code >> k) & 1)
               for code in range(len(table))):
            return sig
    return _emit_cm(f, yh, ym, yl, wname)


def _pair_support(yh, ym, yl, cells, cand):
    """The pins two adjacent row bits really need, and their truth tables.

    A row bit is written as a function of both x_n and x_{n-1} even where the
    Booth digit cannot select the shifted operand, so the symbols alone
    overcount the inputs; the support is taken from the tables instead.
    """
    def val(sig, code):
        return (_const_val(sig) if _is_const(sig)
                else (code >> cand.index(sig)) & 1)

    n = len(cand)
    tables = []
    for acc, xen, xnm, inv in cells:
        tables.append([
            _rowbit_val(val(yh, code), val(ym, code), val(yl, code),
                        val(xen, code), val(xnm, code), inv) ^ val(acc, code)
            for code in range(1 << n)])
    keep = [k for k in range(n)
            if any(t[code] != t[code | (1 << k)]
                   for t in tables
                   for code in range(1 << n) if not (code >> k) & 1)]
    pins = [cand[k] for k in keep]
    small = []
    for t in tables:
        red = [0] * (1 << len(keep))
        for code in range(1 << n):
            red[sum(((code >> k) & 1) << j for j, k in enumerate(keep))] = \
                t[code]
        small.append(red)
    return pins, small


def _emit_pair_lut(f, pins, tables, wlo, whi):
    """One LUT6_2 driving the propagate of two adjacent carry bits.

    The chain takes its data input straight from the accumulator, so O5 is
    free to carry the neighbour's propagate.  A design that drives the data
    input from O5 instead cannot do this, which is why halving a row is
    usually reported as an approximation rather than as a saving.
    """
    out = [0, 0]
    for k, t in enumerate(tables):
        for code, v in enumerate(t):
            if v:
                out[k] |= (1 << code)
    # the table is over len(pins) inputs; replicate it across the unused ones
    step = 1 << len(pins)
    for k in range(2):
        block = out[k]
        for j in range(1, 32 // step):
            out[k] |= block << (j * step)
    init = ((out[1] & 0xFFFFFFFF) << 32) | (out[0] & 0xFFFFFFFF)
    p = list(pins) + ["1'b0"] * (5 - len(pins))
    f.write("  wire %s, %s;\n" % (wlo, whi))
    f.write("  LUT6_2 #(.INIT(64'h%016X)) u_%s (.O5(%s), .O6(%s), "
            ".I0(%s), .I1(%s), .I2(%s), .I3(%s), .I4(%s), .I5(1'b1));\n"
            % (init, wlo, wlo, whi, p[0], p[1], p[2], p[3], p[4]))
    return wlo, whi


def _emit_level(f, m, acc, xname, yname, w, h, x_signed, y_signed, nb,
                out_base):
    """Accumulate Booth level m into acc and return the new acc.

    One LUT6 per row bit drives the propagate of one carry bit, and the carry
    bit's data input comes straight off the accumulator.  That leaves the
    LUT's second output unused, so wherever two adjacent row bits are together
    a function of five inputs or fewer they share a LUT6.  Two places in the
    array qualify: the first digit, whose window has a constant member and
    whose running sum is still the folding constant, and -- for an unsigned
    multiplier -- the last digit, whose window is constant except for the
    operand's top bit so the row is a plain AND.  Everywhere else the window,
    two multiplicand bits and two accumulator bits come to eight.
    """
    lo = 2 * m
    top = row_top(w, x_signed)
    yh = _ye_sig(2 * m + 1, yname, h, y_signed)
    ym = _ye_sig(2 * m, yname, h, y_signed)
    yl = _ye_sig(2 * m - 1, yname, h, y_signed)

    def cell(n):
        """(acc, xen, xnm, invert) for row bit n of this level."""
        return (acc[lo + n], _xe_sig(n, xname, w, x_signed),
                _xe_sig(n - 1, xname, w, x_signed), n == top)

    S_sig, DI_sig, cyc = {}, {}, None
    n = 0
    while n <= top and lo + n < nb:
        p = lo + n
        c0 = cell(n)
        pair = None
        if _PAIR_CELLS and n + 1 <= top and p + 1 < nb:
            c1 = cell(n + 1)
            cand = _distinct(yh, ym, yl, c0[0], c0[1], c0[2],
                             c1[0], c1[1], c1[2])
            pins, tables = _pair_support(yh, ym, yl, (c0, c1), cand)
            if len(pins) <= 5:
                pair = (pins, tables)
        if pair is not None:
            wlo, whi = _emit_pair_lut(
                f, pair[0], pair[1],
                "bs_%s_l%d_%d" % (out_base, m, p),
                "bs_%s_l%d_%d" % (out_base, m, p + 1))
            S_sig[p], S_sig[p + 1] = wlo, whi
            DI_sig[p], DI_sig[p + 1] = c0[0], c1[0]
            n += 2
            continue
        if n == 0:
            # the unpaired first bit hands back c_m on its second output
            sw = "bs_%s_l%d_%d" % (out_base, m, p)
            cw = "cm_%s_l%d" % (out_base, m)
            _emit_typeA_cm_lut(f, acc[p], yh, ym, yl, c0[1], sw, cw)
            S_sig[p], DI_sig[p], cyc = sw, acc[p], cw
        else:
            S_sig[p] = _emit_typeA_lut(f, acc[p], yh, ym, yl, c0[1], c0[2],
                                       c0[3], "bs_%s_l%d_%d"
                                       % (out_base, m, p))
            DI_sig[p] = acc[p]
        n += 1
    if cyc is None:                       # the first bit was paired away
        cyc = _cm_signal(f, yh, ym, yl, "cm_%s_l%d" % (out_base, m))
    for p in range(lo + top + 1, nb):
        S_sig[p] = acc[p]                 # propagate: S = acc, DI = 0
        DI_sig[p] = "1'b0"

    # hard-carry chain over [lo, nb-1]; CW bits per primitive instance
    CW = carry_width()
    span = nb - lo
    prev_co = None
    for c in range(n_chunks(span)):
        base = lo + c * CW
        sb, db = [], []
        for k in range(CW):
            p = base + k
            if p < nb:
                sb.append(S_sig[p]); db.append(DI_sig[p])
            else:
                sb.append("1'b0"); db.append("1'b0")
        co = "co_%s_l%d_%d" % (out_base, m, c)
        ow = "o_%s_l%d_%d" % (out_base, m, c)
        decl_bus(f, co, ow)
        if c == 0:
            ci, cyinit = "1'b0", cyc
        else:
            ci, cyinit = "%s[%d]" % (prev_co, msb_index()), "1'b0"
        emit_carry(f, "cy_%s_l%d_%d" % (out_base, m, c),
                   co, ow, ci, cyinit, db, sb)
        for k in range(CW):
            p = base + k
            if p < nb:
                acc[p] = "%s[%d]" % (ow, k)     # new running sum bit
        prev_co = co
    return acc


_COST_CACHE = {}


def band_lut_cost(w, h, x_signed, y_signed, groups=1):
    """LUT6 sites a band of this shape really costs.

    Counted by running the emitter rather than by a formula: the row width
    depends on the multiplicand's sign and the pairing depends on which window
    bits are constant at the first and last digit, so a closed form would have
    to restate the emitter and could drift from it.  Memoised, because Step 1
    asks for the same few shapes thousands of times.
    """
    key = (w, h, bool(x_signed), bool(y_signed), int(groups or 1))
    if key in _COST_CACHE:
        return _COST_CACHE[key]
    import io as _io
    import re as _re
    f = _io.StringIO()
    emit_booth_array(f, "x", "y", w, h, x_signed, y_signed, "c",
                     groups=groups)
    n = len(_re.findall(r"^\s*(?:LUT6_2|LUT6)\b", f.getvalue(), _re.M))
    _COST_CACHE[key] = n
    return n


def gen_booth_module(name, w, h, x_signed, y_signed, pa="x", pb="y", pr="p",
                     groups=1):
    """Standalone module  name(input [w-1:0] pa, input [h-1:0] pb,
    output [w+h-1:0] pr)  for unit testing."""
    import io
    f = io.StringIO()
    nb = h + w
    f.write("module %s (input [%d:0] %s, input [%d:0] %s, output [%d:0] %s);\n"
            % (name, w - 1, pa, h - 1, pb, nb - 1, pr))
    emit_booth_array(f, pa, pb, w, h, x_signed, y_signed, "bo", groups=groups)
    f.write("  assign %s = bo;\nendmodule\n" % pr)
    return f.getvalue()


# --------------------------------------------------------------------------- #
#  self-test : emulator + emitted-netlist simulation vs slice product
# --------------------------------------------------------------------------- #
def _emulate(x, y, w, h, xs, ys):
    L = booth_digits_needed(h, ys); nb = h + w
    top = row_top(w, xs)
    total = sum(-(1 << (2 * m + top)) for m in range(L))

    def xe(n):
        if 0 <= n < w: return (x >> n) & 1
        if n >= w: return (x >> (w - 1)) & 1 if xs else 0
        return 0

    def ye(k):
        if k < 0: return 0
        if k <= h - 1: return (y >> k) & 1
        return (y >> (h - 1)) & 1 if ys else 0

    for m in range(L):
        yh, ym, yl = ye(2 * m + 1), ye(2 * m), ye(2 * m - 1)
        z, c, s = _booth_flags(yh, ym, yl)
        ra = 0
        for n in range(0, top):
            ra += (0 if z else ((xe(n - 1) if s else xe(n)) ^ c)) << n
        signbit = 0 if z else ((xe(top - 1) if s else xe(top)) ^ c)
        ra += (1 - signbit) << top
        total += (ra + c) << (2 * m)
    return total % (1 << nb)


if __name__ == "__main__":
    import os
    import sys
    import verilog_sim as vs

    # groups=1 must reproduce the original array exactly; the rest are the new
    # grouped forms, which must give the same value at lower depth
    GROUPS = (1, 2, 3, 4)

    # 1) emulator exhaustive
    bad = 0; tot = 0
    for h in range(3, 9):
        for w in range(1, 7):
            for xs in (False, True):
                for ys in (False, True):
                    nb = h + w
                    for x in range(1 << w):
                        for y in range(1 << h):
                            exp = (slice_value(x, 0, w - 1, w, xs) *
                                   slice_value(y, 0, h - 1, h, ys)) % (1 << nb)
                            tot += 1
                            if _emulate(x, y, w, h, xs, ys) != exp:
                                bad += 1
    print("emulator : %s (%d cases)" % ("PASS" if bad == 0 else "FAIL(%d)" % bad, tot))

    # 2) emitted netlist exhaustive (a few shapes / sign modes)
    nbad = 0; ntot = 0
    import random
    rng = random.Random(5)
    import tempfile
    tmpv = os.path.join(tempfile.gettempdir(), "bmod.v")
    cases = [(5, 8, True, True), (7, 8, False, True),
             (4, 6, True, False), (6, 5, False, False),
             (3, 14, True, True)]
    for (w, h, xs, ys) in cases:
      for G in GROUPS:
        src = gen_booth_module("bmod", w, h, xs, ys, pa="a", pb="b", pr="r",
                               groups=G)
        open(tmpv, "w").write(src)
        mod = vs.parse(tmpv, w, h, w + h)
        pairs = [(rng.randrange(1 << w), rng.randrange(1 << h)) for _ in range(300)]
        pairs += [(0, 0), ((1 << w) - 1, (1 << h) - 1), (1 << (w - 1), 1 << (h - 1))]
        for xx, yy in pairs:
            exp = (slice_value(xx, 0, w - 1, w, xs) *
                   slice_value(yy, 0, h - 1, h, ys)) % (1 << (w + h))
            got = vs.simulate(mod, xx, yy)
            ntot += 1
            if got != exp:
                nbad += 1
                if nbad <= 3:
                    print("  RTL MISMATCH w%d h%d xs%d ys%d G%d x%d y%d "
                          "got%d exp%d"
                          % (w, h, xs, ys, G, xx, yy, got, exp))
    print("netlist  : %s (%d vectors)" % ("PASS" if nbad == 0 else "FAIL(%d)" % nbad, ntot))
    sys.exit(0 if (bad == 0 and nbad == 0) else 1)
