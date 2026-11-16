/*
 * Copyright (c) 2026 MAC Attack (Alex Salamati, James Manikyan, Marco Flores)
 * SPDX-License-Identifier: Apache-2.0
 *
 * tiny_tpu_axi: the ZedBoard top for the Tiny-TPU processing element. The ARM plays the host
 * (the RP2040's job on the Tiny Tapeout board) over AXI4-Lite. The PE is the SAME file as the
 * chip: ../chip/src/tiny_tpu_pe.v. Only this wrapper is FPGA-specific.
 *
 * Registers (32-bit, byte offsets):
 *   0x00 CMD     write: [3:0] a, [7:4] w (signed INT4), [9:8] command (0 NOP, 1 CLEAR, 2 MAC, 3 READ).
 *                Each write runs one command in one clock, before the write response returns,
 *                so the ARM never has to wait or poll. Read: the last word written.
 *   0x04 RESULT  read: the 16-bit accumulator copy taken by the last READ, sign-extended to 32 bits.
 *   0x08 STATUS  read: [0] OVF, the sticky 16-bit overflow flag (cleared by CLEAR).
 *   0x0C ID      read: 0x54505534 ("TPU4").
 */

`default_nettype none

module tiny_tpu_axi (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn" *)
    input  wire        s_axi_aclk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input  wire        s_axi_aresetn,

    input  wire [3:0]  s_axi_awaddr,
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

    input  wire [3:0]  s_axi_araddr,
    input  wire [2:0]  s_axi_arprot,
    input  wire        s_axi_arvalid,
    output reg         s_axi_arready,
    output reg  [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready
);

  localparam [31:0] ID = 32'h5450_5534;    // "TPU4"

  wire clk = s_axi_aclk;
  wire rst = ~s_axi_aresetn;

  assign s_axi_bresp = 2'b00;
  assign s_axi_rresp = 2'b00;

  // ---------------------------------------------------------------- write channel
  // Address and data may arrive in either order; each is held until both are here.
  reg        aw_have, w_have;
  reg [3:0]  aw_addr;
  reg [31:0] w_data;
  reg [31:0] cmd_word;

  wire aw_take  = s_axi_awvalid & s_axi_awready;
  wire w_take   = s_axi_wvalid & s_axi_wready;
  wire aw_now   = aw_have | aw_take;
  wire w_now    = w_have | w_take;
  wire [3:0]  addr_now = aw_have ? aw_addr : s_axi_awaddr;
  wire [31:0] data_now = w_have ? w_data : s_axi_wdata;
  wire do_write = aw_now & w_now & ~s_axi_bvalid;

  always @(posedge clk) begin
    if (rst) begin
      aw_have       <= 1'b0;
      w_have        <= 1'b0;
      aw_addr       <= 4'd0;
      w_data        <= 32'd0;
      s_axi_awready <= 1'b0;
      s_axi_wready  <= 1'b0;
      s_axi_bvalid  <= 1'b0;
      cmd_word      <= 32'd0;
    end else begin
      // accept a new address / data only when that half is not already held and no response is pending
      s_axi_awready <= ~aw_now & ~s_axi_bvalid & ~do_write;
      s_axi_wready  <= ~w_now & ~s_axi_bvalid & ~do_write;
      if (aw_take) aw_addr <= s_axi_awaddr;
      if (w_take)  w_data  <= s_axi_wdata;

      if (do_write) begin
        aw_have      <= 1'b0;
        w_have       <= 1'b0;
        s_axi_bvalid <= 1'b1;
        if (addr_now[3:2] == 2'd0) cmd_word <= data_now;
      end else begin
        if (aw_take) aw_have <= 1'b1;
        if (w_take)  w_have  <= 1'b1;
        if (s_axi_bvalid & s_axi_bready) s_axi_bvalid <= 1'b0;
      end
    end
  end

  // One command per write to CMD, issued in the same clock as the write
  wire       cmd_valid = do_write & (addr_now[3:2] == 2'd0);
  wire [1:0] cmd       = data_now[9:8];

  wire signed [15:0] result;
  wire               ovf;

  tiny_tpu_pe u_pe (
      .clk      (clk),
      .rst      (rst),
      .cmd_valid(cmd_valid),
      .cmd      (cmd),
      .a        (data_now[3:0]),
      .w        (data_now[7:4]),
      .result   (result),
      .ovf      (ovf)
  );

  // ---------------------------------------------------------------- read channel
  always @(posedge clk) begin
    if (rst) begin
      s_axi_arready <= 1'b0;
      s_axi_rvalid  <= 1'b0;
      s_axi_rdata   <= 32'd0;
    end else begin
      // one read at a time: ready for one clock when an address is waiting and no data is pending
      s_axi_arready <= s_axi_arvalid & ~s_axi_arready & ~s_axi_rvalid;
      if (s_axi_arvalid & s_axi_arready) begin
        s_axi_rvalid <= 1'b1;
        case (s_axi_araddr[3:2])
          2'd0: s_axi_rdata <= cmd_word;
          2'd1: s_axi_rdata <= {{16{result[15]}}, result};
          2'd2: s_axi_rdata <= {31'd0, ovf};
          default: s_axi_rdata <= ID;
        endcase
      end else if (s_axi_rvalid & s_axi_rready) begin
        s_axi_rvalid <= 1'b0;
      end
    end
  end

  wire _unused = &{s_axi_awprot, s_axi_arprot, s_axi_wstrb, addr_now[1:0], s_axi_araddr[1:0],
                   data_now[31:10], 1'b0};

endmodule

`default_nettype wire
