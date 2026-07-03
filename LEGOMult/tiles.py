"""
tiles.py
========
Tile-set and *integer-exact* partial-product (PP) model for the two-step
"Booth-Array + DSP + LUT tiling" multiplier (Boettcher & Kumm, arXiv:2407.03962),
built on top of the existing LUT+CARRY4 ILP compressor framework (M_pure6).

A WaxWb multiplier board is partitioned (Step 1, tiling_ilp.py) into rectangular
tiles of three kinds:

    * DSP   : an embedded DSP48 block (AMD/Xilinx 24x17 unsigned, 25x18 signed).
              Computes its slice product internally; contributes OPAQUE output
              bits (one heap row) to the merge.
    * BOOTH : a radix-4 Booth-Array sub-multiplier of a fixed "level" L in
              {3,4,5,6,7}.  Booth-encoded operand height <= 2L-1 (unsigned) /
              2L (signed); the other operand width k is free.  It self-compresses
              its L radix-4 rows along a CARRY4 chain (booth_array.py) and
              contributes ONE opaque result vector to the merge (like a DSP) --
              the "residual partial products" that get merged.
    * LUT   : a small LUT multiplier (1x1, 2x1/1x2, 2x2, 3x2/2x3, 3x3).  Its
              cells contribute AND/NAND original-input partial products (OIPs)
              straight into the merge heap (compressed by source LUT+CARRY4).

KEY EXACTNESS ANCHOR
--------------------
For ANY rectangular tile covering board rows [i0..i1] (operand a) x cols
[j0..j1] (operand b):

    sum_{(i,j) in tile} sA_i*sB_j * a_i*b_j * 2^(i+j)
        = ( sum_{i=i0..i1} sA_i a_i 2^i ) * ( sum_{j=j0..j1} sB_j b_j 2^j )
        = slice_a * slice_b                               (Eq. T)

where sA_i=-1 only at i=Wa-1 if sign_a (else +1), likewise sB_j.  Hence an axis
of a tile is *signed* iff the tile touches that operand's MSB AND the operand is
globally signed.  Summing every tile's slice-product (Eq. T) reproduces a*b
EXACTLY, for every sign mode ss/us/su/uu.  Each tile model below is verified
exhaustively against Eq. T (see _self_test).

This module is pure integer/boolean: every PP bit is a `BitExpr` that can be
(a) evaluated for the Python golden model and (b) truth-table-enumerated into a
LUT6 INIT for structural RTL.  Nothing here imports gurobi.
"""

from math import ceil


# =============================================================================
#  BitExpr : a single heap bit, expressible as a LUT function of operand bits
# =============================================================================
class BitExpr(object):
    """One partial-product bit.

    inputs : ordered list of operand-bit handles.  Each handle is one of
                 ('a', i)   -> operand a bit i
                 ('b', j)   -> operand b bit j
                 ('w', name)-> an opaque pre-computed wire (e.g. DSP/Booth
                               sub-output); value supplied at eval time
             (max 6, so it maps to a single LUT6).
    fn     : callable(values_list) -> 0/1, the boolean function over `inputs`.
    label  : human string for debugging / Verilog comments.
    """
    __slots__ = ('inputs', 'fn', 'label')

    def __init__(self, inputs, fn, label=""):
        if len(inputs) > 6:
            raise ValueError("BitExpr needs <=6 inputs, got %d (%s)"
                             % (len(inputs), label))
        self.inputs = list(inputs)
        self.fn = fn
        self.label = label

    def eval(self, a, b, wires=None):
        """Evaluate this bit for integer operands a, b (and a dict of opaque
        wire values, if any)."""
        vals = []
        for h in self.inputs:
            if h[0] == 'a':
                vals.append((a >> h[1]) & 1)
            elif h[0] == 'b':
                vals.append((b >> h[1]) & 1)
            elif h[0] == 'w':
                vals.append(int(wires[h[1]]) & 1 if wires else 0)
            else:
                raise ValueError("bad input handle %r" % (h,))
        return self.fn(vals) & 1

    def lut_init(self):
        """Return (init64, padded_input_handles) for a LUT6 realising this bit.
        Inputs are placed on I0.. in order; unused pins tied low and don't
        affect the function (truth table is independent of them)."""
        n = len(self.inputs)
        init = 0
        for code in range(1 << 6):
            vals = [(code >> i) & 1 for i in range(n)]
            if self.fn(vals) & 1:
                init |= (1 << code)
        return init & 0xFFFFFFFFFFFFFFFF, list(self.inputs)


# convenience bit builders -----------------------------------------------------
def _and_bit(i, j, invert=False):
    if invert:
        return BitExpr([('a', i), ('b', j)],
                       lambda v: 1 - (v[0] & v[1]), "NAND a%d.b%d" % (i, j))
    return BitExpr([('a', i), ('b', j)],
                   lambda v: v[0] & v[1], "AND a%d.b%d" % (i, j))


def _const_bit(value):
    v = value & 1
    return BitExpr([], (lambda vv: v), "const%d" % v)


# =============================================================================
#  Operand-bit sign weights (shared definition with signed_support.py)
# =============================================================================
def _bit_sign(idx, W, signed):
    return -1 if (signed and idx == W - 1) else 1


def slice_value(operand_int, lo, hi, W, signed):
    """Two's-complement-aware value of operand bits [lo..hi].

    Signed iff `signed` and hi == W-1 (slice owns the operand MSB)."""
    val = 0
    for i in range(lo, hi + 1):
        bit = (operand_int >> i) & 1
        w = _bit_sign(i, W, signed)
        val += w * bit * (1 << (i - lo))
    return val


# =============================================================================
#  Tile descriptor
# =============================================================================
class Tile(object):
    """A placed tile.

      kind     : 'DSP' | 'BOOTH' | 'LUT'
      i0,i1    : board row span (operand a bit indices), inclusive
      j0,j1    : board col span (operand b bit indices), inclusive
      booth_axis : for BOOTH only -- 'a' or 'b': which operand is Booth-encoded
                   (the multiplier); the other is the multiplicand.
      level    : for BOOTH only -- Booth level L.
    """
    __slots__ = ('kind', 'i0', 'i1', 'j0', 'j1', 'booth_axis', 'level')

    def __init__(self, kind, i0, i1, j0, j1, booth_axis=None, level=None):
        self.kind = kind
        self.i0, self.i1, self.j0, self.j1 = i0, i1, j0, j1
        self.booth_axis = booth_axis
        self.level = level

    # geometry -----------------------------------------------------------------
    @property
    def h(self):  # rows (a-axis width)
        return self.i1 - self.i0 + 1

    @property
    def w(self):  # cols (b-axis width)
        return self.j1 - self.j0 + 1

    @property
    def area(self):
        return self.h * self.w

    @property
    def col_offset(self):
        return self.i0 + self.j0

    def cells(self):
        for i in range(self.i0, self.i1 + 1):
            for j in range(self.j0, self.j1 + 1):
                yield (i, j)

    def signed_a(self, Wa, sign_a):
        return sign_a and self.i1 == Wa - 1

    def signed_b(self, Wb, sign_b):
        return sign_b and self.j1 == Wb - 1

    def __repr__(self):
        extra = ""
        if self.kind == 'BOOTH':
            extra = " L%d/%s" % (self.level, self.booth_axis)
        return "<%s a[%d:%d] b[%d:%d]%s>" % (self.kind, self.i1, self.i0,
                                             self.j1, self.j0, extra)

    # exact value of this tile's contribution to a*b ---------------------------
    def value(self, a, b, Wa, Wb, sign_a, sign_b):
        sa = self.signed_a(Wa, sign_a)
        sb = self.signed_b(Wb, sign_b)
        va = slice_value(a, self.i0, self.i1, Wa, sa)
        vb = slice_value(b, self.j0, self.j1, Wb, sb)
        return va * vb  # placed at 2^col_offset by caller


# =============================================================================
#  Booth radix-4 model
# =============================================================================
def booth_digits_needed(height, signed):
    """# radix-4 Booth digits (logic levels) for a multiplier of given height."""
    eff = height + (0 if signed else 1)   # unsigned -> pad a 0 MSB
    return (eff + 1) // 2


def booth_level_max_height(level, signed):
    """Max Booth-encoded operand height for a given level."""
    # signed: 2L ; unsigned: 2L-1   (matches paper Table III/IV: L3->6/5 ...)
    return 2 * level if signed else 2 * level - 1


# Booth encoder (paper Table II): triplet (y_{2m+1}, y_2m, y_{2m-1}) -> flags.
def _booth_flags(y_hi, y_mid, y_lo):
    """Return (z, c, s): zero, complement(negative), shift(magnitude-2)."""
    digit = -2 * y_hi + y_mid + y_lo          # in {-2,-1,0,1,2}
    z = 1 if digit == 0 else 0
    c = 1 if digit < 0 else 0
    s = 1 if abs(digit) == 2 else 0
    return z, c, s


def _booth_ppbit_fn(mult_is_a):
    """Boolean fn for one Booth PP bit, over inputs
       [y_hi, y_mid, y_lo, x_n, x_nm1]  ->  selected & maybe-inverted bit.
    pp = z ? c : ((s ? x_{n-1} : x_n) XOR c).  (When z=1 digit is 0; we still
    XOR c so that an all-ones/identity correction stays consistent; but digit 0
    forces magnitude 0, so pp must be 0 -> we special-case z by emitting c only
    where it cancels.  We instead emit pp=0 when z, see below.)"""
    def fn(v):
        y_hi, y_mid, y_lo, x_n, x_nm1 = v[0], v[1], v[2], v[3], v[4]
        z, c, s = _booth_flags(y_hi, y_mid, y_lo)
        if z:
            return 0
        sel = x_nm1 if s else x_n
        return sel ^ c
    return fn


def booth_tile_bits(tile, Wa, Wb, sign_a, sign_b):
    """Generate the radix-4 Booth partial products for a BOOTH tile.

    Returns (bits, const) where:
        bits  : list of (col, BitExpr) positive heap bits (col is ABSOLUTE
                board column).
        const : an integer additive correction (Baugh-Wooley invert-MSB
                constants for the signed rows), added into the heap mod
                2^(Wa+Wb) by the caller.

    Each radix-4 row m realises  d_m * Xslice  via the modified-Booth select
    (paper Table II): pp_n = z?0:(sel_n XOR c), sel_n = s? x_{n-1} : x_n, plus a
    '+1' (= c) at the row LSB for negative digits.  The row is a two's-comp
    (w+2)-bit number; its sign bit is emitted inverted with const -= 2^(sign
    col) (the standard sign-extension trick), so NO sign-bit replication is
    needed.  Verified exhaustively in _self_test against Eq. T.
    """
    if tile.booth_axis == 'a':
        m_lo, m_hi = tile.i0, tile.i1                 # a = Booth multiplier
        m_signed = tile.signed_a(Wa, sign_a)
        x_lo, x_hi = tile.j0, tile.j1                 # b = multiplicand
        x_signed = tile.signed_b(Wb, sign_b)
        mbit = lambda k: ('a', m_lo + k)
        xbit = lambda k: ('b', x_lo + k)
    else:
        m_lo, m_hi = tile.j0, tile.j1                 # b = Booth multiplier
        m_signed = tile.signed_b(Wb, sign_b)
        x_lo, x_hi = tile.i0, tile.i1                 # a = multiplicand
        x_signed = tile.signed_a(Wa, sign_a)
        mbit = lambda k: ('b', m_lo + k)
        xbit = lambda k: ('a', x_lo + k)

    h = m_hi - m_lo + 1
    w = x_hi - x_lo + 1
    ndig = booth_digits_needed(h, m_signed)
    base = tile.col_offset

    def m_handle(k):
        if k < 0:
            return _const_bit(0)
        if k <= h - 1:
            return BitExpr([mbit(k)], lambda v: v[0], "y%d" % k)
        return BitExpr([mbit(h - 1)], lambda v: v[0], "ysgn") if m_signed \
            else _const_bit(0)

    def x_handle(k):
        if k < 0:
            return _const_bit(0)
        if k <= w - 1:
            return BitExpr([xbit(k)], lambda v: v[0], "x%d" % k)
        return BitExpr([xbit(w - 1)], lambda v: v[0], "xsgn") if x_signed \
            else _const_bit(0)

    def ppbit_expr(y_hi, y_mid, y_lo, xb_n, xb_nm1, label):
        comp_inputs = []
        for he in (y_hi, y_mid, y_lo, xb_n, xb_nm1):
            for inp in he.inputs:
                if inp not in comp_inputs:
                    comp_inputs.append(inp)

        def fn(v, y_hi=y_hi, y_mid=y_mid, y_lo=y_lo, xb_n=xb_n, xb_nm1=xb_nm1,
               ci=tuple(comp_inputs)):
            d = {ci[i]: v[i] for i in range(len(ci))}
            z, c, s = _booth_flags(_sub_eval(y_hi, d), _sub_eval(y_mid, d),
                                   _sub_eval(y_lo, d))
            if z:
                return 0
            sel = _sub_eval(xb_nm1, d) if s else _sub_eval(xb_n, d)
            return sel ^ c
        return BitExpr(comp_inputs, fn, label)

    bits = []
    const = 0
    nb = w + 2                         # two's-complement width of one row
    for mdig in range(ndig):
        y_hi = m_handle(2 * mdig + 1)
        y_mid = m_handle(2 * mdig)
        y_lo = m_handle(2 * mdig - 1)
        off = base + 2 * mdig
        # magnitude + low bits n = 0 .. nb-2, sign bit n = nb-1
        for n in range(0, nb):
            be = ppbit_expr(y_hi, y_mid, y_lo, x_handle(n), x_handle(n - 1),
                            "booth m%d n%d" % (mdig, n))
            if n == nb - 1:
                # sign bit -> invert and add -2^(off+n) to const (sign-extend)
                inv = BitExpr(be.inputs, (lambda v, f=be.fn: 1 - f(v)),
                              "~" + be.label)
                bits.append((off + n, inv))
                const -= (1 << (off + n))
            else:
                bits.append((off + n, be))
        # negative-digit two's-complement '+1' = c at the row LSB
        bits.append((off, _booth_c_expr(y_hi, y_mid, y_lo)))

    return bits, const


def _sub_eval(expr, dvals):
    vals = [dvals[inp] for inp in expr.inputs]
    return expr.fn(vals) & 1


def _booth_c_expr(y_hi, y_mid, y_lo):
    comp_inputs = []
    for he in (y_hi, y_mid, y_lo):
        for inp in he.inputs:
            if inp not in comp_inputs:
                comp_inputs.append(inp)

    def fn(v, y_hi=y_hi, y_mid=y_mid, y_lo=y_lo, ci=tuple(comp_inputs)):
        d = {ci[i]: v[i] for i in range(len(ci))}
        yv = (_sub_eval(y_hi, d), _sub_eval(y_mid, d), _sub_eval(y_lo, d))
        _z, c, _s = _booth_flags(*yv)
        return c
    return BitExpr(comp_inputs, fn, "boothC")


def _booth_row_sign_expr(y_hi, y_mid, y_lo, x_handle, w, x_signed):
    """Sign bit of a Booth row d*X (two's complement).  The row value range is
    [-2*Xmax, 2*Xmax].  Its sign bit = (row value < 0).  Equivalent boolean:
    sign = c XOR (negative overflow of magnitude).  Simplest exact form: build
    the magnitude MSB select and combine.  We compute it from the top
    multiplicand bit and c/s flags."""
    xb_top = x_handle(w - 1)       # multiplicand MSB (local)
    xb_top2 = x_handle(w)          # one above (sign-extension / 0)
    comp_inputs = []
    for he in (y_hi, y_mid, y_lo, xb_top, xb_top2):
        for inp in he.inputs:
            if inp not in comp_inputs:
                comp_inputs.append(inp)

    def fn(v, y_hi=y_hi, y_mid=y_mid, y_lo=y_lo, xb_top=xb_top, xb_top2=xb_top2,
           ci=tuple(comp_inputs)):
        d = {ci[i]: v[i] for i in range(len(ci))}
        yv = (_sub_eval(y_hi, d), _sub_eval(y_mid, d), _sub_eval(y_lo, d))
        z, c, s = _booth_flags(*yv)
        if z:
            return 0
        # magnitude top bit:  s -> 2X so MSB at position w is x_top ; else X MSB
        top = _sub_eval(xb_top2, d) if s else _sub_eval(xb_top, d)
        return top ^ c
    return BitExpr(comp_inputs, fn, "boothSgn")


# =============================================================================
#  Tile -> heap PP bits (uniform interface used by merge + RTL + golden)
# =============================================================================
def tile_heap_bits(tile, Wa, Wb, sign_a, sign_b, dsp_wire_namer=None):
    """Return (oip_bits, igp_bits, const) for one tile.

      oip_bits : list of (col, ('OIP'|'OIP_INV', i, j)) -- LUT-tile AND/NAND
                 cells that feed the merge as 2-pin original input PPs.
      igp_bits : list of (col, BitExpr) -- single-bit rows (Booth PP bits,
                 DSP output bits as opaque wires).
      const    : additive correction constant (Baugh-Wooley + Booth negatives).
    """
    if tile.kind == 'LUT':
        oip = []
        const = 0
        sa = tile.signed_a(Wa, sign_a)
        sb = tile.signed_b(Wb, sign_b)
        for (i, j) in tile.cells():
            siA = _bit_sign(i, Wa, sa if i == Wa - 1 else False)
            # cell is negative iff exactly one axis sign weight is -1
            wa = _bit_sign(i, Wa, sa)
            wb = _bit_sign(j, Wb, sb)
            neg = (wa * wb) == -1
            kind = 'OIP_INV' if neg else 'OIP'
            oip.append((i + j, (kind, i, j)))
            if neg:
                # NAND = 1 - a*b ; -(a*b)*2^c = NAND*2^c - 2^c  -> add -2^c
                const += -(1 << (i + j))
        return oip, [], const

    if tile.kind == 'BOOTH':
        # Booth tile is a self-contained sub-multiplier: it outputs ONE result
        # vector (its X*Y), realised structurally by booth_array.emit_booth_array.
        # Here it contributes a single opaque output row to the merge, exactly
        # like a DSP -- the "Booth residual partial products" that get merged.
        igp, const = _opaque_output_bits(tile, 'booth', Wa, Wb, sign_a, sign_b)
        return [], igp, const

    if tile.kind == 'DSP':
        igp, const = _opaque_output_bits(tile, 'dsp', Wa, Wb, sign_a, sign_b)
        return [], igp, const

    raise ValueError("unknown tile kind %s" % tile.kind)


def _opaque_output_bits(tile, prefix, Wa, Wb, sign_a, sign_b):
    """A tile whose hardware computes its slice product internally (DSP or
    structural Booth array) and exposes it as opaque wires
    <prefix>_<i0>_<j0>[bit].  Returns (igp_bits, const): nb = h+w product bits,
    the signed MSB inverted with const -= 2^(MSB col) (sign-extension trick)."""
    igp = []
    nb = tile.h + tile.w
    signed = tile.signed_a(Wa, sign_a) or tile.signed_b(Wb, sign_b)
    const = 0
    for bitidx in range(nb):
        col = tile.col_offset + bitidx
        wname = '%s_%d_%d_%d' % (prefix, tile.i0, tile.j0, bitidx)
        if signed and bitidx == nb - 1:
            igp.append((col, BitExpr([('w', wname)], (lambda v: 1 - v[0]),
                                     "~%s[%d]" % (prefix, bitidx))))
            const -= (1 << col)
        else:
            igp.append((col, BitExpr([('w', wname)], (lambda v: v[0]),
                                     "%s[%d]" % (prefix, bitidx))))
    return igp, const


# =============================================================================
#  Tile-set enumeration for the Step-1 ILP
# =============================================================================
# AMD/Xilinx DSP48: 24x17 unsigned, 25x18 signed (one operand can be 1 wider
# when signed).  We model the usable multiply rectangle.
DSP_UNSIGNED = (24, 17)
DSP_SIGNED = (25, 18)

# LUT tiles are residual exact-cover rectangles.  Unlike the original small
# Table-I tile set, they are no longer restricted to 1x1..3x3, but the search
# space is bounded by the selected Booth level: for level L, the largest LUT
# residual shape is (2L-1) x (2L-1).  Example: L3 allows 1x1..5x5; L4 allows
# 1x1..7x7.  A LUT tile contributes its individual original-input
# partial-product cells to the Step-2 source compressor heap; therefore the
# generic own-cost proxy is one LUT input-product bit per covered cell.  The
# historical Table-I costs are kept only for reference/backward comparison, not
# as an enumeration limit.
LUT_TILE_COST_TABLE_I = {(1, 1): 1, (1, 2): 1, (2, 1): 1, (2, 2): 2,
                        (2, 3): 3, (3, 2): 3, (3, 3): 5}


def lut_tile_cost(h, w):
    """Generic LUT residual-tile own-cost proxy for any h x w rectangle.

    The actual LUT tile representation below is per-cell OIP/OIP_INV bits, so
    the cost must be defined for every rectangle rather than keyed by a fixed
    small-shape table.
    """
    return h * w


def lut_max_shape_for_booth_level(level):
    """Maximum residual LUT rectangle side for the selected Booth level.

    The bound follows the unsigned Booth encoded-operand height: L3 -> 5,
    L4 -> 7, L5 -> 9, etc.  Shapes up to max_side x max_side are enumerated.
    """
    return booth_level_max_height(level, False)


def booth_tile_cost(level, k):
    """Paper Table III costmult_t for a level-L Booth array of free width k.
       L3:3(k+1) L4:4(k+1) L5:5(k+1) L6:6(k+1) L7:7(k+1)."""
    return level * (k + 1)


def dsp_tile_cost():
    return 0   # DSP costs no LUTs; constrained by --max-dsp instead


def _band_anchors(axis_len, h_uns, h_sgn, dsp_dims):
    """Encoded-axis anchor positions for band-aligned Booth enumeration.

    Same-height Booth tiles stack, so in any packing their anchors lie on a grid
    stepped by the unsigned band height.  We seed that grid from a few bases:
    the LSB edge (0), the MSB-owning top band (axis_len - h for each height),
    and -- when DSPs are allowed -- just above a DSP of each possible extent (so
    a Booth band can sit on the DSP corner).  This cuts the encoded-axis
    positions from O(W) to O(W / h_uns) without losing the optimum in practice;
    the LUT residual still absorbs whatever a band misses.
    """
    bases = {0, axis_len - h_uns, axis_len - h_sgn}
    for d in dsp_dims:
        bases.add(d)
    anchors = set()
    for base in bases:
        a = base
        while a >= 0:
            anchors.add(a)
            a -= h_uns
        a = base + h_uns
        while a <= axis_len:
            anchors.add(a)
            a += h_uns
    return {a for a in anchors if 0 <= a <= axis_len}


def _norm_levels(booth_level):
    """Normalise booth_level (int OR iterable of ints) to a sorted list.
    Enables MIXED Booth levels: pass e.g. [3,4,5,6,7] and the ILP may use a
    different level in different regions of the same multiplier."""
    if isinstance(booth_level, int):
        return [booth_level]
    return sorted({int(x) for x in booth_level})


def _mcand_intervals(boundaries, kmin, kmax):
    """Booth multiplicand spans (lo, width) between the given boundary columns.

    Width-dominance: a wider Booth always dominates splitting it (own L*(k+1)
    and h+k pins are both sub-additive in width), so a tile's multiplicand span
    only needs to run between 'boundaries'.  The boundary set is the union of the
    board edges, the DSP start/end columns, AND the per-level band grids -- the
    last supply the intermediate widths that interlocking opposite-orientation
    Booth bands need, which keeps the prune lossless (verified vs full
    enumeration) instead of collapsing to full-width-only when there is no DSP.
    Returns a list of (lo, width)."""
    B = sorted(set(boundaries))
    out = []
    for ai in range(len(B)):
        for bi in range(ai + 1, len(B)):
            k = B[bi] - B[ai]
            if kmin <= k <= kmax:
                out.append((B[ai], k))
    return out


def enumerate_candidate_tiles(Wa, Wb, sign_a, sign_b,
                              booth_level, allow_dsp,
                              dsp_unsigned=DSP_UNSIGNED, dsp_signed=DSP_SIGNED,
                              booth_min_k=4, booth_max_k=None,
                              include_lut=True, booth_band_align=False,
                              booth_width_prune=False):
    """Generate candidate tile placements covering sub-rectangles of the
    Wa x Wb board.  Only Booth tiles of the *configured* level are produced
    (per the requirement: 'if level=7, only level-7 Booth tiles').

    include_lut=False        : omit LUT residual variables entirely (the packing
                               formulation models them implicitly).
    booth_band_align=True    : restrict Booth encoded-axis anchors to the band
                               grid (see _band_anchors) -- the O(W)->O(W/L) prune.

    Returns a list of Tile objects (placements).
    """
    tiles = []

    # ---- LUT tiles (level-bounded rectangle shapes, every position) ----
    if include_lut:
        lut_max = lut_max_shape_for_booth_level(max(_norm_levels(booth_level)))
        for h in range(1, min(Wa, lut_max) + 1):
            for w in range(1, min(Wb, lut_max) + 1):
                for i0 in range(0, Wa - h + 1):
                    for j0 in range(0, Wb - w + 1):
                        tiles.append(Tile('LUT', i0, i0 + h - 1, j0, j0 + w - 1))

    # ---- Booth tiles of the configured level(s) ----
    # booth_level may be a single int OR a collection of levels (e.g. [3,4,5,6,7]).
    # Candidates of EVERY listed level are produced, so the ILP can MIX levels in
    # one multiplier -- a different Booth height per region.  The Booth-encoded
    # operand height is FIXED per level: 2L-1 (unsigned multiplier) or 2L (signed,
    # when the encoded slice owns a signed MSB); the multiplicand width k is free.
    # Leftover board area is covered by LUT/DSP tiles.
    levels = _norm_levels(booth_level)
    if booth_max_k is None:
        booth_max_k = max(Wa, Wb)
    dsp_axis = ({min(d, Wa) for d in (dsp_unsigned[0], dsp_unsigned[1],
                                      dsp_signed[0], dsp_signed[1])},
                {min(d, Wb) for d in (dsp_unsigned[0], dsp_unsigned[1],
                                      dsp_signed[0], dsp_signed[1])}) \
               if allow_dsp else (set(), set())

    # multiplicand-axis spans (level-independent).  With width-prune they run
    # only between board/DSP boundaries (dominance); else every (pos,width).
    kmax_a, kmax_b = min(booth_max_k, Wa), min(booth_max_k, Wb)
    if booth_width_prune:
        # boundaries = board edges + DSP edges + each level's band HEIGHTS and
        # their complements (a one-band-thick interlocking width and its mirror).
        # NOT the full stacking grid -- that would be too dense to prune.
        Ba, Bb = {0, Wa}, {0, Wb}
        for d in dsp_axis[0]:
            Ba |= {d, Wa - d}
        for d in dsp_axis[1]:
            Bb |= {d, Wb - d}
        for L in levels:
            for h in (booth_level_max_height(L, False),
                      booth_level_max_height(L, True)):
                Ba |= {h, Wa - h}
                Bb |= {h, Wb - h}
        Ba = {x for x in Ba if 0 <= x <= Wa}
        Bb = {x for x in Bb if 0 <= x <= Wb}
        mcand_a = _mcand_intervals(Ba, booth_min_k, kmax_a)
        mcand_b = _mcand_intervals(Bb, booth_min_k, kmax_b)
    else:
        mcand_a = [(i0, kk) for kk in range(booth_min_k, kmax_a + 1)
                   for i0 in range(0, Wa - kk + 1)]
        mcand_b = [(j0, kk) for kk in range(booth_min_k, kmax_b + 1)
                   for j0 in range(0, Wb - kk + 1)]

    for L in levels:
        h_uns = booth_level_max_height(L, False)     # 2L-1
        h_sgn = booth_level_max_height(L, True)      # 2L
        a_anchors = _band_anchors(Wa, h_uns, h_sgn, dsp_axis[0]) \
            if booth_band_align else None
        b_anchors = _band_anchors(Wb, h_uns, h_sgn, dsp_axis[1]) \
            if booth_band_align else None

        # orientation 'a': operand a is the Booth multiplier (height), b mcand
        a_heights = {h_uns}
        if sign_a:
            a_heights.add(h_sgn)
        for hh in a_heights:
            if hh > Wa:
                continue
            i0_list = (sorted(a for a in a_anchors if a <= Wa - hh)
                       if booth_band_align else range(0, Wa - hh + 1))
            for i0 in i0_list:
                top_signed = sign_a and (i0 + hh - 1 == Wa - 1)
                # signed height only valid when it owns the MSB; an unsigned
                # height must NOT own a signed MSB.
                if hh == h_sgn and not top_signed:
                    continue
                if hh == h_uns and top_signed and h_uns != h_sgn:
                    continue
                for (j0, kk) in mcand_b:
                    if j0 + kk <= Wb:
                        tiles.append(Tile('BOOTH', i0, i0 + hh - 1,
                                          j0, j0 + kk - 1,
                                          booth_axis='a', level=L))

        # orientation 'b': operand b is the Booth multiplier
        b_heights = {h_uns}
        if sign_b:
            b_heights.add(h_sgn)
        for hh in b_heights:
            if hh > Wb:
                continue
            j0_list = (sorted(b for b in b_anchors if b <= Wb - hh)
                       if booth_band_align else range(0, Wb - hh + 1))
            for j0 in j0_list:
                top_signed = sign_b and (j0 + hh - 1 == Wb - 1)
                if hh == h_sgn and not top_signed:
                    continue
                if hh == h_uns and top_signed and h_uns != h_sgn:
                    continue
                for (i0, kk) in mcand_a:
                    if i0 + kk <= Wa:
                        tiles.append(Tile('BOOTH', i0, i0 + kk - 1,
                                          j0, j0 + hh - 1,
                                          booth_axis='b', level=L))

    # ---- DSP tiles ----
    if allow_dsp:
        # A DSP48 does one (<=25)x(<=18) signed multiply.  The RTL widens an
        # UNSIGNED slice by 1 bit (a signed slice keeps its width), so a tile of
        # raw size da x db realises  (da + (0 if signed_a else 1)) x
        # (db + (0 if signed_b else 1)) .  Keep a placement only if that realised
        # multiply fits ONE DSP, i.e. max<=25 and min<=18 (either port order).
        # This lets a signed-signed corner use the full 25x18, while elsewhere
        # the tile is capped (24x17 / 25x17 / 24x18) -- always exactly 1 DSP.
        cand = set()
        for da in (dsp_unsigned[0], dsp_unsigned[1], dsp_signed[0], dsp_signed[1]):
            for db in (dsp_unsigned[0], dsp_unsigned[1], dsp_signed[0], dsp_signed[1]):
                da_c = min(da, Wa); db_c = min(db, Wb)
                if da_c >= 1 and db_c >= 1:
                    cand.add((da_c, db_c))
        for (da, db) in cand:
            for i0 in range(0, Wa - da + 1):
                i1 = i0 + da - 1
                ra = da + (0 if (sign_a and i1 == Wa - 1) else 1)
                for j0 in range(0, Wb - db + 1):
                    j1 = j0 + db - 1
                    rb = db + (0 if (sign_b and j1 == Wb - 1) else 1)
                    if max(ra, rb) <= 25 and min(ra, rb) <= 18:
                        tiles.append(Tile('DSP', i0, i1, j0, j1))
    # de-dup
    seen = set()
    uniq = []
    for t in tiles:
        key = (t.kind, t.i0, t.i1, t.j0, t.j1, t.booth_axis, t.level)
        if key not in seen:
            seen.add(key)
            uniq.append(t)
    return uniq


# =============================================================================
#  Self-test : every tile model reproduces Eq. T (slice_a * slice_b) exactly,
#  and the heap-bit representation (positive bits + const) matches it too.
# =============================================================================
def _eval_tile_heap(tile, a, b, Wa, Wb, sign_a, sign_b, cached=None):
    """Sum the heap-bit representation of a single tile -> integer value
    (NOT reduced; caller compares mod 2^(Wa+Wb))."""
    if cached is None:
        cached = tile_heap_bits(tile, Wa, Wb, sign_a, sign_b)
    oip, igp, const = cached
    total = const
    for (col, spec) in oip:
        kind, i, j = spec
        ab = ((a >> i) & 1) & ((b >> j) & 1)
        val = (1 - ab) if kind == 'OIP_INV' else ab
        total += val << col
    wires = {}
    if tile.kind in ('DSP', 'BOOTH'):
        prefix = 'dsp' if tile.kind == 'DSP' else 'booth'
        sa = tile.signed_a(Wa, sign_a)
        sb = tile.signed_b(Wb, sign_b)
        va = slice_value(a, tile.i0, tile.i1, Wa, sa)
        vb = slice_value(b, tile.j0, tile.j1, Wb, sb)
        nb = tile.h + tile.w
        field = (va * vb) & ((1 << nb) - 1)
        for bitidx in range(nb):
            wires['%s_%d_%d_%d' % (prefix, tile.i0, tile.j0, bitidx)] = (field >> bitidx) & 1
    for (col, be) in igp:
        total += be.eval(a, b, wires) << col
    return total


def _self_test(verbose=True):
    import random
    rng = random.Random(7)
    ok = True
    modes = [(False, False), (True, False), (False, True), (True, True)]
    cases = 0
    for Wa in range(3, 6):
        for Wb in range(3, 6):
            for sign_a, sign_b in modes:
                tiles = enumerate_candidate_tiles(
                    Wa, Wb, sign_a, sign_b, booth_level=3, allow_dsp=True)
                sample = tiles if len(tiles) <= 24 else rng.sample(tiles, 24)
                M = 1 << (Wa + Wb)
                for t in sample:
                    cached = tile_heap_bits(t, Wa, Wb, sign_a, sign_b)
                    for a in range(1 << Wa):
                        for b in range(1 << Wb):
                            want = (t.value(a, b, Wa, Wb, sign_a, sign_b) << t.col_offset) % M
                            got = _eval_tile_heap(t, a, b, Wa, Wb, sign_a, sign_b, cached) % M
                            if want != got:
                                ok = False
                                if verbose:
                                    print("TILE MISMATCH", t, a, b, want, got)
                                break
                        else:
                            continue
                        break
                    cases += 1
    for L in (4, 5, 6, 7):
        for signed in (False, True):
            hmax = booth_level_max_height(L, signed)
            for h in sorted(set([hmax, max(3, hmax - 1)])):
                for w in (1, 2, 5):
                    Wa, Wb = h, w
                    sign_a, sign_b = signed, False
                    t = Tile('BOOTH', 0, h - 1, 0, w - 1, booth_axis='a', level=L)
                    M = 1 << (Wa + Wb)
                    cached = tile_heap_bits(t, Wa, Wb, sign_a, sign_b)
                    if Wa + Wb <= 12:
                        pairs = [(a, b) for a in range(1 << Wa) for b in range(1 << Wb)]
                    else:
                        pairs = [(rng.randrange(1 << Wa), rng.randrange(1 << Wb))
                                 for _ in range(4000)]
                        pairs += [(0, 0), ((1 << Wa) - 1, (1 << Wb) - 1)]
                    for a, b in pairs:
                        want = (t.value(a, b, Wa, Wb, sign_a, sign_b) << t.col_offset) % M
                        got = _eval_tile_heap(t, a, b, Wa, Wb, sign_a, sign_b, cached) % M
                        if want != got:
                            ok = False
                            if verbose:
                                print("BOOTH MISMATCH L%d h%d w%d signed%d a%d b%d %d!=%d"
                                      % (L, h, w, signed, a, b, want, got))
                            break
                    cases += 1
    print("tiles self-test: %s  (%d tile-cases)" % ("PASS" if ok else "FAIL", cases))
    return ok


if __name__ == "__main__":
    import sys
    sys.exit(0 if _self_test() else 1)
