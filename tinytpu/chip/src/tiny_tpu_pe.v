/*
 * Copyright (c) 2026 MAC Attack (Alex Salamati, James Manikyan, Marco Flores)
 * SPDX-License-Identifier: Apache-2.0
 *
 * tiny_tpu_pe: one INT4 multiply-accumulate processing element (RSCL Tiny-TPU contract v1).
 *
 * The same module is meant for the FPGA prototype and the SKY130 chip; only the top-level
 * wrapper (pins, handshake) differs per platform.
 *
 * Commands, executed on a clock edge where cmd_valid = 1:
 *   CLEAR (2'd1)  acc <= 0, ovf <= 0
 *   MAC   (2'd2)  acc <= acc + a * w      a, w: signed 4-bit; product: signed 8-bit
 *   READ  (2'd3)  result <= acc           (a stable copy for the host to read out)
 *   NOP   (2'd0)  nothing
 *
 * Arithmetic contract: operands are meant to be in [-7, +7] (the model's symmetric INT4);
 * -8 also works here, as plain two's complement. The accumulator is signed 16-bit. If a MAC
 * would leave the 16-bit range, ovf goes high and stays high until the next CLEAR (the sum
 * itself wraps), so an overflow is never silent: the host must treat ovf = 1 as an error.
 * One MAC per clock; there is no multi-cycle state.
 */

`default_nettype none

module tiny_tpu_pe (
    input  wire               clk,
    input  wire               rst,        // synchronous, active high
    input  wire               cmd_valid,
    input  wire        [1:0]  cmd,
    input  wire signed [3:0]  a,          // activation
    input  wire signed [3:0]  w,          // weight
    output reg  signed [15:0] result,     // accumulator copy taken by READ
    output reg                ovf         // sticky overflow flag
);

  localparam [1:0] CMD_NOP = 2'd0, CMD_CLEAR = 2'd1, CMD_MAC = 2'd2, CMD_READ = 2'd3;

  reg  signed [15:0] acc;
  wire signed [7:0]  product = a * w;
  wire signed [16:0] sum     = {acc[15], acc} + {{9{product[7]}}, product};
  wire               sum_ovf = sum[16] ^ sum[15];   // result does not fit in 16 signed bits

  always @(posedge clk) begin
    if (rst) begin
      acc    <= 16'sd0;
      result <= 16'sd0;
      ovf    <= 1'b0;
    end else if (cmd_valid) begin
      case (cmd)
        CMD_CLEAR: begin
          acc <= 16'sd0;
          ovf <= 1'b0;
        end
        CMD_MAC: begin
          acc <= sum[15:0];
          if (sum_ovf) ovf <= 1'b1;
        end
        CMD_READ: result <= acc;
        CMD_NOP: ;
      endcase
    end
  end

endmodule

`default_nettype wire
