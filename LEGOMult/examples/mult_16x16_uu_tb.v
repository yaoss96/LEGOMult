`timescale 1ns/1ps
module tb_tiled_mult_16b;
  reg [15:0] a; reg [15:0] b; wire [31:0] r; reg [31:0] exp;
  integer errors=0,total=0,i,ai,bi;
  tiled_mult_16b dut(.a(a),.b(b),.r(r));
  initial begin
    for(i=0;i<20000;i=i+1) begin
      a=$random; b=$random; #1; total=total+1; exp={ {16{1'b0}}, a } * { {16{1'b0}}, b };
      if(r!==exp) begin errors=errors+1; $display("FAIL a=%0d b=%0d r=%0d exp=%0d",a,b,r,exp); end
    end
    $display("TB DONE Wa=16 Wb=16 total=%0d errors=%0d",total,errors);
    $finish;
  end
endmodule
