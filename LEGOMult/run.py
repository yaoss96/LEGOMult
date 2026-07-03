"""
End-to-end driver:  ILP-Driven FPGA Multiplier Synthesis (asymmetric Wa x Wb).

Usage:
    # Symmetric (legacy; --W still supported)
    python run.py --W 8 --S 4 --lut-carry
    # Asymmetric
    python run.py --Wa 8 --Wb 4 --S 4 --lut-carry
    python run.py --Wa 3 --Wb 7 --S 3 --lut-carry --out mult_3x7.v

The script:
    1) builds the ILP model        (compressors.py + ilp_solver.py)
    2) calls Gurobi to obtain Pareto-optimal CT
    3) emits synthesisable Verilog (verilog_gen.py)
    4) emits a self-checking testbench (.tb.v)
    5) prints Table-III-style usage / area summary
"""

import argparse
import json
import os
import time

from compressors import all_compressors, compressor_paper_label, chain_base_kid
from ilp_solver  import solve_ct, pretty_print
from verilog_gen import emit_verilog


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--W",  type=int, default=None,
                   help="symmetric width: same as --Wa N --Wb N. ignored if "
                        "--Wa or --Wb is provided.")
    p.add_argument("--Wa", type=int, default=None,
                   help="multiplier 'a' width (>= 3)")
    p.add_argument("--Wb", type=int, default=None,
                   help="multiplier 'b' width (>= 3)")
    p.add_argument("--S",  type=int, default=None,
                   help="CT reduction steps (default: max(2, max(Wa,Wb)//2))")
    p.add_argument("--lut-carry", action="store_true")
    p.add_argument("--no-lut-carry", action="store_true",
                   help="legacy compatibility flag")
    p.add_argument("--sign-a", action="store_true",
                   help="treat operand a as signed (two's complement); needs Wa>=4")
    p.add_argument("--sign-b", action="store_true",
                   help="treat operand b as signed (two's complement); needs Wb>=4")
    p.add_argument("--signed", action="store_true",
                   help="shorthand for --sign-a --sign-b")
    p.add_argument("--alpha-lut", type=float, default=1.0,
                   help="weight on total LUT cost (default 1.0)")
    p.add_argument("--gamma-carry", type=float, default=0.0,
                   help="weight on chain-cell count (default 0.0; >0 "
                        "discourages chains, <0 encourages)")
    p.add_argument("--threads", type=int, default=8)
    p.add_argument("--time-limit", type=int, default=60000)
    p.add_argument("--mip-gap", type=float, default=1e-3)
    p.add_argument("--out", type=str, default=None,
                   help="output Verilog filename (default auto)")
    p.add_argument("--dump-json", type=str, default=None,
                   help="also dump the ILP CT result JSON. "
                        "Default: same dir as --out, with .json extension.")
    p.add_argument("--quiet", action="store_true")
    return p.parse_args()


def resolve_widths(args):
    if args.Wa is not None or args.Wb is not None:
        Wa = args.Wa if args.Wa is not None else args.Wb
        Wb = args.Wb if args.Wb is not None else args.Wa
    elif args.W is not None:
        Wa = Wb = args.W
    else:
        Wa = Wb = 8
    if Wa < 3 or Wb < 3:
        raise SystemExit("Wa and Wb must both be >= 3 (LOP block requires "
                         "a[2] and b[2]); got Wa=%d Wb=%d" % (Wa, Wb))
    return Wa, Wb


def dump_result_json(res, path):
    payload = {
        'Wa'      : int(res['Wa']),
        'Wb'      : int(res['Wb']),
        'W'       : int(res.get('W', res['Wa'])),
        'S'       : int(res['S']),
        'sign_a'  : bool(res.get('sign_a', False)),
        'sign_b'  : bool(res.get('sign_b', False)),
        'R_LO'    : int(res['R_LO']),
        'R_HI'    : int(res['R_HI']),
        'nCols'   : int(res['nCols']),
        'cost'    : int(res['cost']),
        'total_lut': int(res.get('total_lut', res['cost'] + 4 + res['Wa'] + res['Wb'] - 4)),
        'n_chain_cells': int(res.get('n_chain_cells', 0)),
        'alpha_lut': float(res.get('alpha_lut', 1.0)),
        'gamma_carry': float(res.get('gamma_carry', 0.0)),
        'objval'  : float(res['objval']),
        'mipgap'  : float(res['mipgap']),
        'comps'   : [{'step': int(c['step']),
                      'col':  int(c['col']),
                      'kid':  str(c['kid'])} for c in res['comps']],
        'OIPV'    : [[int(v) for v in row] for row in res['OIPV']],
        'IGPV'    : [[int(v) for v in row] for row in res['IGPV']],
    }
    with open(path, 'w') as f:
        json.dump(payload, f, indent=2)
    print("ILP result JSON dumped: %s  (%d compressors, total_lut=%d)"
          % (path, len(payload['comps']), payload['total_lut']))


def summarize_table_iii(result, comps, fname):
    Wa, Wb = result['Wa'], result['Wb']
    cnt = {k: 0 for k in comps}
    for c in result['comps']:
        cnt[c['kid']] += 1
    pure_idx  = sorted([k for k in cnt if k.startswith('p')],
                       key=lambda x: int(x[1:]))
    carry_idx = [k for k in cnt if k.startswith('c')]

    print("\n=========  Table III - usage row  =========")
    print("Pure-LUT counts (Table I compressor index):")
    print("  idx :", " ".join("%4s" % k[1:] for k in pure_idx))
    print("  num :", " ".join("%4d" % cnt[k] for k in pure_idx))
    print("  lbl :", " | ".join(compressor_paper_label(k) for k in pure_idx))
    if any(cnt[k] for k in carry_idx):
        base_order = {'cI': 0, 'cII': 1, 'cIII': 2}
        carry_idx = sorted([k for k in carry_idx if cnt[k] > 0],
                           key=lambda x: (base_order[chain_base_kid(x)], x))
        print("LUT-CarryChain counts (Table II type):")
        print("  typ :", " ".join("%6s" % k for k in carry_idx))
        print("  num :", " ".join("%6d" % cnt[k] for k in carry_idx))

    ct  = result['cost']
    lop = 4
    cla = Wa + Wb - 4
    total = ct + lop + cla
    print("LOP=%d  CT=%d  CLA=%d  ===  Area[LUT] = %d" % (lop, ct, cla, total))
    print("Verilog : %s" % fname)
    return cnt


def emit_testbench(Wa, Wb, top_name, vfile, tbfile, sign_a=False, sign_b=False,
                   n_random=20000):
    Tot = Wa + Wb
    # Golden product: sign- (or zero-) extend each operand to Tot bits, then a
    # plain unsigned '*' truncated to Tot bits equals the signed product mod
    # 2^Tot.  Using an explicit fill bit avoids Verilog's mixed-signedness rules.
    fill_a = ("a[%d]" % (Wa - 1)) if sign_a else "1'b0"
    fill_b = ("b[%d]" % (Wb - 1)) if sign_b else "1'b0"
    exp_rhs = "{ {%d{%s}}, a } * { {%d{%s}}, b }" % (Wb, fill_a, Wa, fill_b)
    with open(tbfile, 'w') as f:
        f.write("// Testbench for %s (auto-generated)\n" % top_name)
        f.write("`timescale 1ns/1ps\n")
        f.write("module tb_%s;\n" % top_name)
        f.write("  reg  [%d:0] a;\n" % (Wa - 1))
        f.write("  reg  [%d:0] b;\n" % (Wb - 1))
        f.write("  wire [%d:0] r;\n" % (Tot - 1))
        f.write("  reg  [%d:0] exp;\n" % (Tot - 1))
        f.write("  integer errors = 0, total = 0, i, ai, bi;\n")
        f.write("  %s dut(.a(a), .b(b), .r(r));\n" % top_name)
        f.write("  initial begin\n")
        small = (Wa <= 6 and Wb <= 6)
        if small:
            f.write("    for (ai = 0; ai < (1 << %d); ai = ai + 1) begin\n" % Wa)
            f.write("      for (bi = 0; bi < (1 << %d); bi = bi + 1) begin\n" % Wb)
            f.write("        a = ai[%d:0]; b = bi[%d:0]; #1; total = total + 1;\n" % (Wa - 1, Wb - 1))
            f.write("        exp = %s;\n" % exp_rhs)
            f.write("        if (r !== exp) begin\n")
            f.write("          errors = errors + 1;\n")
            f.write("          $display(\"FAIL a=%0d b=%0d r=%0d exp=%0d\", a, b, r, exp);\n")
            f.write("        end end end\n")
        else:
            f.write("    for (i = 0; i < %d; i = i + 1) begin\n" % n_random)
            f.write("      a = $random; b = $random; #1; total = total + 1;\n")
            f.write("      exp = %s;\n" % exp_rhs)
            f.write("      if (r !== exp) begin\n")
            f.write("        errors = errors + 1;\n")
            f.write("        $display(\"FAIL a=%0d b=%0d r=%0d exp=%0d\", a, b, r, exp);\n")
            f.write("      end end\n")
        f.write("    $display(\"TB DONE  Wa=%d Wb=%d  total=%%0d  errors=%%0d\", total, errors);\n"
                % (Wa, Wb))
        f.write("    $finish;\n")
        f.write("  end\nendmodule\n")
    print("Testbench written: %s" % tbfile)


def main():
    args = parse_args()
    Wa, Wb = resolve_widths(args)
    S = args.S if args.S is not None else max(2, max(Wa, Wb) // 2)
    if args.lut_carry and args.no_lut_carry:
        raise SystemExit("Choose at most one of --lut-carry / --no-lut-carry")
    use_lc = args.lut_carry
    sign_a = args.sign_a or args.signed
    sign_b = args.sign_b or args.signed
    if (sign_a and Wa < 4) or (sign_b and Wb < 4):
        raise SystemExit("signed operands require width >= 4; got Wa=%d sign_a=%s, "
                         "Wb=%d sign_b=%s" % (Wa, sign_a, Wb, sign_b))

    if args.out is None:
        base = ("ilp_mult_%db_S%d" % (Wa, S)) if Wa == Wb \
            else ("ilp_mult_%dx%d_S%d" % (Wa, Wb, S))
        if sign_a or sign_b:
            base += "_%s%s" % ('s' if sign_a else 'u', 's' if sign_b else 'u')
        args.out = base + ".v"

    print("=" * 70)
    print("ILP-Driven FPGA Multiplier  --  Wa=%d  Wb=%d  S=%d  use_lut_carry=%s  "
          "sign_a=%s  sign_b=%s" % (Wa, Wb, S, use_lc, sign_a, sign_b))
    print("alpha_lut=%.3f  gamma_carry=%.3f" % (args.alpha_lut, args.gamma_carry))
    print("=" * 70)
    t0 = time.time()
    res = solve_ct(Wa, Wb, S,
                   use_lut_carry=use_lc,
                   sign_a=sign_a, sign_b=sign_b,
                   alpha_lut=args.alpha_lut,
                   gamma_carry=args.gamma_carry,
                   threads=args.threads,
                   time_limit=args.time_limit,
                   mip_gap=args.mip_gap,
                   verbose=not args.quiet)
    print("\nGurobi solve time : %.2fs" % (time.time() - t0))

    comps = all_compressors(use_lc)
    pretty_print(res, comps)
    emit_verilog(res, args.out)

    top_name = ("ilp_mult_%db" % Wa) if Wa == Wb else ("ilp_mult_%dx%d" % (Wa, Wb))
    tb = args.out.replace(".v", "_tb.v")
    emit_testbench(Wa, Wb, top_name, args.out, tb, sign_a=sign_a, sign_b=sign_b)

    json_path = args.dump_json
    if json_path is None:
        json_path = os.path.splitext(args.out)[0] + ".json"
    dump_result_json(res, json_path)

    cnt = summarize_table_iii(res, comps, args.out)
    if use_lc and sum(v for k, v in cnt.items() if k.startswith('c')) == 0:
        print("WARNING: --lut-carry enabled but this solve picked 0 chain cells.")


if __name__ == "__main__":
    main()
