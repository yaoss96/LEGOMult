// ==========================================================
// Two-step tiling multiplier (DSP + Booth + LUT / LUT+CARRY4)
// Wa=32 Wb=32  sign_a=False sign_b=False  merge=ilp  cols=64
// tiles: {'BOOTH': 1}
// ==========================================================
module tiled_mult_32b (
  input  [31:0] a,
  input  [31:0] b,
  output [63:0] r
);

  // ---- Booth tile booth_0_0 : a[31:0](mult) x b[31:0](mcand)  level L=17 (u/u) ----
  wire [31:0] bx_0_0 = b[31:0];
  wire [31:0] by_0_0 = a[31:0];
  wire bs_booth_0_0_l0_0, bs_booth_0_0_l0_1;
  LUT6_2 #(.INIT(64'h468A468A6A6A6A6A)) u_bs_booth_0_0_l0_0 (.O5(bs_booth_0_0_l0_0), .O6(bs_booth_0_0_l0_1), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[0]), .I3(bx_0_0[1]), .I4(1'b0), .I5(1'b1));
  wire bs_booth_0_0_l0_2, bs_booth_0_0_l0_3;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_2 (.O5(bs_booth_0_0_l0_2), .O6(bs_booth_0_0_l0_3), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[2]), .I3(bx_0_0[1]), .I4(bx_0_0[3]), .I5(1'b1));
  wire bs_booth_0_0_l0_4, bs_booth_0_0_l0_5;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_4 (.O5(bs_booth_0_0_l0_4), .O6(bs_booth_0_0_l0_5), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[4]), .I3(bx_0_0[3]), .I4(bx_0_0[5]), .I5(1'b1));
  wire bs_booth_0_0_l0_6, bs_booth_0_0_l0_7;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_6 (.O5(bs_booth_0_0_l0_6), .O6(bs_booth_0_0_l0_7), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[6]), .I3(bx_0_0[5]), .I4(bx_0_0[7]), .I5(1'b1));
  wire bs_booth_0_0_l0_8, bs_booth_0_0_l0_9;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_8 (.O5(bs_booth_0_0_l0_8), .O6(bs_booth_0_0_l0_9), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[8]), .I3(bx_0_0[7]), .I4(bx_0_0[9]), .I5(1'b1));
  wire bs_booth_0_0_l0_10, bs_booth_0_0_l0_11;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_10 (.O5(bs_booth_0_0_l0_10), .O6(bs_booth_0_0_l0_11), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[10]), .I3(bx_0_0[9]), .I4(bx_0_0[11]), .I5(1'b1));
  wire bs_booth_0_0_l0_12, bs_booth_0_0_l0_13;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_12 (.O5(bs_booth_0_0_l0_12), .O6(bs_booth_0_0_l0_13), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[12]), .I3(bx_0_0[11]), .I4(bx_0_0[13]), .I5(1'b1));
  wire bs_booth_0_0_l0_14, bs_booth_0_0_l0_15;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_14 (.O5(bs_booth_0_0_l0_14), .O6(bs_booth_0_0_l0_15), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[14]), .I3(bx_0_0[13]), .I4(bx_0_0[15]), .I5(1'b1));
  wire bs_booth_0_0_l0_16, bs_booth_0_0_l0_17;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_16 (.O5(bs_booth_0_0_l0_16), .O6(bs_booth_0_0_l0_17), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[16]), .I3(bx_0_0[15]), .I4(bx_0_0[17]), .I5(1'b1));
  wire bs_booth_0_0_l0_18, bs_booth_0_0_l0_19;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_18 (.O5(bs_booth_0_0_l0_18), .O6(bs_booth_0_0_l0_19), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[18]), .I3(bx_0_0[17]), .I4(bx_0_0[19]), .I5(1'b1));
  wire bs_booth_0_0_l0_20, bs_booth_0_0_l0_21;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_20 (.O5(bs_booth_0_0_l0_20), .O6(bs_booth_0_0_l0_21), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[20]), .I3(bx_0_0[19]), .I4(bx_0_0[21]), .I5(1'b1));
  wire bs_booth_0_0_l0_22, bs_booth_0_0_l0_23;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_22 (.O5(bs_booth_0_0_l0_22), .O6(bs_booth_0_0_l0_23), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[22]), .I3(bx_0_0[21]), .I4(bx_0_0[23]), .I5(1'b1));
  wire bs_booth_0_0_l0_24, bs_booth_0_0_l0_25;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_24 (.O5(bs_booth_0_0_l0_24), .O6(bs_booth_0_0_l0_25), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[24]), .I3(bx_0_0[23]), .I4(bx_0_0[25]), .I5(1'b1));
  wire bs_booth_0_0_l0_26, bs_booth_0_0_l0_27;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_26 (.O5(bs_booth_0_0_l0_26), .O6(bs_booth_0_0_l0_27), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[26]), .I3(bx_0_0[25]), .I4(bx_0_0[27]), .I5(1'b1));
  wire bs_booth_0_0_l0_28, bs_booth_0_0_l0_29;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_28 (.O5(bs_booth_0_0_l0_28), .O6(bs_booth_0_0_l0_29), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[28]), .I3(bx_0_0[27]), .I4(bx_0_0[29]), .I5(1'b1));
  wire bs_booth_0_0_l0_30, bs_booth_0_0_l0_31;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_30 (.O5(bs_booth_0_0_l0_30), .O6(bs_booth_0_0_l0_31), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[30]), .I3(bx_0_0[29]), .I4(bx_0_0[31]), .I5(1'b1));
  wire bs_booth_0_0_l0_32, bs_booth_0_0_l0_33;
  LUT6_2 #(.INIT(64'hAAAAAAAA8A8A8A8A)) u_bs_booth_0_0_l0_32 (.O5(bs_booth_0_0_l0_32), .O6(bs_booth_0_0_l0_33), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[31]), .I3(1'b0), .I4(1'b0), .I5(1'b1));
  wire [3:0] co_booth_0_0_l0_0, o_booth_0_0_l0_0;
  CARRY4 u_cy_booth_0_0_l0_0 (
    .CO(co_booth_0_0_l0_0), .O(o_booth_0_0_l0_0),
    .CI(1'b0), .CYINIT(by_0_0[1]),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_3, bs_booth_0_0_l0_2, bs_booth_0_0_l0_1, bs_booth_0_0_l0_0 }));
  wire [3:0] co_booth_0_0_l0_1, o_booth_0_0_l0_1;
  CARRY4 u_cy_booth_0_0_l0_1 (
    .CO(co_booth_0_0_l0_1), .O(o_booth_0_0_l0_1),
    .CI(co_booth_0_0_l0_0[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_7, bs_booth_0_0_l0_6, bs_booth_0_0_l0_5, bs_booth_0_0_l0_4 }));
  wire [3:0] co_booth_0_0_l0_2, o_booth_0_0_l0_2;
  CARRY4 u_cy_booth_0_0_l0_2 (
    .CO(co_booth_0_0_l0_2), .O(o_booth_0_0_l0_2),
    .CI(co_booth_0_0_l0_1[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_11, bs_booth_0_0_l0_10, bs_booth_0_0_l0_9, bs_booth_0_0_l0_8 }));
  wire [3:0] co_booth_0_0_l0_3, o_booth_0_0_l0_3;
  CARRY4 u_cy_booth_0_0_l0_3 (
    .CO(co_booth_0_0_l0_3), .O(o_booth_0_0_l0_3),
    .CI(co_booth_0_0_l0_2[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_15, bs_booth_0_0_l0_14, bs_booth_0_0_l0_13, bs_booth_0_0_l0_12 }));
  wire [3:0] co_booth_0_0_l0_4, o_booth_0_0_l0_4;
  CARRY4 u_cy_booth_0_0_l0_4 (
    .CO(co_booth_0_0_l0_4), .O(o_booth_0_0_l0_4),
    .CI(co_booth_0_0_l0_3[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_19, bs_booth_0_0_l0_18, bs_booth_0_0_l0_17, bs_booth_0_0_l0_16 }));
  wire [3:0] co_booth_0_0_l0_5, o_booth_0_0_l0_5;
  CARRY4 u_cy_booth_0_0_l0_5 (
    .CO(co_booth_0_0_l0_5), .O(o_booth_0_0_l0_5),
    .CI(co_booth_0_0_l0_4[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_23, bs_booth_0_0_l0_22, bs_booth_0_0_l0_21, bs_booth_0_0_l0_20 }));
  wire [3:0] co_booth_0_0_l0_6, o_booth_0_0_l0_6;
  CARRY4 u_cy_booth_0_0_l0_6 (
    .CO(co_booth_0_0_l0_6), .O(o_booth_0_0_l0_6),
    .CI(co_booth_0_0_l0_5[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_27, bs_booth_0_0_l0_26, bs_booth_0_0_l0_25, bs_booth_0_0_l0_24 }));
  wire [3:0] co_booth_0_0_l0_7, o_booth_0_0_l0_7;
  CARRY4 u_cy_booth_0_0_l0_7 (
    .CO(co_booth_0_0_l0_7), .O(o_booth_0_0_l0_7),
    .CI(co_booth_0_0_l0_6[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ bs_booth_0_0_l0_31, bs_booth_0_0_l0_30, bs_booth_0_0_l0_29, bs_booth_0_0_l0_28 }));
  wire [3:0] co_booth_0_0_l0_8, o_booth_0_0_l0_8;
  CARRY4 u_cy_booth_0_0_l0_8 (
    .CO(co_booth_0_0_l0_8), .O(o_booth_0_0_l0_8),
    .CI(co_booth_0_0_l0_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b1, 1'b0 }), .S({ 1'b0, 1'b1, bs_booth_0_0_l0_33, bs_booth_0_0_l0_32 }));
  wire [3:0] co_booth_0_0_l0_9, o_booth_0_0_l0_9;
  CARRY4 u_cy_booth_0_0_l0_9 (
    .CO(co_booth_0_0_l0_9), .O(o_booth_0_0_l0_9),
    .CI(co_booth_0_0_l0_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_10, o_booth_0_0_l0_10;
  CARRY4 u_cy_booth_0_0_l0_10 (
    .CO(co_booth_0_0_l0_10), .O(o_booth_0_0_l0_10),
    .CI(co_booth_0_0_l0_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_11, o_booth_0_0_l0_11;
  CARRY4 u_cy_booth_0_0_l0_11 (
    .CO(co_booth_0_0_l0_11), .O(o_booth_0_0_l0_11),
    .CI(co_booth_0_0_l0_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_12, o_booth_0_0_l0_12;
  CARRY4 u_cy_booth_0_0_l0_12 (
    .CO(co_booth_0_0_l0_12), .O(o_booth_0_0_l0_12),
    .CI(co_booth_0_0_l0_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_13, o_booth_0_0_l0_13;
  CARRY4 u_cy_booth_0_0_l0_13 (
    .CO(co_booth_0_0_l0_13), .O(o_booth_0_0_l0_13),
    .CI(co_booth_0_0_l0_12[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_14, o_booth_0_0_l0_14;
  CARRY4 u_cy_booth_0_0_l0_14 (
    .CO(co_booth_0_0_l0_14), .O(o_booth_0_0_l0_14),
    .CI(co_booth_0_0_l0_13[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_15, o_booth_0_0_l0_15;
  CARRY4 u_cy_booth_0_0_l0_15 (
    .CO(co_booth_0_0_l0_15), .O(o_booth_0_0_l0_15),
    .CI(co_booth_0_0_l0_14[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire bs_booth_0_0_l1_2, cm_booth_0_0_l1;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l1_2 (.O5(cm_booth_0_0_l1), .O6(bs_booth_0_0_l1_2), .I0(by_0_0[3]), .I1(by_0_0[2]), .I2(by_0_0[1]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l0_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l1_3;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_3 (.O(bs_booth_0_0_l1_3), .I0(o_booth_0_0_l0_0[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l1_4;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_4 (.O(bs_booth_0_0_l1_4), .I0(o_booth_0_0_l0_1[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l1_5;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_5 (.O(bs_booth_0_0_l1_5), .I0(o_booth_0_0_l0_1[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l1_6;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_6 (.O(bs_booth_0_0_l1_6), .I0(o_booth_0_0_l0_1[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l1_7;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_7 (.O(bs_booth_0_0_l1_7), .I0(o_booth_0_0_l0_1[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l1_8;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_8 (.O(bs_booth_0_0_l1_8), .I0(o_booth_0_0_l0_2[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l1_9;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_9 (.O(bs_booth_0_0_l1_9), .I0(o_booth_0_0_l0_2[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l1_10;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_10 (.O(bs_booth_0_0_l1_10), .I0(o_booth_0_0_l0_2[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l1_11;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_11 (.O(bs_booth_0_0_l1_11), .I0(o_booth_0_0_l0_2[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l1_12;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_12 (.O(bs_booth_0_0_l1_12), .I0(o_booth_0_0_l0_3[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l1_13;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_13 (.O(bs_booth_0_0_l1_13), .I0(o_booth_0_0_l0_3[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l1_14;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_14 (.O(bs_booth_0_0_l1_14), .I0(o_booth_0_0_l0_3[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l1_15;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_15 (.O(bs_booth_0_0_l1_15), .I0(o_booth_0_0_l0_3[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l1_16;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_16 (.O(bs_booth_0_0_l1_16), .I0(o_booth_0_0_l0_4[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l1_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_17 (.O(bs_booth_0_0_l1_17), .I0(o_booth_0_0_l0_4[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l1_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_18 (.O(bs_booth_0_0_l1_18), .I0(o_booth_0_0_l0_4[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l1_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_19 (.O(bs_booth_0_0_l1_19), .I0(o_booth_0_0_l0_4[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l1_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_20 (.O(bs_booth_0_0_l1_20), .I0(o_booth_0_0_l0_5[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l1_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_21 (.O(bs_booth_0_0_l1_21), .I0(o_booth_0_0_l0_5[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l1_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_22 (.O(bs_booth_0_0_l1_22), .I0(o_booth_0_0_l0_5[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l1_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_23 (.O(bs_booth_0_0_l1_23), .I0(o_booth_0_0_l0_5[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l1_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_24 (.O(bs_booth_0_0_l1_24), .I0(o_booth_0_0_l0_6[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l1_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_25 (.O(bs_booth_0_0_l1_25), .I0(o_booth_0_0_l0_6[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l1_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_26 (.O(bs_booth_0_0_l1_26), .I0(o_booth_0_0_l0_6[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l1_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_27 (.O(bs_booth_0_0_l1_27), .I0(o_booth_0_0_l0_6[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l1_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_28 (.O(bs_booth_0_0_l1_28), .I0(o_booth_0_0_l0_7[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l1_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_29 (.O(bs_booth_0_0_l1_29), .I0(o_booth_0_0_l0_7[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l1_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_30 (.O(bs_booth_0_0_l1_30), .I0(o_booth_0_0_l0_7[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l1_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_31 (.O(bs_booth_0_0_l1_31), .I0(o_booth_0_0_l0_7[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l1_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_32 (.O(bs_booth_0_0_l1_32), .I0(o_booth_0_0_l0_8[0]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l1_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l1_33 (.O(bs_booth_0_0_l1_33), .I0(o_booth_0_0_l0_8[1]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l1_34;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l1_34 (.O(bs_booth_0_0_l1_34), .I0(o_booth_0_0_l0_8[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l1_35;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l1_35 (.O(bs_booth_0_0_l1_35), .I0(o_booth_0_0_l0_8[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l1_0, o_booth_0_0_l1_0;
  CARRY4 u_cy_booth_0_0_l1_0 (
    .CO(co_booth_0_0_l1_0), .O(o_booth_0_0_l1_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l1),
    .DI({ o_booth_0_0_l0_1[1], o_booth_0_0_l0_1[0], o_booth_0_0_l0_0[3], o_booth_0_0_l0_0[2] }), .S({ bs_booth_0_0_l1_5, bs_booth_0_0_l1_4, bs_booth_0_0_l1_3, bs_booth_0_0_l1_2 }));
  wire [3:0] co_booth_0_0_l1_1, o_booth_0_0_l1_1;
  CARRY4 u_cy_booth_0_0_l1_1 (
    .CO(co_booth_0_0_l1_1), .O(o_booth_0_0_l1_1),
    .CI(co_booth_0_0_l1_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l0_2[1], o_booth_0_0_l0_2[0], o_booth_0_0_l0_1[3], o_booth_0_0_l0_1[2] }), .S({ bs_booth_0_0_l1_9, bs_booth_0_0_l1_8, bs_booth_0_0_l1_7, bs_booth_0_0_l1_6 }));
  wire [3:0] co_booth_0_0_l1_2, o_booth_0_0_l1_2;
  CARRY4 u_cy_booth_0_0_l1_2 (
    .CO(co_booth_0_0_l1_2), .O(o_booth_0_0_l1_2),
    .CI(co_booth_0_0_l1_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l0_3[1], o_booth_0_0_l0_3[0], o_booth_0_0_l0_2[3], o_booth_0_0_l0_2[2] }), .S({ bs_booth_0_0_l1_13, bs_booth_0_0_l1_12, bs_booth_0_0_l1_11, bs_booth_0_0_l1_10 }));
  wire [3:0] co_booth_0_0_l1_3, o_booth_0_0_l1_3;
  CARRY4 u_cy_booth_0_0_l1_3 (
    .CO(co_booth_0_0_l1_3), .O(o_booth_0_0_l1_3),
    .CI(co_booth_0_0_l1_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l0_4[1], o_booth_0_0_l0_4[0], o_booth_0_0_l0_3[3], o_booth_0_0_l0_3[2] }), .S({ bs_booth_0_0_l1_17, bs_booth_0_0_l1_16, bs_booth_0_0_l1_15, bs_booth_0_0_l1_14 }));
  wire [3:0] co_booth_0_0_l1_4, o_booth_0_0_l1_4;
  CARRY4 u_cy_booth_0_0_l1_4 (
    .CO(co_booth_0_0_l1_4), .O(o_booth_0_0_l1_4),
    .CI(co_booth_0_0_l1_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l0_5[1], o_booth_0_0_l0_5[0], o_booth_0_0_l0_4[3], o_booth_0_0_l0_4[2] }), .S({ bs_booth_0_0_l1_21, bs_booth_0_0_l1_20, bs_booth_0_0_l1_19, bs_booth_0_0_l1_18 }));
  wire [3:0] co_booth_0_0_l1_5, o_booth_0_0_l1_5;
  CARRY4 u_cy_booth_0_0_l1_5 (
    .CO(co_booth_0_0_l1_5), .O(o_booth_0_0_l1_5),
    .CI(co_booth_0_0_l1_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l0_6[1], o_booth_0_0_l0_6[0], o_booth_0_0_l0_5[3], o_booth_0_0_l0_5[2] }), .S({ bs_booth_0_0_l1_25, bs_booth_0_0_l1_24, bs_booth_0_0_l1_23, bs_booth_0_0_l1_22 }));
  wire [3:0] co_booth_0_0_l1_6, o_booth_0_0_l1_6;
  CARRY4 u_cy_booth_0_0_l1_6 (
    .CO(co_booth_0_0_l1_6), .O(o_booth_0_0_l1_6),
    .CI(co_booth_0_0_l1_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l0_7[1], o_booth_0_0_l0_7[0], o_booth_0_0_l0_6[3], o_booth_0_0_l0_6[2] }), .S({ bs_booth_0_0_l1_29, bs_booth_0_0_l1_28, bs_booth_0_0_l1_27, bs_booth_0_0_l1_26 }));
  wire [3:0] co_booth_0_0_l1_7, o_booth_0_0_l1_7;
  CARRY4 u_cy_booth_0_0_l1_7 (
    .CO(co_booth_0_0_l1_7), .O(o_booth_0_0_l1_7),
    .CI(co_booth_0_0_l1_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l0_8[1], o_booth_0_0_l0_8[0], o_booth_0_0_l0_7[3], o_booth_0_0_l0_7[2] }), .S({ bs_booth_0_0_l1_33, bs_booth_0_0_l1_32, bs_booth_0_0_l1_31, bs_booth_0_0_l1_30 }));
  wire [3:0] co_booth_0_0_l1_8, o_booth_0_0_l1_8;
  CARRY4 u_cy_booth_0_0_l1_8 (
    .CO(co_booth_0_0_l1_8), .O(o_booth_0_0_l1_8),
    .CI(co_booth_0_0_l1_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l0_8[3], o_booth_0_0_l0_8[2] }), .S({ o_booth_0_0_l0_9[1], o_booth_0_0_l0_9[0], bs_booth_0_0_l1_35, bs_booth_0_0_l1_34 }));
  wire [3:0] co_booth_0_0_l1_9, o_booth_0_0_l1_9;
  CARRY4 u_cy_booth_0_0_l1_9 (
    .CO(co_booth_0_0_l1_9), .O(o_booth_0_0_l1_9),
    .CI(co_booth_0_0_l1_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_10[1], o_booth_0_0_l0_10[0], o_booth_0_0_l0_9[3], o_booth_0_0_l0_9[2] }));
  wire [3:0] co_booth_0_0_l1_10, o_booth_0_0_l1_10;
  CARRY4 u_cy_booth_0_0_l1_10 (
    .CO(co_booth_0_0_l1_10), .O(o_booth_0_0_l1_10),
    .CI(co_booth_0_0_l1_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_11[1], o_booth_0_0_l0_11[0], o_booth_0_0_l0_10[3], o_booth_0_0_l0_10[2] }));
  wire [3:0] co_booth_0_0_l1_11, o_booth_0_0_l1_11;
  CARRY4 u_cy_booth_0_0_l1_11 (
    .CO(co_booth_0_0_l1_11), .O(o_booth_0_0_l1_11),
    .CI(co_booth_0_0_l1_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_12[1], o_booth_0_0_l0_12[0], o_booth_0_0_l0_11[3], o_booth_0_0_l0_11[2] }));
  wire [3:0] co_booth_0_0_l1_12, o_booth_0_0_l1_12;
  CARRY4 u_cy_booth_0_0_l1_12 (
    .CO(co_booth_0_0_l1_12), .O(o_booth_0_0_l1_12),
    .CI(co_booth_0_0_l1_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_13[1], o_booth_0_0_l0_13[0], o_booth_0_0_l0_12[3], o_booth_0_0_l0_12[2] }));
  wire [3:0] co_booth_0_0_l1_13, o_booth_0_0_l1_13;
  CARRY4 u_cy_booth_0_0_l1_13 (
    .CO(co_booth_0_0_l1_13), .O(o_booth_0_0_l1_13),
    .CI(co_booth_0_0_l1_12[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_14[1], o_booth_0_0_l0_14[0], o_booth_0_0_l0_13[3], o_booth_0_0_l0_13[2] }));
  wire [3:0] co_booth_0_0_l1_14, o_booth_0_0_l1_14;
  CARRY4 u_cy_booth_0_0_l1_14 (
    .CO(co_booth_0_0_l1_14), .O(o_booth_0_0_l1_14),
    .CI(co_booth_0_0_l1_13[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_15[1], o_booth_0_0_l0_15[0], o_booth_0_0_l0_14[3], o_booth_0_0_l0_14[2] }));
  wire [3:0] co_booth_0_0_l1_15, o_booth_0_0_l1_15;
  CARRY4 u_cy_booth_0_0_l1_15 (
    .CO(co_booth_0_0_l1_15), .O(o_booth_0_0_l1_15),
    .CI(co_booth_0_0_l1_14[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l0_15[3], o_booth_0_0_l0_15[2] }));
  wire bs_booth_0_0_l2_4, cm_booth_0_0_l2;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l2_4 (.O5(cm_booth_0_0_l2), .O6(bs_booth_0_0_l2_4), .I0(by_0_0[5]), .I1(by_0_0[4]), .I2(by_0_0[3]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l1_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l2_5;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_5 (.O(bs_booth_0_0_l2_5), .I0(o_booth_0_0_l1_0[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l2_6;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_6 (.O(bs_booth_0_0_l2_6), .I0(o_booth_0_0_l1_1[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l2_7;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_7 (.O(bs_booth_0_0_l2_7), .I0(o_booth_0_0_l1_1[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l2_8;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_8 (.O(bs_booth_0_0_l2_8), .I0(o_booth_0_0_l1_1[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l2_9;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_9 (.O(bs_booth_0_0_l2_9), .I0(o_booth_0_0_l1_1[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l2_10;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_10 (.O(bs_booth_0_0_l2_10), .I0(o_booth_0_0_l1_2[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l2_11;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_11 (.O(bs_booth_0_0_l2_11), .I0(o_booth_0_0_l1_2[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l2_12;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_12 (.O(bs_booth_0_0_l2_12), .I0(o_booth_0_0_l1_2[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l2_13;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_13 (.O(bs_booth_0_0_l2_13), .I0(o_booth_0_0_l1_2[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l2_14;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_14 (.O(bs_booth_0_0_l2_14), .I0(o_booth_0_0_l1_3[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l2_15;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_15 (.O(bs_booth_0_0_l2_15), .I0(o_booth_0_0_l1_3[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l2_16;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_16 (.O(bs_booth_0_0_l2_16), .I0(o_booth_0_0_l1_3[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l2_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_17 (.O(bs_booth_0_0_l2_17), .I0(o_booth_0_0_l1_3[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l2_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_18 (.O(bs_booth_0_0_l2_18), .I0(o_booth_0_0_l1_4[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l2_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_19 (.O(bs_booth_0_0_l2_19), .I0(o_booth_0_0_l1_4[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l2_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_20 (.O(bs_booth_0_0_l2_20), .I0(o_booth_0_0_l1_4[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l2_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_21 (.O(bs_booth_0_0_l2_21), .I0(o_booth_0_0_l1_4[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l2_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_22 (.O(bs_booth_0_0_l2_22), .I0(o_booth_0_0_l1_5[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l2_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_23 (.O(bs_booth_0_0_l2_23), .I0(o_booth_0_0_l1_5[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l2_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_24 (.O(bs_booth_0_0_l2_24), .I0(o_booth_0_0_l1_5[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l2_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_25 (.O(bs_booth_0_0_l2_25), .I0(o_booth_0_0_l1_5[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l2_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_26 (.O(bs_booth_0_0_l2_26), .I0(o_booth_0_0_l1_6[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l2_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_27 (.O(bs_booth_0_0_l2_27), .I0(o_booth_0_0_l1_6[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l2_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_28 (.O(bs_booth_0_0_l2_28), .I0(o_booth_0_0_l1_6[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l2_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_29 (.O(bs_booth_0_0_l2_29), .I0(o_booth_0_0_l1_6[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l2_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_30 (.O(bs_booth_0_0_l2_30), .I0(o_booth_0_0_l1_7[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l2_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_31 (.O(bs_booth_0_0_l2_31), .I0(o_booth_0_0_l1_7[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l2_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_32 (.O(bs_booth_0_0_l2_32), .I0(o_booth_0_0_l1_7[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l2_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_33 (.O(bs_booth_0_0_l2_33), .I0(o_booth_0_0_l1_7[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l2_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_34 (.O(bs_booth_0_0_l2_34), .I0(o_booth_0_0_l1_8[0]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l2_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l2_35 (.O(bs_booth_0_0_l2_35), .I0(o_booth_0_0_l1_8[1]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l2_36;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l2_36 (.O(bs_booth_0_0_l2_36), .I0(o_booth_0_0_l1_8[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l2_37;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l2_37 (.O(bs_booth_0_0_l2_37), .I0(o_booth_0_0_l1_8[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l2_0, o_booth_0_0_l2_0;
  CARRY4 u_cy_booth_0_0_l2_0 (
    .CO(co_booth_0_0_l2_0), .O(o_booth_0_0_l2_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l2),
    .DI({ o_booth_0_0_l1_1[1], o_booth_0_0_l1_1[0], o_booth_0_0_l1_0[3], o_booth_0_0_l1_0[2] }), .S({ bs_booth_0_0_l2_7, bs_booth_0_0_l2_6, bs_booth_0_0_l2_5, bs_booth_0_0_l2_4 }));
  wire [3:0] co_booth_0_0_l2_1, o_booth_0_0_l2_1;
  CARRY4 u_cy_booth_0_0_l2_1 (
    .CO(co_booth_0_0_l2_1), .O(o_booth_0_0_l2_1),
    .CI(co_booth_0_0_l2_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l1_2[1], o_booth_0_0_l1_2[0], o_booth_0_0_l1_1[3], o_booth_0_0_l1_1[2] }), .S({ bs_booth_0_0_l2_11, bs_booth_0_0_l2_10, bs_booth_0_0_l2_9, bs_booth_0_0_l2_8 }));
  wire [3:0] co_booth_0_0_l2_2, o_booth_0_0_l2_2;
  CARRY4 u_cy_booth_0_0_l2_2 (
    .CO(co_booth_0_0_l2_2), .O(o_booth_0_0_l2_2),
    .CI(co_booth_0_0_l2_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l1_3[1], o_booth_0_0_l1_3[0], o_booth_0_0_l1_2[3], o_booth_0_0_l1_2[2] }), .S({ bs_booth_0_0_l2_15, bs_booth_0_0_l2_14, bs_booth_0_0_l2_13, bs_booth_0_0_l2_12 }));
  wire [3:0] co_booth_0_0_l2_3, o_booth_0_0_l2_3;
  CARRY4 u_cy_booth_0_0_l2_3 (
    .CO(co_booth_0_0_l2_3), .O(o_booth_0_0_l2_3),
    .CI(co_booth_0_0_l2_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l1_4[1], o_booth_0_0_l1_4[0], o_booth_0_0_l1_3[3], o_booth_0_0_l1_3[2] }), .S({ bs_booth_0_0_l2_19, bs_booth_0_0_l2_18, bs_booth_0_0_l2_17, bs_booth_0_0_l2_16 }));
  wire [3:0] co_booth_0_0_l2_4, o_booth_0_0_l2_4;
  CARRY4 u_cy_booth_0_0_l2_4 (
    .CO(co_booth_0_0_l2_4), .O(o_booth_0_0_l2_4),
    .CI(co_booth_0_0_l2_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l1_5[1], o_booth_0_0_l1_5[0], o_booth_0_0_l1_4[3], o_booth_0_0_l1_4[2] }), .S({ bs_booth_0_0_l2_23, bs_booth_0_0_l2_22, bs_booth_0_0_l2_21, bs_booth_0_0_l2_20 }));
  wire [3:0] co_booth_0_0_l2_5, o_booth_0_0_l2_5;
  CARRY4 u_cy_booth_0_0_l2_5 (
    .CO(co_booth_0_0_l2_5), .O(o_booth_0_0_l2_5),
    .CI(co_booth_0_0_l2_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l1_6[1], o_booth_0_0_l1_6[0], o_booth_0_0_l1_5[3], o_booth_0_0_l1_5[2] }), .S({ bs_booth_0_0_l2_27, bs_booth_0_0_l2_26, bs_booth_0_0_l2_25, bs_booth_0_0_l2_24 }));
  wire [3:0] co_booth_0_0_l2_6, o_booth_0_0_l2_6;
  CARRY4 u_cy_booth_0_0_l2_6 (
    .CO(co_booth_0_0_l2_6), .O(o_booth_0_0_l2_6),
    .CI(co_booth_0_0_l2_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l1_7[1], o_booth_0_0_l1_7[0], o_booth_0_0_l1_6[3], o_booth_0_0_l1_6[2] }), .S({ bs_booth_0_0_l2_31, bs_booth_0_0_l2_30, bs_booth_0_0_l2_29, bs_booth_0_0_l2_28 }));
  wire [3:0] co_booth_0_0_l2_7, o_booth_0_0_l2_7;
  CARRY4 u_cy_booth_0_0_l2_7 (
    .CO(co_booth_0_0_l2_7), .O(o_booth_0_0_l2_7),
    .CI(co_booth_0_0_l2_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l1_8[1], o_booth_0_0_l1_8[0], o_booth_0_0_l1_7[3], o_booth_0_0_l1_7[2] }), .S({ bs_booth_0_0_l2_35, bs_booth_0_0_l2_34, bs_booth_0_0_l2_33, bs_booth_0_0_l2_32 }));
  wire [3:0] co_booth_0_0_l2_8, o_booth_0_0_l2_8;
  CARRY4 u_cy_booth_0_0_l2_8 (
    .CO(co_booth_0_0_l2_8), .O(o_booth_0_0_l2_8),
    .CI(co_booth_0_0_l2_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l1_8[3], o_booth_0_0_l1_8[2] }), .S({ o_booth_0_0_l1_9[1], o_booth_0_0_l1_9[0], bs_booth_0_0_l2_37, bs_booth_0_0_l2_36 }));
  wire [3:0] co_booth_0_0_l2_9, o_booth_0_0_l2_9;
  CARRY4 u_cy_booth_0_0_l2_9 (
    .CO(co_booth_0_0_l2_9), .O(o_booth_0_0_l2_9),
    .CI(co_booth_0_0_l2_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_10[1], o_booth_0_0_l1_10[0], o_booth_0_0_l1_9[3], o_booth_0_0_l1_9[2] }));
  wire [3:0] co_booth_0_0_l2_10, o_booth_0_0_l2_10;
  CARRY4 u_cy_booth_0_0_l2_10 (
    .CO(co_booth_0_0_l2_10), .O(o_booth_0_0_l2_10),
    .CI(co_booth_0_0_l2_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_11[1], o_booth_0_0_l1_11[0], o_booth_0_0_l1_10[3], o_booth_0_0_l1_10[2] }));
  wire [3:0] co_booth_0_0_l2_11, o_booth_0_0_l2_11;
  CARRY4 u_cy_booth_0_0_l2_11 (
    .CO(co_booth_0_0_l2_11), .O(o_booth_0_0_l2_11),
    .CI(co_booth_0_0_l2_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_12[1], o_booth_0_0_l1_12[0], o_booth_0_0_l1_11[3], o_booth_0_0_l1_11[2] }));
  wire [3:0] co_booth_0_0_l2_12, o_booth_0_0_l2_12;
  CARRY4 u_cy_booth_0_0_l2_12 (
    .CO(co_booth_0_0_l2_12), .O(o_booth_0_0_l2_12),
    .CI(co_booth_0_0_l2_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_13[1], o_booth_0_0_l1_13[0], o_booth_0_0_l1_12[3], o_booth_0_0_l1_12[2] }));
  wire [3:0] co_booth_0_0_l2_13, o_booth_0_0_l2_13;
  CARRY4 u_cy_booth_0_0_l2_13 (
    .CO(co_booth_0_0_l2_13), .O(o_booth_0_0_l2_13),
    .CI(co_booth_0_0_l2_12[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_14[1], o_booth_0_0_l1_14[0], o_booth_0_0_l1_13[3], o_booth_0_0_l1_13[2] }));
  wire [3:0] co_booth_0_0_l2_14, o_booth_0_0_l2_14;
  CARRY4 u_cy_booth_0_0_l2_14 (
    .CO(co_booth_0_0_l2_14), .O(o_booth_0_0_l2_14),
    .CI(co_booth_0_0_l2_13[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_15[1], o_booth_0_0_l1_15[0], o_booth_0_0_l1_14[3], o_booth_0_0_l1_14[2] }));
  wire bs_booth_0_0_l3_6, cm_booth_0_0_l3;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l3_6 (.O5(cm_booth_0_0_l3), .O6(bs_booth_0_0_l3_6), .I0(by_0_0[7]), .I1(by_0_0[6]), .I2(by_0_0[5]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l2_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l3_7;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_7 (.O(bs_booth_0_0_l3_7), .I0(o_booth_0_0_l2_0[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l3_8;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_8 (.O(bs_booth_0_0_l3_8), .I0(o_booth_0_0_l2_1[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l3_9;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_9 (.O(bs_booth_0_0_l3_9), .I0(o_booth_0_0_l2_1[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l3_10;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_10 (.O(bs_booth_0_0_l3_10), .I0(o_booth_0_0_l2_1[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l3_11;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_11 (.O(bs_booth_0_0_l3_11), .I0(o_booth_0_0_l2_1[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l3_12;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_12 (.O(bs_booth_0_0_l3_12), .I0(o_booth_0_0_l2_2[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l3_13;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_13 (.O(bs_booth_0_0_l3_13), .I0(o_booth_0_0_l2_2[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l3_14;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_14 (.O(bs_booth_0_0_l3_14), .I0(o_booth_0_0_l2_2[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l3_15;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_15 (.O(bs_booth_0_0_l3_15), .I0(o_booth_0_0_l2_2[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l3_16;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_16 (.O(bs_booth_0_0_l3_16), .I0(o_booth_0_0_l2_3[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l3_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_17 (.O(bs_booth_0_0_l3_17), .I0(o_booth_0_0_l2_3[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l3_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_18 (.O(bs_booth_0_0_l3_18), .I0(o_booth_0_0_l2_3[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l3_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_19 (.O(bs_booth_0_0_l3_19), .I0(o_booth_0_0_l2_3[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l3_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_20 (.O(bs_booth_0_0_l3_20), .I0(o_booth_0_0_l2_4[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l3_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_21 (.O(bs_booth_0_0_l3_21), .I0(o_booth_0_0_l2_4[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l3_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_22 (.O(bs_booth_0_0_l3_22), .I0(o_booth_0_0_l2_4[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l3_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_23 (.O(bs_booth_0_0_l3_23), .I0(o_booth_0_0_l2_4[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l3_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_24 (.O(bs_booth_0_0_l3_24), .I0(o_booth_0_0_l2_5[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l3_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_25 (.O(bs_booth_0_0_l3_25), .I0(o_booth_0_0_l2_5[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l3_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_26 (.O(bs_booth_0_0_l3_26), .I0(o_booth_0_0_l2_5[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l3_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_27 (.O(bs_booth_0_0_l3_27), .I0(o_booth_0_0_l2_5[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l3_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_28 (.O(bs_booth_0_0_l3_28), .I0(o_booth_0_0_l2_6[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l3_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_29 (.O(bs_booth_0_0_l3_29), .I0(o_booth_0_0_l2_6[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l3_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_30 (.O(bs_booth_0_0_l3_30), .I0(o_booth_0_0_l2_6[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l3_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_31 (.O(bs_booth_0_0_l3_31), .I0(o_booth_0_0_l2_6[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l3_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_32 (.O(bs_booth_0_0_l3_32), .I0(o_booth_0_0_l2_7[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l3_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_33 (.O(bs_booth_0_0_l3_33), .I0(o_booth_0_0_l2_7[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l3_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_34 (.O(bs_booth_0_0_l3_34), .I0(o_booth_0_0_l2_7[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l3_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_35 (.O(bs_booth_0_0_l3_35), .I0(o_booth_0_0_l2_7[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l3_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_36 (.O(bs_booth_0_0_l3_36), .I0(o_booth_0_0_l2_8[0]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l3_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l3_37 (.O(bs_booth_0_0_l3_37), .I0(o_booth_0_0_l2_8[1]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l3_38;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l3_38 (.O(bs_booth_0_0_l3_38), .I0(o_booth_0_0_l2_8[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l3_39;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l3_39 (.O(bs_booth_0_0_l3_39), .I0(o_booth_0_0_l2_8[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l3_0, o_booth_0_0_l3_0;
  CARRY4 u_cy_booth_0_0_l3_0 (
    .CO(co_booth_0_0_l3_0), .O(o_booth_0_0_l3_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l3),
    .DI({ o_booth_0_0_l2_1[1], o_booth_0_0_l2_1[0], o_booth_0_0_l2_0[3], o_booth_0_0_l2_0[2] }), .S({ bs_booth_0_0_l3_9, bs_booth_0_0_l3_8, bs_booth_0_0_l3_7, bs_booth_0_0_l3_6 }));
  wire [3:0] co_booth_0_0_l3_1, o_booth_0_0_l3_1;
  CARRY4 u_cy_booth_0_0_l3_1 (
    .CO(co_booth_0_0_l3_1), .O(o_booth_0_0_l3_1),
    .CI(co_booth_0_0_l3_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l2_2[1], o_booth_0_0_l2_2[0], o_booth_0_0_l2_1[3], o_booth_0_0_l2_1[2] }), .S({ bs_booth_0_0_l3_13, bs_booth_0_0_l3_12, bs_booth_0_0_l3_11, bs_booth_0_0_l3_10 }));
  wire [3:0] co_booth_0_0_l3_2, o_booth_0_0_l3_2;
  CARRY4 u_cy_booth_0_0_l3_2 (
    .CO(co_booth_0_0_l3_2), .O(o_booth_0_0_l3_2),
    .CI(co_booth_0_0_l3_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l2_3[1], o_booth_0_0_l2_3[0], o_booth_0_0_l2_2[3], o_booth_0_0_l2_2[2] }), .S({ bs_booth_0_0_l3_17, bs_booth_0_0_l3_16, bs_booth_0_0_l3_15, bs_booth_0_0_l3_14 }));
  wire [3:0] co_booth_0_0_l3_3, o_booth_0_0_l3_3;
  CARRY4 u_cy_booth_0_0_l3_3 (
    .CO(co_booth_0_0_l3_3), .O(o_booth_0_0_l3_3),
    .CI(co_booth_0_0_l3_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l2_4[1], o_booth_0_0_l2_4[0], o_booth_0_0_l2_3[3], o_booth_0_0_l2_3[2] }), .S({ bs_booth_0_0_l3_21, bs_booth_0_0_l3_20, bs_booth_0_0_l3_19, bs_booth_0_0_l3_18 }));
  wire [3:0] co_booth_0_0_l3_4, o_booth_0_0_l3_4;
  CARRY4 u_cy_booth_0_0_l3_4 (
    .CO(co_booth_0_0_l3_4), .O(o_booth_0_0_l3_4),
    .CI(co_booth_0_0_l3_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l2_5[1], o_booth_0_0_l2_5[0], o_booth_0_0_l2_4[3], o_booth_0_0_l2_4[2] }), .S({ bs_booth_0_0_l3_25, bs_booth_0_0_l3_24, bs_booth_0_0_l3_23, bs_booth_0_0_l3_22 }));
  wire [3:0] co_booth_0_0_l3_5, o_booth_0_0_l3_5;
  CARRY4 u_cy_booth_0_0_l3_5 (
    .CO(co_booth_0_0_l3_5), .O(o_booth_0_0_l3_5),
    .CI(co_booth_0_0_l3_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l2_6[1], o_booth_0_0_l2_6[0], o_booth_0_0_l2_5[3], o_booth_0_0_l2_5[2] }), .S({ bs_booth_0_0_l3_29, bs_booth_0_0_l3_28, bs_booth_0_0_l3_27, bs_booth_0_0_l3_26 }));
  wire [3:0] co_booth_0_0_l3_6, o_booth_0_0_l3_6;
  CARRY4 u_cy_booth_0_0_l3_6 (
    .CO(co_booth_0_0_l3_6), .O(o_booth_0_0_l3_6),
    .CI(co_booth_0_0_l3_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l2_7[1], o_booth_0_0_l2_7[0], o_booth_0_0_l2_6[3], o_booth_0_0_l2_6[2] }), .S({ bs_booth_0_0_l3_33, bs_booth_0_0_l3_32, bs_booth_0_0_l3_31, bs_booth_0_0_l3_30 }));
  wire [3:0] co_booth_0_0_l3_7, o_booth_0_0_l3_7;
  CARRY4 u_cy_booth_0_0_l3_7 (
    .CO(co_booth_0_0_l3_7), .O(o_booth_0_0_l3_7),
    .CI(co_booth_0_0_l3_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l2_8[1], o_booth_0_0_l2_8[0], o_booth_0_0_l2_7[3], o_booth_0_0_l2_7[2] }), .S({ bs_booth_0_0_l3_37, bs_booth_0_0_l3_36, bs_booth_0_0_l3_35, bs_booth_0_0_l3_34 }));
  wire [3:0] co_booth_0_0_l3_8, o_booth_0_0_l3_8;
  CARRY4 u_cy_booth_0_0_l3_8 (
    .CO(co_booth_0_0_l3_8), .O(o_booth_0_0_l3_8),
    .CI(co_booth_0_0_l3_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l2_8[3], o_booth_0_0_l2_8[2] }), .S({ o_booth_0_0_l2_9[1], o_booth_0_0_l2_9[0], bs_booth_0_0_l3_39, bs_booth_0_0_l3_38 }));
  wire [3:0] co_booth_0_0_l3_9, o_booth_0_0_l3_9;
  CARRY4 u_cy_booth_0_0_l3_9 (
    .CO(co_booth_0_0_l3_9), .O(o_booth_0_0_l3_9),
    .CI(co_booth_0_0_l3_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l2_10[1], o_booth_0_0_l2_10[0], o_booth_0_0_l2_9[3], o_booth_0_0_l2_9[2] }));
  wire [3:0] co_booth_0_0_l3_10, o_booth_0_0_l3_10;
  CARRY4 u_cy_booth_0_0_l3_10 (
    .CO(co_booth_0_0_l3_10), .O(o_booth_0_0_l3_10),
    .CI(co_booth_0_0_l3_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l2_11[1], o_booth_0_0_l2_11[0], o_booth_0_0_l2_10[3], o_booth_0_0_l2_10[2] }));
  wire [3:0] co_booth_0_0_l3_11, o_booth_0_0_l3_11;
  CARRY4 u_cy_booth_0_0_l3_11 (
    .CO(co_booth_0_0_l3_11), .O(o_booth_0_0_l3_11),
    .CI(co_booth_0_0_l3_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l2_12[1], o_booth_0_0_l2_12[0], o_booth_0_0_l2_11[3], o_booth_0_0_l2_11[2] }));
  wire [3:0] co_booth_0_0_l3_12, o_booth_0_0_l3_12;
  CARRY4 u_cy_booth_0_0_l3_12 (
    .CO(co_booth_0_0_l3_12), .O(o_booth_0_0_l3_12),
    .CI(co_booth_0_0_l3_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l2_13[1], o_booth_0_0_l2_13[0], o_booth_0_0_l2_12[3], o_booth_0_0_l2_12[2] }));
  wire [3:0] co_booth_0_0_l3_13, o_booth_0_0_l3_13;
  CARRY4 u_cy_booth_0_0_l3_13 (
    .CO(co_booth_0_0_l3_13), .O(o_booth_0_0_l3_13),
    .CI(co_booth_0_0_l3_12[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l2_14[1], o_booth_0_0_l2_14[0], o_booth_0_0_l2_13[3], o_booth_0_0_l2_13[2] }));
  wire [3:0] co_booth_0_0_l3_14, o_booth_0_0_l3_14;
  CARRY4 u_cy_booth_0_0_l3_14 (
    .CO(co_booth_0_0_l3_14), .O(o_booth_0_0_l3_14),
    .CI(co_booth_0_0_l3_13[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l2_14[3], o_booth_0_0_l2_14[2] }));
  wire bs_booth_0_0_l4_8, cm_booth_0_0_l4;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l4_8 (.O5(cm_booth_0_0_l4), .O6(bs_booth_0_0_l4_8), .I0(by_0_0[9]), .I1(by_0_0[8]), .I2(by_0_0[7]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l3_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l4_9;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_9 (.O(bs_booth_0_0_l4_9), .I0(o_booth_0_0_l3_0[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l4_10;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_10 (.O(bs_booth_0_0_l4_10), .I0(o_booth_0_0_l3_1[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l4_11;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_11 (.O(bs_booth_0_0_l4_11), .I0(o_booth_0_0_l3_1[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l4_12;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_12 (.O(bs_booth_0_0_l4_12), .I0(o_booth_0_0_l3_1[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l4_13;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_13 (.O(bs_booth_0_0_l4_13), .I0(o_booth_0_0_l3_1[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l4_14;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_14 (.O(bs_booth_0_0_l4_14), .I0(o_booth_0_0_l3_2[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l4_15;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_15 (.O(bs_booth_0_0_l4_15), .I0(o_booth_0_0_l3_2[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l4_16;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_16 (.O(bs_booth_0_0_l4_16), .I0(o_booth_0_0_l3_2[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l4_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_17 (.O(bs_booth_0_0_l4_17), .I0(o_booth_0_0_l3_2[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l4_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_18 (.O(bs_booth_0_0_l4_18), .I0(o_booth_0_0_l3_3[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l4_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_19 (.O(bs_booth_0_0_l4_19), .I0(o_booth_0_0_l3_3[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l4_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_20 (.O(bs_booth_0_0_l4_20), .I0(o_booth_0_0_l3_3[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l4_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_21 (.O(bs_booth_0_0_l4_21), .I0(o_booth_0_0_l3_3[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l4_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_22 (.O(bs_booth_0_0_l4_22), .I0(o_booth_0_0_l3_4[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l4_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_23 (.O(bs_booth_0_0_l4_23), .I0(o_booth_0_0_l3_4[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l4_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_24 (.O(bs_booth_0_0_l4_24), .I0(o_booth_0_0_l3_4[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l4_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_25 (.O(bs_booth_0_0_l4_25), .I0(o_booth_0_0_l3_4[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l4_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_26 (.O(bs_booth_0_0_l4_26), .I0(o_booth_0_0_l3_5[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l4_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_27 (.O(bs_booth_0_0_l4_27), .I0(o_booth_0_0_l3_5[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l4_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_28 (.O(bs_booth_0_0_l4_28), .I0(o_booth_0_0_l3_5[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l4_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_29 (.O(bs_booth_0_0_l4_29), .I0(o_booth_0_0_l3_5[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l4_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_30 (.O(bs_booth_0_0_l4_30), .I0(o_booth_0_0_l3_6[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l4_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_31 (.O(bs_booth_0_0_l4_31), .I0(o_booth_0_0_l3_6[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l4_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_32 (.O(bs_booth_0_0_l4_32), .I0(o_booth_0_0_l3_6[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l4_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_33 (.O(bs_booth_0_0_l4_33), .I0(o_booth_0_0_l3_6[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l4_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_34 (.O(bs_booth_0_0_l4_34), .I0(o_booth_0_0_l3_7[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l4_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_35 (.O(bs_booth_0_0_l4_35), .I0(o_booth_0_0_l3_7[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l4_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_36 (.O(bs_booth_0_0_l4_36), .I0(o_booth_0_0_l3_7[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l4_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_37 (.O(bs_booth_0_0_l4_37), .I0(o_booth_0_0_l3_7[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l4_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_38 (.O(bs_booth_0_0_l4_38), .I0(o_booth_0_0_l3_8[0]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l4_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l4_39 (.O(bs_booth_0_0_l4_39), .I0(o_booth_0_0_l3_8[1]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l4_40;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l4_40 (.O(bs_booth_0_0_l4_40), .I0(o_booth_0_0_l3_8[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l4_41;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l4_41 (.O(bs_booth_0_0_l4_41), .I0(o_booth_0_0_l3_8[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l4_0, o_booth_0_0_l4_0;
  CARRY4 u_cy_booth_0_0_l4_0 (
    .CO(co_booth_0_0_l4_0), .O(o_booth_0_0_l4_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l4),
    .DI({ o_booth_0_0_l3_1[1], o_booth_0_0_l3_1[0], o_booth_0_0_l3_0[3], o_booth_0_0_l3_0[2] }), .S({ bs_booth_0_0_l4_11, bs_booth_0_0_l4_10, bs_booth_0_0_l4_9, bs_booth_0_0_l4_8 }));
  wire [3:0] co_booth_0_0_l4_1, o_booth_0_0_l4_1;
  CARRY4 u_cy_booth_0_0_l4_1 (
    .CO(co_booth_0_0_l4_1), .O(o_booth_0_0_l4_1),
    .CI(co_booth_0_0_l4_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l3_2[1], o_booth_0_0_l3_2[0], o_booth_0_0_l3_1[3], o_booth_0_0_l3_1[2] }), .S({ bs_booth_0_0_l4_15, bs_booth_0_0_l4_14, bs_booth_0_0_l4_13, bs_booth_0_0_l4_12 }));
  wire [3:0] co_booth_0_0_l4_2, o_booth_0_0_l4_2;
  CARRY4 u_cy_booth_0_0_l4_2 (
    .CO(co_booth_0_0_l4_2), .O(o_booth_0_0_l4_2),
    .CI(co_booth_0_0_l4_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l3_3[1], o_booth_0_0_l3_3[0], o_booth_0_0_l3_2[3], o_booth_0_0_l3_2[2] }), .S({ bs_booth_0_0_l4_19, bs_booth_0_0_l4_18, bs_booth_0_0_l4_17, bs_booth_0_0_l4_16 }));
  wire [3:0] co_booth_0_0_l4_3, o_booth_0_0_l4_3;
  CARRY4 u_cy_booth_0_0_l4_3 (
    .CO(co_booth_0_0_l4_3), .O(o_booth_0_0_l4_3),
    .CI(co_booth_0_0_l4_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l3_4[1], o_booth_0_0_l3_4[0], o_booth_0_0_l3_3[3], o_booth_0_0_l3_3[2] }), .S({ bs_booth_0_0_l4_23, bs_booth_0_0_l4_22, bs_booth_0_0_l4_21, bs_booth_0_0_l4_20 }));
  wire [3:0] co_booth_0_0_l4_4, o_booth_0_0_l4_4;
  CARRY4 u_cy_booth_0_0_l4_4 (
    .CO(co_booth_0_0_l4_4), .O(o_booth_0_0_l4_4),
    .CI(co_booth_0_0_l4_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l3_5[1], o_booth_0_0_l3_5[0], o_booth_0_0_l3_4[3], o_booth_0_0_l3_4[2] }), .S({ bs_booth_0_0_l4_27, bs_booth_0_0_l4_26, bs_booth_0_0_l4_25, bs_booth_0_0_l4_24 }));
  wire [3:0] co_booth_0_0_l4_5, o_booth_0_0_l4_5;
  CARRY4 u_cy_booth_0_0_l4_5 (
    .CO(co_booth_0_0_l4_5), .O(o_booth_0_0_l4_5),
    .CI(co_booth_0_0_l4_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l3_6[1], o_booth_0_0_l3_6[0], o_booth_0_0_l3_5[3], o_booth_0_0_l3_5[2] }), .S({ bs_booth_0_0_l4_31, bs_booth_0_0_l4_30, bs_booth_0_0_l4_29, bs_booth_0_0_l4_28 }));
  wire [3:0] co_booth_0_0_l4_6, o_booth_0_0_l4_6;
  CARRY4 u_cy_booth_0_0_l4_6 (
    .CO(co_booth_0_0_l4_6), .O(o_booth_0_0_l4_6),
    .CI(co_booth_0_0_l4_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l3_7[1], o_booth_0_0_l3_7[0], o_booth_0_0_l3_6[3], o_booth_0_0_l3_6[2] }), .S({ bs_booth_0_0_l4_35, bs_booth_0_0_l4_34, bs_booth_0_0_l4_33, bs_booth_0_0_l4_32 }));
  wire [3:0] co_booth_0_0_l4_7, o_booth_0_0_l4_7;
  CARRY4 u_cy_booth_0_0_l4_7 (
    .CO(co_booth_0_0_l4_7), .O(o_booth_0_0_l4_7),
    .CI(co_booth_0_0_l4_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l3_8[1], o_booth_0_0_l3_8[0], o_booth_0_0_l3_7[3], o_booth_0_0_l3_7[2] }), .S({ bs_booth_0_0_l4_39, bs_booth_0_0_l4_38, bs_booth_0_0_l4_37, bs_booth_0_0_l4_36 }));
  wire [3:0] co_booth_0_0_l4_8, o_booth_0_0_l4_8;
  CARRY4 u_cy_booth_0_0_l4_8 (
    .CO(co_booth_0_0_l4_8), .O(o_booth_0_0_l4_8),
    .CI(co_booth_0_0_l4_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l3_8[3], o_booth_0_0_l3_8[2] }), .S({ o_booth_0_0_l3_9[1], o_booth_0_0_l3_9[0], bs_booth_0_0_l4_41, bs_booth_0_0_l4_40 }));
  wire [3:0] co_booth_0_0_l4_9, o_booth_0_0_l4_9;
  CARRY4 u_cy_booth_0_0_l4_9 (
    .CO(co_booth_0_0_l4_9), .O(o_booth_0_0_l4_9),
    .CI(co_booth_0_0_l4_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l3_10[1], o_booth_0_0_l3_10[0], o_booth_0_0_l3_9[3], o_booth_0_0_l3_9[2] }));
  wire [3:0] co_booth_0_0_l4_10, o_booth_0_0_l4_10;
  CARRY4 u_cy_booth_0_0_l4_10 (
    .CO(co_booth_0_0_l4_10), .O(o_booth_0_0_l4_10),
    .CI(co_booth_0_0_l4_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l3_11[1], o_booth_0_0_l3_11[0], o_booth_0_0_l3_10[3], o_booth_0_0_l3_10[2] }));
  wire [3:0] co_booth_0_0_l4_11, o_booth_0_0_l4_11;
  CARRY4 u_cy_booth_0_0_l4_11 (
    .CO(co_booth_0_0_l4_11), .O(o_booth_0_0_l4_11),
    .CI(co_booth_0_0_l4_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l3_12[1], o_booth_0_0_l3_12[0], o_booth_0_0_l3_11[3], o_booth_0_0_l3_11[2] }));
  wire [3:0] co_booth_0_0_l4_12, o_booth_0_0_l4_12;
  CARRY4 u_cy_booth_0_0_l4_12 (
    .CO(co_booth_0_0_l4_12), .O(o_booth_0_0_l4_12),
    .CI(co_booth_0_0_l4_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l3_13[1], o_booth_0_0_l3_13[0], o_booth_0_0_l3_12[3], o_booth_0_0_l3_12[2] }));
  wire [3:0] co_booth_0_0_l4_13, o_booth_0_0_l4_13;
  CARRY4 u_cy_booth_0_0_l4_13 (
    .CO(co_booth_0_0_l4_13), .O(o_booth_0_0_l4_13),
    .CI(co_booth_0_0_l4_12[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l3_14[1], o_booth_0_0_l3_14[0], o_booth_0_0_l3_13[3], o_booth_0_0_l3_13[2] }));
  wire bs_booth_0_0_l5_10, cm_booth_0_0_l5;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l5_10 (.O5(cm_booth_0_0_l5), .O6(bs_booth_0_0_l5_10), .I0(by_0_0[11]), .I1(by_0_0[10]), .I2(by_0_0[9]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l4_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l5_11;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_11 (.O(bs_booth_0_0_l5_11), .I0(o_booth_0_0_l4_0[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l5_12;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_12 (.O(bs_booth_0_0_l5_12), .I0(o_booth_0_0_l4_1[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l5_13;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_13 (.O(bs_booth_0_0_l5_13), .I0(o_booth_0_0_l4_1[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l5_14;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_14 (.O(bs_booth_0_0_l5_14), .I0(o_booth_0_0_l4_1[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l5_15;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_15 (.O(bs_booth_0_0_l5_15), .I0(o_booth_0_0_l4_1[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l5_16;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_16 (.O(bs_booth_0_0_l5_16), .I0(o_booth_0_0_l4_2[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l5_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_17 (.O(bs_booth_0_0_l5_17), .I0(o_booth_0_0_l4_2[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l5_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_18 (.O(bs_booth_0_0_l5_18), .I0(o_booth_0_0_l4_2[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l5_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_19 (.O(bs_booth_0_0_l5_19), .I0(o_booth_0_0_l4_2[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l5_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_20 (.O(bs_booth_0_0_l5_20), .I0(o_booth_0_0_l4_3[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l5_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_21 (.O(bs_booth_0_0_l5_21), .I0(o_booth_0_0_l4_3[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l5_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_22 (.O(bs_booth_0_0_l5_22), .I0(o_booth_0_0_l4_3[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l5_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_23 (.O(bs_booth_0_0_l5_23), .I0(o_booth_0_0_l4_3[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l5_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_24 (.O(bs_booth_0_0_l5_24), .I0(o_booth_0_0_l4_4[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l5_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_25 (.O(bs_booth_0_0_l5_25), .I0(o_booth_0_0_l4_4[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l5_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_26 (.O(bs_booth_0_0_l5_26), .I0(o_booth_0_0_l4_4[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l5_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_27 (.O(bs_booth_0_0_l5_27), .I0(o_booth_0_0_l4_4[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l5_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_28 (.O(bs_booth_0_0_l5_28), .I0(o_booth_0_0_l4_5[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l5_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_29 (.O(bs_booth_0_0_l5_29), .I0(o_booth_0_0_l4_5[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l5_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_30 (.O(bs_booth_0_0_l5_30), .I0(o_booth_0_0_l4_5[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l5_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_31 (.O(bs_booth_0_0_l5_31), .I0(o_booth_0_0_l4_5[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l5_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_32 (.O(bs_booth_0_0_l5_32), .I0(o_booth_0_0_l4_6[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l5_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_33 (.O(bs_booth_0_0_l5_33), .I0(o_booth_0_0_l4_6[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l5_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_34 (.O(bs_booth_0_0_l5_34), .I0(o_booth_0_0_l4_6[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l5_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_35 (.O(bs_booth_0_0_l5_35), .I0(o_booth_0_0_l4_6[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l5_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_36 (.O(bs_booth_0_0_l5_36), .I0(o_booth_0_0_l4_7[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l5_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_37 (.O(bs_booth_0_0_l5_37), .I0(o_booth_0_0_l4_7[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l5_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_38 (.O(bs_booth_0_0_l5_38), .I0(o_booth_0_0_l4_7[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l5_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_39 (.O(bs_booth_0_0_l5_39), .I0(o_booth_0_0_l4_7[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l5_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_40 (.O(bs_booth_0_0_l5_40), .I0(o_booth_0_0_l4_8[0]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l5_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l5_41 (.O(bs_booth_0_0_l5_41), .I0(o_booth_0_0_l4_8[1]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l5_42;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l5_42 (.O(bs_booth_0_0_l5_42), .I0(o_booth_0_0_l4_8[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l5_43;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l5_43 (.O(bs_booth_0_0_l5_43), .I0(o_booth_0_0_l4_8[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l5_0, o_booth_0_0_l5_0;
  CARRY4 u_cy_booth_0_0_l5_0 (
    .CO(co_booth_0_0_l5_0), .O(o_booth_0_0_l5_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l5),
    .DI({ o_booth_0_0_l4_1[1], o_booth_0_0_l4_1[0], o_booth_0_0_l4_0[3], o_booth_0_0_l4_0[2] }), .S({ bs_booth_0_0_l5_13, bs_booth_0_0_l5_12, bs_booth_0_0_l5_11, bs_booth_0_0_l5_10 }));
  wire [3:0] co_booth_0_0_l5_1, o_booth_0_0_l5_1;
  CARRY4 u_cy_booth_0_0_l5_1 (
    .CO(co_booth_0_0_l5_1), .O(o_booth_0_0_l5_1),
    .CI(co_booth_0_0_l5_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l4_2[1], o_booth_0_0_l4_2[0], o_booth_0_0_l4_1[3], o_booth_0_0_l4_1[2] }), .S({ bs_booth_0_0_l5_17, bs_booth_0_0_l5_16, bs_booth_0_0_l5_15, bs_booth_0_0_l5_14 }));
  wire [3:0] co_booth_0_0_l5_2, o_booth_0_0_l5_2;
  CARRY4 u_cy_booth_0_0_l5_2 (
    .CO(co_booth_0_0_l5_2), .O(o_booth_0_0_l5_2),
    .CI(co_booth_0_0_l5_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l4_3[1], o_booth_0_0_l4_3[0], o_booth_0_0_l4_2[3], o_booth_0_0_l4_2[2] }), .S({ bs_booth_0_0_l5_21, bs_booth_0_0_l5_20, bs_booth_0_0_l5_19, bs_booth_0_0_l5_18 }));
  wire [3:0] co_booth_0_0_l5_3, o_booth_0_0_l5_3;
  CARRY4 u_cy_booth_0_0_l5_3 (
    .CO(co_booth_0_0_l5_3), .O(o_booth_0_0_l5_3),
    .CI(co_booth_0_0_l5_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l4_4[1], o_booth_0_0_l4_4[0], o_booth_0_0_l4_3[3], o_booth_0_0_l4_3[2] }), .S({ bs_booth_0_0_l5_25, bs_booth_0_0_l5_24, bs_booth_0_0_l5_23, bs_booth_0_0_l5_22 }));
  wire [3:0] co_booth_0_0_l5_4, o_booth_0_0_l5_4;
  CARRY4 u_cy_booth_0_0_l5_4 (
    .CO(co_booth_0_0_l5_4), .O(o_booth_0_0_l5_4),
    .CI(co_booth_0_0_l5_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l4_5[1], o_booth_0_0_l4_5[0], o_booth_0_0_l4_4[3], o_booth_0_0_l4_4[2] }), .S({ bs_booth_0_0_l5_29, bs_booth_0_0_l5_28, bs_booth_0_0_l5_27, bs_booth_0_0_l5_26 }));
  wire [3:0] co_booth_0_0_l5_5, o_booth_0_0_l5_5;
  CARRY4 u_cy_booth_0_0_l5_5 (
    .CO(co_booth_0_0_l5_5), .O(o_booth_0_0_l5_5),
    .CI(co_booth_0_0_l5_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l4_6[1], o_booth_0_0_l4_6[0], o_booth_0_0_l4_5[3], o_booth_0_0_l4_5[2] }), .S({ bs_booth_0_0_l5_33, bs_booth_0_0_l5_32, bs_booth_0_0_l5_31, bs_booth_0_0_l5_30 }));
  wire [3:0] co_booth_0_0_l5_6, o_booth_0_0_l5_6;
  CARRY4 u_cy_booth_0_0_l5_6 (
    .CO(co_booth_0_0_l5_6), .O(o_booth_0_0_l5_6),
    .CI(co_booth_0_0_l5_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l4_7[1], o_booth_0_0_l4_7[0], o_booth_0_0_l4_6[3], o_booth_0_0_l4_6[2] }), .S({ bs_booth_0_0_l5_37, bs_booth_0_0_l5_36, bs_booth_0_0_l5_35, bs_booth_0_0_l5_34 }));
  wire [3:0] co_booth_0_0_l5_7, o_booth_0_0_l5_7;
  CARRY4 u_cy_booth_0_0_l5_7 (
    .CO(co_booth_0_0_l5_7), .O(o_booth_0_0_l5_7),
    .CI(co_booth_0_0_l5_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l4_8[1], o_booth_0_0_l4_8[0], o_booth_0_0_l4_7[3], o_booth_0_0_l4_7[2] }), .S({ bs_booth_0_0_l5_41, bs_booth_0_0_l5_40, bs_booth_0_0_l5_39, bs_booth_0_0_l5_38 }));
  wire [3:0] co_booth_0_0_l5_8, o_booth_0_0_l5_8;
  CARRY4 u_cy_booth_0_0_l5_8 (
    .CO(co_booth_0_0_l5_8), .O(o_booth_0_0_l5_8),
    .CI(co_booth_0_0_l5_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l4_8[3], o_booth_0_0_l4_8[2] }), .S({ o_booth_0_0_l4_9[1], o_booth_0_0_l4_9[0], bs_booth_0_0_l5_43, bs_booth_0_0_l5_42 }));
  wire [3:0] co_booth_0_0_l5_9, o_booth_0_0_l5_9;
  CARRY4 u_cy_booth_0_0_l5_9 (
    .CO(co_booth_0_0_l5_9), .O(o_booth_0_0_l5_9),
    .CI(co_booth_0_0_l5_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l4_10[1], o_booth_0_0_l4_10[0], o_booth_0_0_l4_9[3], o_booth_0_0_l4_9[2] }));
  wire [3:0] co_booth_0_0_l5_10, o_booth_0_0_l5_10;
  CARRY4 u_cy_booth_0_0_l5_10 (
    .CO(co_booth_0_0_l5_10), .O(o_booth_0_0_l5_10),
    .CI(co_booth_0_0_l5_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l4_11[1], o_booth_0_0_l4_11[0], o_booth_0_0_l4_10[3], o_booth_0_0_l4_10[2] }));
  wire [3:0] co_booth_0_0_l5_11, o_booth_0_0_l5_11;
  CARRY4 u_cy_booth_0_0_l5_11 (
    .CO(co_booth_0_0_l5_11), .O(o_booth_0_0_l5_11),
    .CI(co_booth_0_0_l5_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l4_12[1], o_booth_0_0_l4_12[0], o_booth_0_0_l4_11[3], o_booth_0_0_l4_11[2] }));
  wire [3:0] co_booth_0_0_l5_12, o_booth_0_0_l5_12;
  CARRY4 u_cy_booth_0_0_l5_12 (
    .CO(co_booth_0_0_l5_12), .O(o_booth_0_0_l5_12),
    .CI(co_booth_0_0_l5_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l4_13[1], o_booth_0_0_l4_13[0], o_booth_0_0_l4_12[3], o_booth_0_0_l4_12[2] }));
  wire [3:0] co_booth_0_0_l5_13, o_booth_0_0_l5_13;
  CARRY4 u_cy_booth_0_0_l5_13 (
    .CO(co_booth_0_0_l5_13), .O(o_booth_0_0_l5_13),
    .CI(co_booth_0_0_l5_12[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l4_13[3], o_booth_0_0_l4_13[2] }));
  wire bs_booth_0_0_l6_12, cm_booth_0_0_l6;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l6_12 (.O5(cm_booth_0_0_l6), .O6(bs_booth_0_0_l6_12), .I0(by_0_0[13]), .I1(by_0_0[12]), .I2(by_0_0[11]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l5_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l6_13;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_13 (.O(bs_booth_0_0_l6_13), .I0(o_booth_0_0_l5_0[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l6_14;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_14 (.O(bs_booth_0_0_l6_14), .I0(o_booth_0_0_l5_1[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l6_15;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_15 (.O(bs_booth_0_0_l6_15), .I0(o_booth_0_0_l5_1[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l6_16;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_16 (.O(bs_booth_0_0_l6_16), .I0(o_booth_0_0_l5_1[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l6_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_17 (.O(bs_booth_0_0_l6_17), .I0(o_booth_0_0_l5_1[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l6_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_18 (.O(bs_booth_0_0_l6_18), .I0(o_booth_0_0_l5_2[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l6_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_19 (.O(bs_booth_0_0_l6_19), .I0(o_booth_0_0_l5_2[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l6_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_20 (.O(bs_booth_0_0_l6_20), .I0(o_booth_0_0_l5_2[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l6_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_21 (.O(bs_booth_0_0_l6_21), .I0(o_booth_0_0_l5_2[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l6_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_22 (.O(bs_booth_0_0_l6_22), .I0(o_booth_0_0_l5_3[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l6_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_23 (.O(bs_booth_0_0_l6_23), .I0(o_booth_0_0_l5_3[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l6_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_24 (.O(bs_booth_0_0_l6_24), .I0(o_booth_0_0_l5_3[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l6_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_25 (.O(bs_booth_0_0_l6_25), .I0(o_booth_0_0_l5_3[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l6_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_26 (.O(bs_booth_0_0_l6_26), .I0(o_booth_0_0_l5_4[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l6_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_27 (.O(bs_booth_0_0_l6_27), .I0(o_booth_0_0_l5_4[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l6_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_28 (.O(bs_booth_0_0_l6_28), .I0(o_booth_0_0_l5_4[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l6_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_29 (.O(bs_booth_0_0_l6_29), .I0(o_booth_0_0_l5_4[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l6_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_30 (.O(bs_booth_0_0_l6_30), .I0(o_booth_0_0_l5_5[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l6_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_31 (.O(bs_booth_0_0_l6_31), .I0(o_booth_0_0_l5_5[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l6_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_32 (.O(bs_booth_0_0_l6_32), .I0(o_booth_0_0_l5_5[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l6_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_33 (.O(bs_booth_0_0_l6_33), .I0(o_booth_0_0_l5_5[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l6_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_34 (.O(bs_booth_0_0_l6_34), .I0(o_booth_0_0_l5_6[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l6_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_35 (.O(bs_booth_0_0_l6_35), .I0(o_booth_0_0_l5_6[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l6_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_36 (.O(bs_booth_0_0_l6_36), .I0(o_booth_0_0_l5_6[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l6_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_37 (.O(bs_booth_0_0_l6_37), .I0(o_booth_0_0_l5_6[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l6_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_38 (.O(bs_booth_0_0_l6_38), .I0(o_booth_0_0_l5_7[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l6_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_39 (.O(bs_booth_0_0_l6_39), .I0(o_booth_0_0_l5_7[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l6_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_40 (.O(bs_booth_0_0_l6_40), .I0(o_booth_0_0_l5_7[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l6_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_41 (.O(bs_booth_0_0_l6_41), .I0(o_booth_0_0_l5_7[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l6_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_42 (.O(bs_booth_0_0_l6_42), .I0(o_booth_0_0_l5_8[0]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l6_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l6_43 (.O(bs_booth_0_0_l6_43), .I0(o_booth_0_0_l5_8[1]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l6_44;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l6_44 (.O(bs_booth_0_0_l6_44), .I0(o_booth_0_0_l5_8[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l6_45;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l6_45 (.O(bs_booth_0_0_l6_45), .I0(o_booth_0_0_l5_8[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l6_0, o_booth_0_0_l6_0;
  CARRY4 u_cy_booth_0_0_l6_0 (
    .CO(co_booth_0_0_l6_0), .O(o_booth_0_0_l6_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l6),
    .DI({ o_booth_0_0_l5_1[1], o_booth_0_0_l5_1[0], o_booth_0_0_l5_0[3], o_booth_0_0_l5_0[2] }), .S({ bs_booth_0_0_l6_15, bs_booth_0_0_l6_14, bs_booth_0_0_l6_13, bs_booth_0_0_l6_12 }));
  wire [3:0] co_booth_0_0_l6_1, o_booth_0_0_l6_1;
  CARRY4 u_cy_booth_0_0_l6_1 (
    .CO(co_booth_0_0_l6_1), .O(o_booth_0_0_l6_1),
    .CI(co_booth_0_0_l6_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l5_2[1], o_booth_0_0_l5_2[0], o_booth_0_0_l5_1[3], o_booth_0_0_l5_1[2] }), .S({ bs_booth_0_0_l6_19, bs_booth_0_0_l6_18, bs_booth_0_0_l6_17, bs_booth_0_0_l6_16 }));
  wire [3:0] co_booth_0_0_l6_2, o_booth_0_0_l6_2;
  CARRY4 u_cy_booth_0_0_l6_2 (
    .CO(co_booth_0_0_l6_2), .O(o_booth_0_0_l6_2),
    .CI(co_booth_0_0_l6_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l5_3[1], o_booth_0_0_l5_3[0], o_booth_0_0_l5_2[3], o_booth_0_0_l5_2[2] }), .S({ bs_booth_0_0_l6_23, bs_booth_0_0_l6_22, bs_booth_0_0_l6_21, bs_booth_0_0_l6_20 }));
  wire [3:0] co_booth_0_0_l6_3, o_booth_0_0_l6_3;
  CARRY4 u_cy_booth_0_0_l6_3 (
    .CO(co_booth_0_0_l6_3), .O(o_booth_0_0_l6_3),
    .CI(co_booth_0_0_l6_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l5_4[1], o_booth_0_0_l5_4[0], o_booth_0_0_l5_3[3], o_booth_0_0_l5_3[2] }), .S({ bs_booth_0_0_l6_27, bs_booth_0_0_l6_26, bs_booth_0_0_l6_25, bs_booth_0_0_l6_24 }));
  wire [3:0] co_booth_0_0_l6_4, o_booth_0_0_l6_4;
  CARRY4 u_cy_booth_0_0_l6_4 (
    .CO(co_booth_0_0_l6_4), .O(o_booth_0_0_l6_4),
    .CI(co_booth_0_0_l6_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l5_5[1], o_booth_0_0_l5_5[0], o_booth_0_0_l5_4[3], o_booth_0_0_l5_4[2] }), .S({ bs_booth_0_0_l6_31, bs_booth_0_0_l6_30, bs_booth_0_0_l6_29, bs_booth_0_0_l6_28 }));
  wire [3:0] co_booth_0_0_l6_5, o_booth_0_0_l6_5;
  CARRY4 u_cy_booth_0_0_l6_5 (
    .CO(co_booth_0_0_l6_5), .O(o_booth_0_0_l6_5),
    .CI(co_booth_0_0_l6_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l5_6[1], o_booth_0_0_l5_6[0], o_booth_0_0_l5_5[3], o_booth_0_0_l5_5[2] }), .S({ bs_booth_0_0_l6_35, bs_booth_0_0_l6_34, bs_booth_0_0_l6_33, bs_booth_0_0_l6_32 }));
  wire [3:0] co_booth_0_0_l6_6, o_booth_0_0_l6_6;
  CARRY4 u_cy_booth_0_0_l6_6 (
    .CO(co_booth_0_0_l6_6), .O(o_booth_0_0_l6_6),
    .CI(co_booth_0_0_l6_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l5_7[1], o_booth_0_0_l5_7[0], o_booth_0_0_l5_6[3], o_booth_0_0_l5_6[2] }), .S({ bs_booth_0_0_l6_39, bs_booth_0_0_l6_38, bs_booth_0_0_l6_37, bs_booth_0_0_l6_36 }));
  wire [3:0] co_booth_0_0_l6_7, o_booth_0_0_l6_7;
  CARRY4 u_cy_booth_0_0_l6_7 (
    .CO(co_booth_0_0_l6_7), .O(o_booth_0_0_l6_7),
    .CI(co_booth_0_0_l6_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l5_8[1], o_booth_0_0_l5_8[0], o_booth_0_0_l5_7[3], o_booth_0_0_l5_7[2] }), .S({ bs_booth_0_0_l6_43, bs_booth_0_0_l6_42, bs_booth_0_0_l6_41, bs_booth_0_0_l6_40 }));
  wire [3:0] co_booth_0_0_l6_8, o_booth_0_0_l6_8;
  CARRY4 u_cy_booth_0_0_l6_8 (
    .CO(co_booth_0_0_l6_8), .O(o_booth_0_0_l6_8),
    .CI(co_booth_0_0_l6_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l5_8[3], o_booth_0_0_l5_8[2] }), .S({ o_booth_0_0_l5_9[1], o_booth_0_0_l5_9[0], bs_booth_0_0_l6_45, bs_booth_0_0_l6_44 }));
  wire [3:0] co_booth_0_0_l6_9, o_booth_0_0_l6_9;
  CARRY4 u_cy_booth_0_0_l6_9 (
    .CO(co_booth_0_0_l6_9), .O(o_booth_0_0_l6_9),
    .CI(co_booth_0_0_l6_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l5_10[1], o_booth_0_0_l5_10[0], o_booth_0_0_l5_9[3], o_booth_0_0_l5_9[2] }));
  wire [3:0] co_booth_0_0_l6_10, o_booth_0_0_l6_10;
  CARRY4 u_cy_booth_0_0_l6_10 (
    .CO(co_booth_0_0_l6_10), .O(o_booth_0_0_l6_10),
    .CI(co_booth_0_0_l6_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l5_11[1], o_booth_0_0_l5_11[0], o_booth_0_0_l5_10[3], o_booth_0_0_l5_10[2] }));
  wire [3:0] co_booth_0_0_l6_11, o_booth_0_0_l6_11;
  CARRY4 u_cy_booth_0_0_l6_11 (
    .CO(co_booth_0_0_l6_11), .O(o_booth_0_0_l6_11),
    .CI(co_booth_0_0_l6_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l5_12[1], o_booth_0_0_l5_12[0], o_booth_0_0_l5_11[3], o_booth_0_0_l5_11[2] }));
  wire [3:0] co_booth_0_0_l6_12, o_booth_0_0_l6_12;
  CARRY4 u_cy_booth_0_0_l6_12 (
    .CO(co_booth_0_0_l6_12), .O(o_booth_0_0_l6_12),
    .CI(co_booth_0_0_l6_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l5_13[1], o_booth_0_0_l5_13[0], o_booth_0_0_l5_12[3], o_booth_0_0_l5_12[2] }));
  wire bs_booth_0_0_l7_14, cm_booth_0_0_l7;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l7_14 (.O5(cm_booth_0_0_l7), .O6(bs_booth_0_0_l7_14), .I0(by_0_0[15]), .I1(by_0_0[14]), .I2(by_0_0[13]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l6_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l7_15;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_15 (.O(bs_booth_0_0_l7_15), .I0(o_booth_0_0_l6_0[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l7_16;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_16 (.O(bs_booth_0_0_l7_16), .I0(o_booth_0_0_l6_1[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l7_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_17 (.O(bs_booth_0_0_l7_17), .I0(o_booth_0_0_l6_1[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l7_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_18 (.O(bs_booth_0_0_l7_18), .I0(o_booth_0_0_l6_1[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l7_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_19 (.O(bs_booth_0_0_l7_19), .I0(o_booth_0_0_l6_1[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l7_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_20 (.O(bs_booth_0_0_l7_20), .I0(o_booth_0_0_l6_2[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l7_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_21 (.O(bs_booth_0_0_l7_21), .I0(o_booth_0_0_l6_2[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l7_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_22 (.O(bs_booth_0_0_l7_22), .I0(o_booth_0_0_l6_2[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l7_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_23 (.O(bs_booth_0_0_l7_23), .I0(o_booth_0_0_l6_2[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l7_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_24 (.O(bs_booth_0_0_l7_24), .I0(o_booth_0_0_l6_3[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l7_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_25 (.O(bs_booth_0_0_l7_25), .I0(o_booth_0_0_l6_3[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l7_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_26 (.O(bs_booth_0_0_l7_26), .I0(o_booth_0_0_l6_3[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l7_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_27 (.O(bs_booth_0_0_l7_27), .I0(o_booth_0_0_l6_3[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l7_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_28 (.O(bs_booth_0_0_l7_28), .I0(o_booth_0_0_l6_4[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l7_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_29 (.O(bs_booth_0_0_l7_29), .I0(o_booth_0_0_l6_4[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l7_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_30 (.O(bs_booth_0_0_l7_30), .I0(o_booth_0_0_l6_4[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l7_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_31 (.O(bs_booth_0_0_l7_31), .I0(o_booth_0_0_l6_4[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l7_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_32 (.O(bs_booth_0_0_l7_32), .I0(o_booth_0_0_l6_5[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l7_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_33 (.O(bs_booth_0_0_l7_33), .I0(o_booth_0_0_l6_5[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l7_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_34 (.O(bs_booth_0_0_l7_34), .I0(o_booth_0_0_l6_5[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l7_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_35 (.O(bs_booth_0_0_l7_35), .I0(o_booth_0_0_l6_5[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l7_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_36 (.O(bs_booth_0_0_l7_36), .I0(o_booth_0_0_l6_6[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l7_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_37 (.O(bs_booth_0_0_l7_37), .I0(o_booth_0_0_l6_6[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l7_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_38 (.O(bs_booth_0_0_l7_38), .I0(o_booth_0_0_l6_6[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l7_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_39 (.O(bs_booth_0_0_l7_39), .I0(o_booth_0_0_l6_6[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l7_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_40 (.O(bs_booth_0_0_l7_40), .I0(o_booth_0_0_l6_7[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l7_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_41 (.O(bs_booth_0_0_l7_41), .I0(o_booth_0_0_l6_7[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l7_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_42 (.O(bs_booth_0_0_l7_42), .I0(o_booth_0_0_l6_7[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l7_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_43 (.O(bs_booth_0_0_l7_43), .I0(o_booth_0_0_l6_7[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l7_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_44 (.O(bs_booth_0_0_l7_44), .I0(o_booth_0_0_l6_8[0]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l7_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l7_45 (.O(bs_booth_0_0_l7_45), .I0(o_booth_0_0_l6_8[1]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l7_46;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l7_46 (.O(bs_booth_0_0_l7_46), .I0(o_booth_0_0_l6_8[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l7_47;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l7_47 (.O(bs_booth_0_0_l7_47), .I0(o_booth_0_0_l6_8[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l7_0, o_booth_0_0_l7_0;
  CARRY4 u_cy_booth_0_0_l7_0 (
    .CO(co_booth_0_0_l7_0), .O(o_booth_0_0_l7_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l7),
    .DI({ o_booth_0_0_l6_1[1], o_booth_0_0_l6_1[0], o_booth_0_0_l6_0[3], o_booth_0_0_l6_0[2] }), .S({ bs_booth_0_0_l7_17, bs_booth_0_0_l7_16, bs_booth_0_0_l7_15, bs_booth_0_0_l7_14 }));
  wire [3:0] co_booth_0_0_l7_1, o_booth_0_0_l7_1;
  CARRY4 u_cy_booth_0_0_l7_1 (
    .CO(co_booth_0_0_l7_1), .O(o_booth_0_0_l7_1),
    .CI(co_booth_0_0_l7_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l6_2[1], o_booth_0_0_l6_2[0], o_booth_0_0_l6_1[3], o_booth_0_0_l6_1[2] }), .S({ bs_booth_0_0_l7_21, bs_booth_0_0_l7_20, bs_booth_0_0_l7_19, bs_booth_0_0_l7_18 }));
  wire [3:0] co_booth_0_0_l7_2, o_booth_0_0_l7_2;
  CARRY4 u_cy_booth_0_0_l7_2 (
    .CO(co_booth_0_0_l7_2), .O(o_booth_0_0_l7_2),
    .CI(co_booth_0_0_l7_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l6_3[1], o_booth_0_0_l6_3[0], o_booth_0_0_l6_2[3], o_booth_0_0_l6_2[2] }), .S({ bs_booth_0_0_l7_25, bs_booth_0_0_l7_24, bs_booth_0_0_l7_23, bs_booth_0_0_l7_22 }));
  wire [3:0] co_booth_0_0_l7_3, o_booth_0_0_l7_3;
  CARRY4 u_cy_booth_0_0_l7_3 (
    .CO(co_booth_0_0_l7_3), .O(o_booth_0_0_l7_3),
    .CI(co_booth_0_0_l7_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l6_4[1], o_booth_0_0_l6_4[0], o_booth_0_0_l6_3[3], o_booth_0_0_l6_3[2] }), .S({ bs_booth_0_0_l7_29, bs_booth_0_0_l7_28, bs_booth_0_0_l7_27, bs_booth_0_0_l7_26 }));
  wire [3:0] co_booth_0_0_l7_4, o_booth_0_0_l7_4;
  CARRY4 u_cy_booth_0_0_l7_4 (
    .CO(co_booth_0_0_l7_4), .O(o_booth_0_0_l7_4),
    .CI(co_booth_0_0_l7_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l6_5[1], o_booth_0_0_l6_5[0], o_booth_0_0_l6_4[3], o_booth_0_0_l6_4[2] }), .S({ bs_booth_0_0_l7_33, bs_booth_0_0_l7_32, bs_booth_0_0_l7_31, bs_booth_0_0_l7_30 }));
  wire [3:0] co_booth_0_0_l7_5, o_booth_0_0_l7_5;
  CARRY4 u_cy_booth_0_0_l7_5 (
    .CO(co_booth_0_0_l7_5), .O(o_booth_0_0_l7_5),
    .CI(co_booth_0_0_l7_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l6_6[1], o_booth_0_0_l6_6[0], o_booth_0_0_l6_5[3], o_booth_0_0_l6_5[2] }), .S({ bs_booth_0_0_l7_37, bs_booth_0_0_l7_36, bs_booth_0_0_l7_35, bs_booth_0_0_l7_34 }));
  wire [3:0] co_booth_0_0_l7_6, o_booth_0_0_l7_6;
  CARRY4 u_cy_booth_0_0_l7_6 (
    .CO(co_booth_0_0_l7_6), .O(o_booth_0_0_l7_6),
    .CI(co_booth_0_0_l7_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l6_7[1], o_booth_0_0_l6_7[0], o_booth_0_0_l6_6[3], o_booth_0_0_l6_6[2] }), .S({ bs_booth_0_0_l7_41, bs_booth_0_0_l7_40, bs_booth_0_0_l7_39, bs_booth_0_0_l7_38 }));
  wire [3:0] co_booth_0_0_l7_7, o_booth_0_0_l7_7;
  CARRY4 u_cy_booth_0_0_l7_7 (
    .CO(co_booth_0_0_l7_7), .O(o_booth_0_0_l7_7),
    .CI(co_booth_0_0_l7_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l6_8[1], o_booth_0_0_l6_8[0], o_booth_0_0_l6_7[3], o_booth_0_0_l6_7[2] }), .S({ bs_booth_0_0_l7_45, bs_booth_0_0_l7_44, bs_booth_0_0_l7_43, bs_booth_0_0_l7_42 }));
  wire [3:0] co_booth_0_0_l7_8, o_booth_0_0_l7_8;
  CARRY4 u_cy_booth_0_0_l7_8 (
    .CO(co_booth_0_0_l7_8), .O(o_booth_0_0_l7_8),
    .CI(co_booth_0_0_l7_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l6_8[3], o_booth_0_0_l6_8[2] }), .S({ o_booth_0_0_l6_9[1], o_booth_0_0_l6_9[0], bs_booth_0_0_l7_47, bs_booth_0_0_l7_46 }));
  wire [3:0] co_booth_0_0_l7_9, o_booth_0_0_l7_9;
  CARRY4 u_cy_booth_0_0_l7_9 (
    .CO(co_booth_0_0_l7_9), .O(o_booth_0_0_l7_9),
    .CI(co_booth_0_0_l7_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l6_10[1], o_booth_0_0_l6_10[0], o_booth_0_0_l6_9[3], o_booth_0_0_l6_9[2] }));
  wire [3:0] co_booth_0_0_l7_10, o_booth_0_0_l7_10;
  CARRY4 u_cy_booth_0_0_l7_10 (
    .CO(co_booth_0_0_l7_10), .O(o_booth_0_0_l7_10),
    .CI(co_booth_0_0_l7_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l6_11[1], o_booth_0_0_l6_11[0], o_booth_0_0_l6_10[3], o_booth_0_0_l6_10[2] }));
  wire [3:0] co_booth_0_0_l7_11, o_booth_0_0_l7_11;
  CARRY4 u_cy_booth_0_0_l7_11 (
    .CO(co_booth_0_0_l7_11), .O(o_booth_0_0_l7_11),
    .CI(co_booth_0_0_l7_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l6_12[1], o_booth_0_0_l6_12[0], o_booth_0_0_l6_11[3], o_booth_0_0_l6_11[2] }));
  wire [3:0] co_booth_0_0_l7_12, o_booth_0_0_l7_12;
  CARRY4 u_cy_booth_0_0_l7_12 (
    .CO(co_booth_0_0_l7_12), .O(o_booth_0_0_l7_12),
    .CI(co_booth_0_0_l7_11[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l6_12[3], o_booth_0_0_l6_12[2] }));
  wire bs_booth_0_0_l8_16, cm_booth_0_0_l8;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l8_16 (.O5(cm_booth_0_0_l8), .O6(bs_booth_0_0_l8_16), .I0(by_0_0[17]), .I1(by_0_0[16]), .I2(by_0_0[15]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l7_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l8_17;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_17 (.O(bs_booth_0_0_l8_17), .I0(o_booth_0_0_l7_0[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l8_18;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_18 (.O(bs_booth_0_0_l8_18), .I0(o_booth_0_0_l7_1[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l8_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_19 (.O(bs_booth_0_0_l8_19), .I0(o_booth_0_0_l7_1[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l8_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_20 (.O(bs_booth_0_0_l8_20), .I0(o_booth_0_0_l7_1[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l8_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_21 (.O(bs_booth_0_0_l8_21), .I0(o_booth_0_0_l7_1[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l8_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_22 (.O(bs_booth_0_0_l8_22), .I0(o_booth_0_0_l7_2[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l8_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_23 (.O(bs_booth_0_0_l8_23), .I0(o_booth_0_0_l7_2[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l8_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_24 (.O(bs_booth_0_0_l8_24), .I0(o_booth_0_0_l7_2[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l8_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_25 (.O(bs_booth_0_0_l8_25), .I0(o_booth_0_0_l7_2[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l8_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_26 (.O(bs_booth_0_0_l8_26), .I0(o_booth_0_0_l7_3[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l8_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_27 (.O(bs_booth_0_0_l8_27), .I0(o_booth_0_0_l7_3[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l8_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_28 (.O(bs_booth_0_0_l8_28), .I0(o_booth_0_0_l7_3[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l8_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_29 (.O(bs_booth_0_0_l8_29), .I0(o_booth_0_0_l7_3[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l8_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_30 (.O(bs_booth_0_0_l8_30), .I0(o_booth_0_0_l7_4[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l8_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_31 (.O(bs_booth_0_0_l8_31), .I0(o_booth_0_0_l7_4[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l8_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_32 (.O(bs_booth_0_0_l8_32), .I0(o_booth_0_0_l7_4[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l8_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_33 (.O(bs_booth_0_0_l8_33), .I0(o_booth_0_0_l7_4[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l8_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_34 (.O(bs_booth_0_0_l8_34), .I0(o_booth_0_0_l7_5[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l8_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_35 (.O(bs_booth_0_0_l8_35), .I0(o_booth_0_0_l7_5[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l8_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_36 (.O(bs_booth_0_0_l8_36), .I0(o_booth_0_0_l7_5[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l8_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_37 (.O(bs_booth_0_0_l8_37), .I0(o_booth_0_0_l7_5[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l8_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_38 (.O(bs_booth_0_0_l8_38), .I0(o_booth_0_0_l7_6[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l8_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_39 (.O(bs_booth_0_0_l8_39), .I0(o_booth_0_0_l7_6[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l8_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_40 (.O(bs_booth_0_0_l8_40), .I0(o_booth_0_0_l7_6[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l8_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_41 (.O(bs_booth_0_0_l8_41), .I0(o_booth_0_0_l7_6[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l8_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_42 (.O(bs_booth_0_0_l8_42), .I0(o_booth_0_0_l7_7[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l8_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_43 (.O(bs_booth_0_0_l8_43), .I0(o_booth_0_0_l7_7[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l8_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_44 (.O(bs_booth_0_0_l8_44), .I0(o_booth_0_0_l7_7[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l8_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_45 (.O(bs_booth_0_0_l8_45), .I0(o_booth_0_0_l7_7[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l8_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_46 (.O(bs_booth_0_0_l8_46), .I0(o_booth_0_0_l7_8[0]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l8_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l8_47 (.O(bs_booth_0_0_l8_47), .I0(o_booth_0_0_l7_8[1]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l8_48;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l8_48 (.O(bs_booth_0_0_l8_48), .I0(o_booth_0_0_l7_8[2]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l8_49;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l8_49 (.O(bs_booth_0_0_l8_49), .I0(o_booth_0_0_l7_8[3]), .I1(by_0_0[17]), .I2(by_0_0[16]), .I3(by_0_0[15]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l8_0, o_booth_0_0_l8_0;
  CARRY4 u_cy_booth_0_0_l8_0 (
    .CO(co_booth_0_0_l8_0), .O(o_booth_0_0_l8_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l8),
    .DI({ o_booth_0_0_l7_1[1], o_booth_0_0_l7_1[0], o_booth_0_0_l7_0[3], o_booth_0_0_l7_0[2] }), .S({ bs_booth_0_0_l8_19, bs_booth_0_0_l8_18, bs_booth_0_0_l8_17, bs_booth_0_0_l8_16 }));
  wire [3:0] co_booth_0_0_l8_1, o_booth_0_0_l8_1;
  CARRY4 u_cy_booth_0_0_l8_1 (
    .CO(co_booth_0_0_l8_1), .O(o_booth_0_0_l8_1),
    .CI(co_booth_0_0_l8_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l7_2[1], o_booth_0_0_l7_2[0], o_booth_0_0_l7_1[3], o_booth_0_0_l7_1[2] }), .S({ bs_booth_0_0_l8_23, bs_booth_0_0_l8_22, bs_booth_0_0_l8_21, bs_booth_0_0_l8_20 }));
  wire [3:0] co_booth_0_0_l8_2, o_booth_0_0_l8_2;
  CARRY4 u_cy_booth_0_0_l8_2 (
    .CO(co_booth_0_0_l8_2), .O(o_booth_0_0_l8_2),
    .CI(co_booth_0_0_l8_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l7_3[1], o_booth_0_0_l7_3[0], o_booth_0_0_l7_2[3], o_booth_0_0_l7_2[2] }), .S({ bs_booth_0_0_l8_27, bs_booth_0_0_l8_26, bs_booth_0_0_l8_25, bs_booth_0_0_l8_24 }));
  wire [3:0] co_booth_0_0_l8_3, o_booth_0_0_l8_3;
  CARRY4 u_cy_booth_0_0_l8_3 (
    .CO(co_booth_0_0_l8_3), .O(o_booth_0_0_l8_3),
    .CI(co_booth_0_0_l8_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l7_4[1], o_booth_0_0_l7_4[0], o_booth_0_0_l7_3[3], o_booth_0_0_l7_3[2] }), .S({ bs_booth_0_0_l8_31, bs_booth_0_0_l8_30, bs_booth_0_0_l8_29, bs_booth_0_0_l8_28 }));
  wire [3:0] co_booth_0_0_l8_4, o_booth_0_0_l8_4;
  CARRY4 u_cy_booth_0_0_l8_4 (
    .CO(co_booth_0_0_l8_4), .O(o_booth_0_0_l8_4),
    .CI(co_booth_0_0_l8_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l7_5[1], o_booth_0_0_l7_5[0], o_booth_0_0_l7_4[3], o_booth_0_0_l7_4[2] }), .S({ bs_booth_0_0_l8_35, bs_booth_0_0_l8_34, bs_booth_0_0_l8_33, bs_booth_0_0_l8_32 }));
  wire [3:0] co_booth_0_0_l8_5, o_booth_0_0_l8_5;
  CARRY4 u_cy_booth_0_0_l8_5 (
    .CO(co_booth_0_0_l8_5), .O(o_booth_0_0_l8_5),
    .CI(co_booth_0_0_l8_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l7_6[1], o_booth_0_0_l7_6[0], o_booth_0_0_l7_5[3], o_booth_0_0_l7_5[2] }), .S({ bs_booth_0_0_l8_39, bs_booth_0_0_l8_38, bs_booth_0_0_l8_37, bs_booth_0_0_l8_36 }));
  wire [3:0] co_booth_0_0_l8_6, o_booth_0_0_l8_6;
  CARRY4 u_cy_booth_0_0_l8_6 (
    .CO(co_booth_0_0_l8_6), .O(o_booth_0_0_l8_6),
    .CI(co_booth_0_0_l8_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l7_7[1], o_booth_0_0_l7_7[0], o_booth_0_0_l7_6[3], o_booth_0_0_l7_6[2] }), .S({ bs_booth_0_0_l8_43, bs_booth_0_0_l8_42, bs_booth_0_0_l8_41, bs_booth_0_0_l8_40 }));
  wire [3:0] co_booth_0_0_l8_7, o_booth_0_0_l8_7;
  CARRY4 u_cy_booth_0_0_l8_7 (
    .CO(co_booth_0_0_l8_7), .O(o_booth_0_0_l8_7),
    .CI(co_booth_0_0_l8_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l7_8[1], o_booth_0_0_l7_8[0], o_booth_0_0_l7_7[3], o_booth_0_0_l7_7[2] }), .S({ bs_booth_0_0_l8_47, bs_booth_0_0_l8_46, bs_booth_0_0_l8_45, bs_booth_0_0_l8_44 }));
  wire [3:0] co_booth_0_0_l8_8, o_booth_0_0_l8_8;
  CARRY4 u_cy_booth_0_0_l8_8 (
    .CO(co_booth_0_0_l8_8), .O(o_booth_0_0_l8_8),
    .CI(co_booth_0_0_l8_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l7_8[3], o_booth_0_0_l7_8[2] }), .S({ o_booth_0_0_l7_9[1], o_booth_0_0_l7_9[0], bs_booth_0_0_l8_49, bs_booth_0_0_l8_48 }));
  wire [3:0] co_booth_0_0_l8_9, o_booth_0_0_l8_9;
  CARRY4 u_cy_booth_0_0_l8_9 (
    .CO(co_booth_0_0_l8_9), .O(o_booth_0_0_l8_9),
    .CI(co_booth_0_0_l8_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l7_10[1], o_booth_0_0_l7_10[0], o_booth_0_0_l7_9[3], o_booth_0_0_l7_9[2] }));
  wire [3:0] co_booth_0_0_l8_10, o_booth_0_0_l8_10;
  CARRY4 u_cy_booth_0_0_l8_10 (
    .CO(co_booth_0_0_l8_10), .O(o_booth_0_0_l8_10),
    .CI(co_booth_0_0_l8_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l7_11[1], o_booth_0_0_l7_11[0], o_booth_0_0_l7_10[3], o_booth_0_0_l7_10[2] }));
  wire [3:0] co_booth_0_0_l8_11, o_booth_0_0_l8_11;
  CARRY4 u_cy_booth_0_0_l8_11 (
    .CO(co_booth_0_0_l8_11), .O(o_booth_0_0_l8_11),
    .CI(co_booth_0_0_l8_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l7_12[1], o_booth_0_0_l7_12[0], o_booth_0_0_l7_11[3], o_booth_0_0_l7_11[2] }));
  wire bs_booth_0_0_l9_18, cm_booth_0_0_l9;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l9_18 (.O5(cm_booth_0_0_l9), .O6(bs_booth_0_0_l9_18), .I0(by_0_0[19]), .I1(by_0_0[18]), .I2(by_0_0[17]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l8_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l9_19;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_19 (.O(bs_booth_0_0_l9_19), .I0(o_booth_0_0_l8_0[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l9_20;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_20 (.O(bs_booth_0_0_l9_20), .I0(o_booth_0_0_l8_1[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l9_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_21 (.O(bs_booth_0_0_l9_21), .I0(o_booth_0_0_l8_1[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l9_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_22 (.O(bs_booth_0_0_l9_22), .I0(o_booth_0_0_l8_1[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l9_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_23 (.O(bs_booth_0_0_l9_23), .I0(o_booth_0_0_l8_1[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l9_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_24 (.O(bs_booth_0_0_l9_24), .I0(o_booth_0_0_l8_2[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l9_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_25 (.O(bs_booth_0_0_l9_25), .I0(o_booth_0_0_l8_2[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l9_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_26 (.O(bs_booth_0_0_l9_26), .I0(o_booth_0_0_l8_2[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l9_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_27 (.O(bs_booth_0_0_l9_27), .I0(o_booth_0_0_l8_2[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l9_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_28 (.O(bs_booth_0_0_l9_28), .I0(o_booth_0_0_l8_3[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l9_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_29 (.O(bs_booth_0_0_l9_29), .I0(o_booth_0_0_l8_3[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l9_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_30 (.O(bs_booth_0_0_l9_30), .I0(o_booth_0_0_l8_3[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l9_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_31 (.O(bs_booth_0_0_l9_31), .I0(o_booth_0_0_l8_3[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l9_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_32 (.O(bs_booth_0_0_l9_32), .I0(o_booth_0_0_l8_4[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l9_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_33 (.O(bs_booth_0_0_l9_33), .I0(o_booth_0_0_l8_4[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l9_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_34 (.O(bs_booth_0_0_l9_34), .I0(o_booth_0_0_l8_4[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l9_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_35 (.O(bs_booth_0_0_l9_35), .I0(o_booth_0_0_l8_4[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l9_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_36 (.O(bs_booth_0_0_l9_36), .I0(o_booth_0_0_l8_5[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l9_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_37 (.O(bs_booth_0_0_l9_37), .I0(o_booth_0_0_l8_5[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l9_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_38 (.O(bs_booth_0_0_l9_38), .I0(o_booth_0_0_l8_5[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l9_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_39 (.O(bs_booth_0_0_l9_39), .I0(o_booth_0_0_l8_5[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l9_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_40 (.O(bs_booth_0_0_l9_40), .I0(o_booth_0_0_l8_6[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l9_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_41 (.O(bs_booth_0_0_l9_41), .I0(o_booth_0_0_l8_6[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l9_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_42 (.O(bs_booth_0_0_l9_42), .I0(o_booth_0_0_l8_6[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l9_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_43 (.O(bs_booth_0_0_l9_43), .I0(o_booth_0_0_l8_6[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l9_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_44 (.O(bs_booth_0_0_l9_44), .I0(o_booth_0_0_l8_7[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l9_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_45 (.O(bs_booth_0_0_l9_45), .I0(o_booth_0_0_l8_7[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l9_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_46 (.O(bs_booth_0_0_l9_46), .I0(o_booth_0_0_l8_7[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l9_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_47 (.O(bs_booth_0_0_l9_47), .I0(o_booth_0_0_l8_7[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l9_48;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_48 (.O(bs_booth_0_0_l9_48), .I0(o_booth_0_0_l8_8[0]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l9_49;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l9_49 (.O(bs_booth_0_0_l9_49), .I0(o_booth_0_0_l8_8[1]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l9_50;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l9_50 (.O(bs_booth_0_0_l9_50), .I0(o_booth_0_0_l8_8[2]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l9_51;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l9_51 (.O(bs_booth_0_0_l9_51), .I0(o_booth_0_0_l8_8[3]), .I1(by_0_0[19]), .I2(by_0_0[18]), .I3(by_0_0[17]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l9_0, o_booth_0_0_l9_0;
  CARRY4 u_cy_booth_0_0_l9_0 (
    .CO(co_booth_0_0_l9_0), .O(o_booth_0_0_l9_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l9),
    .DI({ o_booth_0_0_l8_1[1], o_booth_0_0_l8_1[0], o_booth_0_0_l8_0[3], o_booth_0_0_l8_0[2] }), .S({ bs_booth_0_0_l9_21, bs_booth_0_0_l9_20, bs_booth_0_0_l9_19, bs_booth_0_0_l9_18 }));
  wire [3:0] co_booth_0_0_l9_1, o_booth_0_0_l9_1;
  CARRY4 u_cy_booth_0_0_l9_1 (
    .CO(co_booth_0_0_l9_1), .O(o_booth_0_0_l9_1),
    .CI(co_booth_0_0_l9_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l8_2[1], o_booth_0_0_l8_2[0], o_booth_0_0_l8_1[3], o_booth_0_0_l8_1[2] }), .S({ bs_booth_0_0_l9_25, bs_booth_0_0_l9_24, bs_booth_0_0_l9_23, bs_booth_0_0_l9_22 }));
  wire [3:0] co_booth_0_0_l9_2, o_booth_0_0_l9_2;
  CARRY4 u_cy_booth_0_0_l9_2 (
    .CO(co_booth_0_0_l9_2), .O(o_booth_0_0_l9_2),
    .CI(co_booth_0_0_l9_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l8_3[1], o_booth_0_0_l8_3[0], o_booth_0_0_l8_2[3], o_booth_0_0_l8_2[2] }), .S({ bs_booth_0_0_l9_29, bs_booth_0_0_l9_28, bs_booth_0_0_l9_27, bs_booth_0_0_l9_26 }));
  wire [3:0] co_booth_0_0_l9_3, o_booth_0_0_l9_3;
  CARRY4 u_cy_booth_0_0_l9_3 (
    .CO(co_booth_0_0_l9_3), .O(o_booth_0_0_l9_3),
    .CI(co_booth_0_0_l9_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l8_4[1], o_booth_0_0_l8_4[0], o_booth_0_0_l8_3[3], o_booth_0_0_l8_3[2] }), .S({ bs_booth_0_0_l9_33, bs_booth_0_0_l9_32, bs_booth_0_0_l9_31, bs_booth_0_0_l9_30 }));
  wire [3:0] co_booth_0_0_l9_4, o_booth_0_0_l9_4;
  CARRY4 u_cy_booth_0_0_l9_4 (
    .CO(co_booth_0_0_l9_4), .O(o_booth_0_0_l9_4),
    .CI(co_booth_0_0_l9_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l8_5[1], o_booth_0_0_l8_5[0], o_booth_0_0_l8_4[3], o_booth_0_0_l8_4[2] }), .S({ bs_booth_0_0_l9_37, bs_booth_0_0_l9_36, bs_booth_0_0_l9_35, bs_booth_0_0_l9_34 }));
  wire [3:0] co_booth_0_0_l9_5, o_booth_0_0_l9_5;
  CARRY4 u_cy_booth_0_0_l9_5 (
    .CO(co_booth_0_0_l9_5), .O(o_booth_0_0_l9_5),
    .CI(co_booth_0_0_l9_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l8_6[1], o_booth_0_0_l8_6[0], o_booth_0_0_l8_5[3], o_booth_0_0_l8_5[2] }), .S({ bs_booth_0_0_l9_41, bs_booth_0_0_l9_40, bs_booth_0_0_l9_39, bs_booth_0_0_l9_38 }));
  wire [3:0] co_booth_0_0_l9_6, o_booth_0_0_l9_6;
  CARRY4 u_cy_booth_0_0_l9_6 (
    .CO(co_booth_0_0_l9_6), .O(o_booth_0_0_l9_6),
    .CI(co_booth_0_0_l9_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l8_7[1], o_booth_0_0_l8_7[0], o_booth_0_0_l8_6[3], o_booth_0_0_l8_6[2] }), .S({ bs_booth_0_0_l9_45, bs_booth_0_0_l9_44, bs_booth_0_0_l9_43, bs_booth_0_0_l9_42 }));
  wire [3:0] co_booth_0_0_l9_7, o_booth_0_0_l9_7;
  CARRY4 u_cy_booth_0_0_l9_7 (
    .CO(co_booth_0_0_l9_7), .O(o_booth_0_0_l9_7),
    .CI(co_booth_0_0_l9_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l8_8[1], o_booth_0_0_l8_8[0], o_booth_0_0_l8_7[3], o_booth_0_0_l8_7[2] }), .S({ bs_booth_0_0_l9_49, bs_booth_0_0_l9_48, bs_booth_0_0_l9_47, bs_booth_0_0_l9_46 }));
  wire [3:0] co_booth_0_0_l9_8, o_booth_0_0_l9_8;
  CARRY4 u_cy_booth_0_0_l9_8 (
    .CO(co_booth_0_0_l9_8), .O(o_booth_0_0_l9_8),
    .CI(co_booth_0_0_l9_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l8_8[3], o_booth_0_0_l8_8[2] }), .S({ o_booth_0_0_l8_9[1], o_booth_0_0_l8_9[0], bs_booth_0_0_l9_51, bs_booth_0_0_l9_50 }));
  wire [3:0] co_booth_0_0_l9_9, o_booth_0_0_l9_9;
  CARRY4 u_cy_booth_0_0_l9_9 (
    .CO(co_booth_0_0_l9_9), .O(o_booth_0_0_l9_9),
    .CI(co_booth_0_0_l9_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l8_10[1], o_booth_0_0_l8_10[0], o_booth_0_0_l8_9[3], o_booth_0_0_l8_9[2] }));
  wire [3:0] co_booth_0_0_l9_10, o_booth_0_0_l9_10;
  CARRY4 u_cy_booth_0_0_l9_10 (
    .CO(co_booth_0_0_l9_10), .O(o_booth_0_0_l9_10),
    .CI(co_booth_0_0_l9_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l8_11[1], o_booth_0_0_l8_11[0], o_booth_0_0_l8_10[3], o_booth_0_0_l8_10[2] }));
  wire [3:0] co_booth_0_0_l9_11, o_booth_0_0_l9_11;
  CARRY4 u_cy_booth_0_0_l9_11 (
    .CO(co_booth_0_0_l9_11), .O(o_booth_0_0_l9_11),
    .CI(co_booth_0_0_l9_10[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l8_11[3], o_booth_0_0_l8_11[2] }));
  wire bs_booth_0_0_l10_20, cm_booth_0_0_l10;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l10_20 (.O5(cm_booth_0_0_l10), .O6(bs_booth_0_0_l10_20), .I0(by_0_0[21]), .I1(by_0_0[20]), .I2(by_0_0[19]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l9_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l10_21;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_21 (.O(bs_booth_0_0_l10_21), .I0(o_booth_0_0_l9_0[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l10_22;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_22 (.O(bs_booth_0_0_l10_22), .I0(o_booth_0_0_l9_1[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l10_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_23 (.O(bs_booth_0_0_l10_23), .I0(o_booth_0_0_l9_1[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l10_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_24 (.O(bs_booth_0_0_l10_24), .I0(o_booth_0_0_l9_1[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l10_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_25 (.O(bs_booth_0_0_l10_25), .I0(o_booth_0_0_l9_1[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l10_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_26 (.O(bs_booth_0_0_l10_26), .I0(o_booth_0_0_l9_2[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l10_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_27 (.O(bs_booth_0_0_l10_27), .I0(o_booth_0_0_l9_2[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l10_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_28 (.O(bs_booth_0_0_l10_28), .I0(o_booth_0_0_l9_2[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l10_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_29 (.O(bs_booth_0_0_l10_29), .I0(o_booth_0_0_l9_2[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l10_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_30 (.O(bs_booth_0_0_l10_30), .I0(o_booth_0_0_l9_3[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l10_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_31 (.O(bs_booth_0_0_l10_31), .I0(o_booth_0_0_l9_3[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l10_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_32 (.O(bs_booth_0_0_l10_32), .I0(o_booth_0_0_l9_3[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l10_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_33 (.O(bs_booth_0_0_l10_33), .I0(o_booth_0_0_l9_3[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l10_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_34 (.O(bs_booth_0_0_l10_34), .I0(o_booth_0_0_l9_4[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l10_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_35 (.O(bs_booth_0_0_l10_35), .I0(o_booth_0_0_l9_4[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l10_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_36 (.O(bs_booth_0_0_l10_36), .I0(o_booth_0_0_l9_4[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l10_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_37 (.O(bs_booth_0_0_l10_37), .I0(o_booth_0_0_l9_4[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l10_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_38 (.O(bs_booth_0_0_l10_38), .I0(o_booth_0_0_l9_5[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l10_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_39 (.O(bs_booth_0_0_l10_39), .I0(o_booth_0_0_l9_5[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l10_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_40 (.O(bs_booth_0_0_l10_40), .I0(o_booth_0_0_l9_5[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l10_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_41 (.O(bs_booth_0_0_l10_41), .I0(o_booth_0_0_l9_5[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l10_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_42 (.O(bs_booth_0_0_l10_42), .I0(o_booth_0_0_l9_6[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l10_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_43 (.O(bs_booth_0_0_l10_43), .I0(o_booth_0_0_l9_6[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l10_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_44 (.O(bs_booth_0_0_l10_44), .I0(o_booth_0_0_l9_6[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l10_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_45 (.O(bs_booth_0_0_l10_45), .I0(o_booth_0_0_l9_6[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l10_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_46 (.O(bs_booth_0_0_l10_46), .I0(o_booth_0_0_l9_7[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l10_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_47 (.O(bs_booth_0_0_l10_47), .I0(o_booth_0_0_l9_7[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l10_48;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_48 (.O(bs_booth_0_0_l10_48), .I0(o_booth_0_0_l9_7[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l10_49;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_49 (.O(bs_booth_0_0_l10_49), .I0(o_booth_0_0_l9_7[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l10_50;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_50 (.O(bs_booth_0_0_l10_50), .I0(o_booth_0_0_l9_8[0]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l10_51;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l10_51 (.O(bs_booth_0_0_l10_51), .I0(o_booth_0_0_l9_8[1]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l10_52;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l10_52 (.O(bs_booth_0_0_l10_52), .I0(o_booth_0_0_l9_8[2]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l10_53;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l10_53 (.O(bs_booth_0_0_l10_53), .I0(o_booth_0_0_l9_8[3]), .I1(by_0_0[21]), .I2(by_0_0[20]), .I3(by_0_0[19]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l10_0, o_booth_0_0_l10_0;
  CARRY4 u_cy_booth_0_0_l10_0 (
    .CO(co_booth_0_0_l10_0), .O(o_booth_0_0_l10_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l10),
    .DI({ o_booth_0_0_l9_1[1], o_booth_0_0_l9_1[0], o_booth_0_0_l9_0[3], o_booth_0_0_l9_0[2] }), .S({ bs_booth_0_0_l10_23, bs_booth_0_0_l10_22, bs_booth_0_0_l10_21, bs_booth_0_0_l10_20 }));
  wire [3:0] co_booth_0_0_l10_1, o_booth_0_0_l10_1;
  CARRY4 u_cy_booth_0_0_l10_1 (
    .CO(co_booth_0_0_l10_1), .O(o_booth_0_0_l10_1),
    .CI(co_booth_0_0_l10_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l9_2[1], o_booth_0_0_l9_2[0], o_booth_0_0_l9_1[3], o_booth_0_0_l9_1[2] }), .S({ bs_booth_0_0_l10_27, bs_booth_0_0_l10_26, bs_booth_0_0_l10_25, bs_booth_0_0_l10_24 }));
  wire [3:0] co_booth_0_0_l10_2, o_booth_0_0_l10_2;
  CARRY4 u_cy_booth_0_0_l10_2 (
    .CO(co_booth_0_0_l10_2), .O(o_booth_0_0_l10_2),
    .CI(co_booth_0_0_l10_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l9_3[1], o_booth_0_0_l9_3[0], o_booth_0_0_l9_2[3], o_booth_0_0_l9_2[2] }), .S({ bs_booth_0_0_l10_31, bs_booth_0_0_l10_30, bs_booth_0_0_l10_29, bs_booth_0_0_l10_28 }));
  wire [3:0] co_booth_0_0_l10_3, o_booth_0_0_l10_3;
  CARRY4 u_cy_booth_0_0_l10_3 (
    .CO(co_booth_0_0_l10_3), .O(o_booth_0_0_l10_3),
    .CI(co_booth_0_0_l10_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l9_4[1], o_booth_0_0_l9_4[0], o_booth_0_0_l9_3[3], o_booth_0_0_l9_3[2] }), .S({ bs_booth_0_0_l10_35, bs_booth_0_0_l10_34, bs_booth_0_0_l10_33, bs_booth_0_0_l10_32 }));
  wire [3:0] co_booth_0_0_l10_4, o_booth_0_0_l10_4;
  CARRY4 u_cy_booth_0_0_l10_4 (
    .CO(co_booth_0_0_l10_4), .O(o_booth_0_0_l10_4),
    .CI(co_booth_0_0_l10_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l9_5[1], o_booth_0_0_l9_5[0], o_booth_0_0_l9_4[3], o_booth_0_0_l9_4[2] }), .S({ bs_booth_0_0_l10_39, bs_booth_0_0_l10_38, bs_booth_0_0_l10_37, bs_booth_0_0_l10_36 }));
  wire [3:0] co_booth_0_0_l10_5, o_booth_0_0_l10_5;
  CARRY4 u_cy_booth_0_0_l10_5 (
    .CO(co_booth_0_0_l10_5), .O(o_booth_0_0_l10_5),
    .CI(co_booth_0_0_l10_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l9_6[1], o_booth_0_0_l9_6[0], o_booth_0_0_l9_5[3], o_booth_0_0_l9_5[2] }), .S({ bs_booth_0_0_l10_43, bs_booth_0_0_l10_42, bs_booth_0_0_l10_41, bs_booth_0_0_l10_40 }));
  wire [3:0] co_booth_0_0_l10_6, o_booth_0_0_l10_6;
  CARRY4 u_cy_booth_0_0_l10_6 (
    .CO(co_booth_0_0_l10_6), .O(o_booth_0_0_l10_6),
    .CI(co_booth_0_0_l10_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l9_7[1], o_booth_0_0_l9_7[0], o_booth_0_0_l9_6[3], o_booth_0_0_l9_6[2] }), .S({ bs_booth_0_0_l10_47, bs_booth_0_0_l10_46, bs_booth_0_0_l10_45, bs_booth_0_0_l10_44 }));
  wire [3:0] co_booth_0_0_l10_7, o_booth_0_0_l10_7;
  CARRY4 u_cy_booth_0_0_l10_7 (
    .CO(co_booth_0_0_l10_7), .O(o_booth_0_0_l10_7),
    .CI(co_booth_0_0_l10_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l9_8[1], o_booth_0_0_l9_8[0], o_booth_0_0_l9_7[3], o_booth_0_0_l9_7[2] }), .S({ bs_booth_0_0_l10_51, bs_booth_0_0_l10_50, bs_booth_0_0_l10_49, bs_booth_0_0_l10_48 }));
  wire [3:0] co_booth_0_0_l10_8, o_booth_0_0_l10_8;
  CARRY4 u_cy_booth_0_0_l10_8 (
    .CO(co_booth_0_0_l10_8), .O(o_booth_0_0_l10_8),
    .CI(co_booth_0_0_l10_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l9_8[3], o_booth_0_0_l9_8[2] }), .S({ o_booth_0_0_l9_9[1], o_booth_0_0_l9_9[0], bs_booth_0_0_l10_53, bs_booth_0_0_l10_52 }));
  wire [3:0] co_booth_0_0_l10_9, o_booth_0_0_l10_9;
  CARRY4 u_cy_booth_0_0_l10_9 (
    .CO(co_booth_0_0_l10_9), .O(o_booth_0_0_l10_9),
    .CI(co_booth_0_0_l10_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l9_10[1], o_booth_0_0_l9_10[0], o_booth_0_0_l9_9[3], o_booth_0_0_l9_9[2] }));
  wire [3:0] co_booth_0_0_l10_10, o_booth_0_0_l10_10;
  CARRY4 u_cy_booth_0_0_l10_10 (
    .CO(co_booth_0_0_l10_10), .O(o_booth_0_0_l10_10),
    .CI(co_booth_0_0_l10_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l9_11[1], o_booth_0_0_l9_11[0], o_booth_0_0_l9_10[3], o_booth_0_0_l9_10[2] }));
  wire bs_booth_0_0_l11_22, cm_booth_0_0_l11;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l11_22 (.O5(cm_booth_0_0_l11), .O6(bs_booth_0_0_l11_22), .I0(by_0_0[23]), .I1(by_0_0[22]), .I2(by_0_0[21]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l10_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l11_23;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_23 (.O(bs_booth_0_0_l11_23), .I0(o_booth_0_0_l10_0[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l11_24;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_24 (.O(bs_booth_0_0_l11_24), .I0(o_booth_0_0_l10_1[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l11_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_25 (.O(bs_booth_0_0_l11_25), .I0(o_booth_0_0_l10_1[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l11_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_26 (.O(bs_booth_0_0_l11_26), .I0(o_booth_0_0_l10_1[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l11_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_27 (.O(bs_booth_0_0_l11_27), .I0(o_booth_0_0_l10_1[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l11_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_28 (.O(bs_booth_0_0_l11_28), .I0(o_booth_0_0_l10_2[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l11_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_29 (.O(bs_booth_0_0_l11_29), .I0(o_booth_0_0_l10_2[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l11_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_30 (.O(bs_booth_0_0_l11_30), .I0(o_booth_0_0_l10_2[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l11_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_31 (.O(bs_booth_0_0_l11_31), .I0(o_booth_0_0_l10_2[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l11_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_32 (.O(bs_booth_0_0_l11_32), .I0(o_booth_0_0_l10_3[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l11_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_33 (.O(bs_booth_0_0_l11_33), .I0(o_booth_0_0_l10_3[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l11_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_34 (.O(bs_booth_0_0_l11_34), .I0(o_booth_0_0_l10_3[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l11_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_35 (.O(bs_booth_0_0_l11_35), .I0(o_booth_0_0_l10_3[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l11_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_36 (.O(bs_booth_0_0_l11_36), .I0(o_booth_0_0_l10_4[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l11_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_37 (.O(bs_booth_0_0_l11_37), .I0(o_booth_0_0_l10_4[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l11_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_38 (.O(bs_booth_0_0_l11_38), .I0(o_booth_0_0_l10_4[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l11_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_39 (.O(bs_booth_0_0_l11_39), .I0(o_booth_0_0_l10_4[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l11_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_40 (.O(bs_booth_0_0_l11_40), .I0(o_booth_0_0_l10_5[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l11_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_41 (.O(bs_booth_0_0_l11_41), .I0(o_booth_0_0_l10_5[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l11_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_42 (.O(bs_booth_0_0_l11_42), .I0(o_booth_0_0_l10_5[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l11_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_43 (.O(bs_booth_0_0_l11_43), .I0(o_booth_0_0_l10_5[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l11_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_44 (.O(bs_booth_0_0_l11_44), .I0(o_booth_0_0_l10_6[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l11_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_45 (.O(bs_booth_0_0_l11_45), .I0(o_booth_0_0_l10_6[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l11_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_46 (.O(bs_booth_0_0_l11_46), .I0(o_booth_0_0_l10_6[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l11_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_47 (.O(bs_booth_0_0_l11_47), .I0(o_booth_0_0_l10_6[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l11_48;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_48 (.O(bs_booth_0_0_l11_48), .I0(o_booth_0_0_l10_7[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l11_49;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_49 (.O(bs_booth_0_0_l11_49), .I0(o_booth_0_0_l10_7[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l11_50;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_50 (.O(bs_booth_0_0_l11_50), .I0(o_booth_0_0_l10_7[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l11_51;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_51 (.O(bs_booth_0_0_l11_51), .I0(o_booth_0_0_l10_7[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l11_52;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_52 (.O(bs_booth_0_0_l11_52), .I0(o_booth_0_0_l10_8[0]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l11_53;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l11_53 (.O(bs_booth_0_0_l11_53), .I0(o_booth_0_0_l10_8[1]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l11_54;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l11_54 (.O(bs_booth_0_0_l11_54), .I0(o_booth_0_0_l10_8[2]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l11_55;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l11_55 (.O(bs_booth_0_0_l11_55), .I0(o_booth_0_0_l10_8[3]), .I1(by_0_0[23]), .I2(by_0_0[22]), .I3(by_0_0[21]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l11_0, o_booth_0_0_l11_0;
  CARRY4 u_cy_booth_0_0_l11_0 (
    .CO(co_booth_0_0_l11_0), .O(o_booth_0_0_l11_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l11),
    .DI({ o_booth_0_0_l10_1[1], o_booth_0_0_l10_1[0], o_booth_0_0_l10_0[3], o_booth_0_0_l10_0[2] }), .S({ bs_booth_0_0_l11_25, bs_booth_0_0_l11_24, bs_booth_0_0_l11_23, bs_booth_0_0_l11_22 }));
  wire [3:0] co_booth_0_0_l11_1, o_booth_0_0_l11_1;
  CARRY4 u_cy_booth_0_0_l11_1 (
    .CO(co_booth_0_0_l11_1), .O(o_booth_0_0_l11_1),
    .CI(co_booth_0_0_l11_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l10_2[1], o_booth_0_0_l10_2[0], o_booth_0_0_l10_1[3], o_booth_0_0_l10_1[2] }), .S({ bs_booth_0_0_l11_29, bs_booth_0_0_l11_28, bs_booth_0_0_l11_27, bs_booth_0_0_l11_26 }));
  wire [3:0] co_booth_0_0_l11_2, o_booth_0_0_l11_2;
  CARRY4 u_cy_booth_0_0_l11_2 (
    .CO(co_booth_0_0_l11_2), .O(o_booth_0_0_l11_2),
    .CI(co_booth_0_0_l11_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l10_3[1], o_booth_0_0_l10_3[0], o_booth_0_0_l10_2[3], o_booth_0_0_l10_2[2] }), .S({ bs_booth_0_0_l11_33, bs_booth_0_0_l11_32, bs_booth_0_0_l11_31, bs_booth_0_0_l11_30 }));
  wire [3:0] co_booth_0_0_l11_3, o_booth_0_0_l11_3;
  CARRY4 u_cy_booth_0_0_l11_3 (
    .CO(co_booth_0_0_l11_3), .O(o_booth_0_0_l11_3),
    .CI(co_booth_0_0_l11_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l10_4[1], o_booth_0_0_l10_4[0], o_booth_0_0_l10_3[3], o_booth_0_0_l10_3[2] }), .S({ bs_booth_0_0_l11_37, bs_booth_0_0_l11_36, bs_booth_0_0_l11_35, bs_booth_0_0_l11_34 }));
  wire [3:0] co_booth_0_0_l11_4, o_booth_0_0_l11_4;
  CARRY4 u_cy_booth_0_0_l11_4 (
    .CO(co_booth_0_0_l11_4), .O(o_booth_0_0_l11_4),
    .CI(co_booth_0_0_l11_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l10_5[1], o_booth_0_0_l10_5[0], o_booth_0_0_l10_4[3], o_booth_0_0_l10_4[2] }), .S({ bs_booth_0_0_l11_41, bs_booth_0_0_l11_40, bs_booth_0_0_l11_39, bs_booth_0_0_l11_38 }));
  wire [3:0] co_booth_0_0_l11_5, o_booth_0_0_l11_5;
  CARRY4 u_cy_booth_0_0_l11_5 (
    .CO(co_booth_0_0_l11_5), .O(o_booth_0_0_l11_5),
    .CI(co_booth_0_0_l11_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l10_6[1], o_booth_0_0_l10_6[0], o_booth_0_0_l10_5[3], o_booth_0_0_l10_5[2] }), .S({ bs_booth_0_0_l11_45, bs_booth_0_0_l11_44, bs_booth_0_0_l11_43, bs_booth_0_0_l11_42 }));
  wire [3:0] co_booth_0_0_l11_6, o_booth_0_0_l11_6;
  CARRY4 u_cy_booth_0_0_l11_6 (
    .CO(co_booth_0_0_l11_6), .O(o_booth_0_0_l11_6),
    .CI(co_booth_0_0_l11_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l10_7[1], o_booth_0_0_l10_7[0], o_booth_0_0_l10_6[3], o_booth_0_0_l10_6[2] }), .S({ bs_booth_0_0_l11_49, bs_booth_0_0_l11_48, bs_booth_0_0_l11_47, bs_booth_0_0_l11_46 }));
  wire [3:0] co_booth_0_0_l11_7, o_booth_0_0_l11_7;
  CARRY4 u_cy_booth_0_0_l11_7 (
    .CO(co_booth_0_0_l11_7), .O(o_booth_0_0_l11_7),
    .CI(co_booth_0_0_l11_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l10_8[1], o_booth_0_0_l10_8[0], o_booth_0_0_l10_7[3], o_booth_0_0_l10_7[2] }), .S({ bs_booth_0_0_l11_53, bs_booth_0_0_l11_52, bs_booth_0_0_l11_51, bs_booth_0_0_l11_50 }));
  wire [3:0] co_booth_0_0_l11_8, o_booth_0_0_l11_8;
  CARRY4 u_cy_booth_0_0_l11_8 (
    .CO(co_booth_0_0_l11_8), .O(o_booth_0_0_l11_8),
    .CI(co_booth_0_0_l11_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l10_8[3], o_booth_0_0_l10_8[2] }), .S({ o_booth_0_0_l10_9[1], o_booth_0_0_l10_9[0], bs_booth_0_0_l11_55, bs_booth_0_0_l11_54 }));
  wire [3:0] co_booth_0_0_l11_9, o_booth_0_0_l11_9;
  CARRY4 u_cy_booth_0_0_l11_9 (
    .CO(co_booth_0_0_l11_9), .O(o_booth_0_0_l11_9),
    .CI(co_booth_0_0_l11_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l10_10[1], o_booth_0_0_l10_10[0], o_booth_0_0_l10_9[3], o_booth_0_0_l10_9[2] }));
  wire [3:0] co_booth_0_0_l11_10, o_booth_0_0_l11_10;
  CARRY4 u_cy_booth_0_0_l11_10 (
    .CO(co_booth_0_0_l11_10), .O(o_booth_0_0_l11_10),
    .CI(co_booth_0_0_l11_9[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l10_10[3], o_booth_0_0_l10_10[2] }));
  wire bs_booth_0_0_l12_24, cm_booth_0_0_l12;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l12_24 (.O5(cm_booth_0_0_l12), .O6(bs_booth_0_0_l12_24), .I0(by_0_0[25]), .I1(by_0_0[24]), .I2(by_0_0[23]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l11_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l12_25;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_25 (.O(bs_booth_0_0_l12_25), .I0(o_booth_0_0_l11_0[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l12_26;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_26 (.O(bs_booth_0_0_l12_26), .I0(o_booth_0_0_l11_1[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l12_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_27 (.O(bs_booth_0_0_l12_27), .I0(o_booth_0_0_l11_1[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l12_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_28 (.O(bs_booth_0_0_l12_28), .I0(o_booth_0_0_l11_1[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l12_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_29 (.O(bs_booth_0_0_l12_29), .I0(o_booth_0_0_l11_1[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l12_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_30 (.O(bs_booth_0_0_l12_30), .I0(o_booth_0_0_l11_2[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l12_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_31 (.O(bs_booth_0_0_l12_31), .I0(o_booth_0_0_l11_2[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l12_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_32 (.O(bs_booth_0_0_l12_32), .I0(o_booth_0_0_l11_2[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l12_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_33 (.O(bs_booth_0_0_l12_33), .I0(o_booth_0_0_l11_2[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l12_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_34 (.O(bs_booth_0_0_l12_34), .I0(o_booth_0_0_l11_3[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l12_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_35 (.O(bs_booth_0_0_l12_35), .I0(o_booth_0_0_l11_3[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l12_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_36 (.O(bs_booth_0_0_l12_36), .I0(o_booth_0_0_l11_3[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l12_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_37 (.O(bs_booth_0_0_l12_37), .I0(o_booth_0_0_l11_3[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l12_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_38 (.O(bs_booth_0_0_l12_38), .I0(o_booth_0_0_l11_4[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l12_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_39 (.O(bs_booth_0_0_l12_39), .I0(o_booth_0_0_l11_4[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l12_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_40 (.O(bs_booth_0_0_l12_40), .I0(o_booth_0_0_l11_4[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l12_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_41 (.O(bs_booth_0_0_l12_41), .I0(o_booth_0_0_l11_4[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l12_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_42 (.O(bs_booth_0_0_l12_42), .I0(o_booth_0_0_l11_5[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l12_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_43 (.O(bs_booth_0_0_l12_43), .I0(o_booth_0_0_l11_5[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l12_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_44 (.O(bs_booth_0_0_l12_44), .I0(o_booth_0_0_l11_5[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l12_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_45 (.O(bs_booth_0_0_l12_45), .I0(o_booth_0_0_l11_5[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l12_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_46 (.O(bs_booth_0_0_l12_46), .I0(o_booth_0_0_l11_6[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l12_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_47 (.O(bs_booth_0_0_l12_47), .I0(o_booth_0_0_l11_6[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l12_48;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_48 (.O(bs_booth_0_0_l12_48), .I0(o_booth_0_0_l11_6[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l12_49;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_49 (.O(bs_booth_0_0_l12_49), .I0(o_booth_0_0_l11_6[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l12_50;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_50 (.O(bs_booth_0_0_l12_50), .I0(o_booth_0_0_l11_7[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l12_51;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_51 (.O(bs_booth_0_0_l12_51), .I0(o_booth_0_0_l11_7[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l12_52;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_52 (.O(bs_booth_0_0_l12_52), .I0(o_booth_0_0_l11_7[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l12_53;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_53 (.O(bs_booth_0_0_l12_53), .I0(o_booth_0_0_l11_7[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l12_54;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_54 (.O(bs_booth_0_0_l12_54), .I0(o_booth_0_0_l11_8[0]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l12_55;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l12_55 (.O(bs_booth_0_0_l12_55), .I0(o_booth_0_0_l11_8[1]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l12_56;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l12_56 (.O(bs_booth_0_0_l12_56), .I0(o_booth_0_0_l11_8[2]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l12_57;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l12_57 (.O(bs_booth_0_0_l12_57), .I0(o_booth_0_0_l11_8[3]), .I1(by_0_0[25]), .I2(by_0_0[24]), .I3(by_0_0[23]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l12_0, o_booth_0_0_l12_0;
  CARRY4 u_cy_booth_0_0_l12_0 (
    .CO(co_booth_0_0_l12_0), .O(o_booth_0_0_l12_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l12),
    .DI({ o_booth_0_0_l11_1[1], o_booth_0_0_l11_1[0], o_booth_0_0_l11_0[3], o_booth_0_0_l11_0[2] }), .S({ bs_booth_0_0_l12_27, bs_booth_0_0_l12_26, bs_booth_0_0_l12_25, bs_booth_0_0_l12_24 }));
  wire [3:0] co_booth_0_0_l12_1, o_booth_0_0_l12_1;
  CARRY4 u_cy_booth_0_0_l12_1 (
    .CO(co_booth_0_0_l12_1), .O(o_booth_0_0_l12_1),
    .CI(co_booth_0_0_l12_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l11_2[1], o_booth_0_0_l11_2[0], o_booth_0_0_l11_1[3], o_booth_0_0_l11_1[2] }), .S({ bs_booth_0_0_l12_31, bs_booth_0_0_l12_30, bs_booth_0_0_l12_29, bs_booth_0_0_l12_28 }));
  wire [3:0] co_booth_0_0_l12_2, o_booth_0_0_l12_2;
  CARRY4 u_cy_booth_0_0_l12_2 (
    .CO(co_booth_0_0_l12_2), .O(o_booth_0_0_l12_2),
    .CI(co_booth_0_0_l12_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l11_3[1], o_booth_0_0_l11_3[0], o_booth_0_0_l11_2[3], o_booth_0_0_l11_2[2] }), .S({ bs_booth_0_0_l12_35, bs_booth_0_0_l12_34, bs_booth_0_0_l12_33, bs_booth_0_0_l12_32 }));
  wire [3:0] co_booth_0_0_l12_3, o_booth_0_0_l12_3;
  CARRY4 u_cy_booth_0_0_l12_3 (
    .CO(co_booth_0_0_l12_3), .O(o_booth_0_0_l12_3),
    .CI(co_booth_0_0_l12_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l11_4[1], o_booth_0_0_l11_4[0], o_booth_0_0_l11_3[3], o_booth_0_0_l11_3[2] }), .S({ bs_booth_0_0_l12_39, bs_booth_0_0_l12_38, bs_booth_0_0_l12_37, bs_booth_0_0_l12_36 }));
  wire [3:0] co_booth_0_0_l12_4, o_booth_0_0_l12_4;
  CARRY4 u_cy_booth_0_0_l12_4 (
    .CO(co_booth_0_0_l12_4), .O(o_booth_0_0_l12_4),
    .CI(co_booth_0_0_l12_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l11_5[1], o_booth_0_0_l11_5[0], o_booth_0_0_l11_4[3], o_booth_0_0_l11_4[2] }), .S({ bs_booth_0_0_l12_43, bs_booth_0_0_l12_42, bs_booth_0_0_l12_41, bs_booth_0_0_l12_40 }));
  wire [3:0] co_booth_0_0_l12_5, o_booth_0_0_l12_5;
  CARRY4 u_cy_booth_0_0_l12_5 (
    .CO(co_booth_0_0_l12_5), .O(o_booth_0_0_l12_5),
    .CI(co_booth_0_0_l12_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l11_6[1], o_booth_0_0_l11_6[0], o_booth_0_0_l11_5[3], o_booth_0_0_l11_5[2] }), .S({ bs_booth_0_0_l12_47, bs_booth_0_0_l12_46, bs_booth_0_0_l12_45, bs_booth_0_0_l12_44 }));
  wire [3:0] co_booth_0_0_l12_6, o_booth_0_0_l12_6;
  CARRY4 u_cy_booth_0_0_l12_6 (
    .CO(co_booth_0_0_l12_6), .O(o_booth_0_0_l12_6),
    .CI(co_booth_0_0_l12_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l11_7[1], o_booth_0_0_l11_7[0], o_booth_0_0_l11_6[3], o_booth_0_0_l11_6[2] }), .S({ bs_booth_0_0_l12_51, bs_booth_0_0_l12_50, bs_booth_0_0_l12_49, bs_booth_0_0_l12_48 }));
  wire [3:0] co_booth_0_0_l12_7, o_booth_0_0_l12_7;
  CARRY4 u_cy_booth_0_0_l12_7 (
    .CO(co_booth_0_0_l12_7), .O(o_booth_0_0_l12_7),
    .CI(co_booth_0_0_l12_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l11_8[1], o_booth_0_0_l11_8[0], o_booth_0_0_l11_7[3], o_booth_0_0_l11_7[2] }), .S({ bs_booth_0_0_l12_55, bs_booth_0_0_l12_54, bs_booth_0_0_l12_53, bs_booth_0_0_l12_52 }));
  wire [3:0] co_booth_0_0_l12_8, o_booth_0_0_l12_8;
  CARRY4 u_cy_booth_0_0_l12_8 (
    .CO(co_booth_0_0_l12_8), .O(o_booth_0_0_l12_8),
    .CI(co_booth_0_0_l12_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l11_8[3], o_booth_0_0_l11_8[2] }), .S({ o_booth_0_0_l11_9[1], o_booth_0_0_l11_9[0], bs_booth_0_0_l12_57, bs_booth_0_0_l12_56 }));
  wire [3:0] co_booth_0_0_l12_9, o_booth_0_0_l12_9;
  CARRY4 u_cy_booth_0_0_l12_9 (
    .CO(co_booth_0_0_l12_9), .O(o_booth_0_0_l12_9),
    .CI(co_booth_0_0_l12_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l11_10[1], o_booth_0_0_l11_10[0], o_booth_0_0_l11_9[3], o_booth_0_0_l11_9[2] }));
  wire bs_booth_0_0_l13_26, cm_booth_0_0_l13;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l13_26 (.O5(cm_booth_0_0_l13), .O6(bs_booth_0_0_l13_26), .I0(by_0_0[27]), .I1(by_0_0[26]), .I2(by_0_0[25]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l12_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l13_27;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_27 (.O(bs_booth_0_0_l13_27), .I0(o_booth_0_0_l12_0[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l13_28;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_28 (.O(bs_booth_0_0_l13_28), .I0(o_booth_0_0_l12_1[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l13_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_29 (.O(bs_booth_0_0_l13_29), .I0(o_booth_0_0_l12_1[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l13_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_30 (.O(bs_booth_0_0_l13_30), .I0(o_booth_0_0_l12_1[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l13_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_31 (.O(bs_booth_0_0_l13_31), .I0(o_booth_0_0_l12_1[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l13_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_32 (.O(bs_booth_0_0_l13_32), .I0(o_booth_0_0_l12_2[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l13_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_33 (.O(bs_booth_0_0_l13_33), .I0(o_booth_0_0_l12_2[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l13_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_34 (.O(bs_booth_0_0_l13_34), .I0(o_booth_0_0_l12_2[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l13_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_35 (.O(bs_booth_0_0_l13_35), .I0(o_booth_0_0_l12_2[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l13_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_36 (.O(bs_booth_0_0_l13_36), .I0(o_booth_0_0_l12_3[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l13_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_37 (.O(bs_booth_0_0_l13_37), .I0(o_booth_0_0_l12_3[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l13_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_38 (.O(bs_booth_0_0_l13_38), .I0(o_booth_0_0_l12_3[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l13_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_39 (.O(bs_booth_0_0_l13_39), .I0(o_booth_0_0_l12_3[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l13_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_40 (.O(bs_booth_0_0_l13_40), .I0(o_booth_0_0_l12_4[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l13_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_41 (.O(bs_booth_0_0_l13_41), .I0(o_booth_0_0_l12_4[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l13_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_42 (.O(bs_booth_0_0_l13_42), .I0(o_booth_0_0_l12_4[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l13_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_43 (.O(bs_booth_0_0_l13_43), .I0(o_booth_0_0_l12_4[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l13_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_44 (.O(bs_booth_0_0_l13_44), .I0(o_booth_0_0_l12_5[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l13_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_45 (.O(bs_booth_0_0_l13_45), .I0(o_booth_0_0_l12_5[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l13_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_46 (.O(bs_booth_0_0_l13_46), .I0(o_booth_0_0_l12_5[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l13_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_47 (.O(bs_booth_0_0_l13_47), .I0(o_booth_0_0_l12_5[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l13_48;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_48 (.O(bs_booth_0_0_l13_48), .I0(o_booth_0_0_l12_6[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l13_49;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_49 (.O(bs_booth_0_0_l13_49), .I0(o_booth_0_0_l12_6[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l13_50;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_50 (.O(bs_booth_0_0_l13_50), .I0(o_booth_0_0_l12_6[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l13_51;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_51 (.O(bs_booth_0_0_l13_51), .I0(o_booth_0_0_l12_6[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l13_52;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_52 (.O(bs_booth_0_0_l13_52), .I0(o_booth_0_0_l12_7[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l13_53;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_53 (.O(bs_booth_0_0_l13_53), .I0(o_booth_0_0_l12_7[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l13_54;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_54 (.O(bs_booth_0_0_l13_54), .I0(o_booth_0_0_l12_7[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l13_55;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_55 (.O(bs_booth_0_0_l13_55), .I0(o_booth_0_0_l12_7[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l13_56;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_56 (.O(bs_booth_0_0_l13_56), .I0(o_booth_0_0_l12_8[0]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l13_57;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l13_57 (.O(bs_booth_0_0_l13_57), .I0(o_booth_0_0_l12_8[1]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l13_58;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l13_58 (.O(bs_booth_0_0_l13_58), .I0(o_booth_0_0_l12_8[2]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l13_59;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l13_59 (.O(bs_booth_0_0_l13_59), .I0(o_booth_0_0_l12_8[3]), .I1(by_0_0[27]), .I2(by_0_0[26]), .I3(by_0_0[25]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l13_0, o_booth_0_0_l13_0;
  CARRY4 u_cy_booth_0_0_l13_0 (
    .CO(co_booth_0_0_l13_0), .O(o_booth_0_0_l13_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l13),
    .DI({ o_booth_0_0_l12_1[1], o_booth_0_0_l12_1[0], o_booth_0_0_l12_0[3], o_booth_0_0_l12_0[2] }), .S({ bs_booth_0_0_l13_29, bs_booth_0_0_l13_28, bs_booth_0_0_l13_27, bs_booth_0_0_l13_26 }));
  wire [3:0] co_booth_0_0_l13_1, o_booth_0_0_l13_1;
  CARRY4 u_cy_booth_0_0_l13_1 (
    .CO(co_booth_0_0_l13_1), .O(o_booth_0_0_l13_1),
    .CI(co_booth_0_0_l13_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l12_2[1], o_booth_0_0_l12_2[0], o_booth_0_0_l12_1[3], o_booth_0_0_l12_1[2] }), .S({ bs_booth_0_0_l13_33, bs_booth_0_0_l13_32, bs_booth_0_0_l13_31, bs_booth_0_0_l13_30 }));
  wire [3:0] co_booth_0_0_l13_2, o_booth_0_0_l13_2;
  CARRY4 u_cy_booth_0_0_l13_2 (
    .CO(co_booth_0_0_l13_2), .O(o_booth_0_0_l13_2),
    .CI(co_booth_0_0_l13_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l12_3[1], o_booth_0_0_l12_3[0], o_booth_0_0_l12_2[3], o_booth_0_0_l12_2[2] }), .S({ bs_booth_0_0_l13_37, bs_booth_0_0_l13_36, bs_booth_0_0_l13_35, bs_booth_0_0_l13_34 }));
  wire [3:0] co_booth_0_0_l13_3, o_booth_0_0_l13_3;
  CARRY4 u_cy_booth_0_0_l13_3 (
    .CO(co_booth_0_0_l13_3), .O(o_booth_0_0_l13_3),
    .CI(co_booth_0_0_l13_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l12_4[1], o_booth_0_0_l12_4[0], o_booth_0_0_l12_3[3], o_booth_0_0_l12_3[2] }), .S({ bs_booth_0_0_l13_41, bs_booth_0_0_l13_40, bs_booth_0_0_l13_39, bs_booth_0_0_l13_38 }));
  wire [3:0] co_booth_0_0_l13_4, o_booth_0_0_l13_4;
  CARRY4 u_cy_booth_0_0_l13_4 (
    .CO(co_booth_0_0_l13_4), .O(o_booth_0_0_l13_4),
    .CI(co_booth_0_0_l13_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l12_5[1], o_booth_0_0_l12_5[0], o_booth_0_0_l12_4[3], o_booth_0_0_l12_4[2] }), .S({ bs_booth_0_0_l13_45, bs_booth_0_0_l13_44, bs_booth_0_0_l13_43, bs_booth_0_0_l13_42 }));
  wire [3:0] co_booth_0_0_l13_5, o_booth_0_0_l13_5;
  CARRY4 u_cy_booth_0_0_l13_5 (
    .CO(co_booth_0_0_l13_5), .O(o_booth_0_0_l13_5),
    .CI(co_booth_0_0_l13_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l12_6[1], o_booth_0_0_l12_6[0], o_booth_0_0_l12_5[3], o_booth_0_0_l12_5[2] }), .S({ bs_booth_0_0_l13_49, bs_booth_0_0_l13_48, bs_booth_0_0_l13_47, bs_booth_0_0_l13_46 }));
  wire [3:0] co_booth_0_0_l13_6, o_booth_0_0_l13_6;
  CARRY4 u_cy_booth_0_0_l13_6 (
    .CO(co_booth_0_0_l13_6), .O(o_booth_0_0_l13_6),
    .CI(co_booth_0_0_l13_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l12_7[1], o_booth_0_0_l12_7[0], o_booth_0_0_l12_6[3], o_booth_0_0_l12_6[2] }), .S({ bs_booth_0_0_l13_53, bs_booth_0_0_l13_52, bs_booth_0_0_l13_51, bs_booth_0_0_l13_50 }));
  wire [3:0] co_booth_0_0_l13_7, o_booth_0_0_l13_7;
  CARRY4 u_cy_booth_0_0_l13_7 (
    .CO(co_booth_0_0_l13_7), .O(o_booth_0_0_l13_7),
    .CI(co_booth_0_0_l13_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l12_8[1], o_booth_0_0_l12_8[0], o_booth_0_0_l12_7[3], o_booth_0_0_l12_7[2] }), .S({ bs_booth_0_0_l13_57, bs_booth_0_0_l13_56, bs_booth_0_0_l13_55, bs_booth_0_0_l13_54 }));
  wire [3:0] co_booth_0_0_l13_8, o_booth_0_0_l13_8;
  CARRY4 u_cy_booth_0_0_l13_8 (
    .CO(co_booth_0_0_l13_8), .O(o_booth_0_0_l13_8),
    .CI(co_booth_0_0_l13_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l12_8[3], o_booth_0_0_l12_8[2] }), .S({ o_booth_0_0_l12_9[1], o_booth_0_0_l12_9[0], bs_booth_0_0_l13_59, bs_booth_0_0_l13_58 }));
  wire [3:0] co_booth_0_0_l13_9, o_booth_0_0_l13_9;
  CARRY4 u_cy_booth_0_0_l13_9 (
    .CO(co_booth_0_0_l13_9), .O(o_booth_0_0_l13_9),
    .CI(co_booth_0_0_l13_8[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l12_9[3], o_booth_0_0_l12_9[2] }));
  wire bs_booth_0_0_l14_28, cm_booth_0_0_l14;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l14_28 (.O5(cm_booth_0_0_l14), .O6(bs_booth_0_0_l14_28), .I0(by_0_0[29]), .I1(by_0_0[28]), .I2(by_0_0[27]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l13_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l14_29;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_29 (.O(bs_booth_0_0_l14_29), .I0(o_booth_0_0_l13_0[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l14_30;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_30 (.O(bs_booth_0_0_l14_30), .I0(o_booth_0_0_l13_1[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l14_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_31 (.O(bs_booth_0_0_l14_31), .I0(o_booth_0_0_l13_1[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l14_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_32 (.O(bs_booth_0_0_l14_32), .I0(o_booth_0_0_l13_1[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l14_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_33 (.O(bs_booth_0_0_l14_33), .I0(o_booth_0_0_l13_1[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l14_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_34 (.O(bs_booth_0_0_l14_34), .I0(o_booth_0_0_l13_2[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l14_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_35 (.O(bs_booth_0_0_l14_35), .I0(o_booth_0_0_l13_2[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l14_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_36 (.O(bs_booth_0_0_l14_36), .I0(o_booth_0_0_l13_2[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l14_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_37 (.O(bs_booth_0_0_l14_37), .I0(o_booth_0_0_l13_2[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l14_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_38 (.O(bs_booth_0_0_l14_38), .I0(o_booth_0_0_l13_3[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l14_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_39 (.O(bs_booth_0_0_l14_39), .I0(o_booth_0_0_l13_3[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l14_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_40 (.O(bs_booth_0_0_l14_40), .I0(o_booth_0_0_l13_3[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l14_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_41 (.O(bs_booth_0_0_l14_41), .I0(o_booth_0_0_l13_3[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l14_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_42 (.O(bs_booth_0_0_l14_42), .I0(o_booth_0_0_l13_4[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l14_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_43 (.O(bs_booth_0_0_l14_43), .I0(o_booth_0_0_l13_4[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l14_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_44 (.O(bs_booth_0_0_l14_44), .I0(o_booth_0_0_l13_4[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l14_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_45 (.O(bs_booth_0_0_l14_45), .I0(o_booth_0_0_l13_4[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l14_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_46 (.O(bs_booth_0_0_l14_46), .I0(o_booth_0_0_l13_5[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l14_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_47 (.O(bs_booth_0_0_l14_47), .I0(o_booth_0_0_l13_5[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l14_48;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_48 (.O(bs_booth_0_0_l14_48), .I0(o_booth_0_0_l13_5[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l14_49;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_49 (.O(bs_booth_0_0_l14_49), .I0(o_booth_0_0_l13_5[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l14_50;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_50 (.O(bs_booth_0_0_l14_50), .I0(o_booth_0_0_l13_6[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l14_51;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_51 (.O(bs_booth_0_0_l14_51), .I0(o_booth_0_0_l13_6[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l14_52;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_52 (.O(bs_booth_0_0_l14_52), .I0(o_booth_0_0_l13_6[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l14_53;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_53 (.O(bs_booth_0_0_l14_53), .I0(o_booth_0_0_l13_6[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l14_54;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_54 (.O(bs_booth_0_0_l14_54), .I0(o_booth_0_0_l13_7[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l14_55;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_55 (.O(bs_booth_0_0_l14_55), .I0(o_booth_0_0_l13_7[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l14_56;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_56 (.O(bs_booth_0_0_l14_56), .I0(o_booth_0_0_l13_7[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l14_57;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_57 (.O(bs_booth_0_0_l14_57), .I0(o_booth_0_0_l13_7[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l14_58;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_58 (.O(bs_booth_0_0_l14_58), .I0(o_booth_0_0_l13_8[0]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l14_59;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l14_59 (.O(bs_booth_0_0_l14_59), .I0(o_booth_0_0_l13_8[1]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l14_60;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l14_60 (.O(bs_booth_0_0_l14_60), .I0(o_booth_0_0_l13_8[2]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l14_61;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l14_61 (.O(bs_booth_0_0_l14_61), .I0(o_booth_0_0_l13_8[3]), .I1(by_0_0[29]), .I2(by_0_0[28]), .I3(by_0_0[27]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l14_0, o_booth_0_0_l14_0;
  CARRY4 u_cy_booth_0_0_l14_0 (
    .CO(co_booth_0_0_l14_0), .O(o_booth_0_0_l14_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l14),
    .DI({ o_booth_0_0_l13_1[1], o_booth_0_0_l13_1[0], o_booth_0_0_l13_0[3], o_booth_0_0_l13_0[2] }), .S({ bs_booth_0_0_l14_31, bs_booth_0_0_l14_30, bs_booth_0_0_l14_29, bs_booth_0_0_l14_28 }));
  wire [3:0] co_booth_0_0_l14_1, o_booth_0_0_l14_1;
  CARRY4 u_cy_booth_0_0_l14_1 (
    .CO(co_booth_0_0_l14_1), .O(o_booth_0_0_l14_1),
    .CI(co_booth_0_0_l14_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l13_2[1], o_booth_0_0_l13_2[0], o_booth_0_0_l13_1[3], o_booth_0_0_l13_1[2] }), .S({ bs_booth_0_0_l14_35, bs_booth_0_0_l14_34, bs_booth_0_0_l14_33, bs_booth_0_0_l14_32 }));
  wire [3:0] co_booth_0_0_l14_2, o_booth_0_0_l14_2;
  CARRY4 u_cy_booth_0_0_l14_2 (
    .CO(co_booth_0_0_l14_2), .O(o_booth_0_0_l14_2),
    .CI(co_booth_0_0_l14_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l13_3[1], o_booth_0_0_l13_3[0], o_booth_0_0_l13_2[3], o_booth_0_0_l13_2[2] }), .S({ bs_booth_0_0_l14_39, bs_booth_0_0_l14_38, bs_booth_0_0_l14_37, bs_booth_0_0_l14_36 }));
  wire [3:0] co_booth_0_0_l14_3, o_booth_0_0_l14_3;
  CARRY4 u_cy_booth_0_0_l14_3 (
    .CO(co_booth_0_0_l14_3), .O(o_booth_0_0_l14_3),
    .CI(co_booth_0_0_l14_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l13_4[1], o_booth_0_0_l13_4[0], o_booth_0_0_l13_3[3], o_booth_0_0_l13_3[2] }), .S({ bs_booth_0_0_l14_43, bs_booth_0_0_l14_42, bs_booth_0_0_l14_41, bs_booth_0_0_l14_40 }));
  wire [3:0] co_booth_0_0_l14_4, o_booth_0_0_l14_4;
  CARRY4 u_cy_booth_0_0_l14_4 (
    .CO(co_booth_0_0_l14_4), .O(o_booth_0_0_l14_4),
    .CI(co_booth_0_0_l14_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l13_5[1], o_booth_0_0_l13_5[0], o_booth_0_0_l13_4[3], o_booth_0_0_l13_4[2] }), .S({ bs_booth_0_0_l14_47, bs_booth_0_0_l14_46, bs_booth_0_0_l14_45, bs_booth_0_0_l14_44 }));
  wire [3:0] co_booth_0_0_l14_5, o_booth_0_0_l14_5;
  CARRY4 u_cy_booth_0_0_l14_5 (
    .CO(co_booth_0_0_l14_5), .O(o_booth_0_0_l14_5),
    .CI(co_booth_0_0_l14_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l13_6[1], o_booth_0_0_l13_6[0], o_booth_0_0_l13_5[3], o_booth_0_0_l13_5[2] }), .S({ bs_booth_0_0_l14_51, bs_booth_0_0_l14_50, bs_booth_0_0_l14_49, bs_booth_0_0_l14_48 }));
  wire [3:0] co_booth_0_0_l14_6, o_booth_0_0_l14_6;
  CARRY4 u_cy_booth_0_0_l14_6 (
    .CO(co_booth_0_0_l14_6), .O(o_booth_0_0_l14_6),
    .CI(co_booth_0_0_l14_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l13_7[1], o_booth_0_0_l13_7[0], o_booth_0_0_l13_6[3], o_booth_0_0_l13_6[2] }), .S({ bs_booth_0_0_l14_55, bs_booth_0_0_l14_54, bs_booth_0_0_l14_53, bs_booth_0_0_l14_52 }));
  wire [3:0] co_booth_0_0_l14_7, o_booth_0_0_l14_7;
  CARRY4 u_cy_booth_0_0_l14_7 (
    .CO(co_booth_0_0_l14_7), .O(o_booth_0_0_l14_7),
    .CI(co_booth_0_0_l14_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l13_8[1], o_booth_0_0_l13_8[0], o_booth_0_0_l13_7[3], o_booth_0_0_l13_7[2] }), .S({ bs_booth_0_0_l14_59, bs_booth_0_0_l14_58, bs_booth_0_0_l14_57, bs_booth_0_0_l14_56 }));
  wire [3:0] co_booth_0_0_l14_8, o_booth_0_0_l14_8;
  CARRY4 u_cy_booth_0_0_l14_8 (
    .CO(co_booth_0_0_l14_8), .O(o_booth_0_0_l14_8),
    .CI(co_booth_0_0_l14_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l13_8[3], o_booth_0_0_l13_8[2] }), .S({ o_booth_0_0_l13_9[1], o_booth_0_0_l13_9[0], bs_booth_0_0_l14_61, bs_booth_0_0_l14_60 }));
  wire bs_booth_0_0_l15_30, cm_booth_0_0_l15;
  LUT6_2 #(.INIT(64'hE9D5162A2A2A2A2A)) u_bs_booth_0_0_l15_30 (.O5(cm_booth_0_0_l15), .O6(bs_booth_0_0_l15_30), .I0(by_0_0[31]), .I1(by_0_0[30]), .I2(by_0_0[29]), .I3(bx_0_0[0]), .I4(o_booth_0_0_l14_0[2]), .I5(1'b1));
  wire bs_booth_0_0_l15_31;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_31 (.O(bs_booth_0_0_l15_31), .I0(o_booth_0_0_l14_0[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[1]), .I5(bx_0_0[0]));
  wire bs_booth_0_0_l15_32;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_32 (.O(bs_booth_0_0_l15_32), .I0(o_booth_0_0_l14_1[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[2]), .I5(bx_0_0[1]));
  wire bs_booth_0_0_l15_33;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_33 (.O(bs_booth_0_0_l15_33), .I0(o_booth_0_0_l14_1[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[3]), .I5(bx_0_0[2]));
  wire bs_booth_0_0_l15_34;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_34 (.O(bs_booth_0_0_l15_34), .I0(o_booth_0_0_l14_1[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[4]), .I5(bx_0_0[3]));
  wire bs_booth_0_0_l15_35;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_35 (.O(bs_booth_0_0_l15_35), .I0(o_booth_0_0_l14_1[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[5]), .I5(bx_0_0[4]));
  wire bs_booth_0_0_l15_36;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_36 (.O(bs_booth_0_0_l15_36), .I0(o_booth_0_0_l14_2[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[6]), .I5(bx_0_0[5]));
  wire bs_booth_0_0_l15_37;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_37 (.O(bs_booth_0_0_l15_37), .I0(o_booth_0_0_l14_2[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[7]), .I5(bx_0_0[6]));
  wire bs_booth_0_0_l15_38;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_38 (.O(bs_booth_0_0_l15_38), .I0(o_booth_0_0_l14_2[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[8]), .I5(bx_0_0[7]));
  wire bs_booth_0_0_l15_39;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_39 (.O(bs_booth_0_0_l15_39), .I0(o_booth_0_0_l14_2[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[9]), .I5(bx_0_0[8]));
  wire bs_booth_0_0_l15_40;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_40 (.O(bs_booth_0_0_l15_40), .I0(o_booth_0_0_l14_3[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[10]), .I5(bx_0_0[9]));
  wire bs_booth_0_0_l15_41;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_41 (.O(bs_booth_0_0_l15_41), .I0(o_booth_0_0_l14_3[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[11]), .I5(bx_0_0[10]));
  wire bs_booth_0_0_l15_42;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_42 (.O(bs_booth_0_0_l15_42), .I0(o_booth_0_0_l14_3[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[12]), .I5(bx_0_0[11]));
  wire bs_booth_0_0_l15_43;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_43 (.O(bs_booth_0_0_l15_43), .I0(o_booth_0_0_l14_3[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[13]), .I5(bx_0_0[12]));
  wire bs_booth_0_0_l15_44;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_44 (.O(bs_booth_0_0_l15_44), .I0(o_booth_0_0_l14_4[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[14]), .I5(bx_0_0[13]));
  wire bs_booth_0_0_l15_45;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_45 (.O(bs_booth_0_0_l15_45), .I0(o_booth_0_0_l14_4[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[15]), .I5(bx_0_0[14]));
  wire bs_booth_0_0_l15_46;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_46 (.O(bs_booth_0_0_l15_46), .I0(o_booth_0_0_l14_4[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[16]), .I5(bx_0_0[15]));
  wire bs_booth_0_0_l15_47;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_47 (.O(bs_booth_0_0_l15_47), .I0(o_booth_0_0_l14_4[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[17]), .I5(bx_0_0[16]));
  wire bs_booth_0_0_l15_48;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_48 (.O(bs_booth_0_0_l15_48), .I0(o_booth_0_0_l14_5[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[18]), .I5(bx_0_0[17]));
  wire bs_booth_0_0_l15_49;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_49 (.O(bs_booth_0_0_l15_49), .I0(o_booth_0_0_l14_5[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[19]), .I5(bx_0_0[18]));
  wire bs_booth_0_0_l15_50;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_50 (.O(bs_booth_0_0_l15_50), .I0(o_booth_0_0_l14_5[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[20]), .I5(bx_0_0[19]));
  wire bs_booth_0_0_l15_51;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_51 (.O(bs_booth_0_0_l15_51), .I0(o_booth_0_0_l14_5[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[21]), .I5(bx_0_0[20]));
  wire bs_booth_0_0_l15_52;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_52 (.O(bs_booth_0_0_l15_52), .I0(o_booth_0_0_l14_6[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[22]), .I5(bx_0_0[21]));
  wire bs_booth_0_0_l15_53;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_53 (.O(bs_booth_0_0_l15_53), .I0(o_booth_0_0_l14_6[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[23]), .I5(bx_0_0[22]));
  wire bs_booth_0_0_l15_54;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_54 (.O(bs_booth_0_0_l15_54), .I0(o_booth_0_0_l14_6[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[24]), .I5(bx_0_0[23]));
  wire bs_booth_0_0_l15_55;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_55 (.O(bs_booth_0_0_l15_55), .I0(o_booth_0_0_l14_6[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[25]), .I5(bx_0_0[24]));
  wire bs_booth_0_0_l15_56;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_56 (.O(bs_booth_0_0_l15_56), .I0(o_booth_0_0_l14_7[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[26]), .I5(bx_0_0[25]));
  wire bs_booth_0_0_l15_57;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_57 (.O(bs_booth_0_0_l15_57), .I0(o_booth_0_0_l14_7[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[27]), .I5(bx_0_0[26]));
  wire bs_booth_0_0_l15_58;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_58 (.O(bs_booth_0_0_l15_58), .I0(o_booth_0_0_l14_7[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[28]), .I5(bx_0_0[27]));
  wire bs_booth_0_0_l15_59;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_59 (.O(bs_booth_0_0_l15_59), .I0(o_booth_0_0_l14_7[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[29]), .I5(bx_0_0[28]));
  wire bs_booth_0_0_l15_60;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_60 (.O(bs_booth_0_0_l15_60), .I0(o_booth_0_0_l14_8[0]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[30]), .I5(bx_0_0[29]));
  wire bs_booth_0_0_l15_61;
  LUT6 #(.INIT(64'h999A966AA996A666)) u_bs_booth_0_0_l15_61 (.O(bs_booth_0_0_l15_61), .I0(o_booth_0_0_l14_8[1]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[31]), .I5(bx_0_0[30]));
  wire bs_booth_0_0_l15_62;
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l15_62 (.O(bs_booth_0_0_l15_62), .I0(o_booth_0_0_l14_8[2]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(bx_0_0[31]), .I5(1'b0));
  wire bs_booth_0_0_l15_63;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l15_63 (.O(bs_booth_0_0_l15_63), .I0(o_booth_0_0_l14_8[3]), .I1(by_0_0[31]), .I2(by_0_0[30]), .I3(by_0_0[29]), .I4(1'b0), .I5(1'b0));
  wire [3:0] co_booth_0_0_l15_0, o_booth_0_0_l15_0;
  CARRY4 u_cy_booth_0_0_l15_0 (
    .CO(co_booth_0_0_l15_0), .O(o_booth_0_0_l15_0),
    .CI(1'b0), .CYINIT(cm_booth_0_0_l15),
    .DI({ o_booth_0_0_l14_1[1], o_booth_0_0_l14_1[0], o_booth_0_0_l14_0[3], o_booth_0_0_l14_0[2] }), .S({ bs_booth_0_0_l15_33, bs_booth_0_0_l15_32, bs_booth_0_0_l15_31, bs_booth_0_0_l15_30 }));
  wire [3:0] co_booth_0_0_l15_1, o_booth_0_0_l15_1;
  CARRY4 u_cy_booth_0_0_l15_1 (
    .CO(co_booth_0_0_l15_1), .O(o_booth_0_0_l15_1),
    .CI(co_booth_0_0_l15_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l14_2[1], o_booth_0_0_l14_2[0], o_booth_0_0_l14_1[3], o_booth_0_0_l14_1[2] }), .S({ bs_booth_0_0_l15_37, bs_booth_0_0_l15_36, bs_booth_0_0_l15_35, bs_booth_0_0_l15_34 }));
  wire [3:0] co_booth_0_0_l15_2, o_booth_0_0_l15_2;
  CARRY4 u_cy_booth_0_0_l15_2 (
    .CO(co_booth_0_0_l15_2), .O(o_booth_0_0_l15_2),
    .CI(co_booth_0_0_l15_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l14_3[1], o_booth_0_0_l14_3[0], o_booth_0_0_l14_2[3], o_booth_0_0_l14_2[2] }), .S({ bs_booth_0_0_l15_41, bs_booth_0_0_l15_40, bs_booth_0_0_l15_39, bs_booth_0_0_l15_38 }));
  wire [3:0] co_booth_0_0_l15_3, o_booth_0_0_l15_3;
  CARRY4 u_cy_booth_0_0_l15_3 (
    .CO(co_booth_0_0_l15_3), .O(o_booth_0_0_l15_3),
    .CI(co_booth_0_0_l15_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l14_4[1], o_booth_0_0_l14_4[0], o_booth_0_0_l14_3[3], o_booth_0_0_l14_3[2] }), .S({ bs_booth_0_0_l15_45, bs_booth_0_0_l15_44, bs_booth_0_0_l15_43, bs_booth_0_0_l15_42 }));
  wire [3:0] co_booth_0_0_l15_4, o_booth_0_0_l15_4;
  CARRY4 u_cy_booth_0_0_l15_4 (
    .CO(co_booth_0_0_l15_4), .O(o_booth_0_0_l15_4),
    .CI(co_booth_0_0_l15_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l14_5[1], o_booth_0_0_l14_5[0], o_booth_0_0_l14_4[3], o_booth_0_0_l14_4[2] }), .S({ bs_booth_0_0_l15_49, bs_booth_0_0_l15_48, bs_booth_0_0_l15_47, bs_booth_0_0_l15_46 }));
  wire [3:0] co_booth_0_0_l15_5, o_booth_0_0_l15_5;
  CARRY4 u_cy_booth_0_0_l15_5 (
    .CO(co_booth_0_0_l15_5), .O(o_booth_0_0_l15_5),
    .CI(co_booth_0_0_l15_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l14_6[1], o_booth_0_0_l14_6[0], o_booth_0_0_l14_5[3], o_booth_0_0_l14_5[2] }), .S({ bs_booth_0_0_l15_53, bs_booth_0_0_l15_52, bs_booth_0_0_l15_51, bs_booth_0_0_l15_50 }));
  wire [3:0] co_booth_0_0_l15_6, o_booth_0_0_l15_6;
  CARRY4 u_cy_booth_0_0_l15_6 (
    .CO(co_booth_0_0_l15_6), .O(o_booth_0_0_l15_6),
    .CI(co_booth_0_0_l15_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l14_7[1], o_booth_0_0_l14_7[0], o_booth_0_0_l14_6[3], o_booth_0_0_l14_6[2] }), .S({ bs_booth_0_0_l15_57, bs_booth_0_0_l15_56, bs_booth_0_0_l15_55, bs_booth_0_0_l15_54 }));
  wire [3:0] co_booth_0_0_l15_7, o_booth_0_0_l15_7;
  CARRY4 u_cy_booth_0_0_l15_7 (
    .CO(co_booth_0_0_l15_7), .O(o_booth_0_0_l15_7),
    .CI(co_booth_0_0_l15_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l14_8[1], o_booth_0_0_l14_8[0], o_booth_0_0_l14_7[3], o_booth_0_0_l14_7[2] }), .S({ bs_booth_0_0_l15_61, bs_booth_0_0_l15_60, bs_booth_0_0_l15_59, bs_booth_0_0_l15_58 }));
  wire [3:0] co_booth_0_0_l15_8, o_booth_0_0_l15_8;
  CARRY4 u_cy_booth_0_0_l15_8 (
    .CO(co_booth_0_0_l15_8), .O(o_booth_0_0_l15_8),
    .CI(co_booth_0_0_l15_7[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, o_booth_0_0_l14_8[3], o_booth_0_0_l14_8[2] }), .S({ 1'b0, 1'b0, bs_booth_0_0_l15_63, bs_booth_0_0_l15_62 }));
  wire bs_booth_0_0_l16_32, bs_booth_0_0_l16_33;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_32 (.O5(bs_booth_0_0_l16_32), .O6(bs_booth_0_0_l16_33), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_0[2]), .I2(bx_0_0[0]), .I3(o_booth_0_0_l15_0[3]), .I4(bx_0_0[1]), .I5(1'b1));
  wire bs_booth_0_0_l16_34, bs_booth_0_0_l16_35;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_34 (.O5(bs_booth_0_0_l16_34), .O6(bs_booth_0_0_l16_35), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_1[0]), .I2(bx_0_0[2]), .I3(o_booth_0_0_l15_1[1]), .I4(bx_0_0[3]), .I5(1'b1));
  wire bs_booth_0_0_l16_36, bs_booth_0_0_l16_37;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_36 (.O5(bs_booth_0_0_l16_36), .O6(bs_booth_0_0_l16_37), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_1[2]), .I2(bx_0_0[4]), .I3(o_booth_0_0_l15_1[3]), .I4(bx_0_0[5]), .I5(1'b1));
  wire bs_booth_0_0_l16_38, bs_booth_0_0_l16_39;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_38 (.O5(bs_booth_0_0_l16_38), .O6(bs_booth_0_0_l16_39), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_2[0]), .I2(bx_0_0[6]), .I3(o_booth_0_0_l15_2[1]), .I4(bx_0_0[7]), .I5(1'b1));
  wire bs_booth_0_0_l16_40, bs_booth_0_0_l16_41;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_40 (.O5(bs_booth_0_0_l16_40), .O6(bs_booth_0_0_l16_41), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_2[2]), .I2(bx_0_0[8]), .I3(o_booth_0_0_l15_2[3]), .I4(bx_0_0[9]), .I5(1'b1));
  wire bs_booth_0_0_l16_42, bs_booth_0_0_l16_43;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_42 (.O5(bs_booth_0_0_l16_42), .O6(bs_booth_0_0_l16_43), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_3[0]), .I2(bx_0_0[10]), .I3(o_booth_0_0_l15_3[1]), .I4(bx_0_0[11]), .I5(1'b1));
  wire bs_booth_0_0_l16_44, bs_booth_0_0_l16_45;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_44 (.O5(bs_booth_0_0_l16_44), .O6(bs_booth_0_0_l16_45), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_3[2]), .I2(bx_0_0[12]), .I3(o_booth_0_0_l15_3[3]), .I4(bx_0_0[13]), .I5(1'b1));
  wire bs_booth_0_0_l16_46, bs_booth_0_0_l16_47;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_46 (.O5(bs_booth_0_0_l16_46), .O6(bs_booth_0_0_l16_47), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_4[0]), .I2(bx_0_0[14]), .I3(o_booth_0_0_l15_4[1]), .I4(bx_0_0[15]), .I5(1'b1));
  wire bs_booth_0_0_l16_48, bs_booth_0_0_l16_49;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_48 (.O5(bs_booth_0_0_l16_48), .O6(bs_booth_0_0_l16_49), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_4[2]), .I2(bx_0_0[16]), .I3(o_booth_0_0_l15_4[3]), .I4(bx_0_0[17]), .I5(1'b1));
  wire bs_booth_0_0_l16_50, bs_booth_0_0_l16_51;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_50 (.O5(bs_booth_0_0_l16_50), .O6(bs_booth_0_0_l16_51), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_5[0]), .I2(bx_0_0[18]), .I3(o_booth_0_0_l15_5[1]), .I4(bx_0_0[19]), .I5(1'b1));
  wire bs_booth_0_0_l16_52, bs_booth_0_0_l16_53;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_52 (.O5(bs_booth_0_0_l16_52), .O6(bs_booth_0_0_l16_53), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_5[2]), .I2(bx_0_0[20]), .I3(o_booth_0_0_l15_5[3]), .I4(bx_0_0[21]), .I5(1'b1));
  wire bs_booth_0_0_l16_54, bs_booth_0_0_l16_55;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_54 (.O5(bs_booth_0_0_l16_54), .O6(bs_booth_0_0_l16_55), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_6[0]), .I2(bx_0_0[22]), .I3(o_booth_0_0_l15_6[1]), .I4(bx_0_0[23]), .I5(1'b1));
  wire bs_booth_0_0_l16_56, bs_booth_0_0_l16_57;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_56 (.O5(bs_booth_0_0_l16_56), .O6(bs_booth_0_0_l16_57), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_6[2]), .I2(bx_0_0[24]), .I3(o_booth_0_0_l15_6[3]), .I4(bx_0_0[25]), .I5(1'b1));
  wire bs_booth_0_0_l16_58, bs_booth_0_0_l16_59;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_58 (.O5(bs_booth_0_0_l16_58), .O6(bs_booth_0_0_l16_59), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_7[0]), .I2(bx_0_0[26]), .I3(o_booth_0_0_l15_7[1]), .I4(bx_0_0[27]), .I5(1'b1));
  wire bs_booth_0_0_l16_60, bs_booth_0_0_l16_61;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_60 (.O5(bs_booth_0_0_l16_60), .O6(bs_booth_0_0_l16_61), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_7[2]), .I2(bx_0_0[28]), .I3(o_booth_0_0_l15_7[3]), .I4(bx_0_0[29]), .I5(1'b1));
  wire bs_booth_0_0_l16_62, bs_booth_0_0_l16_63;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l16_62 (.O5(bs_booth_0_0_l16_62), .O6(bs_booth_0_0_l16_63), .I0(by_0_0[31]), .I1(o_booth_0_0_l15_8[0]), .I2(bx_0_0[30]), .I3(o_booth_0_0_l15_8[1]), .I4(bx_0_0[31]), .I5(1'b1));
  wire [3:0] co_booth_0_0_l16_0, o_booth_0_0_l16_0;
  CARRY4 u_cy_booth_0_0_l16_0 (
    .CO(co_booth_0_0_l16_0), .O(o_booth_0_0_l16_0),
    .CI(1'b0), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_1[1], o_booth_0_0_l15_1[0], o_booth_0_0_l15_0[3], o_booth_0_0_l15_0[2] }), .S({ bs_booth_0_0_l16_35, bs_booth_0_0_l16_34, bs_booth_0_0_l16_33, bs_booth_0_0_l16_32 }));
  wire [3:0] co_booth_0_0_l16_1, o_booth_0_0_l16_1;
  CARRY4 u_cy_booth_0_0_l16_1 (
    .CO(co_booth_0_0_l16_1), .O(o_booth_0_0_l16_1),
    .CI(co_booth_0_0_l16_0[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_2[1], o_booth_0_0_l15_2[0], o_booth_0_0_l15_1[3], o_booth_0_0_l15_1[2] }), .S({ bs_booth_0_0_l16_39, bs_booth_0_0_l16_38, bs_booth_0_0_l16_37, bs_booth_0_0_l16_36 }));
  wire [3:0] co_booth_0_0_l16_2, o_booth_0_0_l16_2;
  CARRY4 u_cy_booth_0_0_l16_2 (
    .CO(co_booth_0_0_l16_2), .O(o_booth_0_0_l16_2),
    .CI(co_booth_0_0_l16_1[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_3[1], o_booth_0_0_l15_3[0], o_booth_0_0_l15_2[3], o_booth_0_0_l15_2[2] }), .S({ bs_booth_0_0_l16_43, bs_booth_0_0_l16_42, bs_booth_0_0_l16_41, bs_booth_0_0_l16_40 }));
  wire [3:0] co_booth_0_0_l16_3, o_booth_0_0_l16_3;
  CARRY4 u_cy_booth_0_0_l16_3 (
    .CO(co_booth_0_0_l16_3), .O(o_booth_0_0_l16_3),
    .CI(co_booth_0_0_l16_2[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_4[1], o_booth_0_0_l15_4[0], o_booth_0_0_l15_3[3], o_booth_0_0_l15_3[2] }), .S({ bs_booth_0_0_l16_47, bs_booth_0_0_l16_46, bs_booth_0_0_l16_45, bs_booth_0_0_l16_44 }));
  wire [3:0] co_booth_0_0_l16_4, o_booth_0_0_l16_4;
  CARRY4 u_cy_booth_0_0_l16_4 (
    .CO(co_booth_0_0_l16_4), .O(o_booth_0_0_l16_4),
    .CI(co_booth_0_0_l16_3[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_5[1], o_booth_0_0_l15_5[0], o_booth_0_0_l15_4[3], o_booth_0_0_l15_4[2] }), .S({ bs_booth_0_0_l16_51, bs_booth_0_0_l16_50, bs_booth_0_0_l16_49, bs_booth_0_0_l16_48 }));
  wire [3:0] co_booth_0_0_l16_5, o_booth_0_0_l16_5;
  CARRY4 u_cy_booth_0_0_l16_5 (
    .CO(co_booth_0_0_l16_5), .O(o_booth_0_0_l16_5),
    .CI(co_booth_0_0_l16_4[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_6[1], o_booth_0_0_l15_6[0], o_booth_0_0_l15_5[3], o_booth_0_0_l15_5[2] }), .S({ bs_booth_0_0_l16_55, bs_booth_0_0_l16_54, bs_booth_0_0_l16_53, bs_booth_0_0_l16_52 }));
  wire [3:0] co_booth_0_0_l16_6, o_booth_0_0_l16_6;
  CARRY4 u_cy_booth_0_0_l16_6 (
    .CO(co_booth_0_0_l16_6), .O(o_booth_0_0_l16_6),
    .CI(co_booth_0_0_l16_5[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_7[1], o_booth_0_0_l15_7[0], o_booth_0_0_l15_6[3], o_booth_0_0_l15_6[2] }), .S({ bs_booth_0_0_l16_59, bs_booth_0_0_l16_58, bs_booth_0_0_l16_57, bs_booth_0_0_l16_56 }));
  wire [3:0] co_booth_0_0_l16_7, o_booth_0_0_l16_7;
  CARRY4 u_cy_booth_0_0_l16_7 (
    .CO(co_booth_0_0_l16_7), .O(o_booth_0_0_l16_7),
    .CI(co_booth_0_0_l16_6[3]), .CYINIT(1'b0),
    .DI({ o_booth_0_0_l15_8[1], o_booth_0_0_l15_8[0], o_booth_0_0_l15_7[3], o_booth_0_0_l15_7[2] }), .S({ bs_booth_0_0_l16_63, bs_booth_0_0_l16_62, bs_booth_0_0_l16_61, bs_booth_0_0_l16_60 }));
  wire [63:0] booth_0_0;
  assign booth_0_0[0] = o_booth_0_0_l0_0[0];
  assign booth_0_0[1] = o_booth_0_0_l0_0[1];
  assign booth_0_0[2] = o_booth_0_0_l1_0[0];
  assign booth_0_0[3] = o_booth_0_0_l1_0[1];
  assign booth_0_0[4] = o_booth_0_0_l2_0[0];
  assign booth_0_0[5] = o_booth_0_0_l2_0[1];
  assign booth_0_0[6] = o_booth_0_0_l3_0[0];
  assign booth_0_0[7] = o_booth_0_0_l3_0[1];
  assign booth_0_0[8] = o_booth_0_0_l4_0[0];
  assign booth_0_0[9] = o_booth_0_0_l4_0[1];
  assign booth_0_0[10] = o_booth_0_0_l5_0[0];
  assign booth_0_0[11] = o_booth_0_0_l5_0[1];
  assign booth_0_0[12] = o_booth_0_0_l6_0[0];
  assign booth_0_0[13] = o_booth_0_0_l6_0[1];
  assign booth_0_0[14] = o_booth_0_0_l7_0[0];
  assign booth_0_0[15] = o_booth_0_0_l7_0[1];
  assign booth_0_0[16] = o_booth_0_0_l8_0[0];
  assign booth_0_0[17] = o_booth_0_0_l8_0[1];
  assign booth_0_0[18] = o_booth_0_0_l9_0[0];
  assign booth_0_0[19] = o_booth_0_0_l9_0[1];
  assign booth_0_0[20] = o_booth_0_0_l10_0[0];
  assign booth_0_0[21] = o_booth_0_0_l10_0[1];
  assign booth_0_0[22] = o_booth_0_0_l11_0[0];
  assign booth_0_0[23] = o_booth_0_0_l11_0[1];
  assign booth_0_0[24] = o_booth_0_0_l12_0[0];
  assign booth_0_0[25] = o_booth_0_0_l12_0[1];
  assign booth_0_0[26] = o_booth_0_0_l13_0[0];
  assign booth_0_0[27] = o_booth_0_0_l13_0[1];
  assign booth_0_0[28] = o_booth_0_0_l14_0[0];
  assign booth_0_0[29] = o_booth_0_0_l14_0[1];
  assign booth_0_0[30] = o_booth_0_0_l15_0[0];
  assign booth_0_0[31] = o_booth_0_0_l15_0[1];
  assign booth_0_0[32] = o_booth_0_0_l16_0[0];
  assign booth_0_0[33] = o_booth_0_0_l16_0[1];
  assign booth_0_0[34] = o_booth_0_0_l16_0[2];
  assign booth_0_0[35] = o_booth_0_0_l16_0[3];
  assign booth_0_0[36] = o_booth_0_0_l16_1[0];
  assign booth_0_0[37] = o_booth_0_0_l16_1[1];
  assign booth_0_0[38] = o_booth_0_0_l16_1[2];
  assign booth_0_0[39] = o_booth_0_0_l16_1[3];
  assign booth_0_0[40] = o_booth_0_0_l16_2[0];
  assign booth_0_0[41] = o_booth_0_0_l16_2[1];
  assign booth_0_0[42] = o_booth_0_0_l16_2[2];
  assign booth_0_0[43] = o_booth_0_0_l16_2[3];
  assign booth_0_0[44] = o_booth_0_0_l16_3[0];
  assign booth_0_0[45] = o_booth_0_0_l16_3[1];
  assign booth_0_0[46] = o_booth_0_0_l16_3[2];
  assign booth_0_0[47] = o_booth_0_0_l16_3[3];
  assign booth_0_0[48] = o_booth_0_0_l16_4[0];
  assign booth_0_0[49] = o_booth_0_0_l16_4[1];
  assign booth_0_0[50] = o_booth_0_0_l16_4[2];
  assign booth_0_0[51] = o_booth_0_0_l16_4[3];
  assign booth_0_0[52] = o_booth_0_0_l16_5[0];
  assign booth_0_0[53] = o_booth_0_0_l16_5[1];
  assign booth_0_0[54] = o_booth_0_0_l16_5[2];
  assign booth_0_0[55] = o_booth_0_0_l16_5[3];
  assign booth_0_0[56] = o_booth_0_0_l16_6[0];
  assign booth_0_0[57] = o_booth_0_0_l16_6[1];
  assign booth_0_0[58] = o_booth_0_0_l16_6[2];
  assign booth_0_0[59] = o_booth_0_0_l16_6[3];
  assign booth_0_0[60] = o_booth_0_0_l16_7[0];
  assign booth_0_0[61] = o_booth_0_0_l16_7[1];
  assign booth_0_0[62] = o_booth_0_0_l16_7[2];
  assign booth_0_0[63] = o_booth_0_0_l16_7[3];

  // ---- tile partial products -> merge heap ----

  // ---- merge : ILP LUT6_2 / CARRY4 compressor tree ----

  // ---- final CLA : per-column LUT6_2 (P/G) + CARRY4 chain ----
  wire [63:0] cla_p, cla_g;
  assign cla_p[0] = booth_0_0[0]; assign cla_g[0] = 1'b0;
  assign cla_p[1] = booth_0_0[1]; assign cla_g[1] = 1'b0;
  assign cla_p[2] = booth_0_0[2]; assign cla_g[2] = 1'b0;
  assign cla_p[3] = booth_0_0[3]; assign cla_g[3] = 1'b0;
  assign cla_p[4] = booth_0_0[4]; assign cla_g[4] = 1'b0;
  assign cla_p[5] = booth_0_0[5]; assign cla_g[5] = 1'b0;
  assign cla_p[6] = booth_0_0[6]; assign cla_g[6] = 1'b0;
  assign cla_p[7] = booth_0_0[7]; assign cla_g[7] = 1'b0;
  assign cla_p[8] = booth_0_0[8]; assign cla_g[8] = 1'b0;
  assign cla_p[9] = booth_0_0[9]; assign cla_g[9] = 1'b0;
  assign cla_p[10] = booth_0_0[10]; assign cla_g[10] = 1'b0;
  assign cla_p[11] = booth_0_0[11]; assign cla_g[11] = 1'b0;
  assign cla_p[12] = booth_0_0[12]; assign cla_g[12] = 1'b0;
  assign cla_p[13] = booth_0_0[13]; assign cla_g[13] = 1'b0;
  assign cla_p[14] = booth_0_0[14]; assign cla_g[14] = 1'b0;
  assign cla_p[15] = booth_0_0[15]; assign cla_g[15] = 1'b0;
  assign cla_p[16] = booth_0_0[16]; assign cla_g[16] = 1'b0;
  assign cla_p[17] = booth_0_0[17]; assign cla_g[17] = 1'b0;
  assign cla_p[18] = booth_0_0[18]; assign cla_g[18] = 1'b0;
  assign cla_p[19] = booth_0_0[19]; assign cla_g[19] = 1'b0;
  assign cla_p[20] = booth_0_0[20]; assign cla_g[20] = 1'b0;
  assign cla_p[21] = booth_0_0[21]; assign cla_g[21] = 1'b0;
  assign cla_p[22] = booth_0_0[22]; assign cla_g[22] = 1'b0;
  assign cla_p[23] = booth_0_0[23]; assign cla_g[23] = 1'b0;
  assign cla_p[24] = booth_0_0[24]; assign cla_g[24] = 1'b0;
  assign cla_p[25] = booth_0_0[25]; assign cla_g[25] = 1'b0;
  assign cla_p[26] = booth_0_0[26]; assign cla_g[26] = 1'b0;
  assign cla_p[27] = booth_0_0[27]; assign cla_g[27] = 1'b0;
  assign cla_p[28] = booth_0_0[28]; assign cla_g[28] = 1'b0;
  assign cla_p[29] = booth_0_0[29]; assign cla_g[29] = 1'b0;
  assign cla_p[30] = booth_0_0[30]; assign cla_g[30] = 1'b0;
  assign cla_p[31] = booth_0_0[31]; assign cla_g[31] = 1'b0;
  assign cla_p[32] = booth_0_0[32]; assign cla_g[32] = 1'b0;
  assign cla_p[33] = booth_0_0[33]; assign cla_g[33] = 1'b0;
  assign cla_p[34] = booth_0_0[34]; assign cla_g[34] = 1'b0;
  assign cla_p[35] = booth_0_0[35]; assign cla_g[35] = 1'b0;
  assign cla_p[36] = booth_0_0[36]; assign cla_g[36] = 1'b0;
  assign cla_p[37] = booth_0_0[37]; assign cla_g[37] = 1'b0;
  assign cla_p[38] = booth_0_0[38]; assign cla_g[38] = 1'b0;
  assign cla_p[39] = booth_0_0[39]; assign cla_g[39] = 1'b0;
  assign cla_p[40] = booth_0_0[40]; assign cla_g[40] = 1'b0;
  assign cla_p[41] = booth_0_0[41]; assign cla_g[41] = 1'b0;
  assign cla_p[42] = booth_0_0[42]; assign cla_g[42] = 1'b0;
  assign cla_p[43] = booth_0_0[43]; assign cla_g[43] = 1'b0;
  assign cla_p[44] = booth_0_0[44]; assign cla_g[44] = 1'b0;
  assign cla_p[45] = booth_0_0[45]; assign cla_g[45] = 1'b0;
  assign cla_p[46] = booth_0_0[46]; assign cla_g[46] = 1'b0;
  assign cla_p[47] = booth_0_0[47]; assign cla_g[47] = 1'b0;
  assign cla_p[48] = booth_0_0[48]; assign cla_g[48] = 1'b0;
  assign cla_p[49] = booth_0_0[49]; assign cla_g[49] = 1'b0;
  assign cla_p[50] = booth_0_0[50]; assign cla_g[50] = 1'b0;
  assign cla_p[51] = booth_0_0[51]; assign cla_g[51] = 1'b0;
  assign cla_p[52] = booth_0_0[52]; assign cla_g[52] = 1'b0;
  assign cla_p[53] = booth_0_0[53]; assign cla_g[53] = 1'b0;
  assign cla_p[54] = booth_0_0[54]; assign cla_g[54] = 1'b0;
  assign cla_p[55] = booth_0_0[55]; assign cla_g[55] = 1'b0;
  assign cla_p[56] = booth_0_0[56]; assign cla_g[56] = 1'b0;
  assign cla_p[57] = booth_0_0[57]; assign cla_g[57] = 1'b0;
  assign cla_p[58] = booth_0_0[58]; assign cla_g[58] = 1'b0;
  assign cla_p[59] = booth_0_0[59]; assign cla_g[59] = 1'b0;
  assign cla_p[60] = booth_0_0[60]; assign cla_g[60] = 1'b0;
  assign cla_p[61] = booth_0_0[61]; assign cla_g[61] = 1'b0;
  assign cla_p[62] = booth_0_0[62]; assign cla_g[62] = 1'b0;
  assign cla_p[63] = booth_0_0[63]; assign cla_g[63] = 1'b0;
  wire [3:0] cy_co_0, cy_o_0;
  CARRY4 u_cy_0 (
    .CO(cy_co_0), .O(cy_o_0),
    .CI(1'b0), .CYINIT(1'b0),
    .DI({ cla_g[3], cla_g[2], cla_g[1], cla_g[0] }), .S({ cla_p[3], cla_p[2], cla_p[1], cla_p[0] }));
  assign r[0] = cy_o_0[0];
  assign r[1] = cy_o_0[1];
  assign r[2] = cy_o_0[2];
  assign r[3] = cy_o_0[3];
  wire [3:0] cy_co_1, cy_o_1;
  CARRY4 u_cy_1 (
    .CO(cy_co_1), .O(cy_o_1),
    .CI(cy_co_0[3]), .CYINIT(1'b0),
    .DI({ cla_g[7], cla_g[6], cla_g[5], cla_g[4] }), .S({ cla_p[7], cla_p[6], cla_p[5], cla_p[4] }));
  assign r[4] = cy_o_1[0];
  assign r[5] = cy_o_1[1];
  assign r[6] = cy_o_1[2];
  assign r[7] = cy_o_1[3];
  wire [3:0] cy_co_2, cy_o_2;
  CARRY4 u_cy_2 (
    .CO(cy_co_2), .O(cy_o_2),
    .CI(cy_co_1[3]), .CYINIT(1'b0),
    .DI({ cla_g[11], cla_g[10], cla_g[9], cla_g[8] }), .S({ cla_p[11], cla_p[10], cla_p[9], cla_p[8] }));
  assign r[8] = cy_o_2[0];
  assign r[9] = cy_o_2[1];
  assign r[10] = cy_o_2[2];
  assign r[11] = cy_o_2[3];
  wire [3:0] cy_co_3, cy_o_3;
  CARRY4 u_cy_3 (
    .CO(cy_co_3), .O(cy_o_3),
    .CI(cy_co_2[3]), .CYINIT(1'b0),
    .DI({ cla_g[15], cla_g[14], cla_g[13], cla_g[12] }), .S({ cla_p[15], cla_p[14], cla_p[13], cla_p[12] }));
  assign r[12] = cy_o_3[0];
  assign r[13] = cy_o_3[1];
  assign r[14] = cy_o_3[2];
  assign r[15] = cy_o_3[3];
  wire [3:0] cy_co_4, cy_o_4;
  CARRY4 u_cy_4 (
    .CO(cy_co_4), .O(cy_o_4),
    .CI(cy_co_3[3]), .CYINIT(1'b0),
    .DI({ cla_g[19], cla_g[18], cla_g[17], cla_g[16] }), .S({ cla_p[19], cla_p[18], cla_p[17], cla_p[16] }));
  assign r[16] = cy_o_4[0];
  assign r[17] = cy_o_4[1];
  assign r[18] = cy_o_4[2];
  assign r[19] = cy_o_4[3];
  wire [3:0] cy_co_5, cy_o_5;
  CARRY4 u_cy_5 (
    .CO(cy_co_5), .O(cy_o_5),
    .CI(cy_co_4[3]), .CYINIT(1'b0),
    .DI({ cla_g[23], cla_g[22], cla_g[21], cla_g[20] }), .S({ cla_p[23], cla_p[22], cla_p[21], cla_p[20] }));
  assign r[20] = cy_o_5[0];
  assign r[21] = cy_o_5[1];
  assign r[22] = cy_o_5[2];
  assign r[23] = cy_o_5[3];
  wire [3:0] cy_co_6, cy_o_6;
  CARRY4 u_cy_6 (
    .CO(cy_co_6), .O(cy_o_6),
    .CI(cy_co_5[3]), .CYINIT(1'b0),
    .DI({ cla_g[27], cla_g[26], cla_g[25], cla_g[24] }), .S({ cla_p[27], cla_p[26], cla_p[25], cla_p[24] }));
  assign r[24] = cy_o_6[0];
  assign r[25] = cy_o_6[1];
  assign r[26] = cy_o_6[2];
  assign r[27] = cy_o_6[3];
  wire [3:0] cy_co_7, cy_o_7;
  CARRY4 u_cy_7 (
    .CO(cy_co_7), .O(cy_o_7),
    .CI(cy_co_6[3]), .CYINIT(1'b0),
    .DI({ cla_g[31], cla_g[30], cla_g[29], cla_g[28] }), .S({ cla_p[31], cla_p[30], cla_p[29], cla_p[28] }));
  assign r[28] = cy_o_7[0];
  assign r[29] = cy_o_7[1];
  assign r[30] = cy_o_7[2];
  assign r[31] = cy_o_7[3];
  wire [3:0] cy_co_8, cy_o_8;
  CARRY4 u_cy_8 (
    .CO(cy_co_8), .O(cy_o_8),
    .CI(cy_co_7[3]), .CYINIT(1'b0),
    .DI({ cla_g[35], cla_g[34], cla_g[33], cla_g[32] }), .S({ cla_p[35], cla_p[34], cla_p[33], cla_p[32] }));
  assign r[32] = cy_o_8[0];
  assign r[33] = cy_o_8[1];
  assign r[34] = cy_o_8[2];
  assign r[35] = cy_o_8[3];
  wire [3:0] cy_co_9, cy_o_9;
  CARRY4 u_cy_9 (
    .CO(cy_co_9), .O(cy_o_9),
    .CI(cy_co_8[3]), .CYINIT(1'b0),
    .DI({ cla_g[39], cla_g[38], cla_g[37], cla_g[36] }), .S({ cla_p[39], cla_p[38], cla_p[37], cla_p[36] }));
  assign r[36] = cy_o_9[0];
  assign r[37] = cy_o_9[1];
  assign r[38] = cy_o_9[2];
  assign r[39] = cy_o_9[3];
  wire [3:0] cy_co_10, cy_o_10;
  CARRY4 u_cy_10 (
    .CO(cy_co_10), .O(cy_o_10),
    .CI(cy_co_9[3]), .CYINIT(1'b0),
    .DI({ cla_g[43], cla_g[42], cla_g[41], cla_g[40] }), .S({ cla_p[43], cla_p[42], cla_p[41], cla_p[40] }));
  assign r[40] = cy_o_10[0];
  assign r[41] = cy_o_10[1];
  assign r[42] = cy_o_10[2];
  assign r[43] = cy_o_10[3];
  wire [3:0] cy_co_11, cy_o_11;
  CARRY4 u_cy_11 (
    .CO(cy_co_11), .O(cy_o_11),
    .CI(cy_co_10[3]), .CYINIT(1'b0),
    .DI({ cla_g[47], cla_g[46], cla_g[45], cla_g[44] }), .S({ cla_p[47], cla_p[46], cla_p[45], cla_p[44] }));
  assign r[44] = cy_o_11[0];
  assign r[45] = cy_o_11[1];
  assign r[46] = cy_o_11[2];
  assign r[47] = cy_o_11[3];
  wire [3:0] cy_co_12, cy_o_12;
  CARRY4 u_cy_12 (
    .CO(cy_co_12), .O(cy_o_12),
    .CI(cy_co_11[3]), .CYINIT(1'b0),
    .DI({ cla_g[51], cla_g[50], cla_g[49], cla_g[48] }), .S({ cla_p[51], cla_p[50], cla_p[49], cla_p[48] }));
  assign r[48] = cy_o_12[0];
  assign r[49] = cy_o_12[1];
  assign r[50] = cy_o_12[2];
  assign r[51] = cy_o_12[3];
  wire [3:0] cy_co_13, cy_o_13;
  CARRY4 u_cy_13 (
    .CO(cy_co_13), .O(cy_o_13),
    .CI(cy_co_12[3]), .CYINIT(1'b0),
    .DI({ cla_g[55], cla_g[54], cla_g[53], cla_g[52] }), .S({ cla_p[55], cla_p[54], cla_p[53], cla_p[52] }));
  assign r[52] = cy_o_13[0];
  assign r[53] = cy_o_13[1];
  assign r[54] = cy_o_13[2];
  assign r[55] = cy_o_13[3];
  wire [3:0] cy_co_14, cy_o_14;
  CARRY4 u_cy_14 (
    .CO(cy_co_14), .O(cy_o_14),
    .CI(cy_co_13[3]), .CYINIT(1'b0),
    .DI({ cla_g[59], cla_g[58], cla_g[57], cla_g[56] }), .S({ cla_p[59], cla_p[58], cla_p[57], cla_p[56] }));
  assign r[56] = cy_o_14[0];
  assign r[57] = cy_o_14[1];
  assign r[58] = cy_o_14[2];
  assign r[59] = cy_o_14[3];
  wire [3:0] cy_co_15, cy_o_15;
  CARRY4 u_cy_15 (
    .CO(cy_co_15), .O(cy_o_15),
    .CI(cy_co_14[3]), .CYINIT(1'b0),
    .DI({ cla_g[63], cla_g[62], cla_g[61], cla_g[60] }), .S({ cla_p[63], cla_p[62], cla_p[61], cla_p[60] }));
  assign r[60] = cy_o_15[0];
  assign r[61] = cy_o_15[1];
  assign r[62] = cy_o_15[2];
  assign r[63] = cy_o_15[3];

endmodule
