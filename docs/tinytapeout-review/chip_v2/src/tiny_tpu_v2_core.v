/*
 * Copyright (c) 2026 MAC Attack (Alex Salamati, James Manikyan, Marco Flores)
 * SPDX-License-Identifier: Apache-2.0
 *
 * tiny_tpu_v2_core: MAC Attack's Tiny-TPU Version 2 core (Version 1 is the professor's one-PE INT4 design).
 * Platform-independent: the Tiny Tapeout and FPGA tops only add pins / a bus around it.
 *
 *   - Two signed INT8 processing elements (a 1x2 array), exact 22-bit sums, one overflow flag each.
 *   - Two 32-byte buffers (ping-pong): the PEs read the layer's inputs from one while POST writes the
 *     layer's outputs into the other; CLEAR with "next layer" swaps them, so a hidden layer's outputs
 *     never leave the chip.
 *   - On-chip post-processing (POST), the same integer step as our FPGA postproc and modelV2:
 *       y = clamp(((sum + bias) * m0 + 2^(shift-1)) >> shift, ReLU ? 0 : -128, 127)
 *     with bias, m0 and shift per neuron, loaded by LOAD_P before each POST.
 *   - Bypass: READ copies the raw 22-bit sums to the result registers, so the host can do the
 *     post-processing itself (for a model with other math, or if POST ever misbehaves).
 *
 * Commands (valid = 1; din is the data byte):
 *   0 NOP
 *   1 CLEAR   both sums = 0, both overflow flags = 0, input position = 0, parameter position = 0.
 *             din[0] = 1: next layer: swap the buffers (outputs become inputs), output position = 0
 *   2 LOAD_X  input buffer[pos] <= din, pos++
 *   3 MAC     sum0 += x[pos] * din, pos++                        (one weight, PE 0 only)
 *   4 READ    result0 <= sum0, result1 <= sum1                    (raw sums: bypass)
 *   5         NOP here (the Tiny Tapeout top uses 5 for BURST)
 *   6 LOAD_P  param[ppos] <= din, ppos++: 12 bytes, PE 0 then PE 1, each
 *             bias[7:0], bias[15:8], bias[23:16] (signed), m0[7:0], m0[15:8] (unsigned), shift (0..47)
 *   7 POST    din[0] = ReLU, din[1] = PE 0 only (odd neuron count). One shared unit does PE 0 then PE 1:
 *             2 clocks after the POST edge y0 is in the output buffer and result0, 3 clocks after it
 *             y1 is in the buffer and result1 (all sign-extended in result). The output position
 *             advances by 2 (or 1). The next POST must come at least 4 clocks later (one sooner is ignored).
 * Dual MAC (mac2 = 1, takes priority over a command in the same clock):
 *             sum0 += x[pos] * w0, sum1 += x[pos] * w1, pos++
 *
 * Limits: at most 32 inputs and 32 outputs per layer; shift 0..47 (larger values act as 47); read a
 * POST's outputs (or use them as inputs) 4 or more clocks after it; a POST's results replace a READ's
 * in the same clock.
 */

`default_nettype none

module tiny_tpu_v2_core (
    input  wire               clk,
    input  wire               rst,          // synchronous, active high
    input  wire               valid,
    input  wire        [2:0]  cmd,
    input  wire        [7:0]  din,
    input  wire               mac2,         // dual MAC this clock
    input  wire        [7:0]  w0,
    input  wire        [7:0]  w1,
    output reg  signed [21:0] result0,
    output reg  signed [21:0] result1,
    output reg                ovf0,
    output reg                ovf1,
    output wire        [4:0]  ptr_out
);

  localparam [2:0] C_CLEAR = 3'd1, C_LOAD = 3'd2, C_MAC = 3'd3, C_READ = 3'd4,
                   C_LOADP = 3'd6, C_POST = 3'd7;

  // ---------------------------------------------------------------- state
  reg signed [7:0]  mem [0:63];     // buffer 0 = entries 0..31, buffer 1 = 32..63
  reg               sel;            // input buffer = sel, output buffer = ~sel
  reg        [4:0]  ptr;            // input position
  reg        [4:0]  optr;           // output position
  reg        [3:0]  pptr;           // parameter position
  reg        [7:0]  prm [0:11];     // per-neuron parameters for the next POST
  reg signed [21:0] acc0, acc1;

  // ---------------------------------------------------------------- the two PEs
  wire signed [7:0]  xi = mem[{sel, ptr}];
  wire signed [7:0]  wa = mac2 ? w0 : din;             // PE 0: w0 in a dual MAC, din in a single MAC
  wire signed [15:0] p0 = xi * wa;
  wire signed [15:0] p1 = xi * $signed(w1);
  wire signed [22:0] s0 = {acc0[21], acc0} + {{7{p0[15]}}, p0};
  wire signed [22:0] s1 = {acc1[21], acc1} + {{7{p1[15]}}, p1};

  // ---------------------------------------------------------------- post-processing, stage 1 inputs
  wire signed [23:0] bias0 = {prm[2], prm[1], prm[0]};
  wire        [15:0] m0_0  = {prm[4], prm[3]};
  wire signed [23:0] bias1 = {prm[8], prm[7], prm[6]};
  wire        [15:0] m0_1  = {prm[10], prm[9]};
  wire signed [24:0] v0 = {{3{acc0[21]}}, acc0} + {bias0[23], bias0};
  wire signed [24:0] v1 = {{3{acc1[21]}}, acc1} + {bias1[23], bias1};

  function [5:0] clip_shift(input [7:0] s);
    clip_shift = (s > 8'd47) ? 6'd47 : s[5:0];
  endfunction

  // One shared post-processing unit (one multiplier, one shifter) handles PE 0, then PE 1:
  //   POST edge:  inputs latched (sum + bias, m0, shift for both PEs; flags; destination)
  //   +1 clock:   t = (sum0 + bias0) * m0_0
  //   +2 clocks:  y0 = round / shift / clamp of t  -> buffer and result0;   t = (sum1 + bias1) * m0_1
  //   +3 clocks:  y1                               -> buffer and result1   (skipped for PE 0 only)
  // A POST that arrives while the unit is busy is ignored (real layers are >= 15 clocks apart).
  reg        [1:0]  phase;                              // 0 idle, 1 multiply 0, 2 finish 0 / multiply 1, 3 finish 1
  reg signed [24:0] vq0, vq1;
  reg        [15:0] mq0, mq1;
  reg        [5:0]  shq0, shq1;
  reg               q_relu, q_single;
  reg        [5:0]  q_dst;                              // {buffer, position} of y0
  reg signed [41:0] t;

  function signed [7:0] finish(input signed [41:0] tv, input [5:0] sh, input relu);
    reg signed [48:0] r;
    reg signed [48:0] y;
    begin
      r = (sh == 6'd0) ? 49'sd0 : (49'sd1 <<< (sh - 6'd1));
      y = ($signed({{7{tv[41]}}, tv}) + r) >>> sh;      // arithmetic shift: floor, like the reference
      if (y > 49'sd127)                     finish = 8'sd127;
      else if (relu && y < 49'sd0)          finish = 8'sd0;
      else if (!relu && y < -49'sd128)      finish = -8'sd128;
      else                                  finish = y[7:0];
    end
  endfunction

  wire signed [24:0] mul_a = (phase == 2'd1) ? vq0 : vq1;
  wire        [15:0] mul_b = (phase == 2'd1) ? mq0 : mq1;
  wire signed [41:0] prod  = mul_a * $signed({1'b0, mul_b});
  wire signed [7:0]  y     = finish(t, (phase == 2'd2) ? shq0 : shq1, q_relu);

  wire do_post = valid & ~mac2 & (cmd == C_POST) & (phase == 2'd0);

  // ---------------------------------------------------------------- control
  always @(posedge clk) begin
    if (rst) begin
      acc0 <= 22'sd0;  acc1 <= 22'sd0;
      result0 <= 22'sd0;  result1 <= 22'sd0;
      ovf0 <= 1'b0;  ovf1 <= 1'b0;
      sel <= 1'b0;  ptr <= 5'd0;  optr <= 5'd0;  pptr <= 4'd0;
      phase <= 2'd0;  q_relu <= 1'b0;  q_single <= 1'b0;  q_dst <= 6'd0;
      vq0 <= 25'sd0;  vq1 <= 25'sd0;  mq0 <= 16'd0;  mq1 <= 16'd0;  shq0 <= 6'd0;  shq1 <= 6'd0;
      t <= 42'sd0;
    end else begin
      // post-processing unit
      case (phase)
        2'd0: if (do_post) begin
          vq0 <= v0;  vq1 <= v1;
          mq0 <= m0_0;  mq1 <= m0_1;
          shq0 <= clip_shift(prm[5]);
          shq1 <= clip_shift(prm[11]);
          q_relu <= din[0];
          q_single <= din[1];
          q_dst <= {~sel, optr};
          optr <= optr + (din[1] ? 5'd1 : 5'd2);
          phase <= 2'd1;
        end
        2'd1: begin
          t <= prod;
          phase <= 2'd2;
        end
        2'd2: begin
          t <= prod;
          phase <= q_single ? 2'd0 : 2'd3;
        end
        default: phase <= 2'd0;
      endcase

      if (mac2) begin
        acc0 <= s0[21:0];
        acc1 <= s1[21:0];
        if (s0[22] ^ s0[21]) ovf0 <= 1'b1;
        if (s1[22] ^ s1[21]) ovf1 <= 1'b1;
        ptr <= ptr + 5'd1;
      end else if (valid) begin
        case (cmd)
          C_CLEAR: begin
            acc0 <= 22'sd0;  acc1 <= 22'sd0;
            ovf0 <= 1'b0;  ovf1 <= 1'b0;
            ptr <= 5'd0;  pptr <= 4'd0;
            if (din[0]) begin
              sel <= ~sel;
              optr <= 5'd0;
            end
          end
          C_LOAD: ptr <= ptr + 5'd1;
          C_MAC: begin
            acc0 <= s0[21:0];
            if (s0[22] ^ s0[21]) ovf0 <= 1'b1;
            ptr <= ptr + 5'd1;
          end
          C_READ: begin
            result0 <= acc0;
            result1 <= acc1;
          end
          C_LOADP: if (pptr < 4'd12) pptr <= pptr + 4'd1;
          default: ;
        endcase
      end

      // post-processing results (they replace a READ's in the same clock)
      if (phase == 2'd2) result0 <= {{14{y[7]}}, y};
      if (phase == 2'd3) result1 <= {{14{y[7]}}, y};
    end
  end

  // ---------------------------------------------------------------- buffers and parameters (no reset)
  always @(posedge clk) begin
    if (valid && !mac2 && cmd == C_LOAD) mem[{sel, ptr}] <= din;
    if (valid && !mac2 && cmd == C_LOADP && pptr < 4'd12) prm[pptr] <= din;
    if (phase == 2'd2) mem[q_dst] <= y;
    if (phase == 2'd3) mem[{q_dst[5], q_dst[4:0] + 5'd1}] <= y;
  end

  assign ptr_out = ptr;

endmodule

`default_nettype wire
