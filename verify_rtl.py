# -*- coding: utf-8 -*-
"""verify_rtl.py -- random functional test of already-generated mult.v files.

For every experiments_out/W*/ that has mult.v + report.json, parse the primitive
netlist and check N random vectors (exhaustive when total width <= 12) against the
golden product, using the design's real sign mode. Writes verify_rtl.csv.

    python verify_rtl.py [root=experiments_out] [N=10000]
"""
import csv
import glob
import json
import os
import random
import sys
import time

import verilog_sim as vs
from tiled_pysim import reference_product


def test_design(folder, n, seed=20240601):
    rep = json.load(open(os.path.join(folder, "report.json")))
    d = rep["design"]
    Wa, Wb = d["Wa"], d["Wb"]
    sa, sb = bool(d["sign_a"]), bool(d["sign_b"])
    mod = vs.parse(os.path.join(folder, "mult.v"), Wa, Wb, Wa + Wb)
    total = Wa + Wb
    rng = random.Random(seed)
    if total <= 12:
        pairs = [(x, y) for x in range(1 << Wa) for y in range(1 << Wb)]
        kind = "exhaustive"
    else:
        pairs = [(rng.randrange(1 << Wa), rng.randrange(1 << Wb)) for _ in range(n)]
        pairs += [(0, 0), ((1 << Wa) - 1, (1 << Wb) - 1),
                  (1 << (Wa - 1), 1 << (Wb - 1)), (1, 1),
                  ((1 << Wa) - 1, 0), (0, (1 << Wb) - 1)]
        kind = "random"
    bad = 0
    first = None
    for (x, y) in pairs:
        got = vs.simulate(mod, x, y)
        exp = reference_product(x, y, Wa, Wb, sa, sb)
        if got != exp:
            bad += 1
            if first is None:
                first = (x, y, got, exp)
    return Wa, Wb, d.get("mode"), len(pairs), kind, bad, first


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "experiments_out"
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 10000
    folders = sorted(glob.glob(os.path.join(root, "W*")))
    csv_path = os.path.join(root, "verify_rtl.csv")
    rows = []
    npass = nfail = nerr = 0
    for f in folders:
        if not (os.path.exists(os.path.join(f, "mult.v")) and
                os.path.exists(os.path.join(f, "report.json"))):
            continue
        tag = os.path.basename(f)
        t0 = time.time()
        try:
            Wa, Wb, mode, nv, kind, bad, first = test_design(f, n)
        except Exception as e:
            nerr += 1
            print("%-20s ERROR  %s" % (tag, str(e)[:90]))
            rows.append([tag, "", "", "", "", "", "ERROR", str(e)[:80]])
            continue
        res = "PASS" if bad == 0 else "FAIL"
        npass += (bad == 0)
        nfail += (bad != 0)
        dt = time.time() - t0
        extra = "" if bad == 0 else "  first a=%d b=%d got=%d exp=%d" % first
        print("%-20s %-4s  %s %-6d fails=%d  (%.1fs)%s"
              % (tag, res, kind, nv, bad, dt, extra))
        rows.append([tag, Wa, Wb, mode, nv, kind, res, bad])
    with open(csv_path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["tag", "Wa", "Wb", "mode", "n_vectors", "kind", "result", "fails"])
        w.writerows(rows)
    print("=" * 56)
    print("SUMMARY: %d PASS, %d FAIL, %d ERROR  (%d designs)  -> %s"
          % (npass, nfail, nerr, npass + nfail + nerr, csv_path))


if __name__ == "__main__":
    main()
