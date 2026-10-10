# -*- coding: utf-8 -*-
"""collect_Lsweep.py  --  merge the max-Booth-level sweep into one 60-row table.

Grid = 3 sizes {32x32,48x48,64x64} x 4 sign modes {uu,us,su,ss}
     x 5 max-Booth-levels {3,4,5,6,7}.

For maxL {3,4,5,6} the design folder lives under experiments_Lsweep\W..._d0_maxL{N};
for maxL 7 (== --booth-levels mix, max-dsp 0) it reuses the existing
experiments_out\W..._d0 folder.  Reads report.json (ILP times / tiling) and
*_metrics.txt (Vivado SliceLUT / CARRY4 / FF / CPD / power) from each.

Writes experiments_Lsweep\Lsweep_results.csv and prints a Markdown table.

    python collect_Lsweep.py
"""
import csv
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
LROOT = os.path.join(HERE, "experiments_Lsweep")
EROOT = os.path.join(HERE, "experiments_out")

SIZES = [(32, 32), (48, 48), (64, 64)]
MODES = ["uu", "us", "su", "ss"]
MAXLS = [3, 4, 5, 6, 7]


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


def folder_for(wa, wb, mode, ml):
    if ml == 7:
        return os.path.join(EROOT, "W%dx%d_%s_d0" % (wa, wb, mode))
    return os.path.join(LROOT, "W%dx%d_%s_d0_maxL%d" % (wa, wb, mode, ml))


def load_xpe():
    """XPE logic-power CSVs keyed by design tag (folder name).
    maxL 3-6 -> experiments_Lsweep, maxL 7 -> experiments_out (paper data)."""
    xpe = {}
    for root in (LROOT, EROOT):
        p = os.path.join(root, "xpe_logic_power.csv")
        if not os.path.exists(p):
            continue
        with open(p) as fh:
            for r in csv.DictReader(fh):
                tag = r.get("design")
                if tag:
                    xpe[tag] = {
                        "logic_W": r.get("xpe_logic_W"),
                        "total_W": r.get("xpe_total_W"),
                    }
    return xpe


XPE = load_xpe()


def fnum(x):
    try:
        return float(str(x).lstrip("<"))
    except (TypeError, ValueError):
        return None


COLS = [
    "size", "Wa", "Wb", "mode", "maxL", "booth_set",
    "slice_lut", "carry4", "ff", "cpd_ns", "fmax_mhz",
    "xpe_logic_W", "xpe_total_W",
    "vivado_pdyn_W", "vivado_ptot_W",
    "n_tiles", "n_booth_tiles", "n_lut_tiles", "booth_levels_used",
    "step1_s", "step2_s", "total_s", "ct_lut", "folder", "status",
]

BOOTH_SET = {3: "3", 4: "3-4", 5: "3-5", 6: "3-6", 7: "3-7"}


def collect_one(wa, wb, mode, ml):
    folder = folder_for(wa, wb, mode, ml)
    row = {c: "" for c in COLS}
    row.update({
        "size": "%dx%d" % (wa, wb), "Wa": wa, "Wb": wb,
        "mode": mode, "maxL": ml, "booth_set": BOOTH_SET[ml],
        "folder": os.path.relpath(folder, HERE),
    })
    rep_path = os.path.join(folder, "report.json")
    if not os.path.exists(rep_path):
        row["status"] = "MISSING"
        return row
    with open(rep_path) as fh:
        rep = json.load(fh)
    m = read_metrics(find(folder, "_metrics.txt"))

    t = rep.get("timing_s", {})
    s2 = rep.get("step2", {})
    til = rep.get("tiling", {})
    counts = til.get("counts", {}) or {}
    blev = til.get("booth_levels", {}) or {}

    cpd = fnum(m.get("CPD_ns"))
    xp = XPE.get(os.path.basename(folder), {})
    row.update({
        "slice_lut": m.get("SliceLUT", ""), "carry4": m.get("CARRY4", ""),
        "ff": m.get("FF", ""), "cpd_ns": m.get("CPD_ns", ""),
        "fmax_mhz": ("%.1f" % (1000.0 / cpd)) if cpd else "",
        "xpe_logic_W": xp.get("logic_W", ""), "xpe_total_W": xp.get("total_W", ""),
        "vivado_pdyn_W": m.get("Pdyn_W", ""), "vivado_ptot_W": m.get("Ptot_W", ""),
        "n_tiles": til.get("n_tiles", ""),
        "n_booth_tiles": counts.get("BOOTH", 0), "n_lut_tiles": counts.get("LUT", 0),
        "booth_levels_used": ";".join("L%s:%s" % (k, v) for k, v in sorted(blev.items())),
        "step1_s": t.get("step1_ilp", ""), "step2_s": t.get("step2_ilp", ""),
        "total_s": t.get("total", ""), "ct_lut": s2.get("ct_lut", ""),
        "status": "ok" if m.get("SliceLUT") else "NO_SYNTH",
    })
    return row


def main():
    rows = []
    for (wa, wb) in SIZES:
        for mode in MODES:
            for ml in MAXLS:
                rows.append(collect_one(wa, wb, mode, ml))

    if not os.path.isdir(LROOT):
        os.makedirs(LROOT)
    csv_path = os.path.join(LROOT, "Lsweep_results.csv")
    with open(csv_path, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=COLS)
        w.writeheader()
        w.writerows(rows)

    # ---- Markdown table (hardware performance) ----
    # Power column is XPE logic power (paper method), shown in mW for readability.
    def mw(x):
        v = fnum(x)
        return ("%.3f" % (v * 1000.0)) if v is not None else "-"

    md_path = os.path.join(LROOT, "Lsweep_table.md")
    hdr = ("| size | mode | maxL | SliceLUT | CARRY4 | FF | CPD(ns) | "
           "Fmax(MHz) | Plogic_XPE(mW) | Booth/LUT tiles | levels used |")
    sep = "|" + "|".join(["---"] * 11) + "|"
    lines = [hdr, sep]
    for r in rows:
        lines.append("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s/%s | %s |" % (
            r["size"], r["mode"], r["maxL"], r["slice_lut"] or "-",
            r["carry4"] or "-", r["ff"] or "-", r["cpd_ns"] or "-",
            r["fmax_mhz"] or "-", mw(r["xpe_logic_W"]),
            r["n_booth_tiles"], r["n_lut_tiles"], r["booth_levels_used"] or "-"))
    md = "\n".join(lines) + "\n"
    with open(md_path, "w") as fh:
        fh.write(md)

    done = sum(1 for r in rows if r["status"] == "ok")
    print("[collect] %d/%d designs complete" % (done, len(rows)))
    print("[collect] CSV   -> %s" % csv_path)
    print("[collect] table -> %s" % md_path)
    print()
    print(md)


if __name__ == "__main__":
    main()
