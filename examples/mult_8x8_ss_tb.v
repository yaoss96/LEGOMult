`timescale 1ns/1ps
module tb_tiled_mult_8b_ss;
  reg [7:0] a; reg [7:0] b; wire [15:0] r; reg [15:0] exp;
  integer errors=0,total=0,i,ai,bi;
  tiled_mult_8b_ss dut(.a(a),.b(b),.r(r));
  initial begin
    for(i=0;i<20000;i=i+1) begin
      a=$random; b=$random; #1; total=total+1; exp={ {8{a[7]}}, a } * { {8{b[7]}}, b };
      if(r!==exp) begin errors=errors+1; $display("FAIL a=%0d b=%0d r=%0d exp=%0d",a,b,r,exp); end
    end
    $display("TB DONE Wa=8 Wb=8 total=%0d errors=%0d",total,errors);
    $finish;
  end
endmodule
