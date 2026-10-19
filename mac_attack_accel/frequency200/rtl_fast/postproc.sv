`timescale 1ns/1ps
// Post-processing unit: turns a wide accumulator result into the next layer's input.
// This is the "activation unit" that sits after the matrix unit in a TPU.
//
//   y = clamp( round( (acc + bias) * m0 / 2^shift ), lo, hi )
//
//   bias   32-bit integer bias of the neuron
//   m0     16-bit fixed-point multiplier; m0 / 2^shift approximates the scale
//          (S_in * S_w / S_out) of integer-only quantized inference
//   round  to nearest, ties toward +infinity: add 2^(shift-1) before the shift
//   relu   1: lo = 0 (ReLU), 0: lo = -2^(OBITS-1); hi = 2^(OBITS-1) - 1
//
// Three pipeline stages: add bias, multiply, round + shift + clamp.
// One result per clock; out_valid follows in_valid by 3 cycles.
module postproc #(
    parameter int ACC   = 32,     // accumulator width (at most 32)
    parameter int OBITS = 8       // output width
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    in_valid,
    input  logic signed [ACC-1:0]   in_acc,
    input  logic signed [31:0]      in_bias,
    input  logic [15:0]             m0,
    input  logic [5:0]              shift,     // 1 .. 48
    input  logic                    relu,
    output logic                    out_valid,
    output logic signed [OBITS-1:0] out_q
);
    localparam logic signed [49:0] HI = 50'sd1 <<< (OBITS - 1);   // 2^(OBITS-1)

    logic                v1, v2;
    logic signed [32:0]  s1;       // acc + bias
    logic signed [49:0]  p2;       // (acc + bias) * m0
    logic signed [49:0]  rnd, y;
    logic                relu2;

    assign rnd = 50'sd1 <<< (shift - 6'd1);
    assign y   = (p2 + rnd) >>> shift;

    always_ff @(posedge clk) begin
        if (rst) begin
            v1 <= 1'b0; v2 <= 1'b0; out_valid <= 1'b0;
            s1 <= '0; p2 <= '0; relu2 <= 1'b0; out_q <= '0;
        end else begin
            // stage 1: add the bias
            v1 <= in_valid;
            s1 <= 33'(in_acc) + 33'(in_bias);
            // stage 2: multiply by m0
            v2 <= v1;
            p2 <= 50'(s1) * $signed({34'd0, m0});
            relu2 <= relu;
            // stage 3: round, shift, clamp
            out_valid <= v2;
            if (y > HI - 1)                      out_q <= OBITS'(HI - 1);
            else if (relu2 && y < 0)             out_q <= '0;
            else if (!relu2 && y < -HI)          out_q <= OBITS'(-HI);
            else                                 out_q <= OBITS'(y);
        end
    end
endmodule
