# LEGOMult — A Two-Step ILP Flow for Wide FPGA Multipliers

LEGOMult synthesizes area-efficient `Wa × Wb` integer multipliers for FPGAs by
splitting compressor-tree construction into **two integer linear programs (ILPs)**
instead of one monolithic program that does not scale with operand width:

```
   ┌─────────────────────────────────────────────────────────────────────┐
   │ STEP 1  —  tiling ILP over the Wa×Wb board                           │
   │   tiles = DSP48  +  mixed-level Radix-4 Booth-array  +  LUT residuals │
   │   compression-aware cost steers the partition toward cheap heaps      │
   ├─────────────────────────────────────────────────────────────────────┤
   │ STEP 2  —  compression ILP                                            │
   │   heap = { DSP result bits, Booth residual PPs, LUT-tile AND/NAND PPs }│
   │   schedule pure-LUT + OIP-absorbing CARRY4 compressors to two rows,   │
   │   then a CARRY4 CLA forms the final product.                          │
   └─────────────────────────────────────────────────────────────────────┘
```

The emitted RTL uses **only FPGA primitives** — `LUT6`, `LUT6_2`, `CARRY4`, and a
behavioural signed/unsigned `*` carrying `(* use_dsp="yes" *)` so Vivado infers a
`DSP48` per DSP tile. Modified Baugh–Wooley arithmetic gives all four sign modes —
**ss, su, us, uu** — and rectangular operands a single synthesis path.

## Installation

```bash
python -m pip install -r requirements.txt   # gurobipy is OPTIONAL (see below)
```

* **No dependencies required** for the greedy fallback path — the core flow runs
  on the Python standard library alone.
* **Gurobi + gurobipy** (with a license) enables the exact, LUT-optimal ILP
  solves. Without it, LEGOMult prints a notice and automatically falls back to a
  deterministic greedy tiler / greedy FA-HA merge that still emits verified,
  primitive-only RTL.
* **Icarus Verilog** (`iverilog`/`vvp`) is optional, for RTL simulation of the
  generated testbench against the bundled `LUT6.v` / `LUT6_2.v` / `CARRY4.v`
  primitive models.
* **AMD/Xilinx Vivado** is optional, for out-of-context synthesis (area/timing).

## Quick start

```bash
# 16x16 unsigned, Booth level 4, logic-only, greedy (no Gurobi needed)
python run_tiled.py --W 16 --booth-level 4 --max-dsp 0 --merge greedy

# 24x24 signed, Booth level 7, up to 4 DSP48 tiles (ILP if Gurobi present)
python run_tiled.py --W 24 --booth-level 7 --max-dsp 4 --signed

# asymmetric 24x18, signed-a × unsigned-b, mixed Booth levels 3..7, 1 DSP
python run_tiled.py --Wa 24 --Wb 18 --booth-levels mix --max-dsp 1 --sign-a
```

Key flags: `--W` / `--Wa --Wb`, `--booth-level {3..7}`,
`--booth-levels {34567,mix,all,...}` (mixed levels), `--max-dsp N` (`0` = logic
only), `--sign-a`, `--sign-b`, `--signed`, `--merge {auto,ilp,greedy}`,
`--no-lut-carry` (disable Table-II chains in the merge),
`--step2-steps S` / `--merge-S S` (Step-2 merge step budget; default auto),
`--out file.v`, `--report-json FILE`, `--no-verify`.

`--step2-steps S` sets the Step-2 merge reduction-step budget. A **smaller** `S`
forces a shallower, wider compressor tree (lower latency, more LUTs); a **larger**
`S` a deeper, narrower one (fewer LUTs, more latency) — sweeping it traces the
area–latency Pareto. If the requested `S` is infeasible the solver escalates.

### Booth level (`--booth-level`, 3–7)

The Booth-Array level fixes the height of the Booth-encoded operand of every
Booth tile:

| level L | digits | height (unsigned) | height (signed) |
|:------:|:------:|:-----------------:|:---------------:|
| 3 | 3 | 5 | 6 |
| 4 | 4 | 7 | 8 |
| 5 | 5 | 9 | 10 |
| 6 | 6 | 11 | 12 |
| 7 | 7 | 13 | 14 |

LUT residual tile shapes are also bounded by the selected Booth level to keep the
Step-1 ILP tractable: level `L` enumerates every `h×w` LUT rectangle with
`1 <= h,w <= 2L-1`. After the ILP places the hard macros (`DSP`/`BOOTH`), the
residual area is reblocked into large level-bounded LUT rectangles.

The Step-1 objective minimizes the weighted number of partial products left for
Step 2. `DSP`/`BOOTH` tiles contribute internally-generated product bits (`IGP`,
weight 1: one LUT pin each); `LUT` cells contribute original-input products
(`OIP`, weight 2: two operand pins `a_i`, `b_j`).

## Single-stage baseline (`run.py`)

`run.py` is the prior single-stage compressor-tree ILP (the monolithic baseline
LEGOMult decomposes). It requires Gurobi.

```bash
python run.py --W 8  --S 4 --lut-carry            # 8x8, step budget 4
python run.py --Wa 9 --Wb 7 --S 4 --no-lut-carry  # asymmetric, pure-LUT
```

## Synthesis (`synth.bat` / `synth.tcl`)

Out-of-context Vivado synthesis of a generated `.v`, counting real
LUT/CARRY4/DSP primitives and reporting critical-path delay.

```bat
:: synth.bat [FILE.v] [MODE] [PERIOD_ns]
synth.bat tiled_mult_32b_L4_d1_ss.v         :: area + combinational CPD
synth.bat tiled_mult_32b_L4_d1_ss.v reg 3.5 :: registered timing, 3.5 ns target
```

Part / Vivado path default to Kintex-7 `xc7k70tfbv484-3`; override `PART` /
`VIVADO` before the call. `SliceLUT` (LUT-combining aware) is the area number to
report; pair it with `CPD` from a `reg`-mode run for the area–latency Pareto.

## Windows launchers (`.bat`)

`run.bat`, `run_tiled.bat`, `test.bat`, `test_tiled.bat` are Windows convenience
wrappers. They call `run_tiled.py` via a `PYEXE` variable that defaults to a
Gurobi Python install — **edit `PYEXE` at the top of each `.bat`** to point at
your own Python (e.g. `set PYEXE=python`). `test_tiled.bat` also drives
`iverilog`/`vvp` inside WSL. On Linux/macOS just call the Python scripts directly.

## Correctness / verification

The tiling decomposition is exact: for every rectangular tile,
`Σ sA_i·sB_j·a_i·b_j·2^(i+j) = slice_a × slice_b`, so summing all tiles
reproduces `a*b` for any sign mode. Verification happens at three levels:

* `tiles.py` self-test — every tile's PP model vs the exact slice product;
* `tiled_pysim.py` — full tiling+merge+CLA vs `a*b` (exhaustive for small sizes,
  random otherwise), modes ss/us/su/uu;
* `verilog_sim.py` / `run_tiled.py --verify` — simulates the generated primitive
  netlist vs `a*b` (exhaustive ≤12-bit total, random otherwise).

Unit tests:

```bash
python -m pytest tests/
```

For RTL sign-off, run `test_tiled.bat` (iverilog) or simulate the emitted `*_tb.v`
in Vivado.

## File overview

| file | role |
|------|------|
| `run_tiled.py` | end-to-end two-step driver (Step1→Step2→RTL→TB→verify) |
| `tiles.py` | tile set (DSP, Booth level-L, level-bounded LUT residuals) + exact PP model |
| `tiling_ilp.py` | **Step 1** set-partition tiling ILP (Gurobi) + greedy fallback |
| `merge_ilp.py` | **Step 2** LUT+CARRY4 compressor-tree ILP + greedy FA/HA fallback |
| `booth_array.py` | radix-4 Booth ARRAY (LUT6 encode + CARRY4 accumulate) |
| `tiled_verilog_gen.py` | structural RTL: DSP48 + Booth arrays + merge LUT6_2/CARRY4 |
| `tiled_pysim.py` | Python golden model (tiling→heap→reduction→CLA) checked vs `a*b` |
| `verilog_sim.py` | primitive-level netlist simulator (`LUT6`/`LUT6_2`/`CARRY4`/DSP) |
| `verify_python.py`, `verify_rtl.py` | functional verification helpers |
| `run.py` | single-stage compressor-tree ILP baseline |
| `compressors.py`, `signed_support.py`, `verilog_gen.py`, `ilp_solver.py` | shared compressor library, Baugh–Wooley sign support, RTL emitters, single-stage ILP |
| `generate_exhaustive_tb.py` | exhaustive Verilog testbench generator |
| `LUT6.v`, `LUT6_2.v`, `CARRY4.v` | primitive simulation models for iverilog |

## License

MIT — see `LICENSE`.
