import argparse


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--W",  type=int, default=None,
                   help="symmetric width (legacy; same as --Wa W --Wb W)")
    p.add_argument("--Wa", type=int, default=None)
    p.add_argument("--Wb", type=int, default=None)
    p.add_argument("--out", type=str, required=True)
    args = p.parse_args()

    if args.Wa is not None or args.Wb is not None:
        Wa = args.Wa if args.Wa is not None else args.Wb
        Wb = args.Wb if args.Wb is not None else args.Wa
    elif args.W is not None:
        Wa = Wb = args.W
    else:
        raise SystemExit("must pass --W or --Wa/--Wb")

    Tot = Wa + Wb
    top = ("ilp_mult_%db" % Wa) if Wa == Wb else ("ilp_mult_%dx%d" % (Wa, Wb))

    with open(args.out, "w", newline="\n") as f:
        f.write("`timescale 1ns/1ps\n")
        f.write("module tb_ilp_mult_exhaustive;\n")
        f.write("  reg  [%d:0] a;\n" % (Wa - 1))
        f.write("  reg  [%d:0] b;\n" % (Wb - 1))
        f.write("  wire [%d:0] r;\n" % (Tot - 1))
        f.write("  reg  [%d:0] exp;\n" % (Tot - 1))
        f.write("  integer errors, total, ai, bi;\n")
        f.write("\n")
        f.write("  %s dut(.a(a), .b(b), .r(r));\n" % top)
        f.write("\n")
        f.write("  initial begin\n")
        f.write("    errors = 0;\n")
        f.write("    total = 0;\n")
        f.write("    for (ai = 0; ai < (1 << %d); ai = ai + 1) begin\n" % Wa)
        f.write("      for (bi = 0; bi < (1 << %d); bi = bi + 1) begin\n" % Wb)
        f.write("        a = ai[%d:0];\n" % (Wa - 1))
        f.write("        b = bi[%d:0];\n" % (Wb - 1))
        f.write("        #1;\n")
        f.write("        total = total + 1;\n")
        f.write("        exp = { {%d{1'b0}}, a } * { {%d{1'b0}}, b };\n" % (Wb, Wa))
        f.write("        if (r !== exp) begin\n")
        f.write("          errors = errors + 1;\n")
        f.write("          $display(\"FAIL a=%0d b=%0d r=%0d exp=%0d\", a, b, r, exp);\n")
        f.write("        end\n")
        f.write("      end\n")
        f.write("    end\n")
        f.write("    $display(\"TB DONE Wa=%d Wb=%d total=%%0d errors=%%0d\", total, errors);\n"
                % (Wa, Wb))
        f.write("    $finish;\n")
        f.write("  end\n")
        f.write("endmodule\n")


if __name__ == "__main__":
    main()
