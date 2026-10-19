`timescale 1ns/1ps
// Processing element (PE): one signed multiply-accumulate per clock cycle.
//
//   psum_out <= psum_in + a_in * w
//
// The weight w stays in the PE (weight-stationary). The activation is passed to
// the PE on the right; the partial sum is passed to the PE below.
//
// SAT = 0: the sum wraps around if it overflows ACC bits (two's complement).
// SAT = 1: the sum is clamped to the largest or smallest ACC-bit value instead.
module pe #(
    parameter int BITS = 8,      // operand width: 8 for INT8, 4 for INT4
    parameter int ACC  = 32,     // partial-sum width; at least 2*BITS
    parameter int SAT  = 0       // 1 = saturating adder
)(
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   w_load,    // 1: take a new weight from the PE above
    input  logic signed [BITS-1:0] w_in,
    output logic signed [BITS-1:0] w_out,     // to the PE below (weight load path)
    input  logic signed [BITS-1:0] a_in,
    output logic signed [BITS-1:0] a_out,     // to the PE on the right
    input  logic signed [ACC-1:0]  psum_in,
    output logic signed [ACC-1:0]  psum_out   // to the PE below
);
    logic signed [BITS-1:0]   w;
    logic signed [2*BITS-1:0] prod;
    logic signed [ACC-1:0]    prod_ext;
    logic signed [ACC:0]      sum;            // one extra bit, so overflow is visible

    assign prod  = a_in * w;                   // 2*BITS bits always hold the full product
    assign w_out = w;

    generate
        if (ACC > 2 * BITS) begin : g_ext
            assign prod_ext = {{(ACC - 2 * BITS){prod[2*BITS-1]}}, prod};
        end else begin : g_same
            assign prod_ext = prod;
        end
    endgenerate

    assign sum = {psum_in[ACC-1], psum_in} + {prod_ext[ACC-1], prod_ext};

    // Largest and smallest ACC-bit values, written as ACC+1-bit patterns:
    //   MAXV = 2^(ACC-1) - 1 = 00111...1      MINV = -2^(ACC-1) = 11000...0
    localparam logic signed [ACC:0] MAXV = {2'b00, {(ACC-1){1'b1}}};
    localparam logic signed [ACC:0] MINV = {2'b11, {(ACC-1){1'b0}}};

    always_ff @(posedge clk) begin
        if (rst) begin
            w        <= '0;
            a_out    <= '0;
            psum_out <= '0;
        end else begin
            if (w_load) w <= w_in;
            a_out <= a_in;
            if (SAT != 0 && sum > MAXV)      psum_out <= MAXV[ACC-1:0];
            else if (SAT != 0 && sum < MINV) psum_out <= MINV[ACC-1:0];
            else                             psum_out <= sum[ACC-1:0];
        end
    end
endmodule
