`timescale 1ns/1ps
// mac_axi: lets the ZedBoard's ARM processor drive the matrix core (mm_core).
//
//   ARM (Cortex-A9) --AXI4-Lite, M_AXI_GP0--> mac_axi --> mm_core (buffers + P x P systolic array)
//
// Written in plain Verilog-2001 on purpose: Vivado's block design can only use a Verilog or
// VHDL file as the top of a "module reference". The core underneath stays SystemVerilog.
//
// Register map (32-bit registers, byte offsets from the base address in the Address Editor):
//
//   0x00 CTRL         W   bit 0 = start (ignored while busy). Clears DONE and LOAD_ERR.
//   0x04 STATUS       R   bit 0 = busy, bit 1 = done (stays set until the next start),
//                         bit 2 = a load was attempted while busy (it was dropped)
//   0x08 DIMS         RW  [7:0] M, [15:8] K, [23:16] N   (C = A x B; A is M x K, B is K x N)
//   0x0C LOAD_PTR     RW  [0] matrix (0 = A, 1 = B), [15:8] row, [23:16] column to start at
//   0x10 LOAD_DATA    W   4 INT8 values, byte 0 first. Each byte goes to the current position,
//                         which then moves one column right and wraps to the next row at the
//                         row end. So a whole matrix is one stream of bytes in row order.
//                         Bytes past the end of the matrix are dropped.
//   0x14 RESULT_PTR   RW  [7:0] row, [15:8] column of the next C value to read
//   0x18 RESULT_DATA  R   C[row][column] as a signed 32-bit value; the position then moves on
//                         the same way (column first, then row)
//   0x1C PERF_PASSES  R   tile passes in the last run
//   0x20 PERF_CYCLES  R   cycles spent in passes (equals passes x (M + 3P - 2))
//   0x24 PERF_TOTAL   R   all busy cycles (PERF_CYCLES + 3)
//   0x28 INFO         R   [7:0] P, [15:8] bits per input, [23:16] accumulator bits, [31:24] MAXD
//   0x2C ID           R   0x4D414331 ("MAC1")
//
// Typical use: write DIMS, write LOAD_PTR = A at (0,0), stream A with LOAD_DATA, the same for B,
// write CTRL = 1, poll STATUS until done, write RESULT_PTR = (0,0), read RESULT_DATA M x N times.
module mac_axi #(
    parameter P    = 8,      // array size (P x P PEs)
    parameter MAXD = 64      // largest M, K or N
)(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn" *)
    input  wire        s_axi_aclk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input  wire        s_axi_aresetn,
    // write address and data
    input  wire [5:0]  s_axi_awaddr,
    input  wire [2:0]  s_axi_awprot,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,
    output wire [1:0]  s_axi_bresp,
    output wire        s_axi_bvalid,
    input  wire        s_axi_bready,
    // read address and data
    input  wire [5:0]  s_axi_araddr,
    input  wire [2:0]  s_axi_arprot,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,
    output wire [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output wire        s_axi_rvalid,
    input  wire        s_axi_rready
);
    localparam BITS = 8;
    localparam ACC  = 32;
    localparam [31:0] INFO_WORD = (MAXD << 24) | (ACC << 16) | (BITS << 8) | P;

    localparam [5:0] A_CTRL = 6'h00, A_STATUS = 6'h04, A_DIMS = 6'h08, A_LOAD_PTR = 6'h0C,
                     A_LOAD_DATA = 6'h10, A_RES_PTR = 6'h14, A_RES_DATA = 6'h18,
                     A_PASSES = 6'h1C, A_CYCLES = 6'h20, A_TOTAL = 6'h24, A_INFO = 6'h28, A_ID = 6'h2C;

    wire clk = s_axi_aclk;
    wire rst = ~s_axi_aresetn;           // the core uses an active-high reset

    // Replicable local reset for the compute array; AXI channel reset stays direct.
    (* max_fanout = 16 *) reg core_rst = 1'b1;
    always @(posedge clk) core_rst <= rst;

    // ------------------------------------------------------------ the matrix core
    reg        core_start;
    reg  [7:0] dim_m, dim_k, dim_n;
    wire       core_busy, core_done;
    wire       core_wr_en;
    wire [7:0] core_wr_data;
    wire [ACC-1:0] core_rd_data;
    // Isolate the C-buffer lane mux from the AXI register-selection mux.
    reg [ACC-1:0] core_rd_q;
    always @(posedge s_axi_aclk) core_rd_q <= core_rd_data;
    wire [31:0] perf_passes, perf_cycles, perf_total;
    reg        ld_sel;                   // 0 = loading A, 1 = loading B
    reg  [7:0] ld_row, ld_col;           // where the next loaded byte goes
    reg  [7:0] rd_row, rd_col;           // which C value RESULT_DATA returns

    mm_core #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(0), .MAXD(MAXD), .READ_PIPELINE(1), .DSP_CASCADE(1)) u_core (
        .clk(clk), .rst(core_rst),
        .wr_en(core_wr_en), .wr_sel(ld_sel), .wr_row(ld_row), .wr_col(ld_col), .wr_data(core_wr_data),
        .start(core_start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n),
        .busy(core_busy), .done(core_done),
        .rd_row(rd_row), .rd_col(rd_col), .rd_data(core_rd_data),
        .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total));

    // ------------------------------------------------------------ byte loader
    // A LOAD_DATA write holds 4 bytes; they go into the core one per clock.
    reg  [31:0] ld_word;
    reg  [2:0]  ld_left;                 // bytes still to write from ld_word
    reg [7:0] ld_rows, ld_rowlen;
    reg ld_start_inside;
    // Writes are serialized through capture, commit and response. Bounds settle
    // before the next LOAD_DATA commit, including after DIMS/LOAD_PTR changes.
    always @(posedge clk) begin
        ld_rows <= ld_sel ? dim_k : dim_m;
        ld_rowlen <= ld_sel ? dim_n : dim_k;
        ld_start_inside <= (ld_row < ld_rows) && (ld_col < ld_rowlen);
    end
    // Bounds are stable for an accepted LOAD_DATA transaction. Predict its end
    // instead of rechecking both coordinates in the row-counter enable path.
    reg ld_inside;
    reg [7:0] ld_last_col, ld_last_row;
    assign core_wr_en   = (ld_left != 3'd0) && ld_inside && !core_busy;
    assign core_wr_data = ld_word[7:0];

    // ------------------------------------------------------------ status bits
    reg done_flag, load_err;

    // ------------------------------------------------------------ AXI write channel
    reg axi_awready, axi_wready, axi_bvalid;
    assign s_axi_awready = axi_awready;
    assign s_axi_wready  = axi_wready;
    assign s_axi_bvalid  = axi_bvalid;
    assign s_axi_bresp   = 2'b00;        // always OKAY
    // A write happens in the cycle where both address and data are handed over.
    wire wr_fire = axi_awready && s_axi_awvalid && axi_wready && s_axi_wvalid;

    // Capture a transaction before decoding it, isolating the AXI interconnect.
    reg wr_pending;
    reg [5:0] wr_addr_q;
    reg [31:0] wr_data_q;
    always @(posedge clk) begin
        if (rst) wr_pending <= 1'b0;
        else wr_pending <= wr_fire;
        if (wr_fire) begin
            wr_addr_q <= s_axi_awaddr;
            wr_data_q <= s_axi_wdata;
        end
    end

    // ------------------------------------------------------------ AXI read channel
    reg        axi_arready, axi_rvalid;
    reg [31:0] axi_rdata;
    reg [5:0]  rd_addr;
    reg [2:0]  rd_wait;                  // clocks until the read data is ready
    assign s_axi_arready = axi_arready;
    assign s_axi_rvalid  = axi_rvalid;
    assign s_axi_rdata   = axi_rdata;
    assign s_axi_rresp   = 2'b00;
    wire ar_fire = axi_arready && s_axi_arvalid;
    wire r_fire  = axi_rvalid && s_axi_rready;

    always @(posedge clk) begin
        if (rst) begin
            axi_awready <= 1'b0; axi_wready <= 1'b0; axi_bvalid <= 1'b0;
            axi_arready <= 1'b0; axi_rvalid <= 1'b0; axi_rdata <= 32'd0;
            rd_addr <= 6'd0; rd_wait <= 2'd0;
            core_start <= 1'b0; dim_m <= 8'd0; dim_k <= 8'd0; dim_n <= 8'd0;
            ld_sel <= 1'b0; ld_row <= 8'd0; ld_col <= 8'd0; ld_word <= 32'd0; ld_left <= 3'd0;
            ld_inside <= 1'b0; ld_last_col <= 8'd0; ld_last_row <= 8'd0;
            rd_row <= 8'd0; rd_col <= 8'd0;
            done_flag <= 1'b0; load_err <= 1'b0;
        end else begin
            core_start <= 1'b0;
            if (core_done && !core_rst) done_flag <= 1'b1;

            // ---- loader: one byte per clock, then step to the next position
            if (ld_left != 3'd0) begin
                ld_word <= {8'd0, ld_word[31:8]};
                ld_left <= ld_left - 3'd1;
                if (ld_inside) begin
                    if (ld_col == ld_last_col) begin
                        ld_col <= 8'd0;
                        ld_row <= ld_row + 8'd1;
                        if (ld_row == ld_last_row) ld_inside <= 1'b0;
                    end else begin
                        ld_col <= ld_col + 8'd1;
                    end
                end
            end

            // ---- write channel: take address and data together, one write at a time.
            // A new write waits until the previous LOAD_DATA bytes are all written.
            if (!axi_awready && s_axi_awvalid && s_axi_wvalid && !axi_bvalid && !wr_pending && ld_left == 3'd0) begin
                axi_awready <= 1'b1;
                axi_wready  <= 1'b1;
            end else begin
                axi_awready <= 1'b0;
                axi_wready  <= 1'b0;
            end
            if (wr_pending) begin
                axi_bvalid <= 1'b1;
                case (wr_addr_q)
                    A_CTRL: if (wr_data_q[0] && !core_busy) begin
                                core_start <= 1'b1;
                                done_flag  <= 1'b0;
                                load_err   <= 1'b0;
                            end
                    A_DIMS: if (!core_busy) begin
                                dim_m <= wr_data_q[7:0];
                                dim_k <= wr_data_q[15:8];
                                dim_n <= wr_data_q[23:16];
                            end
                    A_LOAD_PTR: begin
                                ld_sel <= wr_data_q[0];
                                ld_row <= wr_data_q[15:8];
                                ld_col <= wr_data_q[23:16];
                            end
                    A_LOAD_DATA: if (core_busy) load_err <= 1'b1;
                            else begin
                                ld_word <= wr_data_q;
                                ld_left <= 3'd4;
                                ld_inside <= ld_start_inside;
                                ld_last_col <= ld_rowlen - 8'd1;
                                ld_last_row <= ld_rows - 8'd1;
                            end
                    A_RES_PTR: begin
                                rd_row <= wr_data_q[7:0];
                                rd_col <= wr_data_q[15:8];
                            end
                    default: ;
                endcase
            end
            if (axi_bvalid && s_axi_bready) axi_bvalid <= 1'b0;

            // ---- read channel: allow memory read and result staging before responding
            if (!axi_arready && s_axi_arvalid && !axi_rvalid && rd_wait == 2'd0)
                axi_arready <= 1'b1;
            else
                axi_arready <= 1'b0;
            if (ar_fire) begin
                rd_addr <= s_axi_araddr;
                rd_wait <= 3'd4;
            end
            if (rd_wait != 2'd0) begin
                rd_wait <= rd_wait - 2'd1;
                if (rd_wait == 2'd1) begin
                    axi_rvalid <= 1'b1;
                    case (rd_addr)
                        A_STATUS:   axi_rdata <= {29'd0, load_err, done_flag, core_busy};
                        A_DIMS:     axi_rdata <= {8'd0, dim_n, dim_k, dim_m};
                        A_LOAD_PTR: axi_rdata <= {8'd0, ld_col, ld_row, 7'd0, ld_sel};
                        A_RES_PTR:  axi_rdata <= {16'd0, rd_col, rd_row};
                        A_RES_DATA: axi_rdata <= core_rd_q;
                        A_PASSES:   axi_rdata <= perf_passes;
                        A_CYCLES:   axi_rdata <= perf_cycles;
                        A_TOTAL:    axi_rdata <= perf_total;
                        A_INFO:     axi_rdata <= INFO_WORD;
                        A_ID:       axi_rdata <= 32'h4D41_4331;
                        default:    axi_rdata <= 32'd0;
                    endcase
                end
            end
            if (r_fire) begin
                axi_rvalid <= 1'b0;
                if (rd_addr == A_RES_DATA) begin           // move to the next C value
                    if (rd_col + 8'd1 == dim_n) begin
                        rd_col <= 8'd0;
                        rd_row <= rd_row + 8'd1;
                    end else begin
                        rd_col <= rd_col + 8'd1;
                    end
                end
            end
        end
    end

    // AXI signals this slave does not need
    wire unused = &{1'b0, s_axi_awprot, s_axi_arprot, s_axi_wstrb};
endmodule








