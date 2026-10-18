# -*- coding: utf-8 -*-
"""bench_B_synth.py -- synthesise the [B] benchmark compressors and collect the
numbers that can be put next to [B]'s published ones.

Measurement follows [B]: a REGISTER SANDWICH (inputs and outputs registered, the
compressor purely combinational between them) on the part [B] used for its
7 Series evaluation, xc7vh870tflg1932-2, with LUTs counted *including the
terminal adder*.  The one thing we cannot match is the tool version -- [B] used
Vivado 2023.1 and this machine has 2024.2 -- which the paper states.

Vivado must run one instance at a time; this driver is strictly sequential.

    python bench_B_synth.py                     # all generated benchmarks
    python bench_B_synth.py --part xcvc1902-vsva2197-2MP-e-S   # Versal
"""
from __future__ import print_function

import argparse
import csv
import glob
import json
import os
import subprocess
import sys
import time

SDIR = os.path.dirname(os.path.abspath(__file__))
SYNTH_BAT = os.path.join(SDIR, "synth.bat")

# the exact 7 Series part of [B] Fig. 25
PART_B_7SERIES = "xc7vh870tflg1932-2"


def read_metrics(path):
    d = {}
    if not os.path.exists(path):
        return d
    for line in open(path):
        if "=" in line:
            k, v = line.strip().split("=", 1)
            d[k] = v
    return d


def synth_one(vfile, part, smode, period, force=False):
    mfile = os.path.splitext(vfile)[0] + "_metrics.txt"
    if os.path.exists(mfile) and not force:
        return read_metrics(mfile), 0.0, "cached"
    env = dict(os.environ)
    env["PART"] = part
    t0 = time.time()
    p = subprocess.run(["cmd", "/c", SYNTH_BAT, vfile, smode, str(period)],
                       cwd=SDIR, env=env, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT)
    dt = time.time() - t0
    log = os.path.splitext(vfile)[0] + "_synth.log"
    with open(log, "w", encoding="utf-8") as fh:
        fh.write(p.stdout.decode("utf-8", "replace"))
    if not os.path.exists(mfile):
        return {}, dt, "synth_fail(rc=%d, see %s)" % (p.returncode,
                                                      os.path.basename(log))
    return read_metrics(mfile), dt, "ok"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default="bench_out")
    ap.add_argument("--part", default=PART_B_7SERIES)
    ap.add_argument("--smode", default="reg", choices=["reg", "comb"],
                    help="reg = register sandwich, as [B] measures")
    ap.add_argument("--period", type=float, default=10.0,
                    help="clock for the CPD arithmetic; synthesis itself is "
                         "not timing-driven in this flow")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--csv", default=None)
    a = ap.parse_args()

    jsons = sorted(glob.glob(os.path.join(a.dir, "bench_*.json")))
    if not jsons:
        sys.exit("no benchmarks in %s -- run bench_B.py first" % a.dir)

    out_csv = a.csv or os.path.join(
        a.dir, "results_%s_%s.csv" % (a.part.split("-")[0], a.smode))
    rows = []
    print("part=%s  mode=%s  %d benchmark(s)\n" % (a.part, a.smode, len(jsons)))

    for jf in jsons:
        rec = json.load(open(jf))
        vfile = os.path.join(a.dir, rec["verilog"])
        m, dt, status = synth_one(vfile, a.part, a.smode, a.period, a.force)
        lut = m.get("SliceLUT", "NA")
        row = {
            "shape": rec["shape"], "label": rec["label"], "mode": rec["mode"],
            "nCols": rec["nCols"], "max_height": rec["max_height"],
            "total_bits": rec["total_bits"],
            "S": rec["S"], "tree_lut_cost": rec["ct_cost"],
            "mipgap": rec["mipgap"], "solve_s": rec["solve_s"],
            "verified": rec["verified"],
            "part": a.part, "synth_mode": a.smode,
            "SliceLUT": lut, "LUTcells": m.get("LUTcells", "NA"),
            "CARRY": m.get("CARRY4", "NA"), "FF": m.get("FF", "NA"),
            "CPD_ns": m.get("CPD_ns", "NA"),
            "B_7series": (rec.get("B_7series") or {}).get("B"),
            "B_versal": (rec.get("B_versal") or {}).get("B"),
            "status": status, "synth_s": round(dt, 1),
        }
        rows.append(row)
        # Only the external mode is comparable with [B]: absorbed and gates
        # both compute the whole 16x16 product, partial-product generation
        # included, which [B]'s published numbers exclude.
        ref = row["B_7series"] if "xc7" in a.part else row["B_versal"]
        delta = ""
        if rec["mode"] != "external":
            delta = "   (not comparable with [B]: includes PP generation)"
            row["B_7series"] = row["B_versal"] = None
        elif ref and lut not in ("NA", None):
            delta = "   vs [B] %4s  = %+.1f%%" % (ref, 100.0 * (int(lut) - ref) / ref)
        print("  %-10s %-9s LUT=%-6s CARRY=%-5s CPD=%-7s %s%s"
              % (row["label"], row["mode"], lut, row["CARRY"], row["CPD_ns"],
                 status, delta))

    with open(out_csv, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        w.writeheader()
        for r in rows:
            w.writerow(r)
    print("\nwrote %s" % out_csv)


if __name__ == "__main__":
    main()
