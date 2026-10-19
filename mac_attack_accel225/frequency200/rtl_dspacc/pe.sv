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
(* use_dsp = "yes" *) module pe #(
    parameter int BITS = 8,      // operand width: 8 for INT8, 4 for INT4
    parameter int ACC  = 32,     // partial-sum width; at least 2*BITS
    parameter int EARLY_MAC = 0, // internal product stage; caller supplies activation one cycle early
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

    logic signed [BITS-1:0] mac_a;
    generate
        if (EARLY_MAC >= 2) begin : g_a_pipeline
            always_ff @(posedge clk) begin
                if (rst) mac_a <= '0;
                else mac_a <= a_in;
            end
        end else begin : g_a_direct
            assign mac_a = a_in;
        end
    endgenerate
    logic signed [2*BITS-1:0] product_q;
    generate
        if (EARLY_MAC != 0) begin : g_product_pipeline
            always_ff @(posedge clk) begin
                if (rst) product_q <= '0;
                // The core loads weights one cycle early, before the product stage.
                else product_q <= mac_a * w;
            end
            assign prod = product_q;
        end else begin : g_product_comb
            assign prod = a_in * w;
        end
    endgenerate
    //                   // 2*BITS bits always hold the full product
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
            w <= '0;
            a_out <= '0;
        end else begin
            if (w_load) w <= w_in;
            a_out <= a_in;
        end
    end

    generate
        if (SAT == 0) begin : g_wrap
            // A single signed MAC expression lets the DSP multiplier and adder
            // share one slice; the registered result still has one-cycle latency.
            always_ff @(posedge clk) begin
                if (rst) psum_out <= '0;
                else psum_out <= psum_in + prod;
            end
        end else begin : g_sat
            always_ff @(posedge clk) begin
                if (rst) psum_out <= '0;
                else if (sum > MAXV) psum_out <= MAXV[ACC-1:0];
                else if (sum < MINV) psum_out <= MINV[ACC-1:0];
                else psum_out <= sum[ACC-1:0];
            end
        end
    endgenerate
endmodule



