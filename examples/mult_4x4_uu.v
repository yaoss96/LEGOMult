// ==========================================================
// Two-step tiling multiplier (DSP + Booth + LUT / LUT+CARRY4)
// Wa=4 Wb=4  sign_a=False sign_b=False  merge=ilp  cols=8
// tiles: {'LUT': 1}
// ==========================================================
module tiled_mult_4b (
  input  [3:0] a,
  input  [3:0] b,
  output [7:0] r
);

  // ---- tile partial products -> merge heap ----

  // ---- merge : ILP LUT6_2 / CARRY4 compressor tree ----
  wire w_s0_c1_n0_l0_o5, w_s0_c1_n0_l0_o6;
  LUT6_2 #(.INIT(64'h8000800078887888)) u_s0_c1_n0_l0 (
    .O5(w_s0_c1_n0_l0_o5), .O6(w_s0_c1_n0_l0_o6),
    .I0(a[0]), .I1(b[1]), .I2(a[1]), .I3(b[0]),
    .I4(1'b0), .I5(1'b1));
  wire w_s0_c3_n1_l0_o5, w_s0_c3_n1_l0_o6;
  LUT6_2 #(.INIT(64'h8000800078887888)) u_s0_c3_n1_l0 (
    .O5(w_s0_c3_n1_l0_o5), .O6(w_s0_c3_n1_l0_o6),
    .I0(a[0]), .I1(b[3]), .I2(a[1]), .I3(b[2]),
    .I4(1'b0), .I5(1'b1));
  wire w_s1_c3_n2_l0_o5, w_s1_c3_n2_l0_o6;
  LUT6_2 #(.INIT(64'hF888800087777888)) u_s1_c3_n2_l0 (
    .O5(w_s1_c3_n2_l0_o5), .O6(w_s1_c3_n2_l0_o6),
    .I0(a[2]), .I1(b[1]), .I2(a[3]), .I3(b[0]),
    .I4(w_s0_c3_n1_l0_o5), .I5(1'b1));
  wire w_s2_c2_n3_l0_o5, w_s2_c2_n3_l0_o6;
  LUT6_2 #(.INIT(64'hF888800087777888)) u_s2_c2_n3_l0 (
    .O5(w_s2_c2_n3_l0_o5), .O6(w_s2_c2_n3_l0_o6),
    .I0(a[0]), .I1(b[2]), .I2(a[1]), .I3(b[1]),
    .I4(w_s0_c1_n0_l0_o6), .I5(1'b1));
  wire w_s2_c4_n4_l0_o5, w_s2_c4_n4_l0_o6;
  LUT6_2 #(.INIT(64'hF888800087777888)) u_s2_c4_n4_l0 (
    .O5(w_s2_c4_n4_l0_o5), .O6(w_s2_c4_n4_l0_o6),
    .I0(a[1]), .I1(b[3]), .I2(a[2]), .I3(b[2]),
    .I4(w_s1_c3_n2_l0_o6), .I5(1'b1));
  wire w_s3_c4_n5_l0_o5, w_s3_c4_n5_l0_o6;
  LUT6_2 #(.INIT(64'h8888888866666666)) u_s3_c4_n5_l0 (
    .O5(w_s3_c4_n5_l0_o5), .O6(w_s3_c4_n5_l0_o6),
    .I0(w_s2_c4_n4_l0_o5), .I1(w_s0_c3_n1_l0_o6), .I2(1'b0), .I3(1'b0),
    .I4(1'b0), .I5(1'b1));
  wire w_s3_c5_n6_l0_o5, w_s3_c5_n6_l0_o6;
  LUT6_2 #(.INIT(64'hF888800087777888)) u_s3_c5_n6_l0 (
    .O5(w_s3_c5_n6_l0_o5), .O6(w_s3_c5_n6_l0_o6),
    .I0(a[2]), .I1(b[3]), .I2(a[3]), .I3(b[2]),
    .I4(w_s2_c4_n4_l0_o6), .I5(1'b1));

  // ---- final CLA : per-column LUT6_2 (P/G) + CARRY4 chain ----
  wire [7:0] cla_p, cla_g;
  LUT6_2 #(.INIT(64'h8888888800000000)) u_cla_0 (.O5(cla_g[0]), .O6(cla_p[0]),
    .I0(a[0]), .I1(b[0]), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b1));
  assign cla_p[1] = w_s0_c1_n0_l0_o5; assign cla_g[1] = 1'b0;
  LUT6_2 #(.INIT(64'h7878787880808080)) u_cla_2 (.O5(cla_g[2]), .O6(cla_p[2]),
    .I0(a[2]), .I1(b[0]), .I2(w_s2_c2_n3_l0_o5), .I3(1'b0), .I4(1'b0), .I5(1'b1));
  LUT6_2 #(.INIT(64'h6666666688888888)) u_cla_3 (.O5(cla_g[3]), .O6(cla_p[3]),
    .I0(w_s2_c2_n3_l0_o6), .I1(w_s1_c3_n2_l0_o5), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b1));
  LUT6_2 #(.INIT(64'h7878787880808080)) u_cla_4 (.O5(cla_g[4]), .O6(cla_p[4]),
    .I0(a[3]), .I1(b[1]), .I2(w_s3_c4_n5_l0_o5), .I3(1'b0), .I4(1'b0), .I5(1'b1));
  LUT6_2 #(.INIT(64'h6666666688888888)) u_cla_5 (.O5(cla_g[5]), .O6(cla_p[5]),
    .I0(w_s3_c4_n5_l0_o6), .I1(w_s3_c5_n6_l0_o5), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b1));
  LUT6_2 #(.INIT(64'h7878787880808080)) u_cla_6 (.O5(cla_g[6]), .O6(cla_p[6]),
    .I0(a[3]), .I1(b[3]), .I2(w_s3_c5_n6_l0_o6), .I3(1'b0), .I4(1'b0), .I5(1'b1));
  assign cla_p[7] = 1'b0; assign cla_g[7] = 1'b0;
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

endmodule
