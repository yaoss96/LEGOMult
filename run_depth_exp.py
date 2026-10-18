# -*- coding: utf-8 -*-
"""run_depth_exp.py -- let Step 1 choose the band's level grouping under a depth
ceiling, and check that its choices track the externally swept front.

The group count is now a property of a candidate tile, so Step 1 sees both what
a grouping costs (booth_tile_cost) and how deep it leaves the band
(booth_tile_depth).  Minimising area subject to `--max-tile-depth` and sweeping
the ceiling therefore traces an area-delay front that is *optimised* at every
point, instead of being sampled by varying a parameter the model cannot see.

This is the end-to-end check of that: every design is generated, verified at the
gate level and synthesised on the device Table VI uses.

    python run_depth_exp.py --W 32 --mode uu --depths 0,200,160,128,112,96
"""
from __future__ import print_function

import argparse
import csv
import json
import os
import random
import subprocess
import sys
import time

SDIR = os.path.dirname(os.path.abspath(__file__))
SYNTH_BAT = os.path.join(SDIR, "synth.bat")
PART = "xc7k70tfbv484-3"


def verify(vf, W, sa, sb, n=25, seed=20260409):
    import verilog_sim as vs
    from tiled_pysim import reference_product
    mod = vs.parse(vf, W, W, 2 * W)
    mask = (1 << (2 * W)) - 1
    rng = random.Random(seed)
    pairs = [(0, 0), (1, 1), ((1 << W) - 1, (1 << W) - 1), (1 << (W - 1), 3)]
    pairs += [(rng.randrange(1 << W), rng.randrange(1 << W)) for _ in range(n)]
    for a, b in pairs:
        if (vs.simulate(mod, a, b) & mask) != \
                (reference_product(a, b, W, W, sa, sb) & mask):
            return False
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--W", type=int, default=32)
    ap.add_argument("--mode", default="uu")
    ap.add_argument("--depths", default="0,200,160,128,112,96",
                    help="max tile depth per point; 0 means no ceiling")
    ap.add_argument("--groups", default="1,2,3,4,6")
    ap.add_argument("--min-booth", type=int, default=0,
                    help="keep at least this many Booth bands in the "
                         "tiling; without it a tight ceiling is escaped "
                         "by choosing an all-LUT tiling instead")
    ap.add_argument("--out", default="depth_out")
    ap.add_argument("--time-limit", type=float, default=240.0)
    ap.add_argument("--threads", type=int, default=8)
    a = ap.parse_args()

    from tiling_ilp import solve_tiling
    from merge_ilp import build_heap, solve_merge, simulate_merge_state
    from tiled_verilog_gen import emit_tiled_verilog
    from tiles import booth_tile_depth

    W = a.W
    sa, sb = a.mode[0] == "s", a.mode[1] == "s"
    L = (W + 1) // 2 if sb else (W + 2) // 2
    groups = tuple(int(x) for x in a.groups.split(","))
    if not os.path.isdir(a.out):
        os.makedirs(a.out)

    rows = []
    for tok in a.depths.split(","):
        D = int(tok)
        D = None if D == 0 else D
        tag = "W%d_%s_L%d_D%s%s" % (W, a.mode, L, D or "inf",
                                    "_b%d" % a.min_booth if a.min_booth else "")
        vf = os.path.join(a.out, "mult_%s.v" % tag)
        mf = os.path.splitext(vf)[0] + "_metrics.txt"
        jf = os.path.join(a.out, "%s.json" % tag)

        if not os.path.exists(mf):
            t0 = time.time()
            tiles, info = solve_tiling(W, W, sign_a=sa, sign_b=sb,
                                       booth_level=L, max_dsp=0,
                                       booth_groups=groups, max_tile_depth=D,
                                       min_booth=a.min_booth,
                                       time_limit=a.time_limit,
                                       threads=a.threads, verbose=False)
            bands = [t for t in tiles if t.kind == "BOOTH"]
            chosen = sorted({t.groups for t in bands}) or [None]
            deepest = max([booth_tile_depth(t.level, t.groups or 1, t.h + t.w)
                           for t in bands] or [0])
            heap = build_heap(tiles, W, W, sa, sb)
            res = solve_merge(heap, use_lut_carry=True, threads=a.threads,
                              time_limit=a.time_limit, mip_gap=1e-4,
                              verbose=False)
            ok, _, _ = simulate_merge_state(heap, res)
            if not ok:
                sys.exit("merge schedule does not reproduce the heap")
            emit_tiled_verilog(tiles, res, W, W, sa, sb, vf,
                               modname="mult_%s" % tag)
            if not verify(vf, W, sa, sb):
                sys.exit("RTL MISMATCH in %s" % vf)
            json.dump({"tag": tag, "W": W, "mode": a.mode, "levels": L,
                       "max_tile_depth": D, "n_candidates": info["n_candidates"],
                       "n_tiles": len(tiles), "n_bands": len(bands),
                       "groups_chosen": chosen, "deepest_band": deepest,
                       "ct_lut": res["ct_cost"], "S": res["S"],
                       "solve_s": round(time.time() - t0, 1),
                       "verified": True}, open(jf, "w"), indent=2)
            subprocess.run(["cmd", "/c", SYNTH_BAT, vf, "comb", "3.0"],
                           cwd=SDIR, env=dict(os.environ, PART=PART),
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        m = dict(l.strip().split("=", 1) for l in open(mf) if "=" in l) \
            if os.path.exists(mf) else {}
        rec = json.load(open(jf))
        rec.update(SliceLUT=m.get("SliceLUT"), CARRY=m.get("CARRY4"),
                   CPD_ns=m.get("CPD_ns"))
        rows.append(rec)
        print("  Dmax=%-6s bands=%d groups=%-10s deepest=%-5d "
              "LUT=%-6s CPD=%-8s verified=%s"
              % (rec["max_tile_depth"], rec["n_bands"],
                 ",".join(str(g) for g in rec["groups_chosen"]),
                 rec["deepest_band"], rec.get("SliceLUT"), rec.get("CPD_ns"),
                 rec["verified"]))

    out_csv = os.path.join(a.out, "results_W%d_%s.csv" % (W, a.mode))
    keys = sorted({k for r in rows for k in r})
    with open(out_csv, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=keys)
        w.writeheader()
        for r in rows:
            w.writerow(r)
    print("\nwrote %s" % out_csv)


if __name__ == "__main__":
    main()
