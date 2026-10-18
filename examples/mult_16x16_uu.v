// ==========================================================
// Two-step tiling multiplier (DSP + Booth + LUT / LUT+CARRY4)
// Wa=16 Wb=16  sign_a=False sign_b=False  merge=ilp  cols=32
// tiles: {'BOOTH': 1}
// ==========================================================
module tiled_mult_16b (
  input  [15:0] a,
  input  [15:0] b,
  output [31:0] r
);

  // ---- Booth tile booth_0_0 : a[15:0](mult) x b[15:0](mcand)  level L=9 (u/u) ----
  wire [15:0] bx_0_0 = b[15:0];
  wire [15:0] by_0_0 = a[15:0];
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
  LUT6_2 #(.INIT(64'hAAAAAAAA8A8A8A8A)) u_bs_booth_0_0_l0_16 (.O5(bs_booth_0_0_l0_16), .O6(bs_booth_0_0_l0_17), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[15]), .I3(1'b0), .I4(1'b0), .I5(1'b1));
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
    .DI({ 1'b0, 1'b0, 1'b1, 1'b0 }), .S({ 1'b0, 1'b1, bs_booth_0_0_l0_17, bs_booth_0_0_l0_16 }));
  wire [3:0] co_booth_0_0_l0_5, o_booth_0_0_l0_5;
  CARRY4 u_cy_booth_0_0_l0_5 (
    .CO(co_booth_0_0_l0_5), .O(o_booth_0_0_l0_5),
    .CI(co_booth_0_0_l0_4[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_6, o_booth_0_0_l0_6;
  CARRY4 u_cy_booth_0_0_l0_6 (
    .CO(co_booth_0_0_l0_6), .O(o_booth_0_0_l0_6),
    .CI(co_booth_0_0_l0_5[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b1, 1'b0, 1'b1 }));
  wire [3:0] co_booth_0_0_l0_7, o_booth_0_0_l0_7;
  CARRY4 u_cy_booth_0_0_l0_7 (
    .CO(co_booth_0_0_l0_7), .O(o_booth_0_0_l0_7),
    .CI(co_booth_0_0_l0_6[3]), .CYINIT(1'b0),
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
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l1_18 (.O(bs_booth_0_0_l1_18), .I0(o_booth_0_0_l0_4[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[15]), .I5(1'b0));
  wire bs_booth_0_0_l1_19;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l1_19 (.O(bs_booth_0_0_l1_19), .I0(o_booth_0_0_l0_4[3]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, o_booth_0_0_l0_4[3], o_booth_0_0_l0_4[2] }), .S({ o_booth_0_0_l0_5[1], o_booth_0_0_l0_5[0], bs_booth_0_0_l1_19, bs_booth_0_0_l1_18 }));
  wire [3:0] co_booth_0_0_l1_5, o_booth_0_0_l1_5;
  CARRY4 u_cy_booth_0_0_l1_5 (
    .CO(co_booth_0_0_l1_5), .O(o_booth_0_0_l1_5),
    .CI(co_booth_0_0_l1_4[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_6[1], o_booth_0_0_l0_6[0], o_booth_0_0_l0_5[3], o_booth_0_0_l0_5[2] }));
  wire [3:0] co_booth_0_0_l1_6, o_booth_0_0_l1_6;
  CARRY4 u_cy_booth_0_0_l1_6 (
    .CO(co_booth_0_0_l1_6), .O(o_booth_0_0_l1_6),
    .CI(co_booth_0_0_l1_5[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l0_7[1], o_booth_0_0_l0_7[0], o_booth_0_0_l0_6[3], o_booth_0_0_l0_6[2] }));
  wire [3:0] co_booth_0_0_l1_7, o_booth_0_0_l1_7;
  CARRY4 u_cy_booth_0_0_l1_7 (
    .CO(co_booth_0_0_l1_7), .O(o_booth_0_0_l1_7),
    .CI(co_booth_0_0_l1_6[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l0_7[3], o_booth_0_0_l0_7[2] }));
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
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l2_20 (.O(bs_booth_0_0_l2_20), .I0(o_booth_0_0_l1_4[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[15]), .I5(1'b0));
  wire bs_booth_0_0_l2_21;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l2_21 (.O(bs_booth_0_0_l2_21), .I0(o_booth_0_0_l1_4[3]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, o_booth_0_0_l1_4[3], o_booth_0_0_l1_4[2] }), .S({ o_booth_0_0_l1_5[1], o_booth_0_0_l1_5[0], bs_booth_0_0_l2_21, bs_booth_0_0_l2_20 }));
  wire [3:0] co_booth_0_0_l2_5, o_booth_0_0_l2_5;
  CARRY4 u_cy_booth_0_0_l2_5 (
    .CO(co_booth_0_0_l2_5), .O(o_booth_0_0_l2_5),
    .CI(co_booth_0_0_l2_4[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_6[1], o_booth_0_0_l1_6[0], o_booth_0_0_l1_5[3], o_booth_0_0_l1_5[2] }));
  wire [3:0] co_booth_0_0_l2_6, o_booth_0_0_l2_6;
  CARRY4 u_cy_booth_0_0_l2_6 (
    .CO(co_booth_0_0_l2_6), .O(o_booth_0_0_l2_6),
    .CI(co_booth_0_0_l2_5[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l1_7[1], o_booth_0_0_l1_7[0], o_booth_0_0_l1_6[3], o_booth_0_0_l1_6[2] }));
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
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l3_22 (.O(bs_booth_0_0_l3_22), .I0(o_booth_0_0_l2_4[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[15]), .I5(1'b0));
  wire bs_booth_0_0_l3_23;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l3_23 (.O(bs_booth_0_0_l3_23), .I0(o_booth_0_0_l2_4[3]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, o_booth_0_0_l2_4[3], o_booth_0_0_l2_4[2] }), .S({ o_booth_0_0_l2_5[1], o_booth_0_0_l2_5[0], bs_booth_0_0_l3_23, bs_booth_0_0_l3_22 }));
  wire [3:0] co_booth_0_0_l3_5, o_booth_0_0_l3_5;
  CARRY4 u_cy_booth_0_0_l3_5 (
    .CO(co_booth_0_0_l3_5), .O(o_booth_0_0_l3_5),
    .CI(co_booth_0_0_l3_4[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l2_6[1], o_booth_0_0_l2_6[0], o_booth_0_0_l2_5[3], o_booth_0_0_l2_5[2] }));
  wire [3:0] co_booth_0_0_l3_6, o_booth_0_0_l3_6;
  CARRY4 u_cy_booth_0_0_l3_6 (
    .CO(co_booth_0_0_l3_6), .O(o_booth_0_0_l3_6),
    .CI(co_booth_0_0_l3_5[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l2_6[3], o_booth_0_0_l2_6[2] }));
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
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l4_24 (.O(bs_booth_0_0_l4_24), .I0(o_booth_0_0_l3_4[2]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(bx_0_0[15]), .I5(1'b0));
  wire bs_booth_0_0_l4_25;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l4_25 (.O(bs_booth_0_0_l4_25), .I0(o_booth_0_0_l3_4[3]), .I1(by_0_0[9]), .I2(by_0_0[8]), .I3(by_0_0[7]), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, o_booth_0_0_l3_4[3], o_booth_0_0_l3_4[2] }), .S({ o_booth_0_0_l3_5[1], o_booth_0_0_l3_5[0], bs_booth_0_0_l4_25, bs_booth_0_0_l4_24 }));
  wire [3:0] co_booth_0_0_l4_5, o_booth_0_0_l4_5;
  CARRY4 u_cy_booth_0_0_l4_5 (
    .CO(co_booth_0_0_l4_5), .O(o_booth_0_0_l4_5),
    .CI(co_booth_0_0_l4_4[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ o_booth_0_0_l3_6[1], o_booth_0_0_l3_6[0], o_booth_0_0_l3_5[3], o_booth_0_0_l3_5[2] }));
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
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l5_26 (.O(bs_booth_0_0_l5_26), .I0(o_booth_0_0_l4_4[2]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(bx_0_0[15]), .I5(1'b0));
  wire bs_booth_0_0_l5_27;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l5_27 (.O(bs_booth_0_0_l5_27), .I0(o_booth_0_0_l4_4[3]), .I1(by_0_0[11]), .I2(by_0_0[10]), .I3(by_0_0[9]), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, o_booth_0_0_l4_4[3], o_booth_0_0_l4_4[2] }), .S({ o_booth_0_0_l4_5[1], o_booth_0_0_l4_5[0], bs_booth_0_0_l5_27, bs_booth_0_0_l5_26 }));
  wire [3:0] co_booth_0_0_l5_5, o_booth_0_0_l5_5;
  CARRY4 u_cy_booth_0_0_l5_5 (
    .CO(co_booth_0_0_l5_5), .O(o_booth_0_0_l5_5),
    .CI(co_booth_0_0_l5_4[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l4_5[3], o_booth_0_0_l4_5[2] }));
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
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l6_28 (.O(bs_booth_0_0_l6_28), .I0(o_booth_0_0_l5_4[2]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(bx_0_0[15]), .I5(1'b0));
  wire bs_booth_0_0_l6_29;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l6_29 (.O(bs_booth_0_0_l6_29), .I0(o_booth_0_0_l5_4[3]), .I1(by_0_0[13]), .I2(by_0_0[12]), .I3(by_0_0[11]), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, o_booth_0_0_l5_4[3], o_booth_0_0_l5_4[2] }), .S({ o_booth_0_0_l5_5[1], o_booth_0_0_l5_5[0], bs_booth_0_0_l6_29, bs_booth_0_0_l6_28 }));
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
  LUT6 #(.INIT(64'h966AA666966AA666)) u_bs_booth_0_0_l7_30 (.O(bs_booth_0_0_l7_30), .I0(o_booth_0_0_l6_4[2]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(bx_0_0[15]), .I5(1'b0));
  wire bs_booth_0_0_l7_31;
  LUT6 #(.INIT(64'h5999599959995999)) u_bs_booth_0_0_l7_31 (.O(bs_booth_0_0_l7_31), .I0(o_booth_0_0_l6_4[3]), .I1(by_0_0[15]), .I2(by_0_0[14]), .I3(by_0_0[13]), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, o_booth_0_0_l6_4[3], o_booth_0_0_l6_4[2] }), .S({ 1'b0, 1'b0, bs_booth_0_0_l7_31, bs_booth_0_0_l7_30 }));
  wire bs_booth_0_0_l8_16, bs_booth_0_0_l8_17;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_16 (.O5(bs_booth_0_0_l8_16), .O6(bs_booth_0_0_l8_17), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_0[2]), .I2(bx_0_0[0]), .I3(o_booth_0_0_l7_0[3]), .I4(bx_0_0[1]), .I5(1'b1));
  wire bs_booth_0_0_l8_18, bs_booth_0_0_l8_19;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_18 (.O5(bs_booth_0_0_l8_18), .O6(bs_booth_0_0_l8_19), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_1[0]), .I2(bx_0_0[2]), .I3(o_booth_0_0_l7_1[1]), .I4(bx_0_0[3]), .I5(1'b1));
  wire bs_booth_0_0_l8_20, bs_booth_0_0_l8_21;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_20 (.O5(bs_booth_0_0_l8_20), .O6(bs_booth_0_0_l8_21), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_1[2]), .I2(bx_0_0[4]), .I3(o_booth_0_0_l7_1[3]), .I4(bx_0_0[5]), .I5(1'b1));
  wire bs_booth_0_0_l8_22, bs_booth_0_0_l8_23;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_22 (.O5(bs_booth_0_0_l8_22), .O6(bs_booth_0_0_l8_23), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_2[0]), .I2(bx_0_0[6]), .I3(o_booth_0_0_l7_2[1]), .I4(bx_0_0[7]), .I5(1'b1));
  wire bs_booth_0_0_l8_24, bs_booth_0_0_l8_25;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_24 (.O5(bs_booth_0_0_l8_24), .O6(bs_booth_0_0_l8_25), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_2[2]), .I2(bx_0_0[8]), .I3(o_booth_0_0_l7_2[3]), .I4(bx_0_0[9]), .I5(1'b1));
  wire bs_booth_0_0_l8_26, bs_booth_0_0_l8_27;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_26 (.O5(bs_booth_0_0_l8_26), .O6(bs_booth_0_0_l8_27), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_3[0]), .I2(bx_0_0[10]), .I3(o_booth_0_0_l7_3[1]), .I4(bx_0_0[11]), .I5(1'b1));
  wire bs_booth_0_0_l8_28, bs_booth_0_0_l8_29;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_28 (.O5(bs_booth_0_0_l8_28), .O6(bs_booth_0_0_l8_29), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_3[2]), .I2(bx_0_0[12]), .I3(o_booth_0_0_l7_3[3]), .I4(bx_0_0[13]), .I5(1'b1));
  wire bs_booth_0_0_l8_30, bs_booth_0_0_l8_31;
  LUT6_2 #(.INIT(64'h55AAFF006C6C6C6C)) u_bs_booth_0_0_l8_30 (.O5(bs_booth_0_0_l8_30), .O6(bs_booth_0_0_l8_31), .I0(by_0_0[15]), .I1(o_booth_0_0_l7_4[0]), .I2(bx_0_0[14]), .I3(o_booth_0_0_l7_4[1]), .I4(bx_0_0[15]), .I5(1'b1));
  wire [3:0] co_booth_0_0_l8_0, o_booth_0_0_l8_0;
  CARRY4 u_cy_booth_0_0_l8_0 (
    .CO(co_booth_0_0_l8_0), .O(o_booth_0_0_l8_0),
    .CI(1'b0), .CYINIT(1'b0),
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
  wire [31:0] booth_0_0;
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
  assign booth_0_0[18] = o_booth_0_0_l8_0[2];
  assign booth_0_0[19] = o_booth_0_0_l8_0[3];
  assign booth_0_0[20] = o_booth_0_0_l8_1[0];
  assign booth_0_0[21] = o_booth_0_0_l8_1[1];
  assign booth_0_0[22] = o_booth_0_0_l8_1[2];
  assign booth_0_0[23] = o_booth_0_0_l8_1[3];
  assign booth_0_0[24] = o_booth_0_0_l8_2[0];
  assign booth_0_0[25] = o_booth_0_0_l8_2[1];
  assign booth_0_0[26] = o_booth_0_0_l8_2[2];
  assign booth_0_0[27] = o_booth_0_0_l8_2[3];
  assign booth_0_0[28] = o_booth_0_0_l8_3[0];
  assign booth_0_0[29] = o_booth_0_0_l8_3[1];
  assign booth_0_0[30] = o_booth_0_0_l8_3[2];
  assign booth_0_0[31] = o_booth_0_0_l8_3[3];

  // ---- tile partial products -> merge heap ----

  // ---- merge : ILP LUT6_2 / CARRY4 compressor tree ----

  // ---- final CLA : per-column LUT6_2 (P/G) + CARRY4 chain ----
  wire [31:0] cla_p, cla_g;
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

endmodule
