`timescale 1ns/1ps
module tb_tiled_mult_32b;
  reg [31:0] a; reg [31:0] b; wire [63:0] r; reg [63:0] exp;
  integer errors=0,total=0,i,ai,bi;
  tiled_mult_32b dut(.a(a),.b(b),.r(r));
  initial begin
    for(i=0;i<20000;i=i+1) begin
      a=$random; b=$random; #1; total=total+1; exp={ {32{1'b0}}, a } * { {32{1'b0}}, b };
      if(r!==exp) begin errors=errors+1; $display("FAIL a=%0d b=%0d r=%0d exp=%0d",a,b,r,exp); end
    end
    $display("TB DONE Wa=32 Wb=32 total=%0d errors=%0d",total,errors);
    $finish;
  end
endmodule
