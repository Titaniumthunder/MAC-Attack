/*
 * Copyright (c) 2026 MAC Attack (Alex Salamati, James Manikyan, Marco Flores)
 * SPDX-License-Identifier: Apache-2.0
 *
 * tiny_tpu_v2_axi: the ZedBoard top for Tiny-TPU Version 2. The ARM plays the host (the RP2040's job on
 * the Tiny Tapeout board) over AXI4-Lite. The core is the SAME file as the chip:
 * ../chip_v2/src/tiny_tpu_v2_core.v (two INT8 PEs, ping-pong buffers, on-chip bias + rescale + ReLU).
 * Only this wrapper is FPGA-specific; it replaces the chip's pins (tt_um_..._v2 in project.v).
 *
 * Every write runs its core steps one per clock, back to back, and the write response comes back only
 * when they are done (and, after a POST, when both outputs are in the result registers and the buffer).
 * So the ARM never waits or polls: write, write, ..., read.
 *
 * Registers (32-bit, byte offsets)
 *   write
 *   0x00 CMD     [10:8] command, [7:0] data: one core command (0 NOP, 1 CLEAR, 2 LOAD_X, 3 MAC (PE 0),
 *                4 READ, 6 LOAD_P, 7 POST; 5 is a NOP here: the chip's BURST is replaced by PAIR / PAIR2)
 *   0x04 PAIR    [7:0] weight for PE 0, [15:8] weight for PE 1: one dual MAC
 *   0x08 PAIR2   two dual MACs: [15:0] the first pair (as PAIR), [31:16] the second
 *   0x0C LOADX4  four LOAD_X, byte [7:0] first
 *   0x10 LOADP4  four LOAD_P, byte [7:0] first (a neuron pair's 12 parameter bytes = 3 writes)
 *   read
 *   0x14 RESULT0 PE 0's result, sign-extended: raw 22-bit sum after READ, 8-bit output after POST
 *   0x18 RESULT1 PE 1's result
 *   0x1C STATUS  [0] OVF0, [1] OVF1 (sticky 22-bit overflow, cleared by CLEAR), [6:2] input position
 *   0x20 ID      0x54505538 ("TPU8")
 *   0x24 STEPS   core steps run since reset (commands + dual MACs; one per clock), wraps at 2^32
 */

`default_nettype none

module tiny_tpu_v2_axi (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn" *)
    input  wire        s_axi_aclk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input  wire        s_axi_aresetn,

    input  wire [5:0]  s_axi_awaddr,
    input  wire [2:0]  s_axi_awprot,
    input  wire        s_axi_awvalid,
    output reg         s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output reg         s_axi_wready,
    output wire [1:0]  s_axi_bresp,
    output reg         s_axi_bvalid,
    input  wire        s_axi_bready,

    input  wire [5:0]  s_axi_araddr,
    input  wire [2:0]  s_axi_arprot,
    input  wire        s_axi_arvalid,
    output reg         s_axi_arready,
    output reg  [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready
);

  localparam [31:0] ID = 32'h5450_5538;    // "TPU8"
  localparam [2:0]  C_LOAD = 3'd2, C_LOADP = 3'd6, C_POST = 3'd7;
  localparam [3:0]  A_CMD = 4'd0, A_PAIR = 4'd1, A_PAIR2 = 4'd2, A_LOADX4 = 4'd3, A_LOADP4 = 4'd4,
                    A_RES0 = 4'd5, A_RES1 = 4'd6, A_STATUS = 4'd7, A_ID = 4'd8, A_STEPS = 4'd9;

  wire clk = s_axi_aclk;
  wire rst = ~s_axi_aresetn;

  assign s_axi_bresp = 2'b00;
  assign s_axi_rresp = 2'b00;

  // ---------------------------------------------------------------- step queue
  // A write loads 1, 2 or 4 steps; one step goes to the core every clock. After a POST the wrapper
  // stays busy 3 more clocks, so the next access sees both outputs (the core's POST takes 3 clocks).
  reg [2:0]  q_n;          // steps left
  reg        q_pair;       // the steps are dual MACs
  reg [2:0]  q_cmd;        // otherwise, this command on each data byte
  reg [31:0] q_data;       // data bytes (or weight pairs), lowest first
  reg [1:0]  cool;         // clocks left after a POST
  reg [31:0] steps;

  wire busy       = (q_n != 3'd0) | (cool != 2'd0);
  wire step       = (q_n != 3'd0);
  wire core_valid = step & ~q_pair;
  wire core_mac2  = step & q_pair;

  // ---------------------------------------------------------------- write channel
  // Address and data may arrive in either order; each is held until both are here. The response is
  // held until the write's steps are done.
  reg        aw_have, w_have, b_pend;
  reg [5:0]  aw_addr;
  reg [31:0] w_data;

  wire aw_take  = s_axi_awvalid & s_axi_awready;
  wire w_take   = s_axi_wvalid & s_axi_wready;
  wire aw_now   = aw_have | aw_take;
  wire w_now    = w_have | w_take;
  wire [5:0]  addr_now = aw_have ? aw_addr : s_axi_awaddr;
  wire [31:0] data_now = w_have ? w_data : s_axi_wdata;
  wire idle_b   = ~s_axi_bvalid & ~b_pend;
  wire do_write = aw_now & w_now & idle_b & ~busy;

  always @(posedge clk) begin
    if (rst) begin
      aw_have       <= 1'b0;
      w_have        <= 1'b0;
      b_pend        <= 1'b0;
      aw_addr       <= 6'd0;
      w_data        <= 32'd0;
      s_axi_awready <= 1'b0;
      s_axi_wready  <= 1'b0;
      s_axi_bvalid  <= 1'b0;
      q_n           <= 3'd0;
      q_pair        <= 1'b0;
      q_cmd         <= 3'd0;
      q_data        <= 32'd0;
      cool          <= 2'd0;
      steps         <= 32'd0;
    end else begin
      // accept a new address / data only when that half is not already held and no response is pending
      s_axi_awready <= ~aw_now & idle_b & ~do_write;
      s_axi_wready  <= ~w_now & idle_b & ~do_write;
      if (aw_take) aw_addr <= s_axi_awaddr;
      if (w_take)  w_data  <= s_axi_wdata;

      if (do_write) begin
        aw_have <= 1'b0;
        w_have  <= 1'b0;
        b_pend  <= 1'b1;
        q_data  <= data_now;
        case (addr_now[5:2])
          A_CMD:    begin q_n <= 3'd1; q_pair <= 1'b0; q_cmd <= data_now[10:8]; end
          A_PAIR:   begin q_n <= 3'd1; q_pair <= 1'b1; end
          A_PAIR2:  begin q_n <= 3'd2; q_pair <= 1'b1; end
          A_LOADX4: begin q_n <= 3'd4; q_pair <= 1'b0; q_cmd <= C_LOAD; end
          A_LOADP4: begin q_n <= 3'd4; q_pair <= 1'b0; q_cmd <= C_LOADP; end
          default:  ;                               // read-only or unused address: no steps
        endcase
      end else begin
        if (aw_take) aw_have <= 1'b1;
        if (w_take)  w_have  <= 1'b1;
        if (b_pend & ~busy) begin
          b_pend       <= 1'b0;
          s_axi_bvalid <= 1'b1;
        end
        if (s_axi_bvalid & s_axi_bready) s_axi_bvalid <= 1'b0;
      end

      // run one step per clock
      if (step) begin
        q_n    <= q_n - 3'd1;
        q_data <= q_pair ? {16'd0, q_data[31:16]} : {8'd0, q_data[31:8]};
        steps  <= steps + 32'd1;
      end
      if (core_valid && q_cmd == C_POST) cool <= 2'd3;
      else if (cool != 2'd0)             cool <= cool - 2'd1;
    end
  end

  // ---------------------------------------------------------------- the core (same file as the chip)
  wire signed [21:0] result0, result1;
  wire               ovf0, ovf1;
  wire        [4:0]  ptr;

  tiny_tpu_v2_core u_core (
      .clk    (clk),
      .rst    (rst),
      .valid  (core_valid),
      .cmd    (q_cmd),
      .din    (q_data[7:0]),
      .mac2   (core_mac2),
      .w0     (q_data[7:0]),
      .w1     (q_data[15:8]),
      .result0(result0),
      .result1(result1),
      .ovf0   (ovf0),
      .ovf1   (ovf1),
      .ptr_out(ptr)
  );

  // ---------------------------------------------------------------- read channel
  // One read at a time, and none while a write's steps are still running.
  always @(posedge clk) begin
    if (rst) begin
      s_axi_arready <= 1'b0;
      s_axi_rvalid  <= 1'b0;
      s_axi_rdata   <= 32'd0;
    end else begin
      s_axi_arready <= s_axi_arvalid & ~s_axi_arready & ~s_axi_rvalid & ~busy;
      if (s_axi_arvalid & s_axi_arready) begin
        s_axi_rvalid <= 1'b1;
        case (s_axi_araddr[5:2])
          A_RES0:   s_axi_rdata <= {{10{result0[21]}}, result0};
          A_RES1:   s_axi_rdata <= {{10{result1[21]}}, result1};
          A_STATUS: s_axi_rdata <= {25'd0, ptr, ovf1, ovf0};
          A_ID:     s_axi_rdata <= ID;
          A_STEPS:  s_axi_rdata <= steps;
          default:  s_axi_rdata <= 32'd0;
        endcase
      end else if (s_axi_rvalid & s_axi_rready) begin
        s_axi_rvalid <= 1'b0;
      end
    end
  end

  wire _unused = &{s_axi_awprot, s_axi_arprot, s_axi_wstrb, addr_now[1:0], s_axi_araddr[1:0], 1'b0};

endmodule

`default_nettype wire
