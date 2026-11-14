/*
 * Copyright (c) 2026 MAC Attack (Alex Salamati, James Manikyan, Marco Flores)
 * SPDX-License-Identifier: Apache-2.0
 *
 * Tiny Tapeout wrapper for tiny_tpu_pe (one INT4 MAC processing element).
 * The host (the RP2040 on the Tiny Tapeout demo board) keeps the model and sends one
 * command at a time with a 4-phase handshake, so it works at any host speed:
 *
 *   1. put the operands on ui_in and the command on uio_in[1:0]
 *   2. raise STROBE (uio_in[2])
 *   3. wait for ACK (uio_out[4]) = 1      the command has been executed
 *   4. lower STROBE, wait for ACK = 0     ready for the next command
 *
 * Pins
 *   ui_in[3:0]   a, activation (signed INT4)
 *   ui_in[7:4]   w, weight     (signed INT4)
 *   uio_in[1:0]  command: 0 NOP, 1 CLEAR, 2 MAC, 3 READ
 *   uio_in[2]    STROBE (host -> chip)
 *   uio_in[3]    HI: 0 = uo_out shows result[7:0], 1 = result[15:8]
 *   uio_out[4]   ACK (chip -> host)
 *   uio_out[5]   OVF: sticky 16-bit overflow flag, cleared by CLEAR
 *   uo_out[7:0]  the selected byte of the 16-bit result latched by the last READ
 *
 * Operands and the command must be stable from step 1 until ACK = 1. STROBE goes through a
 * two-flip-flop synchronizer, so a command executes 2-3 clocks after STROBE rises.
 */

`default_nettype none

module tt_um_titaniumthunder_tiny_tpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire rst = ~rst_n;

  // STROBE synchronizer and rising-edge detect
  reg strobe_s1, strobe_s2, strobe_s3;
  always @(posedge clk) begin
    if (rst) begin
      strobe_s1 <= 1'b0;
      strobe_s2 <= 1'b0;
      strobe_s3 <= 1'b0;
    end else begin
      strobe_s1 <= uio_in[2];
      strobe_s2 <= strobe_s1;
      strobe_s3 <= strobe_s2;
    end
  end
  wire cmd_valid = strobe_s2 & ~strobe_s3;

  // ACK rises on the same clock edge that executes the command, and falls after STROBE falls
  reg ack;
  always @(posedge clk) begin
    if (rst) ack <= 1'b0;
    else     ack <= strobe_s2;
  end

  wire signed [15:0] result;
  wire               ovf;

  tiny_tpu_pe u_pe (
      .clk      (clk),
      .rst      (rst),
      .cmd_valid(cmd_valid),
      .cmd      (uio_in[1:0]),
      .a        (ui_in[3:0]),
      .w        (ui_in[7:4]),
      .result   (result),
      .ovf      (ovf)
  );

  assign uo_out  = uio_in[3] ? result[15:8] : result[7:0];
  assign uio_out = {2'b00, ovf, ack, 4'b0000};
  assign uio_oe  = 8'b0011_0000;                 // uio[5:4] are outputs, the rest inputs

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:4], 1'b0};

endmodule

`default_nettype wire
