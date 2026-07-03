"""
tiled_verilog_gen.py  --  structural RTL for the two-step tiling multiplier.

Emits ONLY FPGA primitives, matching the original framework's style:

    * DSP tiles   -> a behavioural signed/unsigned `*` carrying (* use_dsp="yes" *)
                     so Vivado infers ONE DSP48 block per tile;
    * Booth tiles -> a self-contained radix-4 Booth ARRAY (booth_array.py):
                     LUT6 Type-A Booth-encode cells + CARRY4 accumulation that
                     internally compresses the L rows and outputs ONE result
                     vector (cost ~L*(k+1) LUT6, paper Table III), merged like
                     a DSP output row;
    * LUT tiles   -> their AND/NAND cells enter the merge as original-input
                     partial products (OIP), consumed directly by the merge
                     compressors' LUT6_2 (2 pins/cell), exactly as the source
                     framework does;  for the greedy fallback each cell is first
                     realised as one AND/NAND LUT6;
    * merge tree  -> the LUT6_2 / CARRY4 compressors chosen by the Step-2 ILP,
                     emitted by REUSING verilog_gen._emit_compressor /
                     _emit_lutcarry_chain (the already-verified source emitters);
    * final CLA   -> per-column LUT6_2 (P/G) + CARRY4 chain over all Wa+Wb cols.

The generated module is `<modname>(a, b, r)`, r = a*b (mod 2^(Wa+Wb), i.e. the
two's-complement product for signed axes).  All four sign modes ss/us/su/uu.
"""

from tiles import tile_heap_bits
from merge_ilp import build_heap
from verilog_gen import (_emit_compressor, _emit_lutcarry_chain,
                         _build_lutcarry_chains, IGPPool, _kid_sort_key,
                         compute_init)
from compressors import all_compressors
from booth_array import emit_booth_array
from tiles import booth_digits_needed


# --------------------------------------------------------------------------- #
#  tile-aware OIP manager (mirrors verilog_gen.PPManager interface)
# --------------------------------------------------------------------------- #
class TilePPManager(object):
    """Per-column queue of (a_name, b_name, inverted) for LUT-tile cells."""
    def __init__(self, Wa, Wb):
        self.Wa = Wa
        self.Wb = Wb
        self.q = {}

    def add(self, col, i, j, inv):
        self.q.setdefault(col, []).append(("a[%d]" % i, "b[%d]" % j, inv))

    def pop(self, col):
        if col in self.q and self.q[col]:
            return self.q[col].pop(0)
        return ("1'b0", "1'b0", False)


# --------------------------------------------------------------------------- #
#  DSP tile emission  (one DSP48 per tile via behavioural signed `*`)
# --------------------------------------------------------------------------- #
def _emit_dsp(f, tile, Wa, Wb, sign_a, sign_b):
    """Emit a DSP product wire dsp_<i0>_<j0>[nb-1:0] = slice_a * slice_b and
    return a dict mapping the heap wire-name -> the concrete bit expression."""
    sa = tile.signed_a(Wa, sign_a)
    sb = tile.signed_b(Wb, sign_b)
    nb = tile.h + tile.w
    base = "dsp_%d_%d" % (tile.i0, tile.j0)
    a_sl = "a[%d:%d]" % (tile.i1, tile.i0) if tile.i1 > tile.i0 else "a[%d]" % tile.i0
    b_sl = "b[%d:%d]" % (tile.j1, tile.j0) if tile.j1 > tile.j0 else "b[%d]" % tile.j0
    # An unsigned slice is widened by ONE bit (prepend 0) so it is a
    # non-negative signed value; a signed slice keeps its exact width.  Using
    # the minimal width is what lets a 24x17 (unsigned) or 25x18 (signed) slice
    # map to a SINGLE DSP48 -- over-widening (e.g. 26x19) forces Vivado to use 2.
    wa = tile.h if sa else tile.h + 1
    wb = tile.w if sb else tile.w + 1
    ax = "$signed({1'b0, %s})" % a_sl if not sa else "$signed(%s)" % a_sl
    bx = "$signed({1'b0, %s})" % b_sl if not sb else "$signed(%s)" % b_sl
    f.write("\n  // ---- DSP tile %s : %s x %s  (%s) ----\n"
            % (base, a_sl, b_sl,
               ("signed" if sa else "unsigned") + "/" +
               ("signed" if sb else "unsigned")))
    f.write("  wire signed [%d:0] %s_a = %s;\n" % (wa - 1, base, ax))
    f.write("  wire signed [%d:0] %s_b = %s;\n" % (wb - 1, base, bx))
    f.write("  (* use_dsp = \"yes\" *) wire signed [%d:0] %s_p = %s_a * %s_b;\n"
            % (wa + wb - 1, base, base, base))
    f.write("  wire [%d:0] %s = %s_p[%d:0];\n" % (nb - 1, base, base, nb - 1))
    return base, nb


# --------------------------------------------------------------------------- #
#  Booth tile emission  (self-contained radix-4 Booth array -> 1 result vector)
# --------------------------------------------------------------------------- #
def _emit_booth_tile(f, tile, Wa, Wb, sign_a, sign_b):
    """Emit a structural Booth array for `tile`, producing wire
    booth_<i0>_<j0>[nb-1:0] = slice_a*slice_b.  Returns nb = h+w."""
    sa = tile.signed_a(Wa, sign_a)
    sb = tile.signed_b(Wb, sign_b)
    a_sl = ("a[%d:%d]" % (tile.i1, tile.i0)) if tile.i1 > tile.i0 else ("a[%d]" % tile.i0)
    b_sl = ("b[%d:%d]" % (tile.j1, tile.j0)) if tile.j1 > tile.j0 else ("b[%d]" % tile.j0)
    out_base = "booth_%d_%d" % (tile.i0, tile.j0)
    bx = "bx_%d_%d" % (tile.i0, tile.j0)   # multiplicand alias
    by = "by_%d_%d" % (tile.i0, tile.j0)   # multiplier alias
    if tile.booth_axis == 'a':             # a = Booth multiplier, b = multiplicand
        mh, mw = tile.h, tile.w
        x_signed, y_signed = sb, sa
        x_slice, y_slice = b_sl, a_sl
    else:                                  # b = Booth multiplier, a = multiplicand
        mh, mw = tile.w, tile.h
        x_signed, y_signed = sa, sb
        x_slice, y_slice = a_sl, b_sl
    L = booth_digits_needed(mh, y_signed)
    f.write("\n  // ---- Booth tile %s : %s(mult) x %s(mcand)  level L=%d (%s/%s) ----\n"
            % (out_base, y_slice, x_slice, L,
               "s" if y_signed else "u", "s" if x_signed else "u"))
    f.write("  wire [%d:0] %s = %s;\n" % (mw - 1, bx, x_slice))
    f.write("  wire [%d:0] %s = %s;\n" % (mh - 1, by, y_slice))
    nb = emit_booth_array(f, bx, by, mw, mh, x_signed, y_signed, out_base)
    return nb


# --------------------------------------------------------------------------- #
#  generic BitExpr -> wire (Booth LUT, DSP bit, const)
# --------------------------------------------------------------------------- #
def _handle_to_sig(h, dsp_wires):
    if h[0] == 'a':
        return "a[%d]" % h[1]
    if h[0] == 'b':
        return "b[%d]" % h[1]
    if h[0] == 'w':
        return dsp_wires[h[1]]          # e.g. "dsp_0_0[5]"
    raise ValueError(h)


def _bitexpr_to_wire(f, be, dsp_wires, uid_counter):
    """Return a Verilog signal for BitExpr `be`, emitting a LUT6 if needed."""
    n = len(be.inputs)
    if n == 0:
        return "1'b1" if be.fn([]) & 1 else "1'b0"
    if n == 1:
        sig = _handle_to_sig(be.inputs[0], dsp_wires)
        f0 = be.fn([0]) & 1
        f1 = be.fn([1]) & 1
        if f0 == 0 and f1 == 1:
            return sig                                  # identity -> wire
        if f0 == 1 and f1 == 0:
            uid = next(uid_counter)
            w = "w_inv_%d" % uid
            f.write("  wire %s;\n" % w)
            f.write("  LUT6 #(.INIT(64'h5555555555555555)) u_%s "
                    "(.O(%s), .I0(%s), .I1(1'b0), .I2(1'b0), .I3(1'b0), "
                    ".I4(1'b0), .I5(1'b0));\n" % (w, w, sig))
            return w
    # general: LUT6 with truth-table INIT
    init, handles = be.lut_init()
    sigs = [_handle_to_sig(h, dsp_wires) for h in handles]
    while len(sigs) < 6:
        sigs.append("1'b0")
    uid = next(uid_counter)
    w = "w_be_%d" % uid
    f.write("  wire %s;\n" % w)
    f.write("  LUT6 #(.INIT(64'h%016X)) u_%s (\n"
            "    .O(%s), .I0(%s), .I1(%s), .I2(%s), .I3(%s), .I4(%s), .I5(%s));\n"
            % (init, w, w, sigs[0], sigs[1], sigs[2], sigs[3], sigs[4], sigs[5]))
    return w


def _counter():
    i = 0
    while True:
        yield i
        i += 1


# --------------------------------------------------------------------------- #
#  final CLA over all Wa+Wb columns
# --------------------------------------------------------------------------- #
def _emit_merge_cla(f, nCols, ppmgr, ipool, S, oipv_last, igpv_last):
    f.write("\n  // ---- final CLA : per-column LUT6_2 (P/G) + CARRY4 chain ----\n")
    f.write("  wire [%d:0] cla_p, cla_g;\n" % (nCols - 1))
    for col in range(nCols):
        kinds, sigs = [], []
        for _ in range(oipv_last[col]):
            a, b, inv = ppmgr.pop(col)
            kinds.append('OIP_INV' if inv else 'OIP'); sigs += [a, b]
        for _ in range(igpv_last[col]):
            kinds.append('IGP'); sigs.append(ipool.pop(S, col))
        # 0 residual bits -> feed 0 to the adder (no LUT needed)
        if not sigs:
            f.write("  assign cla_p[%d] = 1'b0; assign cla_g[%d] = 1'b0;\n"
                    % (col, col))
            continue
        # exactly 1 IGP residual (already a single wire) -> S = that wire,
        # generate = 0.  The CARRY4 half-adds it with the carry; NO LUT needed.
        if oipv_last[col] == 0 and igpv_last[col] == 1:
            f.write("  assign cla_p[%d] = %s; assign cla_g[%d] = 1'b0;\n"
                    % (col, sigs[0], col))
            continue
        init_o5 = compute_init(kinds, 'g', 5)
        init_o6 = compute_init(kinds, 'p', 5)
        init = ((init_o6 & 0xFFFFFFFF) << 32) | (init_o5 & 0xFFFFFFFF)
        while len(sigs) < 5:
            sigs.append("1'b0")
        sigs = sigs[:5] + ["1'b1"]
        f.write("  LUT6_2 #(.INIT(64'h%016X)) u_cla_%d (.O5(cla_g[%d]), "
                ".O6(cla_p[%d]),\n    .I0(%s), .I1(%s), .I2(%s), .I3(%s), "
                ".I4(%s), .I5(%s));\n"
                % (init, col, col, col, sigs[0], sigs[1], sigs[2], sigs[3],
                   sigs[4], sigs[5]))
    nC4 = (nCols + 3) // 4
    for c in range(nC4):
        i0 = c * 4
        iN = min(i0 + 4, nCols)
        slc = iN - i0
        f.write("  wire [3:0] cy_co_%d, cy_o_%d;\n" % (c, c))
        if slc < 4:
            di = "{ %d'b0, cla_g[%d:%d] }" % (4 - slc, iN - 1, i0)
            si = "{ %d'b0, cla_p[%d:%d] }" % (4 - slc, iN - 1, i0)
        else:
            di = "cla_g[%d:%d]" % (iN - 1, i0)
            si = "cla_p[%d:%d]" % (iN - 1, i0)
        ci = "1'b0" if c == 0 else "cy_co_%d[3]" % (c - 1)
        f.write("  CARRY4 u_cy_%d (.CO(cy_co_%d), .O(cy_o_%d), .CI(%s), "
                ".CYINIT(1'b0), .DI(%s), .S(%s));\n"
                % (c, c, c, ci, di, si))
        for k in range(slc):
            f.write("  assign r[%d] = cy_o_%d[%d];\n" % (i0 + k, c, k))


# --------------------------------------------------------------------------- #
#  top-level
# --------------------------------------------------------------------------- #
def emit_tiled_verilog(tiles, merge_res, Wa, Wb, sign_a, sign_b, filename,
                       modname=None):
    nCols = Wa + Wb
    method = merge_res.get('method', 'ilp')
    use_chains = any(c['kid'].startswith('c') for c in merge_res['comps'])
    if modname is None:
        modname = ("tiled_mult_%db" % Wa) if Wa == Wb \
            else ("tiled_mult_%dx%d" % (Wa, Wb))
        if sign_a or sign_b:
            modname += "_%s%s" % ('s' if sign_a else 'u', 's' if sign_b else 'u')

    heap = build_heap(tiles, Wa, Wb, sign_a, sign_b)
    ppmgr = TilePPManager(Wa, Wb)
    ipool = IGPPool()
    uid = _counter()

    with open(filename, 'w') as f:
        f.write("// ==========================================================\n")
        f.write("// Two-step tiling multiplier (DSP + Booth + LUT / LUT+CARRY4)\n")
        f.write("// Wa=%d Wb=%d  sign_a=%s sign_b=%s  merge=%s  cols=%d\n"
                % (Wa, Wb, sign_a, sign_b, method, nCols))
        from collections import Counter
        tc = Counter(t.kind for t in tiles)
        f.write("// tiles: %s\n" % dict(tc))
        f.write("// ==========================================================\n")
        f.write("module %s (\n  input  [%d:0] a,\n  input  [%d:0] b,\n"
                "  output [%d:0] r\n);\n" % (modname, Wa - 1, Wb - 1, nCols - 1))

        # ---- DSP + Booth tiles : emit sub-multipliers, build wire-name map ----
        dsp_wires = {}
        for t in tiles:
            if t.kind == 'DSP':
                base, nb = _emit_dsp(f, t, Wa, Wb, sign_a, sign_b)
                for bi in range(nb):
                    dsp_wires['dsp_%d_%d_%d' % (t.i0, t.j0, bi)] = \
                        "%s[%d]" % (base, bi)
            elif t.kind == 'BOOTH':
                nb = _emit_booth_tile(f, t, Wa, Wb, sign_a, sign_b)
                for bi in range(nb):
                    dsp_wires['booth_%d_%d_%d' % (t.i0, t.j0, bi)] = \
                        "booth_%d_%d[%d]" % (t.i0, t.j0, bi)

        # ---- seed the heap into PPManager (OIP) + IGPPool (IGP) ----
        f.write("\n  // ---- tile partial products -> merge heap ----\n")
        greedy = (method != 'ilp')
        for col in range(nCols):
            for (kind, i, j) in heap.oip[col]:
                inv = (kind == 'OIP_INV')
                if greedy:
                    # realise each LUT-tile cell as one AND/NAND LUT6 -> IGP
                    w = "w_be_%d" % next(uid)
                    init = 0x8888888888888888 if not inv else 0x7777777777777777
                    f.write("  wire %s;\n" % w)
                    f.write("  LUT6 #(.INIT(64'h%016X)) u_%s (.O(%s), "
                            ".I0(a[%d]), .I1(b[%d]), .I2(1'b0), .I3(1'b0), "
                            ".I4(1'b0), .I5(1'b0));\n" % (init, w, w, i, j))
                    ipool.add(0, col, w)
                else:
                    ppmgr.add(col, i, j, inv)
            for be in heap.igp[col]:
                w = _bitexpr_to_wire(f, be, dsp_wires, uid)
                ipool.add(0, col, w)

        # ---- merge compressor tree (reuse source emitters) ----
        f.write("\n  // ---- merge : ILP LUT6_2 / CARRY4 compressor tree ----\n")
        comps = all_compressors(use_lut_carry=use_chains)
        if use_chains:
            pure, chains = _build_lutcarry_chains(merge_res['comps'])
        else:
            pure, chains = list(merge_res['comps']), []
        by_step = {}
        for i, c in enumerate(pure):
            by_step.setdefault(c['step'], []).append(('pure', c['col'], i, c))
        for i, ch in enumerate(chains):
            by_step.setdefault(ch[0]['step'], []).append(
                ('chain', ch[0]['col'], i, ch))
        for step in sorted(by_step):
            for kind, col, i, obj in sorted(
                    by_step[step],
                    key=lambda x: (x[1], 0 if x[0] == 'pure' else 1, x[2])):
                if kind == 'pure':
                    spec = comps[obj['kid']]
                    cid = "s%d_c%d_n%d" % (obj['step'], obj['col'], i)
                    _emit_compressor(f, obj, spec, ppmgr, ipool, cid)
                else:
                    cid = "lc_s%d_c%d_n%d" % (obj[0]['step'], obj[0]['col'], i)
                    _emit_lutcarry_chain(f, obj, ppmgr, ipool, cid)

        # ---- final CLA ----
        S = merge_res['S']
        _emit_merge_cla(f, nCols, ppmgr, ipool, S,
                        merge_res['OIPV'][-1], merge_res['IGPV'][-1])
        f.write("\nendmodule\n")
    return modname


def emit_tiled_testbench(Wa, Wb, modname, vfile, tbfile,
                         sign_a=False, sign_b=False, n_random=20000):
    Tot = Wa + Wb
    fill_a = ("a[%d]" % (Wa - 1)) if sign_a else "1'b0"
    fill_b = ("b[%d]" % (Wb - 1)) if sign_b else "1'b0"
    exp_rhs = "{ {%d{%s}}, a } * { {%d{%s}}, b }" % (Wb, fill_a, Wa, fill_b)
    with open(tbfile, 'w') as f:
        f.write("`timescale 1ns/1ps\nmodule tb_%s;\n" % modname)
        f.write("  reg [%d:0] a; reg [%d:0] b; wire [%d:0] r; reg [%d:0] exp;\n"
                % (Wa - 1, Wb - 1, Tot - 1, Tot - 1))
        f.write("  integer errors=0,total=0,i,ai,bi;\n")
        f.write("  %s dut(.a(a),.b(b),.r(r));\n  initial begin\n" % modname)
        if Wa <= 6 and Wb <= 6:
            f.write("    for(ai=0;ai<(1<<%d);ai=ai+1) for(bi=0;bi<(1<<%d);bi=bi+1) begin\n"
                    % (Wa, Wb))
            f.write("      a=ai[%d:0]; b=bi[%d:0]; #1; total=total+1; exp=%s;\n"
                    % (Wa - 1, Wb - 1, exp_rhs))
            f.write("      if(r!==exp) begin errors=errors+1; "
                    "$display(\"FAIL a=%0d b=%0d r=%0d exp=%0d\",a,b,r,exp); end\n")
            f.write("    end\n")
        else:
            f.write("    for(i=0;i<%d;i=i+1) begin\n" % n_random)
            f.write("      a=$random; b=$random; #1; total=total+1; exp=%s;\n" % exp_rhs)
            f.write("      if(r!==exp) begin errors=errors+1; "
                    "$display(\"FAIL a=%0d b=%0d r=%0d exp=%0d\",a,b,r,exp); end\n")
            f.write("    end\n")
        f.write("    $display(\"TB DONE Wa=%d Wb=%d total=%%0d errors=%%0d\",total,errors);\n"
                % (Wa, Wb))
        f.write("    $finish;\n  end\nendmodule\n")
