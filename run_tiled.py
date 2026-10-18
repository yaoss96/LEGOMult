"""
run_tiled.py  --  END-TO-END driver for the two-step tiling multiplier.

    Step 1 : tile the Wa x Wb board into DSP / Booth(level-L) / LUT tiles  (ILP)
    Step 2 : merge ALL tile partial products with the source LUT+CARRY4
             compressor-tree ILP, then a CARRY4 CLA forms the product.

Emits structural RTL (LUT6 / LUT6_2 / CARRY4 + DSP48) and a self-checking
testbench, prints a usage summary, and (optionally) verifies functionally with
the in-repo golden model + primitive netlist simulator.

Examples
--------
    python run_tiled.py --W 24 --booth-level 7 --max-dsp 4 --signed
    python run_tiled.py --Wa 24 --Wb 24 --booth-level 4 --max-dsp 1 --sign-a --sign-b
    python run_tiled.py --W 16 --booth-level 5 --max-dsp 0          (logic only, uu)
    python run_tiled.py --W 8  --booth-level 3 --merge greedy --no-verify

Booth level is fixed by --booth-level in {3,4,5,6,7}: ALL Booth tiles use that
level (height 2L-1 unsigned / 2L signed); every region a Booth tile can't cover
is filled with LUT+CARRY4 (and DSP) tiles.  Sign modes ss/us/su/uu via
--sign-a/--sign-b.
"""

import argparse
import json
import os
import re
import time

from tiling_ilp import solve_tiling, summarize_tiling
from carry_prim import set_carry_width, set_carry_for_part, carry_name
from merge_ilp import build_heap, solve_merge, greedy_merge, simulate_merge_state
from tiled_verilog_gen import emit_tiled_verilog, emit_tiled_testbench


def parse_args():
    p = argparse.ArgumentParser(description="Two-step DSP+Booth+LUT tiling multiplier")
    p.add_argument("--W", type=int, default=None, help="symmetric width (Wa=Wb=W)")
    p.add_argument("--Wa", type=int, default=None)
    p.add_argument("--Wb", type=int, default=None)
    p.add_argument("--booth-level", type=int, default=4,
                   help="Booth-Array level L (height 2L-1 unsigned / 2L signed). "
                        "L is not capped: L = ceil(W/2) makes a single band cover "
                        "the whole encoded axis (full-width Booth array).")
    p.add_argument("--booth-levels", type=str, default=None,
                   help="MIX Booth levels: e.g. '34567', '3,4,5,6,7', 'mix'/'all' "
                        "(=3..7), 'full' (=3..ceil(W/2), i.e. up to a full-width "
                        "band), or a range '3-16'.  Overrides --booth-level; the "
                        "ILP may use a different level per region.")
    p.add_argument("--max-dsp", type=int, default=0,
                   help="DSP48 budget for Step 1 (0 = logic only)")
    p.add_argument("--sign-a", action="store_true")
    p.add_argument("--sign-b", action="store_true")
    p.add_argument("--signed", action="store_true", help="= --sign-a --sign-b")
    p.add_argument("--merge", choices=["auto", "ilp", "greedy"], default="auto",
                   help="Step-2 method: auto = ILP then greedy fallback")
    p.add_argument("--no-lut-carry", action="store_true",
                   help="disable Table-II LUT-CarryChain compressors in the merge")
    p.add_argument("--booth-groups", dest="booth_groups", type=int, default=1,
                   help="split each Booth band's levels into this many groups, "
                        "accumulated separately and recombined in a tree. The "
                        "band is otherwise a serial ripple of L adds and is "
                        "what the critical path of a wide design is mostly "
                        "made of. 1 = the original array.")
    p.add_argument("--max-chain", dest="max_chain", type=int, default=None,
                   help="bound the length of any Step-2 carry chain, in cells. "
                        "This is the delay handle: (O2) counts LUTs only, so "
                        "without it the solver will run one chain across the "
                        "heap to save a cell and the critical path is the "
                        "carry propagating along it. Sweep it for an "
                        "area-delay front. >= 2; omit for unbounded.")
    p.add_argument("--step2-steps", "--merge-S", dest="step2_steps", type=int,
                   default=None, metavar="S",
                   help="Step-2 (merge) reduction-step budget S; default = auto. "
                        "Smaller S forces a shallower, wider tree (lower latency, "
                        "more LUTs); the solver still escalates from S if that many "
                        "steps are infeasible. Use to sweep the area-latency Pareto.")
    p.add_argument("--carry-width", type=int, default=None, choices=[4, 8],
                   help="hard-carry primitive granularity: 4 = CARRY4 "
                        "(7-series), 8 = CARRY8 (UltraScale+/Versal). "
                        "Default: inferred from --part, else 4.")
    p.add_argument("--part", type=str, default=None,
                   help="target Vivado part (e.g. xcvc1902-vsva2197-2MP-e-S). "
                        "Only used to pick the carry primitive; it does not "
                        "invoke Vivado.")
    p.add_argument("--out", type=str, default=None, help="output .v path")
    p.add_argument("--time-limit", type=int, default=600)
    p.add_argument("--mip-gap", type=float, default=1e-3)
    p.add_argument("--threads", type=int, default=8)
    p.add_argument("--tiling-gurobi", choices=["auto", "on", "off"], default="auto",
                   help="use Gurobi for Step-1 tiling (auto = try, fall back to greedy)")
    p.add_argument("--tiling-cost", choices=["colcost", "weighted_pp", "paper", "flc"],
                   default="colcost",
                   help="Step-1 objective: colcost = OIP/IGP column-aware (default); "
                        "weighted_pp = pin-weight; paper/flc = legacy")
    p.add_argument("--no-verify", action="store_true",
                   help="skip the in-repo functional verification")
    p.add_argument("--verify-samples", type=int, default=2000)
    p.add_argument("--report-json", type=str, default=None, metavar="FILE",
                   help="write a JSON report (params, Step-1/Step-2 ILP times, "
                        "ILP estimates, and the full tiling/partition) to FILE")
    p.add_argument("--quiet", action="store_true")
    return p.parse_args()


def resolve_widths(a):
    if a.Wa is not None or a.Wb is not None:
        Wa = a.Wa if a.Wa is not None else a.Wb
        Wb = a.Wb if a.Wb is not None else a.Wa
    elif a.W is not None:
        Wa = Wb = a.W
    else:
        Wa = Wb = 24
    return Wa, Wb


def count_primitives(path):
    txt = open(path).read()
    return {
        'LUT6':   len(re.findall(r'\bLUT6\b(?!_)', txt)),
        'LUT6_2': len(re.findall(r'\bLUT6_2\b', txt)),
        'CARRY4': (len(re.findall(r'\bCARRY4\b', txt))
                   + len(re.findall(r'\bCARRY8\b', txt))),
        'DSP48':  len(re.findall(r'use_dsp', txt)),
    }


def _tile_dict(t, Wa, Wb, sign_a, sign_b):
    """One tile's full placement record for the partition report."""
    sa = t.signed_a(Wa, sign_a)
    sb = t.signed_b(Wb, sign_b)
    d = {
        "kind": t.kind,                       # DSP | BOOTH | LUT
        "a_rows": [t.i0, t.i1],               # operand-a bit span (inclusive)
        "b_cols": [t.j0, t.j1],               # operand-b bit span (inclusive)
        "h": t.h, "w": t.w, "area": t.area,
        "sign_mode": ('s' if sa else 'u') + ('s' if sb else 'u'),
    }
    if t.kind == 'BOOTH':
        d["booth_level"] = t.level
        d["booth_axis"] = t.booth_axis        # which operand is Booth-encoded
        d["multiplicand_width"] = t.w if t.booth_axis == 'a' else t.h
    if t.kind in ('DSP', 'BOOTH'):
        d["out_cols"] = [t.col_offset, t.col_offset + t.h + t.w - 1]
        d["role"] = "IGP (opaque result word)"
    else:                                     # LUT residual
        d["out_cols"] = [t.i0 + t.j0, t.i1 + t.j1]
        d["role"] = "LUT residual (OIP cells)"
    return d


def _write_report(path, Wa, Wb, sign_a, sign_b, mode, a, levels,
                  tiles, tinfo, heap, merge_res, prims, modname,
                  step1_time, step2_time):
    from collections import Counter
    kinds = Counter(t.kind for t in tiles)
    blevels = Counter(t.level for t in tiles if t.kind == 'BOOTH')
    rep = {
        "design": {
            "Wa": Wa, "Wb": Wb, "mode": mode,
            "sign_a": bool(sign_a), "sign_b": bool(sign_b),
            "max_dsp": a.max_dsp, "booth_levels": levels,
            "tiling_cost": a.tiling_cost, "lut_carry": (not a.no_lut_carry),
            "step2_steps_arg": a.step2_steps,
            "max_chain": a.max_chain,
            "booth_groups": a.booth_groups,
        },
        "timing_s": {
            "step1_ilp": round(step1_time, 3),
            "step2_ilp": round(step2_time, 3),
            "total": round(step1_time + step2_time, 3),
        },
        "step1": {k: tinfo.get(k) for k in
                  ("method", "n_candidates", "formulation", "cost", "colcost",
                   "weighted_pp_cost", "booth_own_lut_cost", "solver_obj",
                   "mipgap", "status")},
        "step2": {
            "method": merge_res.get('method'),
            "S": merge_res.get('S'),
            "n_compressors": len(merge_res.get('comps', [])),
            "ct_lut": merge_res.get('ct_cost'),
            "n_chain_cells": merge_res.get('n_chain_cells'),
        },
        "heap": {
            "n_cols": heap.nCols,
            "max_height": heap.max_height(),
            "total_bits": sum(heap.total_heights()),
        },
        "ilp_estimate": {
            "LUT6": prims['LUT6'], "LUT6_2": prims['LUT6_2'],
            "CARRY4": prims['CARRY4'], "DSP48": prims['DSP48'],
            "est_lut_total": prims['LUT6'] + prims['LUT6_2'],
            "ct_lut": merge_res.get('ct_cost'),
        },
        "rtl": {"module": modname, "file": os.path.abspath(a.out)},
        "tiling": {
            "n_tiles": len(tiles),
            "counts": dict(kinds),
            "booth_levels": {str(k): v for k, v in sorted(blevels.items())},
            "tiles": [_tile_dict(t, Wa, Wb, sign_a, sign_b) for t in tiles],
        },
    }
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
    with open(path, "w") as f:
        json.dump(rep, f, indent=2)


def main():
    a = parse_args()
    Wa, Wb = resolve_widths(a)
    # Pick the hard-carry primitive before any RTL is emitted: explicit
    # --carry-width wins, else infer it from --part, else keep CARRY4.
    if a.carry_width is not None:
        set_carry_width(a.carry_width)
    elif a.part:
        set_carry_for_part(a.part)
    sign_a = a.sign_a or a.signed
    sign_b = a.sign_b or a.signed
    mode = ('s' if sign_a else 'u') + ('s' if sign_b else 'u')
    # Booth level(s): single (--booth-level) or MIXED (--booth-levels)
    # A level-L band covers 2L-1 (unsigned) / 2L (signed) rows of the encoded
    # axis, so L_full = ceil(max(Wa,Wb)/2) is the smallest level whose single
    # band spans the whole axis: at L >= L_full the tile set contains the
    # monolithic full-width Booth array as one candidate tile.
    # unsigned Y of a level-L band is 2L-1 wide, signed 2L, so the smallest
    # level that spans a W-row axis in *either* sign mode is ceil((W+1)/2).
    L_full = (max(Wa, Wb) + 2) // 2
    if a.booth_levels:
        s = a.booth_levels.strip().lower()
        if s in ('mix', 'all'):
            levels = [3, 4, 5, 6, 7]
        elif s == 'full':
            levels = list(range(3, L_full + 1))
        elif '-' in s:                      # inclusive range, e.g. '3-16'
            lo, hi = (int(x) for x in s.split('-', 1))
            levels = list(range(lo, hi + 1))
        elif ',' in s or ' ' in s:
            levels = sorted({int(x) for x in s.replace(',', ' ').split()})
        elif s.isdigit() and 2 <= int(s) <= L_full:
            # a bare number that is itself a legal level means THAT level, so
            # '17' is level 17 and not the digit pair {1, 7}.
            levels = [int(s)]
        else:                               # contiguous digits e.g. '34567'
            levels = sorted({int(c) for c in s})
    else:
        levels = [a.booth_level]
    # Drop levels whose band cannot fit the board instead of aborting, so one
    # sweep spec ('mix', 'full', '3-17', ...) is usable at every width.
    kept = [lv for lv in levels if 2 <= lv <= L_full]
    if not kept:
        raise SystemExit("no usable booth level in %s: admissible range is "
                         "2..%d for W=%d" % (levels, L_full, max(Wa, Wb)))
    if kept != levels:
        print("[Step 1] booth levels %s -> %s (L_full=%d for W=%d)"
              % (levels, kept, L_full, max(Wa, Wb)))
    levels = kept
    L_arg = levels if len(levels) > 1 else levels[0]       # int or list to solver
    Ltag = "".join(str(x) for x in levels) if len(levels) > 1 else str(levels[0])
    verbose = not a.quiet

    if a.out is None:
        base = ("tiled_mult_%db" % Wa) if Wa == Wb else ("tiled_mult_%dx%d" % (Wa, Wb))
        base += "_L%s_d%d_%s" % (Ltag, a.max_dsp, mode)
        a.out = base + ".v"
    _outdir = os.path.dirname(a.out)
    if _outdir:
        os.makedirs(_outdir, exist_ok=True)

    print("=" * 72)
    print("Two-step tiling multiplier  Wa=%d Wb=%d  booth-level(s)=%s  max_dsp=%d  "
          "sign=%s" % (Wa, Wb, Ltag, a.max_dsp, mode))
    print("=" * 72)

    # ---------------- Step 1 : tiling ----------------
    t0 = time.time()
    use_g_tiling = {'auto': True, 'on': True, 'off': False}[a.tiling_gurobi]
    tiles, tinfo = solve_tiling(Wa, Wb, sign_a, sign_b, booth_level=L_arg, cost_model=a.tiling_cost,
                                max_dsp=a.max_dsp, use_gurobi=use_g_tiling,
                                time_limit=a.time_limit, mip_gap=a.mip_gap,
                                threads=a.threads, verbose=verbose)
    step1_time = time.time() - t0
    print("\n[Step 1] %s" % summarize_tiling(tiles, Wa, Wb, tinfo))
    print("[Step 1] time %.2fs" % step1_time)

    # ---------------- Step 2 : merge ----------------
    import booth_array
    booth_array.set_groups(a.booth_groups)

    heap = build_heap(tiles, Wa, Wb, sign_a, sign_b)
    print("\n[Step 2] merge heap: %d columns, max height %d, total bits %d"
          % (heap.nCols, heap.max_height(), sum(heap.total_heights())))
    t1 = time.time()
    merge_res = None
    if a.merge in ("auto", "ilp"):
        # "auto" used to swallow this and carry on with greedy.  That produced
        # a different compressor tree while the run still exited 0 and the
        # netlist still verified, so the substitution was visible only in the
        # method field.  Both modes now fail loudly; --merge greedy is how you
        # ask for the Gurobi-free reduction.
        try:
            merge_res = solve_merge(heap, S=a.step2_steps,
                                    use_lut_carry=not a.no_lut_carry,
                                    max_chain=a.max_chain,
                                    threads=a.threads, time_limit=a.time_limit,
                                    mip_gap=a.mip_gap, verbose=verbose)
        except Exception as e:
            raise RuntimeError(
                "Step 2 ILP merge failed (%s). Pass --merge greedy to ask for "
                "the Gurobi-free reduction on purpose." % str(e)[:200])
    if merge_res is None:
        merge_res = greedy_merge(heap)
        print("[Step 2] using greedy full/half-adder reduction (Gurobi-free).")
    sim_heap = heap if merge_res['method'] == 'ilp' else heap.as_all_igp()
    ok_res, _, _ = simulate_merge_state(sim_heap, merge_res)
    step2_time = time.time() - t1
    print("[Step 2] method=%s  S=%d  compressors=%d  CT_LUT=%d  chains=%d  "
          "residue_valid=%s  (%.2fs)"
          % (merge_res['method'], merge_res['S'], len(merge_res['comps']),
             merge_res['ct_cost'], merge_res['n_chain_cells'], ok_res,
             step2_time))

    # ---------------- RTL + testbench ----------------
    modname = emit_tiled_verilog(tiles, merge_res, Wa, Wb, sign_a, sign_b, a.out)
    tb = a.out.replace(".v", "_tb.v")
    emit_tiled_testbench(Wa, Wb, modname, a.out, tb, sign_a, sign_b)
    prims = count_primitives(a.out)
    print("\n[RTL] module %s -> %s" % (modname, a.out))
    print("[RTL] testbench -> %s" % tb)
    print("[RTL] primitives: %d LUT6 + %d LUT6_2 + %d %s + %d DSP48  "
          "(~%d LUTs total)"
          % (prims['LUT6'], prims['LUT6_2'], prims['CARRY4'], carry_name(),
             prims['DSP48'],
             prims['LUT6'] + prims['LUT6_2']))

    # ---------------- machine-readable report (times, estimate, partition) ----
    if a.report_json:
        _write_report(a.report_json, Wa, Wb, sign_a, sign_b, mode, a, levels,
                      tiles, tinfo, heap, merge_res, prims, modname,
                      step1_time, step2_time)
        print("[Report] %s" % a.report_json)

    # ---------------- functional verification ----------------
    if not a.no_verify:
        import random
        import verilog_sim as vs
        from tiled_pysim import reference_product
        print("\n[Verify] simulating the generated primitive netlist ...")
        mod = vs.parse(a.out, Wa, Wb, Wa + Wb)
        rng = random.Random(2024)
        exhaustive = (Wa + Wb) <= 12
        # the pure-Python netlist sim is O(netlist) per vector; cap the vector
        # count for wide multipliers so --verify never hangs (use iverilog /
        # test_tiled.bat for heavy RTL sign-off).
        nsamp = a.verify_samples
        if Wa + Wb >= 56:
            nsamp = min(nsamp, 150)
        elif Wa + Wb >= 40:
            nsamp = min(nsamp, 400)
        if exhaustive:
            pairs = [(x, y) for x in range(1 << Wa) for y in range(1 << Wb)]
        else:
            pairs = [(rng.randrange(1 << Wa), rng.randrange(1 << Wb))
                     for _ in range(nsamp)]
            pairs += [(0, 0), ((1 << Wa) - 1, (1 << Wb) - 1),
                      (1 << (Wa - 1), 1 << (Wb - 1)), (1, 1)]
        bad = 0
        for (x, y) in pairs:
            got = vs.simulate(mod, x, y)
            exp = reference_product(x, y, Wa, Wb, sign_a, sign_b)
            if got != exp:
                if bad < 3:
                    print("   FAIL a=%d b=%d got=%d exp=%d" % (x, y, got, exp))
                bad += 1
        tag = ("exhaustive" if exhaustive else "%d random" % len(pairs))
        print("[Verify] netlist sim vs a*b : %s  (%s vectors)"
              % ("PASS" if bad == 0 else "FAIL(%d)" % bad, tag))
        if bad:
            raise SystemExit("netlist verification FAILED")

    print("\nDone. Synthesize %s in Vivado; simulate with %s (iverilog/Vivado)."
          % (a.out, tb))


if __name__ == "__main__":
    main()
