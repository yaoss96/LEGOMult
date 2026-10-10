# Measured data behind the paper

Every CSV here is the direct output of a campaign in this repo:
each row is one synthesised design, and each was verified at the
gate level against the bit-accurate model before synthesis.
Regenerate any of them by re-running the driver named below.

## `sota_kintex7.csv` (56 designs)

Table VI: all operand sizes, both sign modes, 0 and 1 DSP, on the Kintex-7 xc7k70tfbv484-3 that [C] reports on. One row per Booth level.

## `band_groups.csv` (40 designs)

Table IX: splitting a full-width Booth band into G level groups, W = 16/24/32/48, both sign modes, logic only.

## `band_groups_narrow.csv` (16 designs)

Table VI, narrow sizes: the same sweep at W = 4 and 8, where the band is too shallow for the grouping to buy anything.

## `band_groups_1dsp.csv` (10 designs)

Table VI, 1-DSP column: the same sweep at W = 32 with one DSP48.

## `device_families.csv` (16 designs)

Table VIII: one design retargeted to Spartan-7, Kintex-7, Kintex UltraScale+ and Versal AI Core.

## `ultra_wide.csv` (16 designs)

Table X: 48, 64, 96 and 128-bit operands, with Step-1 and Step-2 solve times reported separately.

## `compressor_bench_virtex7.csv` (9 designs)

Table VII: our Step 2 on the compressor-tree benchmark suite of [B], on the Virtex-7 part and under the register-sandwich convention [B] uses.

## Status

All six tables are current: every row was re-measured with the per-level cell
assignment described in the top-level README, and each design was verified at
the gate level against the bit-accurate model before synthesis.

`sota_kintex7.csv` was synthesised with Vivado 2022.2, the release closest to
the 2022.1 that the work it compares against reports; the rest use 2024.2.
Running the same 47 designs through both showed identical LUT counts and a
mean delay difference of 0.09 ns, so the two are interchangeable in practice.

## Reproducing

```bash
python run_paper_exp.py sota      # data/sota_kintex7.csv
python run_paper_exp.py family    # data/device_families.csv
python run_paper_exp.py wide      # data/ultra_wide.csv
python run_group_exp.py           # data/band_groups*.csv
python bench_B.py --shape all --mode external --out bench_out
python bench_B_synth.py           # data/compressor_bench_*.csv
```

The ILP steps need Gurobi; `--merge greedy` gives a
Gurobi-free fallback that is valid but not optimal.
Synthesis needs Vivado on PATH or `VIVADO` set.
