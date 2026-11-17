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
// One result per clock. out_valid follows in_valid by LAT cycles:
//   PPIPE = 0   LAT = 3: add bias, multiply, round + shift + clamp (the original three stages)
//   PPIPE = 1   LAT = 7: add bias, multiply (3 registers, so the tool can pipeline the two DSPs a
//               33 x 17 multiply needs), add the rounding constant, shift, clamp.
//   PPIPE = 2   LAT = 9: as PPIPE = 1, with the shift in two steps (by a multiple of 8, then by
//               0 .. 7) and the clamp in two (its three tests, then the choice). For 250 MHz
//               (22 Oct 2026, step 15c: the 7-stage unit's shift and clamp missed 250 MHz).
// All three give exactly the same numbers; only the latency differs.
//
// On-chip MLP (21 Oct 2026): m0, shift and relu are now taken in the same clock as in_acc and
// in_bias and travel down the pipeline with them, so they can change on every clock (one scale per
// output channel). Before, m0 and relu were used one clock later and shift two clocks later, which
// was only right while they stayed constant (the tests held them constant, so they passed). With
// constant inputs the results are the same as before.
module postproc #(
    parameter int ACC   = 32,     // accumulator width (at most 32)
    parameter int OBITS = 8,      // output width
    parameter int PPIPE = 0       // 0 = 3 stages (LAT 3), 1 = 7 stages (LAT 7), 2 = 9 stages for 250 MHz (LAT 9)
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

    // Stage 1: add the bias; take m0, shift and relu together with the data
    logic                v1, relu1;
    logic signed [32:0]  s1;                 // acc + bias
    logic [15:0]         m01;
    logic [5:0]          sh1;
    always_ff @(posedge clk) begin
        if (rst) begin
            v1 <= 1'b0; s1 <= '0; m01 <= '0; sh1 <= '0; relu1 <= 1'b0;
        end else begin
            v1    <= in_valid;
            s1    <= 33'(in_acc) + 33'(in_bias);
            m01   <= m0;
            sh1   <= shift;
            relu1 <= relu;
        end
    end

    // The last stage: y = (p + rnd) >>> shift, then clamp to the output range
    function automatic logic signed [OBITS-1:0] clamp(input logic signed [49:0] y, input logic r);
        if (y > HI - 1)              clamp = OBITS'(HI - 1);
        else if (r && y < 0)         clamp = '0;
        else if (!r && y < -HI)      clamp = OBITS'(-HI);
        else                         clamp = OBITS'(y);
    endfunction

    generate
        if (PPIPE == 0) begin : g_pp3
            // Stage 2: multiply by m0. Stage 3: round, shift, clamp.
            logic                v2, relu2;
            logic signed [49:0]  p2;          // (acc + bias) * m0
            logic [5:0]          sh2;
            logic signed [49:0]  rnd, y;
            assign rnd = 50'sd1 <<< (sh2 - 6'd1);
            assign y   = (p2 + rnd) >>> sh2;
            always_ff @(posedge clk) begin
                if (rst) begin
                    v2 <= 1'b0; out_valid <= 1'b0;
                    p2 <= '0; sh2 <= '0; relu2 <= 1'b0; out_q <= '0;
                end else begin
                    v2    <= v1;
                    p2    <= 50'(s1) * $signed({34'd0, m01});
                    sh2   <= sh1;
                    relu2 <= relu1;
                    out_valid <= v2;
                    out_q     <= clamp(y, relu2);
                end
            end
        end else if (PPIPE == 1) begin : g_pp7
            // Stages 2-4: the multiply and two more registers (no reset, so they can go into the DSPs)
            // Stage 5: add the rounding constant. Stage 6: shift. Stage 7: clamp.
            logic [4:0]          vq;          // valid after stages 2 .. 6
            logic signed [49:0]  pa, pb, pc;  // (acc + bias) * m0, then delayed twice
            logic [5:0]          sh2, sh3, sh4, sh5;
            logic [4:0]          rl;          // relu after stages 2 .. 6
            logic signed [49:0]  rnd4;        // 2^(shift-1), made in stage 4
            logic signed [49:0]  t5;          // p + rnd
            logic signed [49:0]  y6;          // (p + rnd) >>> shift
            always_ff @(posedge clk) begin
                if (rst) begin
                    vq <= '0;
                    out_valid <= 1'b0;
                end else begin
                    vq <= {vq[3:0], v1};
                    out_valid <= vq[4];
                end
            end
            always_ff @(posedge clk) begin
                pa   <= 50'(s1) * $signed({34'd0, m01});
                pb   <= pa;
                pc   <= pb;
                sh2  <= sh1;  sh3 <= sh2;  sh4 <= sh3;  sh5 <= sh4;
                rl   <= {rl[3:0], relu1};
                rnd4 <= 50'sd1 <<< (sh3 - 6'd1);
                t5   <= pc + rnd4;
                y6   <= t5 >>> sh5;
                out_q <= clamp(y6, rl[4]);
            end
        end else begin : g_pp9
            // Stages 2-4: the multiply, as in g_pp7. Stage 5: add the rounding constant.
            // Stage 6: shift by shift[5:3] x 8. Stage 7: shift by shift[2:0].
            // Stage 8: the clamp's three tests. Stage 9: pick the output.
            // Same numbers as g_pp7 for every input: for s = 8a + b, t >>> s = (t >>> 8a) >>> b (a
            // shift past the top fills with the sign either way), and stages 8-9 are clamp() with its
            // three comparisons registered.
            logic [6:0]              vq;          // valid after stages 2 .. 8
            logic signed [49:0]      pa, pb, pc;  // (acc + bias) * m0, then delayed twice
            logic [5:0]              sh2, sh3, sh4, sh5;
            logic [2:0]              sf6;         // shift[2:0], for stage 7
            logic [6:0]              rl;          // relu after stages 2 .. 8
            logic signed [49:0]      rnd4;        // 2^(shift-1), made in stage 4
            logic signed [49:0]      t5;          // p + rnd
            logic signed [49:0]      c6;          // (p + rnd) >>> (shift[5:3] x 8)
            logic signed [49:0]      y7;          // (p + rnd) >>> shift
            logic                    hi8, neg8, lo8;  // y > HI - 1, y < 0, y < -HI
            logic signed [OBITS-1:0] q8;          // y's low bits: the output when no limit applies
            always_ff @(posedge clk) begin
                if (rst) begin
                    vq <= '0;
                    out_valid <= 1'b0;
                end else begin
                    vq <= {vq[5:0], v1};
                    out_valid <= vq[6];
                end
            end
            always_ff @(posedge clk) begin
                pa   <= 50'(s1) * $signed({34'd0, m01});
                pb   <= pa;
                pc   <= pb;
                sh2  <= sh1;  sh3 <= sh2;  sh4 <= sh3;  sh5 <= sh4;
                rl   <= {rl[5:0], relu1};
                rnd4 <= 50'sd1 <<< (sh3 - 6'd1);
                t5   <= pc + rnd4;
                c6   <= t5 >>> {sh5[5:3], 3'b000};
                sf6  <= sh5[2:0];
                y7   <= c6 >>> sf6;
                hi8  <= (y7 > HI - 1);
                neg8 <= (y7 < 0);
                lo8  <= (y7 < -HI);
                q8   <= OBITS'(y7);
                if (hi8)                 out_q <= OBITS'(HI - 1);
                else if (rl[6] && neg8)  out_q <= '0;
                else if (!rl[6] && lo8)  out_q <= OBITS'(-HI);
                else                     out_q <= q8;
            end
        end
    endgenerate
endmodule
