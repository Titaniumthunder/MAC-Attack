`timescale 1ns/1ps
// Processing element (PE): one signed multiply-accumulate per clock cycle.
//
//   PIPE = 0:  psum_out <= psum_in + a_in * w                      (multiply and add in one cycle)
//   PIPE = 1:  prod     <= a_in * w ;  psum_out <= psum_in + prod   (cycle 1 multiply, cycle 2 add)
//
// With PIPE = 1 every PE in the array is one cycle later in the same way, so the partial
// sum from the PE above still meets the matching product: results simply leave the array
// one cycle later. The weight is still used at the same cycle, so reloading weights for the
// next pass is not disturbed and the cycles per pass do not change.
//
// The weight w stays in the PE (weight-stationary). The activation is passed to
// the PE on the right; the partial sum is passed to the PE below.
//
// SAT = 0: the sum wraps around if it overflows ACC bits (two's complement).
// SAT = 1: the sum is clamped to the largest or smallest ACC-bit value instead.
//
// DSP use (Vivado; other tools ignore these attributes):
//   * use_dsp = "yes" on the multiply: without it Vivado built the 8 x 8 multipliers from LUTs.
//   * use_dsp = "no" on the add: otherwise Vivado gave the 32-bit add a second DSP (2 per PE,
//     128 for P = 8), and the product had to cross general routing from one DSP's output to
//     the other's input (2.6-3.1 ns) before 1.9 ns of setup inside the second DSP. That was
//     the path that failed at 200 MHz. In LUT carry chains next to the DSP the add is short.
//
// No reset on the data registers (weight, activation, product, partial sum). Their
// contents only count when the array's valid flag says so, and the weights are always
// loaded before they are used. Leaving the reset off keeps the reset wire short (it
// used to reach every DSP on the chip) and lets the registers sit inside the DSP.
module pe #(
    parameter int BITS = 8,      // operand width: 8 for INT8, 4 for INT4
    parameter int ACC  = 32,     // partial-sum width; at least 2*BITS
    parameter int SAT  = 0,      // 1 = saturating adder
    parameter int PIPE = 1       // 1 = product register between multiply and add
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
    (* use_dsp = "yes" *)
    logic signed [2*BITS-1:0] prod;           // the multiply (this cycle)
    logic signed [2*BITS-1:0] prod_use;       // the product that is added this cycle
    logic signed [ACC-1:0]    prod_ext;
    (* use_dsp = "no" *)
    logic signed [ACC:0]      sum;            // one extra bit, so overflow is visible

    assign prod  = a_in * w;                   // 2*BITS bits always hold the full product
    assign w_out = w;

    generate
        if (PIPE != 0) begin : g_pipe          // stage 1 ends here: register the product
            logic signed [2*BITS-1:0] prod_q;
            always_ff @(posedge clk) prod_q <= prod;
            assign prod_use = prod_q;
        end else begin : g_nopipe
            assign prod_use = prod;
        end
    endgenerate

    generate
        if (ACC > 2 * BITS) begin : g_ext
            assign prod_ext = {{(ACC - 2 * BITS){prod_use[2*BITS-1]}}, prod_use};
        end else begin : g_same
            assign prod_ext = prod_use;
        end
    endgenerate

    assign sum = {psum_in[ACC-1], psum_in} + {prod_ext[ACC-1], prod_ext};

    // Largest and smallest ACC-bit values, written as ACC+1-bit patterns:
    //   MAXV = 2^(ACC-1) - 1 = 00111...1      MINV = -2^(ACC-1) = 11000...0
    localparam logic signed [ACC:0] MAXV = {2'b00, {(ACC-1){1'b1}}};
    localparam logic signed [ACC:0] MINV = {2'b11, {(ACC-1){1'b0}}};

    always_ff @(posedge clk) begin
        if (w_load) w <= w_in;
        a_out <= a_in;
        if (SAT != 0 && sum > MAXV)      psum_out <= MAXV[ACC-1:0];
        else if (SAT != 0 && sum < MINV) psum_out <= MINV[ACC-1:0];
        else                             psum_out <= sum[ACC-1:0];
    end

    /* verilator lint_off UNUSEDSIGNAL */
    logic unused_rst;
    assign unused_rst = rst;                  // kept in the port list so the array is unchanged
    /* verilator lint_on UNUSEDSIGNAL */
endmodule
