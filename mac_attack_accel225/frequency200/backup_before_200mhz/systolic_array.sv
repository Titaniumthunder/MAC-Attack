`timescale 1ns/1ps
// P x P weight-stationary systolic array.
//
//   * Weights: one row of B per cycle while w_load is high, for P cycles.
//     Send row P-1 first and row 0 last; each row shifts down one PE per cycle.
//   * Activations: one row of A per cycle while in_valid is high. Row k of the
//     array is delayed k cycles (input skew) so the right numbers meet.
//   * Partial sums flow down the columns. Column j is delayed P-1-j cycles at the
//     bottom (output deskew) so a whole row of C leaves at once.
//
// A row of A that enters on cycle t leaves as a row of C on cycle t + 2P - 1.
module systolic_array #(
    parameter int P    = 4,
    parameter int BITS = 8,
    parameter int ACC  = 32,
    parameter int SAT  = 0
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              w_load,
    input  logic [P*BITS-1:0] w_row,      // B[k][0..P-1]; element j at bits [j*BITS +: BITS]
    input  logic              in_valid,
    input  logic [P*BITS-1:0] a_row,      // A[i][0..P-1]; element k at bits [k*BITS +: BITS]
    output logic              out_valid,
    output logic [P*ACC-1:0]  c_row       // C[i][0..P-1]; element j at bits [j*ACC +: ACC]
);
    logic signed [BITS-1:0] a_h   [P][P+1];   // a_h[k][j]   : activation entering PE(k,j)
    logic signed [ACC-1:0]  psum_v[P+1][P];   // psum_v[k][j]: partial sum entering PE(k,j)
    logic signed [BITS-1:0] w_v   [P+1][P];   // w_v[k][j]   : weight entering PE(k,j)

    genvar k, j;
    generate
        for (k = 0; k < P; k++) begin : g_skew
            if (k == 0) begin : g_none
                assign a_h[0][0] = a_row[BITS-1:0];
            end else begin : g_dly
                delay_line #(.WIDTH(BITS), .DEPTH(k)) u_skew (
                    .clk(clk), .rst(rst), .d(a_row[k*BITS +: BITS]), .q(a_h[k][0]));
            end
        end
        for (j = 0; j < P; j++) begin : g_top
            assign psum_v[0][j] = '0;
            assign w_v[0][j]    = w_row[j*BITS +: BITS];
        end
        for (k = 0; k < P; k++) begin : g_r
            for (j = 0; j < P; j++) begin : g_c
                pe #(.BITS(BITS), .ACC(ACC), .SAT(SAT)) u_pe (
                    .clk(clk), .rst(rst), .w_load(w_load),
                    .w_in(w_v[k][j]),      .w_out(w_v[k+1][j]),
                    .a_in(a_h[k][j]),      .a_out(a_h[k][j+1]),
                    .psum_in(psum_v[k][j]), .psum_out(psum_v[k+1][j]));
            end
        end
        for (j = 0; j < P; j++) begin : g_out
            if (j == P - 1) begin : g_none
                assign c_row[j*ACC +: ACC] = psum_v[P][j];
            end else begin : g_dly
                delay_line #(.WIDTH(ACC), .DEPTH(P - 1 - j)) u_deskew (
                    .clk(clk), .rst(rst), .d(psum_v[P][j]), .q(c_row[j*ACC +: ACC]));
            end
        end
    endgenerate

    delay_line #(.WIDTH(1), .DEPTH(2 * P - 1)) u_valid (
        .clk(clk), .rst(rst), .d(in_valid), .q(out_valid));
endmodule
