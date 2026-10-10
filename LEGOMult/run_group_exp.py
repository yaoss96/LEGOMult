# -*- coding: utf-8 -*-
"""run_group_exp.py -- is the Booth level-group win stable across widths and
sign modes, or is it one lucky point?

A Booth band accumulates its L levels serially, one carry-propagate add per
level, so a wide band is a long ripple and that ripple is most of the critical
path of a logic-only design.  `booth_array.set_groups(G)` splits the levels into
G groups accumulated separately and recombined in a tree, trading G-1 extra
adds per band for a depth of L/G + ceil(log2 G) instead of L.

Measured at 32x32 unsigned the trade was strongly favourable on the full-width
band (CPD -54% for +27% LUTs at G=4) and poor on the many-small-band tiling
(CPD -9% for +41%).  This campaign checks the first case across widths and both
sign modes before any of it is written up.

Step 1 is solved once per (W, mode) and held fixed across G, so the numbers
isolate the band structure.  Resumable: anything already synthesised is skipped.

    python run_group_exp.py --widths 16,24,32,48 --groups 1,2,3,4,6
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
PART = "xc7k70tfbv484-3"            # the device of [33], as Table VI uses


def full_level(W, signed):
    """Levels in a band that spans the whole operand."""
    return (W + 1) // 2 if signed else (W + 2) // 2


def read_metrics(path):
    if not os.path.exists(path):
        return {}
    return dict(l.strip().split("=", 1) for l in open(path) if "=" in l)


def verify(vf, W, sign_a, sign_b, n=40, seed=20260408):
    """Gate-level check against the framework's own reference product.

    The operands are two's complement in the signed modes, so a plain a*b is
    the wrong reference there -- which is how the first run of this campaign
    "failed" on an unmodified design.
    """
    import verilog_sim as vs
    from tiled_pysim import reference_product
    mod = vs.parse(vf, W, W, 2 * W)
    mask = (1 << (2 * W)) - 1
    rng = random.Random(seed)
    pairs = [(0, 0), (1, 1), ((1 << W) - 1, (1 << W) - 1), (1 << (W - 1), 3)]
    pairs += [(rng.randrange(1 << W), rng.randrange(1 << W)) for _ in range(n)]
    for a, b in pairs:
        want = reference_product(a, b, W, W, sign_a, sign_b)
        if (vs.simulate(mod, a, b) & mask) != (want & mask):
            return False, len(pairs)
    return True, len(pairs)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--widths", default="16,24,32,48")
    ap.add_argument("--modes", default="uu,ss")
    ap.add_argument("--groups", default="1,2,3,4,6")
    ap.add_argument("--max-dsp", type=int, default=0)
    ap.add_argument("--out", default="group_out")
    ap.add_argument("--time-limit", type=float, default=240.0)
    ap.add_argument("--threads", type=int, default=8)
    ap.add_argument("--verify", type=int, default=40)
    ap.add_argument("--csv", default=None)
    a = ap.parse_args()

    widths = [int(x) for x in a.widths.split(",")]
    modes = a.modes.split(",")
    groups = [int(x) for x in a.groups.split(",")]
    if not os.path.isdir(a.out):
        os.makedirs(a.out)
    out_csv = a.csv or os.path.join(a.out, "results_d%d.csv" % a.max_dsp)

    from tiling_ilp import solve_tiling
    from merge_ilp import build_heap, solve_merge, greedy_merge
    from merge_ilp import simulate_merge_state
    from tiled_verilog_gen import emit_tiled_verilog
    import booth_array

    rows = []
    for W in widths:
        for mode in modes:
            sa, sb = mode[0] == "s", mode[1] == "s"
            L = full_level(W, sb)
            print("\n=== W=%d %s  full-width band, L=%d ===" % (W, mode, L))
            t0 = time.time()
            tiles, _ = solve_tiling(W, W, sign_a=sa, sign_b=sb, booth_level=L,
                                    max_dsp=a.max_dsp,
                                    time_limit=a.time_limit,
                                    threads=a.threads, verbose=False)
            heap = build_heap(tiles, W, W, sa, sb)
            print("  Step 1: %d tiles in %.1f s; heap max height %d"
                  % (len(tiles), time.time() - t0, heap.max_height()))

            for G in groups:
                tag = "W%d_%s_L%d_d%d_g%d" % (W, mode, L, a.max_dsp, G)
                vf = os.path.join(a.out, "mult_%s.v" % tag)
                mf = os.path.splitext(vf)[0] + "_metrics.txt"
                jf = os.path.join(a.out, "%s.json" % tag)

                if not os.path.exists(mf):
                    booth_array.set_groups(G)
                    t1 = time.time()
                    try:
                        res = solve_merge(heap, use_lut_carry=True,
                                          threads=a.threads,
                                          time_limit=a.time_limit,
                                          mip_gap=1e-4, verbose=False)
                    except Exception as e:                       # noqa: BLE001
                        print("  G=%-2d merge failed: %s" % (G, str(e)[:60]))
                        continue
                    ok, _, _ = simulate_merge_state(heap, res)
                    if not ok:
                        sys.exit("merge schedule does not reproduce the heap")
                    emit_tiled_verilog(tiles, res, W, W, sa, sb, vf,
                                       modname="mult_%s" % tag)
                    gen_s = time.time() - t1
                    vok, nvec = (None, 0)
                    if a.verify:
                        vok, nvec = verify(vf, W, sa, sb, a.verify)
                        if not vok:
                            sys.exit("RTL MISMATCH in %s" % vf)
                    json.dump({"tag": tag, "W": W, "mode": mode, "levels": L,
                               "max_dsp": a.max_dsp,
                               "groups": G, "S": res["S"],
                               "ct_lut": res["ct_cost"],
                               "mipgap": res["mipgap"],
                               "gen_s": round(gen_s, 1),
                               "verified": vok, "n_vectors": nvec},
                              open(jf, "w"), indent=2)
                    env = dict(os.environ, PART=PART)
                    subprocess.run(["cmd", "/c", SYNTH_BAT, vf, "comb", "3.0"],
                                   cwd=SDIR, env=env, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT)

                m = read_metrics(mf)
                rec = json.load(open(jf)) if os.path.exists(jf) else {"tag": tag}
                rec.update(part=PART, SliceLUT=m.get("SliceLUT"),
                           CARRY=m.get("CARRY4"), CPD_ns=m.get("CPD_ns"))
                rows.append(rec)
                print("  G=%-2d LUT=%-6s CARRY=%-5s CPD=%-8s verified=%s"
                      % (G, rec.get("SliceLUT"), rec.get("CARRY"),
                         rec.get("CPD_ns"), rec.get("verified")))

    if rows:
        keys = sorted({k for r in rows for k in r})
        with open(out_csv, "w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(fh, fieldnames=keys)
            w.writeheader()
            for r in rows:
                w.writerow(r)
        print("\nwrote %s" % out_csv)


if __name__ == "__main__":
    main()
