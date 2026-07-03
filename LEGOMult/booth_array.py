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


def emit_booth_array(f, xname, yname, w, h, x_signed, y_signed, out_base):
    """Emit the Booth array; declare wire [nb-1:0] out_base and drive it with
    X*Y.  xname/yname are the multiplicand/multiplier bus names (already sliced
    to [w-1:0]/[h-1:0] by the caller).  Returns nb = w+h."""
    L = booth_digits_needed(h, y_signed)
    nb = h + w
    const = 0
    for m in range(L):
        const -= (1 << (2 * m + w + 1))
    const &= (1 << nb) - 1

    # acc[p] : current signal for product bit p ; level 0 starts at the const
    acc = ["1'b1" if (const >> p) & 1 else "1'b0" for p in range(nb)]

    for m in range(L):
        lo = 2 * m
        yh = _ye_sig(2 * m + 1, yname, h, y_signed)
        ym = _ye_sig(2 * m, yname, h, y_signed)
        yl = _ye_sig(2 * m - 1, yname, h, y_signed)
        # build S and DI for every bit p in [lo, nb-1]
        S_sig = {}
        DI_sig = {}
        for p in range(lo, nb):
            n = p - lo
            if n == 0:
                # combined LUT6_2: O6 = sum bit, O5 = c_m (saves a LUT per level)
                x0 = _xe_sig(0, xname, w, x_signed)
                sw = "bs_%s_l%d_%d" % (out_base, m, p)
                cw = "cm_%s_l%d" % (out_base, m)
                _emit_typeA_cm_lut(f, acc[p], yh, ym, yl, x0, sw, cw)
                S_sig[p] = sw
                DI_sig[p] = acc[p]
                cyc = cw                            # negative-digit carry-in
            elif n <= w + 1:
                xen = _xe_sig(n, xname, w, x_signed)
                xnm = _xe_sig(n - 1, xname, w, x_signed)
                invert = (n == w + 1)               # inverted sign bit
                wS = "bs_%s_l%d_%d" % (out_base, m, p)
                S_sig[p] = _emit_typeA_lut(f, acc[p], yh, ym, yl, xen, xnm,
                                           invert, wS)
                DI_sig[p] = acc[p]
            else:
                S_sig[p] = acc[p]                   # propagate: S = acc, DI = 0
                DI_sig[p] = "1'b0"
        # CARRY4 chain over [lo, nb-1]
        span = nb - lo
        nC4 = (span + 3) // 4
        prev_co = None
        for c in range(nC4):
            base = lo + c * 4
            sb, db = [], []
            for k in range(4):
                p = base + k
                if p < nb:
                    sb.append(S_sig[p]); db.append(DI_sig[p])
                else:
                    sb.append("1'b0"); db.append("1'b0")
            co = "co_%s_l%d_%d" % (out_base, m, c)
            ow = "o_%s_l%d_%d" % (out_base, m, c)
            f.write("  wire [3:0] %s, %s;\n" % (co, ow))
            if c == 0:
                ci, cyinit = "1'b0", cyc
            else:
                ci, cyinit = "%s[3]" % prev_co, "1'b0"
            f.write("  CARRY4 u_cy_%s_l%d_%d (.CO(%s), .O(%s), .CI(%s), "
                    ".CYINIT(%s), .DI({%s,%s,%s,%s}), .S({%s,%s,%s,%s}));\n"
                    % (out_base, m, c, co, ow, ci, cyinit,
                       db[3], db[2], db[1], db[0], sb[3], sb[2], sb[1], sb[0]))
            for k in range(4):
                p = base + k
                if p < nb:
                    acc[p] = "%s[%d]" % (ow, k)     # new running sum bit
            prev_co = co

    f.write("  wire [%d:0] %s;\n" % (nb - 1, out_base))
    for p in range(nb):
        f.write("  assign %s[%d] = %s;\n" % (out_base, p, acc[p]))
    return nb


def gen_booth_module(name, w, h, x_signed, y_signed, pa="x", pb="y", pr="p"):
    """Standalone module  name(input [w-1:0] pa, input [h-1:0] pb,
    output [w+h-1:0] pr)  for unit testing."""
    import io
    f = io.StringIO()
    nb = h + w
    f.write("module %s (input [%d:0] %s, input [%d:0] %s, output [%d:0] %s);\n"
            % (name, w - 1, pa, h - 1, pb, nb - 1, pr))
    emit_booth_array(f, pa, pb, w, h, x_signed, y_signed, "bo")
    f.write("  assign %s = bo;\nendmodule\n" % pr)
    return f.getvalue()


# --------------------------------------------------------------------------- #
#  self-test : emulator + emitted-netlist simulation vs slice product
# --------------------------------------------------------------------------- #
def _emulate(x, y, w, h, xs, ys):
    L = booth_digits_needed(h, ys); nb = h + w
    total = sum(-(1 << (2 * m + w + 1)) for m in range(L))

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
        for n in range(0, w + 1):
            ra += (0 if z else ((xe(n - 1) if s else xe(n)) ^ c)) << n
        signbit = 0 if z else ((xe(w) if s else xe(w + 1)) ^ c)
        ra += (1 - signbit) << (w + 1)
        total += (ra + c) << (2 * m)
    return total % (1 << nb)


if __name__ == "__main__":
    import sys
    import verilog_sim as vs

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
    for (w, h, xs, ys) in [(5, 8, True, True), (7, 8, False, True),
                           (4, 6, True, False), (6, 5, False, False),
                           (3, 14, True, True)]:
        src = gen_booth_module("bmod", w, h, xs, ys, pa="a", pb="b", pr="r")
        open("/tmp/bmod.v", "w").write(src)
        mod = vs.parse("/tmp/bmod.v", w, h, w + h)
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
                    print("  RTL MISMATCH w%d h%d xs%d ys%d x%d y%d got%d exp%d"
                          % (w, h, xs, ys, xx, yy, got, exp))
    print("netlist  : %s (%d vectors)" % ("PASS" if nbad == 0 else "FAIL(%d)" % nbad, ntot))
    sys.exit(0 if (bad == 0 and nbad == 0) else 1)
