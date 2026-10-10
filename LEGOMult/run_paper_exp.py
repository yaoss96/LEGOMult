# -*- coding: utf-8 -*-
"""run_paper_exp.py -- the three synthesis campaigns behind the paper.

Each campaign is a list of configurations; every configuration is generated
with run_tiled.py (Gurobi python) and then synthesized with Vivado through
synth.bat, and one row is appended to the campaign CSV.  Runs are resumable:
a configuration whose *_metrics.txt already exists is skipped.

    python run_paper_exp.py sota      # comparison on the device of [C]
    python run_paper_exp.py family    # 7-series / UltraScale+ / Versal
    python run_paper_exp.py wide      # ultra-wide scaling (solve time)
    python run_paper_exp.py <name> --collect-only

Campaign 'sota' reproduces the experimental setup of
  A. Boettcher, M. Kumm, "Multiplier Design Addressing Area-Delay Trade-offs by
  using DSP and Logic resources on FPGAs", ASAP 2024  (cited as [C] below):
Kintex-7 xc7k70tfbv484-3, combinational, so our LUT/CPD numbers are directly
comparable with its Table V.
"""
from __future__ import print_function

import argparse
import csv
import json
import os
import subprocess
import sys
import time

SDIR = os.path.dirname(os.path.abspath(__file__))
PYEXE = r"C:\gurobi1001\win64\python37\bin\python.exe"
# synth.bat clears the .Xil directory of whatever it runs in, so two
# concurrent campaigns on one host knock each other over.  Point
# LEGO_SYNTH_BAT at a private copy of synth.bat + synth.tcl and the
# job gets its own working directory as well.
SYNTH_BAT = os.environ.get("LEGO_SYNTH_BAT",
                           os.path.join(SDIR, "synth.bat"))
SYNTH_CWD = os.path.dirname(SYNTH_BAT)

PART_K7 = "xc7k70tfbv484-3"        # the device [C] reports on
PART_S7 = "xc7s100fgga676-2"       # the paper's edge target (SP701)
PART_USP = "xcku3p-ffva676-1-e"    # Kintex UltraScale+  (CARRY8)
PART_VER = "xcvc1902-vsva2197-2MP-e-S"   # Versal AI Core (LOOKAHEAD8)


def levels_for(W):
    """Level sets worth trying at width W.

    L_full = (W+2)//2 is the smallest level whose single band spans the whole
    encoded axis, i.e. the monolithic full-width Booth array; L_full-1 is the
    largest level that still leaves the solver a real tiling choice.
    """
    lf = (W + 2) // 2
    # Keep a short-band point (low delay), a mid point, the two widest bands
    # (low area, incl. the monolithic full-width array) and the 3..7 mix.  The
    # extended tile set offers two heights per level, so enumerating every level
    # is both redundant and the dominant cost of the sweep.
    out = [str(l) for l in (3, 4, 7) if 2 <= l <= lf]
    for l in sorted({lf - 1, lf}):
        if l >= 2 and str(l) not in out:
            out.append(str(l))
    if lf >= 3:
        out.append("mix")
    seen, uniq = set(), []
    for x in out:
        if x not in seen:
            seen.add(x)
            uniq.append(x)
    return uniq


CAMPAIGNS = {}


def _sota():
    cfgs = []
    for W in (4, 8, 16, 32):
        for mode in ("uu", "ss"):
            for dsp in (0, 1):
                # One DSP48 covers any board up to 24x17 on its own, so at
                # W <= 16 the Booth level cannot change the result (0 LUTs).
                lvs = levels_for(W) if (dsp == 0 or W > 16) else ["mix"]
                for lv in lvs:
                    cfgs.append(dict(W=W, mode=mode, dsp=dsp, levels=lv,
                                     part=PART_K7, smode="comb", period=3.0,
                                     tlim=240))
    return cfgs


def _family():
    """Portability.  The table needs the SAME design synthesised on
    each device, so one level per (W, mode) is enough: the full-width band,
    which is the level Step 1 selects for these widths anyway.  Sweeping levels
    again per device would only repeat the Section V-D sweep four times."""
    cfgs = []
    for part in (PART_S7, PART_K7, PART_USP, PART_VER):
        for W in (16, 32):
            for mode in ("uu", "ss"):
                lf = (W + 2) // 2
                lv = str(lf if mode == "uu" else lf - 1)
                cfgs.append(dict(W=W, mode=mode, dsp=0, levels=lv,
                                 part=part, smode="comb", period=3.0,
                                 tlim=240))
    return cfgs


def _wide():
    """Ultra-wide scaling.

    Ordered so the SPINE runs first -- one configuration at each of 48, 64, 96
    and 128 bits -- because that is the row set the scaling argument needs. The
    remaining sign/level/DSP points follow, so a partial run still answers the
    question rather than covering 48 bits four times.
    """
    spine, rest = [], []

    def cfg(W, mode, dsp, lv):
        return dict(W=W, mode=mode, dsp=dsp, levels=lv, part=PART_S7,
                    smode="comb", period=20.0, tlim=900)

    for W in (48, 64, 96, 128):
        spine.append(cfg(W, "ss", 0, "7"))
    for W in (48, 64, 96, 128):
        rest.append(cfg(W, "uu", 0, "7"))
        rest.append(cfg(W, "ss", 2, "7"))
        if W <= 64:
            rest.append(cfg(W, "uu", 0, "mix"))
            rest.append(cfg(W, "ss", 0, "mix"))
    return spine + rest


CAMPAIGNS["sota"] = _sota
CAMPAIGNS["family"] = _family
CAMPAIGNS["wide"] = _wide


def tag_of(c):
    return "W%d_%s_d%d_L%s_%s" % (c["W"], c["mode"], c["dsp"],
                                  c["levels"].replace(",", "").replace("-", "to"),
                                  c["part"].split("-")[0])


def read_metrics(path):
    d = {}
    if os.path.exists(path):
        with open(path) as fh:
            for line in fh:
                if "=" in line:
                    k, v = line.strip().split("=", 1)
                    d[k] = v
    return d


COLS = ["tag", "W", "mode", "dsp_budget", "levels", "part", "synth_mode",
        "gen_s", "synth_s", "step1_s", "step2_s", "ilp_total_s", "step2_S",
        "ct_lut", "est_lut", "est_LUT6", "est_LUT6_2", "est_CARRY4",
        "SliceLUT", "LUTcells", "CARRY", "DSP", "FF", "CPD_ns",
        "n_tiles", "n_dsp_tiles", "n_booth_tiles", "n_lut_tiles",
        "booth_levels", "verified", "status"]


def run_one(c, outroot, force=False):
    tag = tag_of(c)
    od = os.path.join(outroot, tag)
    if not os.path.isdir(od):
        os.makedirs(od)
    vfile = os.path.join(od, "mult.v")
    mfile = os.path.join(od, "mult_metrics.txt")
    rfile = os.path.join(od, "report.json")
    status = "ok"
    gen_s = synth_s = 0.0

    if force or not os.path.exists(vfile):
        cmd = [PYEXE, os.path.join(SDIR, "run_tiled.py"),
               "--W", str(c["W"]), "--max-dsp", str(c["dsp"]),
               "--booth-levels", c["levels"],
               "--out", vfile, "--report-json", rfile,
               "--time-limit", str(c.get("tlim", 600)),
               "--verify-samples", "300",
               # selects CARRY4 vs CARRY8; does not invoke Vivado
               "--part", c["part"]]
        if c["mode"][0] == "s":
            cmd.append("--sign-a")
        if c["mode"][1] == "s":
            cmd.append("--sign-b")
        t0 = time.time()
        p = subprocess.run(cmd, cwd=SDIR, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT)
        gen_s = time.time() - t0
        log = p.stdout.decode("utf-8", "replace")
        with open(os.path.join(od, "gen.log"), "w", encoding="utf-8") as fh:
            fh.write(log)
        if p.returncode != 0 or not os.path.exists(vfile):
            status = "gen_fail"
            print("  [%s] GENERATION FAILED (rc=%d)" % (tag, p.returncode))

    if status == "ok" and (force or not os.path.exists(mfile)):
        env = dict(os.environ)
        env["PART"] = c["part"]
        t0 = time.time()
        p = subprocess.run(["cmd", "/c", SYNTH_BAT,
                            os.path.abspath(vfile), c["smode"],
                            str(c["period"])], cwd=SYNTH_CWD, env=env,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        synth_s = time.time() - t0
        with open(os.path.join(od, "synth.log"), "w", encoding="utf-8") as fh:
            fh.write(p.stdout.decode("utf-8", "replace"))
        if not os.path.exists(mfile):
            status = "synth_fail"
            print("  [%s] SYNTH FAILED (rc=%d)" % (tag, p.returncode))

    return collect_one(c, outroot, gen_s, synth_s, status)


def collect_one(c, outroot, gen_s=0.0, synth_s=0.0, status="ok"):
    tag = tag_of(c)
    od = os.path.join(outroot, tag)
    m = read_metrics(os.path.join(od, "mult_metrics.txt"))
    rep = {}
    rp = os.path.join(od, "report.json")
    if os.path.exists(rp):
        try:
            with open(rp) as fh:
                rep = json.load(fh)
        except Exception:
            rep = {}
    t = rep.get("timing_s", {}) or {}
    s2 = rep.get("step2", {}) or {}
    est = rep.get("ilp_estimate", {}) or {}
    til = rep.get("tiling", {}) or {}
    cnt = til.get("counts", {}) or {}
    blev = til.get("booth_levels", {}) or {}
    verified = ""
    gl = os.path.join(od, "gen.log")
    if os.path.exists(gl):
        txt = open(gl, encoding="utf-8", errors="replace").read()
        if "netlist sim vs a*b : PASS" in txt:
            verified = "PASS"
        elif "FAIL" in txt:
            verified = "FAIL"
    return {
        "tag": tag, "W": c["W"], "mode": c["mode"], "dsp_budget": c["dsp"],
        "levels": c["levels"], "part": c["part"], "synth_mode": c["smode"],
        "gen_s": round(gen_s, 1), "synth_s": round(synth_s, 1),
        "step1_s": t.get("step1_ilp"), "step2_s": t.get("step2_ilp"),
        "ilp_total_s": t.get("total"),
        "step2_S": s2.get("S"), "ct_lut": s2.get("ct_lut"),
        "est_lut": est.get("est_lut_total"), "est_LUT6": est.get("LUT6"),
        "est_LUT6_2": est.get("LUT6_2"), "est_CARRY4": est.get("CARRY4"),
        "SliceLUT": m.get("SliceLUT"), "LUTcells": m.get("LUTcells"),
        "CARRY": m.get("CARRY4"), "DSP": m.get("DSP"), "FF": m.get("FF"),
        "CPD_ns": m.get("CPD_ns"),
        "n_tiles": til.get("n_tiles"), "n_dsp_tiles": cnt.get("DSP", 0),
        "n_booth_tiles": cnt.get("BOOTH", 0), "n_lut_tiles": cnt.get("LUT", 0),
        "booth_levels": ";".join("L%s:%s" % (k, v) for k, v in sorted(blev.items())),
        "verified": verified, "status": status,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("campaign", choices=sorted(CAMPAIGNS))
    ap.add_argument("--collect-only", action="store_true")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--filter", default=None,
                    help="only run configs whose tag contains this substring")
    a = ap.parse_args()

    cfgs = CAMPAIGNS[a.campaign]()
    if a.filter:
        cfgs = [c for c in cfgs if a.filter in tag_of(c)]
    outroot = os.path.join(SDIR, "revision_out", a.campaign)
    if not os.path.isdir(outroot):
        os.makedirs(outroot)
    csv_path = os.path.join(outroot, "results.csv")

    rows = []
    for i, c in enumerate(cfgs, 1):
        tag = tag_of(c)
        print("[%d/%d] %s" % (i, len(cfgs), tag), flush=True)
        if a.collect_only:
            rows.append(collect_one(c, outroot))
        else:
            rows.append(run_one(c, outroot, force=a.force))
        r = rows[-1]
        print("        SliceLUT=%s CARRY=%s DSP=%s CPD=%s est=%s tiles=%s/%s/%s %s"
              % (r["SliceLUT"], r["CARRY"], r["DSP"], r["CPD_ns"], r["est_lut"],
                 r["n_dsp_tiles"], r["n_booth_tiles"], r["n_lut_tiles"],
                 r["verified"]), flush=True)
        with open(csv_path, "w", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=COLS)
            w.writeheader()
            w.writerows(rows)
    print("\nwrote %s (%d rows)" % (csv_path, len(rows)))


if __name__ == "__main__":
    main()
