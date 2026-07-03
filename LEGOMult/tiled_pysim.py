"""
tiled_pysim.py  --  end-to-end Python golden model & verifier for the
two-step (tiling + LUT+CARRY4 merge) multiplier.

It simulates EXACTLY what the generated hardware computes:

  1. each tile produces its partial-product bits (LUT-tile AND/NAND cells,
     Booth radix-4 rows, DSP slice-product wires)   -> the merged heap;
  2. the merge compressor schedule reduces the heap, every compressor being
     evaluated arithmetically (sum = bit0, carry = bit1, carry2 = bit2 of the
     popped column bit-count) -- the same function its LUT6_2/CARRY4 realises;
  3. the final <=2-row residue is added (the CLA) to form the product.

The result is compared to the reference a*b (two's-complement for signed axes)
for sign modes ss / us / su / uu.  Used both as a standalone checker and by the
end-to-end driver run_tiled.py.

NOTE: the bit-level compressor simulation here models the PURE compressors
(Table I) and the greedy FA/HA fallback.  The LUT-CarryChain compressors
(Table II) are an area optimisation that conserves the same column weights; they
are exercised by the generated RTL under the user's iverilog/Vivado flow
(test_tiled.bat).  Pass use_lut_carry=False (default for verification) to keep
the golden model self-contained.
"""

from tiles import slice_value
from merge_ilp import build_heap, solve_merge, greedy_merge


def reference_product(a, b, Wa, Wb, sign_a, sign_b):
    """Signed/unsigned reference product, reduced mod 2^(Wa+Wb)."""
    av = slice_value(a, 0, Wa - 1, Wa, sign_a)
    bv = slice_value(b, 0, Wb - 1, Wb, sign_b)
    return (av * bv) % (1 << (Wa + Wb))


def compute_dsp_wires(tiles, a, b, Wa, Wb, sign_a, sign_b):
    """Opaque tile output bits (DSP and Booth-array), named as tile_heap_bits
    expects: <prefix>_<i0>_<j0>_<bit>.  Both compute the slice product X*Y."""
    wires = {}
    for t in tiles:
        if t.kind not in ('DSP', 'BOOTH'):
            continue
        prefix = 'dsp' if t.kind == 'DSP' else 'booth'
        sa = t.signed_a(Wa, sign_a)
        sb = t.signed_b(Wb, sign_b)
        va = slice_value(a, t.i0, t.i1, Wa, sa)
        vb = slice_value(b, t.j0, t.j1, Wb, sb)
        nb = t.h + t.w
        field = (va * vb) & ((1 << nb) - 1)
        for bi in range(nb):
            wires['%s_%d_%d_%d' % (prefix, t.i0, t.j0, bi)] = (field >> bi) & 1
    return wires


def _seed_pools(heap, a, b, dsp_wires):
    """Return oip_val[(0,col)] and igp_val[(0,col)] lists of evaluated bits."""
    oip = {}
    igp = {}
    for col in range(heap.nCols):
        ol = []
        for (kind, i, j) in heap.oip[col]:
            ab = ((a >> i) & 1) & ((b >> j) & 1)
            ol.append((1 - ab) if kind == 'OIP_INV' else ab)
        oip[(0, col)] = ol
        igp[(0, col)] = [be.eval(a, b, dsp_wires) for be in heap.igp[col]]
    return oip, igp


def simulate_product(heap, merge_res, a, b, Wa, Wb, dsp_wires):
    """Bit-level simulate the pure-compressor schedule + CLA -> product int."""
    from compressors import all_compressors
    lib = all_compressors(use_lut_carry=True)   # specs only; chains unused here
    nCols = heap.nCols
    S = merge_res['S']
    oip, igp = _seed_pools(heap, a, b, dsp_wires)
    for s in range(1, S + 1):
        for col in range(nCols):
            oip[(s, col)] = []
            igp[(s, col)] = []

    by = {}
    for c in merge_res['comps']:
        by.setdefault((c['step'], c['col']), []).append(c['kid'])

    for s in range(S):
        # snapshot remaining-after-consumption; we pop from current-step pools
        for col in range(nCols):
            for kid in by.get((s, col), []):
                sp = lib[kid]
                if kid.startswith('c'):
                    raise NotImplementedError(
                        "bit-level golden models pure compressors only; run the "
                        "merge with use_lut_carry=False for verification.")
                ones = 0
                for _ in range(sp['oip_c']):
                    ones += oip[(s, col)].pop()
                for _ in range(sp['igp_c']):
                    ones += igp[(s, col)].pop()
                for _ in range(sp['igp_n']):
                    # an IGP_N input is a bit from column j+1 (weight 2^(j+1)),
                    # so it counts as 2 in this column's bit-sum (cf. the
                    # IGP_N case of verilog_gen.compute_init).
                    ones += 2 * igp[(s, col + 1)].pop()
                # outputs
                if sp['gen_c']:
                    igp[(s + 1, col)].append(ones & 1)
                if sp['gen_n'] and col + 1 < nCols:
                    igp[(s + 1, col + 1)].append((ones >> 1) & 1)
                if sp['gen_2n'] and col + 2 < nCols:
                    igp[(s + 1, col + 2)].append((ones >> 2) & 1)
        # carry unconsumed bits forward to next step
        for col in range(nCols):
            oip[(s + 1, col)].extend(oip[(s, col)])
            igp[(s + 1, col)].extend(igp[(s, col)])

    # CLA: residue has <=2 bits per column -> add the (<=2) rows with carry
    carry = 0
    result = 0
    for col in range(nCols):
        bits = oip[(S, col)] + igp[(S, col)]
        total = sum(bits) + carry
        result |= (total & 1) << col
        carry = total >> 1
    return result % (1 << nCols)


# --------------------------------------------------------------------------- #
#  Verification entry points
# --------------------------------------------------------------------------- #
def verify_config(Wa, Wb, sign_a, sign_b, booth_level, max_dsp,
                  tiles=None, merge_res=None, heap=None,
                  use_gurobi=False, n_random=2000, exhaustive_limit=12,
                  verbose=True):
    """Build (or accept) a tiling+merge and check it against a*b.  Returns
    (ok, n_checked, first_failure_or_None)."""
    from tiling_ilp import solve_tiling
    if tiles is None:
        tiles, _ = solve_tiling(Wa, Wb, sign_a, sign_b, booth_level, max_dsp,
                                use_gurobi=use_gurobi, verbose=False)
    if heap is None:
        heap = build_heap(tiles, Wa, Wb, sign_a, sign_b)
    if merge_res is None:
        if use_gurobi:
            merge_res = solve_merge(heap, use_lut_carry=False, verbose=False)
        else:
            merge_res = greedy_merge(heap)
    # The greedy fallback treats every bit as IGP (its RTL pre-realises each
    # LUT-tile AND cell as one LUT); simulate against the all-IGP heap view.
    sim_heap = heap if merge_res.get('method') == 'ilp' else heap.as_all_igp()

    import random
    rng = random.Random(1234)
    if Wa + Wb <= exhaustive_limit:
        pairs = [(a, b) for a in range(1 << Wa) for b in range(1 << Wb)]
    else:
        pairs = [(rng.randrange(1 << Wa), rng.randrange(1 << Wb))
                 for _ in range(n_random)]
        corners = [0, 1, (1 << Wa) - 1, 1 << (Wa - 1)]
        cornerb = [0, 1, (1 << Wb) - 1, 1 << (Wb - 1)]
        pairs += [(x, y) for x in corners for y in cornerb]

    n = 0
    for a, b in pairs:
        dsp_wires = compute_dsp_wires(tiles, a, b, Wa, Wb, sign_a, sign_b)
        got = simulate_product(sim_heap, merge_res, a, b, Wa, Wb, dsp_wires)
        exp = reference_product(a, b, Wa, Wb, sign_a, sign_b)
        n += 1
        if got != exp:
            if verbose:
                print("  FAIL a=%d b=%d got=%d exp=%d (Wa%d Wb%d sa%d sb%d)"
                      % (a, b, got, exp, Wa, Wb, sign_a, sign_b))
            return False, n, (a, b, got, exp)
    return True, n, None


def verify_all_sign_modes(Wa, Wb, booth_level, max_dsp,
                          use_gurobi=False, n_random=1500, verbose=True):
    modes = [(False, False, 'uu'), (False, True, 'us'),
             (True, False, 'su'), (True, True, 'ss')]
    all_ok = True
    for sa, sb, tag in modes:
        if (sa and Wa < 4) or (sb and Wb < 4):
            continue
        ok, n, fail = verify_config(Wa, Wb, sa, sb, booth_level, max_dsp,
                                    use_gurobi=use_gurobi, n_random=n_random,
                                    verbose=verbose)
        if verbose:
            print("  %s  %s : %d checks" % (tag, "PASS" if ok else "FAIL", n))
        all_ok = all_ok and ok
    return all_ok


if __name__ == "__main__":
    import sys
    Wa = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    Wb = int(sys.argv[2]) if len(sys.argv) > 2 else Wa
    L = int(sys.argv[3]) if len(sys.argv) > 3 else 4
    md = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    use_g = (sys.argv[5] == 'ilp') if len(sys.argv) > 5 else False
    print("=== golden verify %dx%d booth-level=%d max_dsp=%d merge=%s ===" %
          (Wa, Wb, L, md, 'ilp' if use_g else 'greedy'))
    ok = verify_all_sign_modes(Wa, Wb, L, md, use_gurobi=use_g)
    print("ALL:", "PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)
