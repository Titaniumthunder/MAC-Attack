/*
 * Copyright (c) 2026 MAC Attack (Alex Salamati, James Manikyan, Marco Flores)
 * SPDX-License-Identifier: Apache-2.0
 *
 * Tiny-TPU Version 2 (MAC Attack) for Tiny Tapeout: tiny_tpu_v2_core (two INT8 PEs, exact 22-bit sums,
 * ping-pong input/output buffers, on-chip bias + rescale + ReLU) on the demo board's pins, with a BURST
 * mode that brings in two weights per clock so both PEs work every clock. Version 1 is the professor's
 * one-PE INT4 design (tinytpu/chip). The host (the board's RP2040) keeps the model and streams it in:
 *
 *   first layer:        CLEAR, LOAD_X x (number of inputs)
 *   per neuron pair:    CLEAR, LOAD_P x 12, BURST n, n data clocks, POST     (outputs stay on chip)
 *   next layer:         CLEAR with DATA = 1 (the outputs become the inputs), then neuron pairs again
 *   last layer:         CLEAR, BURST n, n data clocks, READ, read both raw 22-bit sums (bypass)
 *   (bypass for any layer: READ instead of LOAD_P/POST, and the host does the post-processing)
 *
 * Pins, normal (command) state
 *   ui_in[7:0]   DATA: input value (LOAD_X), weight (MAC), parameter byte (LOAD_P), burst length
 *                (BURST), flags (POST: bit 0 ReLU, bit 1 PE 0 only; CLEAR: bit 0 next layer)
 *   uio_in[2:0]  CMD: 0 NOP, 1 CLEAR, 2 LOAD_X, 3 MAC (PE 0), 4 READ, 5 BURST, 6 LOAD_P, 7 POST
 *   uio_in[3]    STROBE (MODE 0) or VALID (MODE 1)
 *   uio_in[4]    MODE: 0 = handshake, any host speed; 1 = streaming, one command per clock
 *   uio_in[6:5]  BSEL: uo_out shows 0 result[7:0], 1 result[15:8], 2 result[21:16] sign-extended, 3 status
 *   uio_in[7]    PSEL: which PE's result (0 or 1)
 *   uo_out[7:0]  the selected byte; status = {ACK, input position[4:0], OVF1, OVF0}
 *   result = the raw sum after READ, or the post-processed output (sign-extended) after POST
 * Pins during a burst (n clocks right after a BURST n command)
 *   ui_in[7:0]   weight for PE 0;   uio_in[7:0]   weight for PE 1   (every pin is data)
 *
 * MODE 0 (handshake): set DATA and CMD, raise STROBE, wait until ACK (status bit 7, so keep BSEL = 3
 *   while waiting) is 1, lower STROBE, wait for ACK = 0. BURST does nothing here (PE 0 via MAC only).
 * MODE 1 (streaming): every rising clock edge with VALID = 1 runs CMD on DATA. BURST n (n = 1..255,
 *   at most 32 per neuron) makes the next n clock edges dual-MAC clocks, then the pins are commands
 *   again. Everything must be synchronous to clk. All uio pins are inputs (uio_oe = 0).
 * Change MODE only while idle.
 */

`default_nettype none

module tt_um_titaniumthunder_tiny_tpu_v2 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  localparam [2:0] C_BURST = 3'd5;

  wire rst = ~rst_n;

  // Burst state: n dual-MAC clocks after a BURST n command (streaming mode)
  reg       burst;
  reg [7:0] count;

  wire mode = uio_in[4];
  wire cmd_pins_live = ~burst;                 // during a burst every pin is weight data

  // MODE 0: STROBE synchronizer + edge detect; held at 0 during bursts so data bits never look like a strobe
  reg s1, s2, s3, ack;
  always @(posedge clk) begin
    if (rst || burst) begin
      s1  <= 1'b0;
      s2  <= 1'b0;
      s3  <= 1'b0;
      ack <= 1'b0;
    end else begin
      s1  <= uio_in[3];
      s2  <= s1;
      s3  <= s2;
      ack <= s2;
    end
  end

  wire valid = cmd_pins_live & (mode ? uio_in[3] : (s2 & ~s3));
  wire [2:0] cmd = uio_in[2:0];
  wire start_burst = valid & mode & (cmd == C_BURST) & (ui_in != 8'd0);

  always @(posedge clk) begin
    if (rst) begin
      burst <= 1'b0;
      count <= 8'd0;
    end else if (burst) begin
      count <= count - 1'b1;
      if (count == 8'd1) burst <= 1'b0;
    end else if (start_burst) begin
      burst <= 1'b1;
      count <= ui_in;
    end
  end

  wire signed [21:0] result0, result1;
  wire               ovf0, ovf1;
  wire        [4:0]  ptr;

  tiny_tpu_v2_core u_core (
      .clk    (clk),
      .rst    (rst),
      .valid  (valid),
      .cmd    (cmd),
      .din    (ui_in),
      .mac2   (burst),
      .w0     (ui_in),
      .w1     (uio_in),
      .result0(result0),
      .result1(result1),
      .ovf0   (ovf0),
      .ovf1   (ovf1),
      .ptr_out(ptr)
  );

  wire [21:0] r = uio_in[7] ? result1 : result0;
  reg  [7:0]  byte_out;
  always @(*) begin
    case (uio_in[6:5])
      2'd0:    byte_out = r[7:0];
      2'd1:    byte_out = r[15:8];
      2'd2:    byte_out = {{2{r[21]}}, r[21:16]};
      default: byte_out = {ack, ptr, ovf1, ovf0};
    endcase
  end

  assign uo_out  = byte_out;
  assign uio_out = 8'b0000_0000;
  assign uio_oe  = 8'b0000_0000;               // all uio pins are inputs

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule

`default_nettype wire
