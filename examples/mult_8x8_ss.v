// ==========================================================
// Two-step tiling multiplier (DSP + Booth + LUT / LUT+CARRY4)
// Wa=8 Wb=8  sign_a=True sign_b=True  merge=ilp  cols=16
// tiles: {'BOOTH': 1}
// ==========================================================
module tiled_mult_8b_ss (
  input  [7:0] a,
  input  [7:0] b,
  output [15:0] r
);

  // ---- Booth tile booth_0_0 : b[7:0](mult) x a[7:0](mcand)  level L=4 (s/s) ----
  wire [7:0] bx_0_0 = a[7:0];
  wire [7:0] by_0_0 = b[7:0];
  wire bs_booth_0_0_l0_0, bs_booth_0_0_l0_1;
  LUT6_2 #(.INIT(64'h468A468A6A6A6A6A)) u_bs_booth_0_0_l0_0 (.O5(bs_booth_0_0_l0_0), .O6(bs_booth_0_0_l0_1), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[0]), .I3(bx_0_0[1]), .I4(1'b0), .I5(1'b1));
  wire bs_booth_0_0_l0_2, bs_booth_0_0_l0_3;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_2 (.O5(bs_booth_0_0_l0_2), .O6(bs_booth_0_0_l0_3), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[2]), .I3(bx_0_0[1]), .I4(bx_0_0[3]), .I5(1'b1));
  wire bs_booth_0_0_l0_4, bs_booth_0_0_l0_5;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_4 (.O5(bs_booth_0_0_l0_4), .O6(bs_booth_0_0_l0_5), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[4]), .I3(bx_0_0[3]), .I4(bx_0_0[5]), .I5(1'b1));
  wire bs_booth_0_0_l0_6, bs_booth_0_0_l0_7;
  LUT6_2 #(.INIT(64'h46468A8A486A486A)) u_bs_booth_0_0_l0_6 (.O5(bs_booth_0_0_l0_6), .O6(bs_booth_0_0_l0_7), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[6]), .I3(bx_0_0[5]), .I4(bx_0_0[7]), .I5(1'b1));
  wire bs_booth_0_0_l0_8;
  LUT6 #(.INIT(64'h4A4A4A4A4A4A4A4A)) u_bs_booth_0_0_l0_8 (.O(bs_booth_0_0_l0_8), .I0(by_0_0[1]), .I1(by_0_0[0]), .I2(bx_0_0[7]), .I3(1'b0), .I4(1'b0), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, 1'b0, 1'b1 }), .S({ 1'b1, 1'b0, 1'b1, bs_booth_0_0_l0_8 }));
  wire [3:0] co_booth_0_0_l0_3, o_booth_0_0_l0_3;
  CARRY4 u_cy_booth_0_0_l0_3 (
    .CO(co_booth_0_0_l0_3), .O(o_booth_0_0_l0_3),
    .CI(co_booth_0_0_l0_2[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b1, 1'b0, 1'b1, 1'b0 }));
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
  LUT6 #(.INIT(64'h6665599966655999)) u_bs_booth_0_0_l1_10 (.O(bs_booth_0_0_l1_10), .I0(o_booth_0_0_l0_2[2]), .I1(by_0_0[3]), .I2(by_0_0[2]), .I3(by_0_0[1]), .I4(bx_0_0[7]), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, 1'b0, o_booth_0_0_l0_2[2] }), .S({ o_booth_0_0_l0_3[1], o_booth_0_0_l0_3[0], o_booth_0_0_l0_2[3], bs_booth_0_0_l1_10 }));
  wire [3:0] co_booth_0_0_l1_3, o_booth_0_0_l1_3;
  CARRY4 u_cy_booth_0_0_l1_3 (
    .CO(co_booth_0_0_l1_3), .O(o_booth_0_0_l1_3),
    .CI(co_booth_0_0_l1_2[3]), .CYINIT(1'b0),
    .DI({ 1'b0, 1'b0, 1'b0, 1'b0 }), .S({ 1'b0, 1'b0, o_booth_0_0_l0_3[3], o_booth_0_0_l0_3[2] }));
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
  LUT6 #(.INIT(64'h6665599966655999)) u_bs_booth_0_0_l2_12 (.O(bs_booth_0_0_l2_12), .I0(o_booth_0_0_l1_2[2]), .I1(by_0_0[5]), .I2(by_0_0[4]), .I3(by_0_0[3]), .I4(bx_0_0[7]), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, 1'b0, o_booth_0_0_l1_2[2] }), .S({ o_booth_0_0_l1_3[1], o_booth_0_0_l1_3[0], o_booth_0_0_l1_2[3], bs_booth_0_0_l2_12 }));
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
  LUT6 #(.INIT(64'h6665599966655999)) u_bs_booth_0_0_l3_14 (.O(bs_booth_0_0_l3_14), .I0(o_booth_0_0_l2_2[2]), .I1(by_0_0[7]), .I2(by_0_0[6]), .I3(by_0_0[5]), .I4(bx_0_0[7]), .I5(1'b0));
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
    .DI({ 1'b0, 1'b0, 1'b0, o_booth_0_0_l2_2[2] }), .S({ 1'b0, 1'b0, o_booth_0_0_l2_2[3], bs_booth_0_0_l3_14 }));
  wire [15:0] booth_0_0;
  assign booth_0_0[0] = o_booth_0_0_l0_0[0];
  assign booth_0_0[1] = o_booth_0_0_l0_0[1];
  assign booth_0_0[2] = o_booth_0_0_l1_0[0];
  assign booth_0_0[3] = o_booth_0_0_l1_0[1];
  assign booth_0_0[4] = o_booth_0_0_l2_0[0];
  assign booth_0_0[5] = o_booth_0_0_l2_0[1];
  assign booth_0_0[6] = o_booth_0_0_l3_0[0];
  assign booth_0_0[7] = o_booth_0_0_l3_0[1];
  assign booth_0_0[8] = o_booth_0_0_l3_0[2];
  assign booth_0_0[9] = o_booth_0_0_l3_0[3];
  assign booth_0_0[10] = o_booth_0_0_l3_1[0];
  assign booth_0_0[11] = o_booth_0_0_l3_1[1];
  assign booth_0_0[12] = o_booth_0_0_l3_1[2];
  assign booth_0_0[13] = o_booth_0_0_l3_1[3];
  assign booth_0_0[14] = o_booth_0_0_l3_2[0];
  assign booth_0_0[15] = o_booth_0_0_l3_2[1];

  // ---- tile partial products -> merge heap ----
  wire w_inv_0;
  LUT6 #(.INIT(64'h5555555555555555)) u_w_inv_0 (.O(w_inv_0), .I0(booth_0_0[15]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));

  // ---- merge : ILP LUT6_2 / CARRY4 compressor tree ----

  // ---- final CLA : per-column LUT6_2 (P/G) + CARRY4 chain ----
  wire [15:0] cla_p, cla_g;
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
  LUT6_2 #(.INIT(64'h6666666688888888)) u_cla_15 (.O5(cla_g[15]), .O6(cla_p[15]),
    .I0(w_inv_0), .I1(1'b1), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b1));
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

endmodule
