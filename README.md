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

* **Gurobi + gurobipy** (with a license) is what the paper measures. Both ILPs
  **fail loudly** if it is missing or a solve dies: they do not fall back.
  A silent substitution is indistinguishable from success — the run still exits
  0 and the netlist still verifies — while the design it reports is not the one
  the method produces.
* **The greedy path is opt-in**, via `--tiling-gurobi off --merge greedy`. It
  needs no dependencies beyond the standard library and still emits verified,
  primitive-only RTL, but its numbers are not the paper's.
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

`MODE` is `comb`, `reg` or `impl`. `comb` and `reg` stop after synthesis, which
is optimistic by roughly a third on delay; `impl` carries on through
`place_design` and `route_design`, which is what you need to compare against
work that reports implemented numbers.

**Calling Vivado directly:** use `synth_warm.tcl`, not `synth.tcl`.

```bash
vivado -mode batch -source synth_warm.tcl -tclargs mult.v xc7s100fgga676-2 reg 20.0
```

A fresh `vivado -mode batch` session fails its *first* `synth_design` with
`couldn't read file ".../unimacro/unimacro_vhdl.tcl": No error`, because the
helper process that spawns child Vivados is not ready yet. `synth_warm.tcl`
absorbs that with a throw-away synthesis and then sources `synth.tcl`
unchanged. `synth.bat` already does its own warm-up, so it needs no wrapper.

## Windows launchers (`.bat`)

`run.bat`, `run_tiled.bat`, `test.bat`, `test_tiled.bat` are Windows convenience
wrappers. They take the interpreter from **`LEGO_PYEXE`**, which must point at
a Python that can import `gurobipy`, and refuse to start if it is unset or
missing. `run_paper_exp.py` reads the same variable and additionally probes the
import, so a wrong interpreter is rejected up front rather than hours later in
the numbers.

```bat
set LEGO_PYEXE=C:\gurobi1001\win64\python37\bin\python.exe
```

```bash
export LEGO_PYEXE=/opt/gurobi1001/linux64/bin/python3.7
```

`test_tiled.bat` also drives `iverilog`/`vvp` inside WSL. On Linux/macOS just
call the Python scripts directly.

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

## How many LUTs a Booth level really costs

A level of a band is one LUT6 per row bit, each driving the propagate input of
one carry bit. Two details decide how many row bits there are, and both are
worth about three percent of a 32-bit design.

**Row width depends on the multiplicand's sign.** A level contributes `d·X`
with the radix-4 digit `d ∈ {-2..2}`. For a two's-complement multiplicand that
value fits in `w+1` bits, so the row's most significant bit *is* its sign and
the folded Baugh–Wooley complement goes there. For an unsigned multiplicand
`2X` alone already needs `w+1` bits, so the sign takes a cell of its own and
the row is `w+2` wide. Taking the unsigned width in both modes spends one LUT
per level for nothing. `booth_array.row_top(w, x_signed)` is the one place
this is decided; `set_narrow_signed_row(False)` restores the wide row if you
want to measure the difference.

**The companion LUT5 is free, so two row bits can share a LUT6.** A LUT6 is
two LUT5s over five shared inputs. A cell needs its own LUT5 for the
propagate term, but the carry cell's *data* input is the running sum, which is
already a signal and reaches the carry logic through the slice bypass — so the
second LUT5 is unused. Two adjacent row bits therefore occupy one LUT6 site
whenever they are together a function of five inputs or fewer, and both halves
keep the carry chain because each LUT5 still drives its own carry bit. Two
places in a band qualify:

| where | why it fits in five inputs | 32×32 |
|---|---|---|
| the first digit | the recoding window's low member is zero and the running sum is still the folding constant: 2 window bits + 3 multiplicand bits | 34 → 17 cells |
| the last digit of an **unsigned** multiplier | the window is constant but for the operand's top bit, so the row is a plain AND: 1 + 2 multiplicand bits + 2 accumulated bits | 32 → 16 cells |

Everywhere else the window, two multiplicand bits and two accumulated bits
come to eight and the cells stay apart. `_pair_support()` takes the support
from the truth table rather than from the symbols, because a row bit is
*written* as a function of both `x_n` and `x_{n-1}` even where the digit
cannot select the shifted operand — counting symbols misses the last-digit
case. `set_pair_cells(False)` turns the pairing off.

Measured on the Kintex-7 xc7k70tfbv484-3, logic only, combinational:

| 32×32 | plain | narrow row | pairing | both |
|---|---|---|---|---|
| unsigned | 576 | 576 | 543 | **543** |
| signed | 544 | 528 | 527 | **512** |

**Both changes are exact** and are covered by the regression in
`python booth_array.py`: the emulator is checked exhaustively (2,072,640 cases
over `w ≤ 7`, `h ≤ 10`, all four sign modes) and the emitted netlist is
simulated against `a*b`.

Because neither property is uniform over the tile set, the structural term of
the Step-1 cost is no longer the closed form `L(k+1)`. `booth_tile_cost()`
calls `booth_array.band_lut_cost()`, which runs the emitter's cell assignment
and memoises the answer, so the tiling program prices the cost the netlist
will actually have. The saving falls on the ends of a band, which is why it
favours few wide bands over many narrow ones.

## Area--delay control: Booth band level grouping

A Booth band's Type-A LUT fuses the Booth select with the addition into the
running sum. That is what makes a level cost one LUT per multiplicand bit --
and what makes the `L` levels strictly serial, so a full-width band on a 32-bit
operand is seventeen carry-propagate adds deep. On a logic-only design that
depth, not the compressor tree and not the final adder, is most of the critical
path: bounding every Step-2 carry chain from 34 cells to 2 moves the measured
32x32 delay by 1.4%, while splitting the band moves it by 54%.

`--booth-groups G` splits the levels into `G` groups, each accumulated on its
own chain, the group sums recombined in a tree:

| | cost | depth |
|---|---|---|
| `G = 1` (the plain array) | `band_lut_cost()` LUTs (see above) | `L` adds |
| `G` groups | `+ (G-1)(nb-L)` LUTs | `⌈L/G⌉ + ⌈log2 G⌉` adds |

`G = 1` emits the identical netlist, which is how the change is regression
tested (`python booth_array.py` runs both the emulator and the emitted netlist
exhaustively, for `G = 1..4`).

The grouping is a property of a **candidate tile**, not a global switch, so
Step 1 prices it: `solve_tiling(..., booth_groups=(1,2,3,4,6),
max_tile_depth=D)` keeps only candidates whose band fits under `D` and
minimises area over the rest. Sweeping `D` traces an area--delay front every
point of which is optimal for its own depth:

```bash
python run_depth_exp.py --W 32 --mode uu --depths 0,200,160,128,112,96 \
                        --min-booth 1
```

Measured on the Kintex-7, the trade improves monotonically with operand width:
at 16 bits `G = 4` costs about +49% LUTs for -40% delay, and at 48 bits +19%
for -61%. It is therefore worth little on narrow operands. `--min-booth 1` is
needed at tight depth bounds because the bound constrains the **band only** --
without it the solver escapes by choosing an all-LUT tiling, whose Step-2
program does not solve at 32 bits.

## Compressor-tree benchmark (`bench_B.py`)

Step 2 on its own is a bit-heap compressor generator, so it can be compared
directly against that literature. `bench_B.py` runs it on the published
benchmark shapes of Hoßfeld *et al.* (ACM TRETS 17(2):30, 2024) -- `(128)`,
`(256)`, `(512)`, `(128,128)`, `(256,256)`, `(512,512)` and `Mul16` -- and
emits RTL with the `(a, b, r)` port convention the rest of the flow uses, so
`synth.tcl` and `verilog_sim.py` work on it unchanged.

```bash
python bench_B.py --shape all --mode external --out bench_out
python bench_B_synth.py --part xc7vh870tflg1932-2 --smode reg
```

Three input modes, and **only the first is comparable with published numbers**:

* `external` -- every matrix bit is a primary input, which is what that
  literature measures.
* `absorbed` -- `Mul16` as a real 16x16 multiplication with the AND gates
  consumed inside the compressor LUTs (the ungenerated partial products).
* `gates` -- the same multiplication with the AND gates materialised.

`absorbed` and `gates` both include partial-product generation, which the
published numbers exclude; they are comparable with *each other*, and that pair
is what measures absorption (396 -> 189 LUTs, a 52.3% reduction).
`bench_B_synth.py` refuses to print a comparison for them.

## Carry primitives across fabrics (`carry_prim.py`)

One module decides the carry primitive for the whole flow, so a design can be
retargeted without touching the ILPs: `CARRY4` on 7-series, `CARRY8` on
UltraScale+, and `LOOKAHEAD8` on Versal. `run_tiled.py --part <part>` selects
it. Two traps worth knowing:

* `CARRY8` needs `CARRY_TYPE("SINGLE_CY8")` and `CI_TOP` tied low, or the
  chain silently splits in two.
* Versal reports carry usage as `LOOKAHEAD8`, not `CARRY*`; a `CARRY*`-only
  filter reports zero. It also charges `LUTCY` carry fractures to the LUT
  budget, so its headline LUT figure is not comparable with the 7-series one
  even though the logic LUT count is lower.

## File overview

| file | role |
|------|------|
| `run_tiled.py` | end-to-end two-step driver (Step1→Step2→RTL→TB→verify) |
| `tiles.py` | tile set (DSP, Booth level-L, level-bounded LUT residuals) + exact PP model |
| `tiling_ilp.py` | **Step 1** set-partition tiling ILP (Gurobi); opt-in greedy tiler |
| `merge_ilp.py` | **Step 2** LUT+CARRY4 compressor-tree ILP; opt-in greedy FA/HA merge |
| `booth_array.py` | radix-4 Booth ARRAY (LUT6 encode + CARRY4 accumulate) |
| `tiled_verilog_gen.py` | structural RTL: DSP48 + Booth arrays + merge LUT6_2/CARRY4 |
| `tiled_pysim.py` | Python golden model (tiling→heap→reduction→CLA) checked vs `a*b` |
| `verilog_sim.py` | primitive-level netlist simulator (`LUT6`/`LUT6_2`/`CARRY4`/DSP) |
| `verify_python.py`, `verify_rtl.py` | functional verification helpers |
| `run.py` | single-stage compressor-tree ILP baseline |
| `compressors.py`, `signed_support.py`, `verilog_gen.py`, `ilp_solver.py` | shared compressor library, Baugh–Wooley sign support, RTL emitters, single-stage ILP |
| `generate_exhaustive_tb.py` | exhaustive Verilog testbench generator |
| `synth.tcl`, `synth_warm.tcl` | Vivado synthesis (`comb`/`reg`/`impl`); the wrapper adds the batch warm-up |
| `LUT6.v`, `LUT6_2.v`, `CARRY4.v` | primitive simulation models for iverilog |

## License

MIT — see `LICENSE`.
