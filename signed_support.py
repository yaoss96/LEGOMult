"""
Signed-multiplier support via (modified) Baugh-Wooley.

A single, shared source of truth for sign handling, imported by the ILP solver,
the Verilog generator, and the Python verifier so all three agree exactly.

Operand model (each bit weighted, MSB negative iff that operand is signed):

    A = sum_{i=0}^{Wa-1}  sA_i * a_i * 2^i ,   sA_i = +1, except sA_{Wa-1} = -1 if sign_a
    B = sum_{j=0}^{Wb-1}  sB_j * b_j * 2^j ,   sB_j = +1, except sB_{Wb-1} = -1 if sign_b

So each partial product a_i*b_j carries sign  sigma_ij = sA_i * sB_j in {+1,-1}.
sigma_ij = -1 iff EXACTLY ONE of (i is A's signed MSB, j is B's signed MSB) holds.

Baugh-Wooley converts every negative partial product into an addition:
    -w*(a_i & b_j) = w*NAND(a_i,b_j) - w          (w = 2^{i+j})
so negative PPs become NAND cells, and a single correction constant
    K = sum_{sigma_ij=-1} 2^{i+j}
is subtracted.  Subtracting K == adding C = (-K) mod 2^{Wa+Wb} and discarding the
carry beyond bit (Wa+Wb-1).  Hence:

    A*B (mod 2^{Wa+Wb}) = [ heap of AND/NAND partial products ] + C

The bits of C land at columns {Wa-1, Wb-1, Wa+Wb-1} (some may merge by carry).
For Wa,Wb >= 4 every low correction bit sits in the CT region [3, Wa+Wb-2] and is
injected as an initial IGP; the single bit at column Wa+Wb-1 (the product sign
bit, present whenever either operand is signed) is realised by inverting the
final CLA carry-out.

Signed operands require Wa,Wb >= 4 so that no inverted PP and no correction bit
falls into the fixed LOP region (columns 0..2).  Unsigned keeps Wa,Wb >= 3.
"""


def operand_bit_sign(idx, W, signed):
    """+1 / -1 weight sign of operand bit `idx` (MSB negative iff signed)."""
    return -1 if (signed and idx == W - 1) else 1


def pp_inverted(i, j, Wa, Wb, sign_a, sign_b):
    """True iff partial product a_i*b_j is negative -> emitted as NAND."""
    return operand_bit_sign(i, Wa, sign_a) * operand_bit_sign(j, Wb, sign_b) == -1


def correction_constant(Wa, Wb, sign_a, sign_b):
    """C = (-K) mod 2^(Wa+Wb), the additive Baugh-Wooley correction.

    K = sum over negative partial products of 2^(i+j).  Unsigned operands give
    K = 0 (every cell positive), so C = 0 and this is fully backward compatible.
    """
    K = 0
    for i in range(Wa):
        for j in range(Wb):
            if pp_inverted(i, j, Wa, Wb, sign_a, sign_b):
                K += 1 << (i + j)
    total = Wa + Wb
    return (-K) % (1 << total)


def correction_bits(Wa, Wb, sign_a, sign_b):
    """Return (igp_columns, msb_correction).

    igp_columns : list of ABSOLUTE columns (one entry per set bit) in the CT
                  region [3, Wa+Wb-2] where a constant '1' must be injected as
                  an initial IGP.
    msb_correction : True iff the final result MSB (col Wa+Wb-1) must be
                     inverted (constant '1' at the top column).
    """
    C = correction_constant(Wa, Wb, sign_a, sign_b)
    total = Wa + Wb
    igp_cols = []
    msb_correction = False
    for p in range(total):
        if not ((C >> p) & 1):
            continue
        if p == total - 1:
            msb_correction = True
        elif 3 <= p <= total - 2:
            igp_cols.append(p)
        else:
            raise ValueError(
                "Baugh-Wooley correction bit at col %d falls outside the CT "
                "region for Wa=%d Wb=%d; signed operands require Wa,Wb>=4."
                % (p, Wa, Wb))
    return igp_cols, msb_correction


def validate_sign_widths(Wa, Wb, sign_a, sign_b):
    """Raise if signedness is requested at a width the framework can't model."""
    if (sign_a and Wa < 4) or (sign_b and Wb < 4):
        raise ValueError(
            "signed operands require width >= 4 (sign bit must not land in the "
            "fixed LOP region); got Wa=%d sign_a=%s, Wb=%d sign_b=%s"
            % (Wa, sign_a, Wb, sign_b))


# ---------------------------------------------------------------- self-test
def _to_signed(x, W, signed):
    return x - (1 << W) if (signed and (x >> (W - 1)) & 1) else x


def _heap_value(a_int, b_int, Wa, Wb, sign_a, sign_b):
    """Build the AND/NAND bit-heap + correction C exactly as the hardware does,
    and return its value mod 2^(Wa+Wb)."""
    a = [(a_int >> i) & 1 for i in range(Wa)]
    b = [(b_int >> j) & 1 for j in range(Wb)]
    total = Wa + Wb
    acc = 0
    for i in range(Wa):
        for j in range(Wb):
            and_bit = a[i] & b[j]
            cell = (1 - and_bit) if pp_inverted(i, j, Wa, Wb, sign_a, sign_b) else and_bit
            acc += cell << (i + j)
    acc += correction_constant(Wa, Wb, sign_a, sign_b)
    return acc % (1 << total)


def _self_test():
    ok = True
    modes = [(False, False), (True, False), (False, True), (True, True)]
    for Wa in range(4, 8):
        for Wb in range(4, 8):
            for sign_a, sign_b in modes:
                bad = 0
                for a in range(1 << Wa):
                    for b in range(1 << Wb):
                        got = _heap_value(a, b, Wa, Wb, sign_a, sign_b)
                        sa = _to_signed(a, Wa, sign_a)
                        sb = _to_signed(b, Wb, sign_b)
                        exp = (sa * sb) % (1 << (Wa + Wb))
                        if got != exp:
                            bad += 1
                tag = "%dx%d sA=%d sB=%d" % (Wa, Wb, sign_a, sign_b)
                if bad:
                    print("FAIL [%s]: %d mismatches" % (tag, bad))
                    ok = False
    for Wa in range(4, 10):
        for Wb in range(4, 10):
            for sign_a, sign_b in modes:
                correction_bits(Wa, Wb, sign_a, sign_b)
    print("Baugh-Wooley self-test:", "PASS" if ok else "FAIL")
    return ok


if __name__ == "__main__":
    import sys
    sys.exit(0 if _self_test() else 1)
