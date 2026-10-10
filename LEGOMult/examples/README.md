# Pre-generated multipliers

Eight multipliers emitted by `run_tiled.py`, four widths in both sign modes.
Each is the **smallest** design the flow produces at its size with no DSP48,
so these are the `LEGOMult (min area)` rows of the paper's Kintex-7
comparison and can be checked against it directly.

| file | module | operands | Booth level | LUT6 + LUT6_2 | CARRY4 | Slice LUTs after place | CPD |
|---|---|---|---|---|---|---|---|
| `mult_4x4_uu.v` | `tiled_mult_4b` | 4×4 unsigned | 3 | 13 | 2 | 13 | 2.60 ns |
| `mult_8x8_uu.v` | `tiled_mult_8b` | 8×8 unsigned | 5 | 39 | 20 | 39 | 6.97 ns |
| `mult_16x16_uu.v` | `tiled_mult_16b` | 16×16 unsigned | 9 | 143 | 64 | 143 | 11.20 ns |
| `mult_32x32_uu.v` | `tiled_mult_32b` | 32×32 unsigned | 17 | 543 | 224 | 543 | 19.52 ns |
| `mult_4x4_ss.v` | `tiled_mult_4b_ss` | 4×4 signed | 3 | 13 | 2 | 13 | 2.57 ns |
| `mult_8x8_ss.v` | `tiled_mult_8b_ss` | 8×8 signed | 4 | 34 | 18 | 33 | 6.00 ns |
| `mult_16x16_ss.v` | `tiled_mult_16b_ss` | 16×16 signed | 8 | 130 | 60 | 129 | 10.17 ns |
| `mult_32x32_ss.v` | `tiled_mult_32b_ss` | 32×32 signed | 16 | 514 | 216 | 513 | 18.50 ns |

Instantiated primitives and placed Slice LUTs differ by a few where Vivado
packs two LUT5s into one site; the placed figure is the one the paper quotes.
Measured with Vivado 2024.2 on `xc7k70tfbv484-3`, combinational, critical path
from a register sandwich.

## Interface

```verilog
module tiled_mult_32b_ss (
  input  [31:0] a,      // multiplicand
  input  [31:0] b,      // multiplier
  output [63:0] r       // a * b, two's complement in the signed variants
);
```

`r` is always `Wa + Wb` bits wide and is the exact product: these are not
truncated or approximate multipliers.

## Running them

The netlists are structural and instantiate `LUT6`, `LUT6_2` and `CARRY4`
only, so they need primitive models. For Vivado those come from the library;
for an open simulator use the models in the parent directory:

```bash
iverilog -o sim mult_32x32_ss_tb.v mult_32x32_ss.v \
         ../LUT6.v ../LUT6_2.v ../CARRY4.v
./sim                       # self-checking, prints PASS or the failing vector
```

Each `.v` ships with the testbench `run_tiled.py` wrote beside it, and the
`.json` next to it records the tiling, the compression schedule and the solver
times for that design.

## Regenerating

```bash
python run_tiled.py --Wa 32 --Wb 32 --sign-a --sign-b \
       --max-dsp 0 --booth-levels 16 \
       --out mult_32x32_ss.v --report-json mult_32x32_ss.json \
       --verify-samples 400 --part xc7k70tfbv484-3
```

Drop `--sign-a --sign-b` for the unsigned variants and set `--booth-levels` to
the level in the table above. Every file here was verified at the gate level
against `a*b` before being committed: exhaustively at 4×4, and over random
vectors at the wider sizes.
