# -*- coding: utf-8 -*-
"""collect_results.py  --  append one CSV row for a finished design folder.

Reads <folder>/report.json (run_tiled.py: times, ILP estimate, full tiling) and
<folder>/*_metrics.txt (synth.tcl: SliceLUT / CPD / power) and appends a row to
the master results.csv.

    python collect_results.py <design_folder> <results.csv>
"""
import csv
import json
import os
import sys


def find(folder, suffix):
    if not os.path.isdir(folder):
        return None
    for f in sorted(os.listdir(folder)):
        if f.endswith(suffix):
            return os.path.join(folder, f)
    return None


def read_metrics(path):
    d = {}
    if path and os.path.exists(path):
        with open(path) as fh:
            for line in fh:
                if "=" in line:
                    k, v = line.strip().split("=", 1)
                    d[k] = v
    return d


COLS = [
    "tag", "Wa", "Wb", "mode", "max_dsp",
    "step1_s", "step2_s", "total_s",
    "step2_S", "ct_lut", "est_lut_total", "est_LUT6", "est_LUT6_2",
    "est_CARRY4", "est_DSP",
    "slice_lut", "carry4", "dsp", "ff", "cpd_ns",
    "p_logic_W", "p_lut_W", "p_signals_W", "p_dsp_W", "p_dyn_W", "p_total_W",
    "n_tiles", "n_dsp_tiles", "n_booth_tiles", "n_lut_tiles", "booth_levels",
    "synth_mode", "rtl_file",
]


def main():
    folder = sys.argv[1]
    csv_path = sys.argv[2]
    rep_path = os.path.join(folder, "report.json")
    rep = {}
    if os.path.exists(rep_path):
        with open(rep_path) as fh:
            rep = json.load(fh)
    m = read_metrics(find(folder, "_metrics.txt"))

    d = rep.get("design", {})
    t = rep.get("timing_s", {})
    s2 = rep.get("step2", {})
    est = rep.get("ilp_estimate", {})
    til = rep.get("tiling", {})
    counts = til.get("counts", {}) or {}
    blev = til.get("booth_levels", {}) or {}

    row = {
        "tag": os.path.basename(os.path.normpath(folder)),
        "Wa": d.get("Wa"), "Wb": d.get("Wb"), "mode": d.get("mode"),
        "max_dsp": d.get("max_dsp"),
        "step1_s": t.get("step1_ilp"), "step2_s": t.get("step2_ilp"),
        "total_s": t.get("total"),
        "step2_S": s2.get("S"), "ct_lut": s2.get("ct_lut"),
        "est_lut_total": est.get("est_lut_total"),
        "est_LUT6": est.get("LUT6"), "est_LUT6_2": est.get("LUT6_2"),
        "est_CARRY4": est.get("CARRY4"), "est_DSP": est.get("DSP48"),
        "slice_lut": m.get("SliceLUT"), "carry4": m.get("CARRY4"),
        "dsp": m.get("DSP"), "ff": m.get("FF"), "cpd_ns": m.get("CPD_ns"),
        "p_logic_W": m.get("Plogic_W"), "p_lut_W": m.get("Plut_W"),
        "p_signals_W": m.get("Psignals_W"), "p_dsp_W": m.get("Pdsp_W"),
        "p_dyn_W": m.get("Pdyn_W"), "p_total_W": m.get("Ptot_W"),
        "n_tiles": til.get("n_tiles"),
        "n_dsp_tiles": counts.get("DSP", 0),
        "n_booth_tiles": counts.get("BOOTH", 0),
        "n_lut_tiles": counts.get("LUT", 0),
        "booth_levels": ";".join("L%s:%s" % (k, v) for k, v in blev.items()),
        "synth_mode": m.get("mode"),
        "rtl_file": (rep.get("rtl", {}) or {}).get("file"),
    }

    exists = os.path.exists(csv_path)
    with open(csv_path, "a", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=COLS)
        if not exists:
            w.writeheader()
        w.writerow(row)
    print("[collect] appended %s -> %s" % (row["tag"], csv_path))


if __name__ == "__main__":
    main()
