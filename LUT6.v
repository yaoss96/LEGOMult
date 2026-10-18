module LUT6 (
    output O,
    input  I5, I4, I3, I2, I1, I0
);
    parameter [63:0] INIT = 64'h0000000000000000;

    wire [5:0] I = {I5, I4, I3, I2, I1, I0};
    assign O = INIT[I];
endmodule
