`timescale 1ns/1ps
module tb_tiled_mult_4b;
  reg [3:0] a; reg [3:0] b; wire [7:0] r; reg [7:0] exp;
  integer errors=0,total=0,i,ai,bi;
  tiled_mult_4b dut(.a(a),.b(b),.r(r));
  initial begin
    for(ai=0;ai<(1<<4);ai=ai+1) for(bi=0;bi<(1<<4);bi=bi+1) begin
      a=ai[3:0]; b=bi[3:0]; #1; total=total+1; exp={ {4{1'b0}}, a } * { {4{1'b0}}, b };
      if(r!==exp) begin errors=errors+1; $display("FAIL a=%0d b=%0d r=%0d exp=%0d",a,b,r,exp); end
    end
    $display("TB DONE Wa=4 Wb=4 total=%0d errors=%0d",total,errors);
    $finish;
  end
endmodule
