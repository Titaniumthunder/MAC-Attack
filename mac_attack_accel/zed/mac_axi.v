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
//                         bit 2 = a load was attempted while busy (it was dropped),
//                         bit 3 = waiting for the core clock (CORE_CLK = 1 only: the clocking
//                         wizard is not locked yet or the core is still in reset; CTRL is ignored)
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
//   0x24 PERF_TOTAL   R   all busy cycles (PERF_CYCLES + 3 + PIPE + MEM_REG = PERF_CYCLES + 7 by default)
//   0x28 INFO         R   [7:0] P, [15:8] bits per input, [23:16] accumulator bits, [31:24] MAXD
//   0x2C ID           R   0x4D414331 ("MAC1")
//   0x30 CONFIG       R   [7:0] PIPE, [15:8] MEM_REG, [16] CORE_CLK (1 = the core has its own clock),
//                         [17] PE_PRIM (1 = PEs placed as DSP48E1 primitives)
//
// Typical use: write DIMS, write LOAD_PTR = A at (0,0), stream A with LOAD_DATA, the same for B,
// write CTRL = 1, poll STATUS until done, write RESULT_PTR = (0,0), read RESULT_DATA M x N times.
//
// Step 9 (17 Oct 2026), timing only, same results and same bus timing:
//   * RESULT_DATA moves to the next C value when the read data is captured (rd_wait = 1) instead
//     of when the ARM accepts it (rready). The "last column" test is a flag registered the cycle
//     before, against N - 1 kept in a register, so no adder, no compare and no interconnect
//     signal sits in front of the rd_row/rd_col flip-flops. The next read starts only after this
//     one is accepted, so the ARM sees exactly the same values as before.
//   * The loader's write port into the core is registered: the bounds compares now end at a
//     flip-flop instead of at the block-RAM write enables. A byte reaches its buffer one clock
//     later; the next AXI write (for example CTRL = start) is accepted at the earliest two clocks
//     after the last byte, so a run never starts before every byte is in.
// Step 10 (17 Oct 2026): EXACT_ACC = 1 makes the accumulators 2*8 + clog2(MAXD) bits (22 for
//   MAXD = 64), the smallest width that can never overflow (proof in mm_core.sv). RESULT_DATA is
//   that value sign-extended to 32 bits, so the ARM reads exactly the same numbers as before.
//   EXACT_ACC = 0 gives the old 32-bit accumulators.
// Step 11 (17 Oct 2026): PIPE = 2, one DSP per PE with its input, multiplier and output registers
//   and the add inside the DSP (see pe.sv). Same results; perf_total one cycle more per run.
// Step 11b (17 Oct 2026): from pe.sv Vivado built two DSPs per PE, so PE_PRIM = 1 (the default) places
//   each PE as one DSP48E1 directly (zed/pe_dsp48.sv, same circuit as pe.sv with PIPE = 2). PE_PRIM = 1
//   always uses PIPE = 2. PE_PRIM = 0 uses pe.sv with the PIPE given here.
// Step 12 (17 Oct 2026): CORE_CLK = 1 runs the matrix core on its own clock (core_clk, from a
//   Clocking Wizard), as in NVIDIA Simba's separate clocks per block (GALS). This side (the AXI
//   registers and the loader) stays on s_axi_aclk. The two clocks may be unrelated; everything that
//   crosses between them is one of these:
//     * start and done: a toggle on one side, two flip-flops (ASYNC_REG) and an edge detector on
//       the other. CTRL is accepted only while the core is idle and out of reset.
//     * reset: two flip-flops into the core clock (together with the wizard's locked signal);
//       "core ready" back the same way (STATUS bit 3 is its inverse).
//     * A and B buffers: written on s_axi_aclk, read on core_clk (dual-clock block RAMs).
//       C: a copy written on core_clk and read on s_axi_aclk (see mm_core.sv, HCLK_SEP).
//     * DIMS and the performance counters: they do not change while the other side reads them
//       (DIMS only while idle; the counters only during a run, read after done).
//   zed/mac_zed_cdc.xdc tells Vivado the two clocks are asynchronous.
//   CORE_CLK = 0: one clock, exactly as before (core_clk and core_locked are not used).
module mac_axi #(
    parameter P         = 8,   // array size (P x P PEs)
    parameter MAXD      = 64,  // largest M, K or N
    parameter PIPE      = 2,   // PE pipeline: 1 = multiply, add (LUTs); 2 = input, multiply, add in the DSP (see pe.sv)
    parameter MEM_REG   = 2,   // registers after the block-RAM reads (see mm_core.sv)
    parameter EXACT_ACC = 1,   // 1 = accumulators 2*8 + clog2(MAXD) bits (exact), 0 = 32 bits
    parameter CORE_CLK  = 0,   // 1 = the core runs on core_clk (step 12); 0 = everything on s_axi_aclk
    parameter PE_PRIM   = 1    // 1 = each PE is one DSP48E1 placed directly (zed/pe_dsp48.sv, PIPE = 2); 0 = pe.sv
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
    input  wire        s_axi_rready,
    // core clock (used only when CORE_CLK = 1): from a Clocking Wizard, and its locked output
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 core_clk CLK" *)
    input  wire        core_clk,
    input  wire        core_locked
);
    localparam BITS = 8;
    localparam ACC  = (EXACT_ACC != 0) ? 2 * BITS + $clog2(MAXD) : 32;   // 22 for MAXD = 64
    localparam [31:0] INFO_WORD = (MAXD << 24) | (ACC << 16) | (BITS << 8) | P;

    localparam [5:0] A_CTRL = 6'h00, A_STATUS = 6'h04, A_DIMS = 6'h08, A_LOAD_PTR = 6'h0C,
                     A_LOAD_DATA = 6'h10, A_RES_PTR = 6'h14, A_RES_DATA = 6'h18,
                     A_PASSES = 6'h1C, A_CYCLES = 6'h20, A_TOTAL = 6'h24, A_INFO = 6'h28, A_ID = 6'h2C,
                     A_CONFIG = 6'h30;
    localparam PIPE_EFF = (PE_PRIM != 0) ? 2 : PIPE;             // the DSP48E1 PE is the PIPE = 2 circuit
    localparam [31:0] CONFIG_WORD = ((PE_PRIM != 0 ? 1 : 0) << 17) | ((CORE_CLK != 0 ? 1 : 0) << 16) |
                                    (MEM_REG << 8) | PIPE_EFF;

    wire clk = s_axi_aclk;
    // Active-high reset for this block and the core, registered here so the reset wire
    // gets a whole clock cycle to reach its loads (and the tool may copy the register).
    (* max_fanout = 64 *) reg rst;
    always @(posedge clk) rst <= ~s_axi_aresetn;

    // ------------------------------------------------------------ the matrix core
    reg        core_start;               // one-clock pulse on this side when CTRL starts a run
    reg  [7:0] dim_m, dim_k, dim_n;
    wire       busy_h;                   // the core is running, as seen on this side
    wire       done_h;                   // one-clock pulse on this side when a run has finished
    wire       wait_h;                   // waiting for the core clock (CORE_CLK = 1 only)
    reg        core_wr_en, core_wr_sel;  // the loader's write port, registered (see the header)
    reg  [7:0] core_wr_row, core_wr_col, core_wr_data;
    wire [ACC-1:0] core_rd_data;
    wire [31:0] perf_passes, perf_cycles, perf_total;
    reg        ld_sel;                   // 0 = loading A, 1 = loading B
    reg  [7:0] ld_row, ld_col;           // where the next loaded byte goes
    reg  [7:0] rd_row, rd_col;           // which C value RESULT_DATA returns

    generate
        if (CORE_CLK == 0) begin : g_one_clock
            // One clock: the core runs on s_axi_aclk, as before
            wire core_busy, core_done;
            mm_core #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(0), .MAXD(MAXD), .PIPE(PIPE_EFF), .MEM_REG(MEM_REG),
                      .HCLK_SEP(0), .PE_PRIM(PE_PRIM)) u_core (
                .clk(clk), .hclk(clk), .rst(rst),
                .wr_en(core_wr_en), .wr_sel(core_wr_sel), .wr_row(core_wr_row), .wr_col(core_wr_col), .wr_data(core_wr_data),
                .start(core_start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n),
                .busy(core_busy), .done(core_done),
                .rd_row(rd_row), .rd_col(rd_col), .rd_data(core_rd_data),
                .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total));
            assign busy_h = core_busy;
            assign done_h = core_done;
            assign wait_h = 1'b0;
            wire unused_cc = &{1'b0, core_clk, core_locked};
        end else begin : g_two_clocks
            // ---- core clock side
            // Reset: this side's reset, or the wizard not locked, into the core clock (2 flip-flops)
            (* ASYNC_REG = "TRUE" *) reg crst_s1, crst_s2;
            (* max_fanout = 64 *) reg c_rst;
            always @(posedge core_clk) begin
                crst_s1 <= rst | ~core_locked;
                crst_s2 <= crst_s1;
                c_rst   <= crst_s2;
            end
            // Start: a toggle from this side (start_tgl), seen after 2 flip-flops; a change is a start
            reg start_tgl = 1'b0;            // no reset: the core side follows it while in reset
            (* ASYNC_REG = "TRUE" *) reg cst_s1, cst_s2;
            reg cst_seen, c_start;
            always @(posedge core_clk) begin
                cst_s1   <= start_tgl;
                cst_s2   <= cst_s1;
                cst_seen <= cst_s2;
                c_start  <= (cst_s2 != cst_seen) && !c_rst;
            end
            // Done: a toggle on the core side, back the same way
            wire c_busy, c_done;
            reg  done_tgl = 1'b0;
            always @(posedge core_clk) if (c_done) done_tgl <= ~done_tgl;
            // "Core ready" (out of reset), back to this side
            reg c_ready;
            always @(posedge core_clk) c_ready <= !c_rst;

            mm_core #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(0), .MAXD(MAXD), .PIPE(PIPE_EFF), .MEM_REG(MEM_REG),
                      .HCLK_SEP(1), .PE_PRIM(PE_PRIM)) u_core (
                .clk(core_clk), .hclk(clk), .rst(c_rst),
                .wr_en(core_wr_en), .wr_sel(core_wr_sel), .wr_row(core_wr_row), .wr_col(core_wr_col), .wr_data(core_wr_data),
                .start(c_start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n),
                .busy(c_busy), .done(c_done),
                .rd_row(rd_row), .rd_col(rd_col), .rd_data(core_rd_data),
                .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total));
            wire unused_cb = c_busy;

            // ---- this side (s_axi_aclk)
            always @(posedge clk) if (core_start) start_tgl <= ~start_tgl;
            (* ASYNC_REG = "TRUE" *) reg hdn_s1, hdn_s2;
            (* ASYNC_REG = "TRUE" *) reg hrdy_s1, hrdy_s2;
            reg hdn_seen, busy_r;
            always @(posedge clk) begin
                hdn_s1   <= done_tgl;
                hdn_s2   <= hdn_s1;
                hdn_seen <= hdn_s2;
                hrdy_s1  <= c_ready;
                hrdy_s2  <= hrdy_s1;
                if (rst)                busy_r <= 1'b0;
                else if (core_start)    busy_r <= 1'b1;
                else if (done_h)        busy_r <= 1'b0;
            end
            assign done_h = (hdn_s2 != hdn_seen) && !rst;
            assign busy_h = busy_r;
            assign wait_h = !hrdy_s2;
        end
    endgenerate

    // ------------------------------------------------------------ byte loader
    // A LOAD_DATA write holds 4 bytes; they go into the core one per clock.
    reg  [31:0] ld_word;
    reg  [2:0]  ld_left;                 // bytes still to write from ld_word
    // Size of the matrix being loaded, kept in registers (they change only when DIMS or LOAD_PTR
    // is written, at least 2 cycles before the next LOAD_DATA write can start), so the compares
    // below start from flip-flops instead of from a mux on ld_sel.
    reg  [7:0]  ld_rows;                 // rows of the matrix being loaded
    reg  [7:0]  ld_rowlen;               // row length
    reg  [7:0]  ld_collast;              // row length - 1 (the last column)
    always @(posedge clk) begin
        ld_rows    <= ld_sel ? dim_k : dim_m;
        ld_rowlen  <= ld_sel ? dim_n : dim_k;
        ld_collast <= (ld_sel ? dim_n : dim_k) - 8'd1;
    end
    wire        ld_inside = (ld_row < ld_rows) && (ld_col < ld_rowlen);
    // One byte per clock into the core, through a register stage
    always @(posedge clk) begin
        if (rst) core_wr_en <= 1'b0;
        else     core_wr_en <= (ld_left != 3'd0) && ld_inside && !busy_h;
        core_wr_sel  <= ld_sel;
        core_wr_row  <= ld_row;
        core_wr_col  <= ld_col;
        core_wr_data <= ld_word[7:0];
    end

    // ------------------------------------------------------------ status bits
    reg done_flag, load_err;

    // ------------------------------------------------------------ AXI write channel
    reg axi_awready, axi_wready, axi_bvalid;
    assign s_axi_awready = axi_awready;
    assign s_axi_wready  = axi_wready;
    assign s_axi_bvalid  = axi_bvalid;
    assign s_axi_bresp   = 2'b00;        // always OKAY
    // A write happens in the cycle where both address and data are handed over. awready and
    // wready are raised only after awvalid and wvalid were seen, and AXI says a valid stays
    // up (with the address and data unchanged) until it is accepted, so that cycle is simply
    // the one where axi_awready is 1, and the address and data are the copies taken the
    // cycle before. Decoding from these registers keeps the ARM's slow AXI wires (they leave
    // the processor late and cross the chip) out of the decode logic.
    wire wr_fire = axi_awready;
    reg [5:0]  wr_addr_q;
    reg [31:0] wr_data_q;
    always @(posedge clk) begin
        wr_addr_q <= s_axi_awaddr;
        wr_data_q <= s_axi_wdata;
    end

    // ------------------------------------------------------------ AXI read channel
    reg        axi_arready, axi_rvalid;
    reg [31:0] axi_rdata;
    reg [5:0]  rd_addr;
    reg [1:0]  rd_wait;                  // clocks until the read data is ready
    assign s_axi_arready = axi_arready;
    assign s_axi_rvalid  = axi_rvalid;
    assign s_axi_rdata   = axi_rdata;
    assign s_axi_rresp   = 2'b00;
    wire ar_fire = axi_arready && s_axi_arvalid;
    wire r_fire  = axi_rvalid && s_axi_rready;
    // C read data, registered: the block-RAM output and the lane select get a cycle of their own.
    // Sign-extended from ACC to 32 bits: the sign bit copied 33 - ACC times, then the other bits
    // (no change when ACC = 32).
    reg [31:0] core_rd_q;
    always @(posedge clk) core_rd_q <= {{(33 - ACC){core_rd_data[ACC-1]}}, core_rd_data[ACC-2:0]};
    // RESULT_DATA stepping: N - 1, and "the current column is the last one", both registered.
    // dim_n changes only on a DIMS write and rd_col only on a RESULT_PTR write or a RESULT_DATA
    // read; each is at least 3 clocks before the next read captures its data (rd_wait = 1).
    reg [7:0] dim_n_m1;
    reg       rd_col_last;
    always @(posedge clk) begin
        dim_n_m1    <= dim_n - 8'd1;
        rd_col_last <= (rd_col == dim_n_m1);
    end

    always @(posedge clk) begin
        if (rst) begin
            axi_awready <= 1'b0; axi_wready <= 1'b0; axi_bvalid <= 1'b0;
            axi_arready <= 1'b0; axi_rvalid <= 1'b0; axi_rdata <= 32'd0;
            rd_addr <= 6'd0; rd_wait <= 2'd0;
            core_start <= 1'b0; dim_m <= 8'd0; dim_k <= 8'd0; dim_n <= 8'd0;
            ld_sel <= 1'b0; ld_row <= 8'd0; ld_col <= 8'd0; ld_word <= 32'd0; ld_left <= 3'd0;
            rd_row <= 8'd0; rd_col <= 8'd0;
            done_flag <= 1'b0; load_err <= 1'b0;
        end else begin
            core_start <= 1'b0;
            if (done_h) done_flag <= 1'b1;

            // ---- loader: one byte per clock, then step to the next position
            if (ld_left != 3'd0) begin
                ld_word <= {8'd0, ld_word[31:8]};
                ld_left <= ld_left - 3'd1;
                if (ld_inside) begin
                    if (ld_col == ld_collast) begin
                        ld_col <= 8'd0;
                        ld_row <= ld_row + 8'd1;
                    end else begin
                        ld_col <= ld_col + 8'd1;
                    end
                end
            end

            // ---- write channel: take address and data together, one write at a time.
            // A new write waits until the previous LOAD_DATA bytes are all written.
            if (!axi_awready && s_axi_awvalid && s_axi_wvalid && !axi_bvalid && ld_left == 3'd0) begin
                axi_awready <= 1'b1;
                axi_wready  <= 1'b1;
            end else begin
                axi_awready <= 1'b0;
                axi_wready  <= 1'b0;
            end
            if (wr_fire) begin
                axi_bvalid <= 1'b1;
                case (wr_addr_q)
                    A_CTRL: if (wr_data_q[0] && !busy_h && !wait_h) begin
                                core_start <= 1'b1;
                                done_flag  <= 1'b0;
                                load_err   <= 1'b0;
                            end
                    A_DIMS: if (!busy_h) begin
                                dim_m <= wr_data_q[7:0];
                                dim_k <= wr_data_q[15:8];
                                dim_n <= wr_data_q[23:16];
                            end
                    A_LOAD_PTR: begin
                                ld_sel <= wr_data_q[0];
                                ld_row <= wr_data_q[15:8];
                                ld_col <= wr_data_q[23:16];
                            end
                    A_LOAD_DATA: if (busy_h) load_err <= 1'b1;
                            else begin
                                ld_word <= wr_data_q;
                                ld_left <= 3'd4;
                            end
                    A_RES_PTR: begin
                                rd_row <= wr_data_q[7:0];
                                rd_col <= wr_data_q[15:8];
                            end
                    default: ;
                endcase
            end
            if (axi_bvalid && s_axi_bready) axi_bvalid <= 1'b0;

            // ---- read channel: wait three clocks so the core's memory read (1) and the
            //      registered read data (1) are ready
            if (!axi_arready && s_axi_arvalid && !axi_rvalid && rd_wait == 2'd0)
                axi_arready <= 1'b1;
            else
                axi_arready <= 1'b0;
            if (ar_fire) begin
                rd_addr <= s_axi_araddr;
                rd_wait <= 2'd3;
            end
            if (rd_wait != 2'd0) begin
                rd_wait <= rd_wait - 2'd1;
                if (rd_wait == 2'd1) begin
                    axi_rvalid <= 1'b1;
                    if (rd_addr == A_RES_DATA) begin       // move to the next C value
                        if (rd_col_last) begin
                            rd_col <= 8'd0;
                            rd_row <= rd_row + 8'd1;
                        end else begin
                            rd_col <= rd_col + 8'd1;
                        end
                    end
                    case (rd_addr)
                        A_STATUS:   axi_rdata <= {28'd0, wait_h, load_err, done_flag, busy_h};
                        A_DIMS:     axi_rdata <= {8'd0, dim_n, dim_k, dim_m};
                        A_LOAD_PTR: axi_rdata <= {8'd0, ld_col, ld_row, 7'd0, ld_sel};
                        A_RES_PTR:  axi_rdata <= {16'd0, rd_col, rd_row};
                        A_RES_DATA: axi_rdata <= core_rd_q;
                        A_PASSES:   axi_rdata <= perf_passes;
                        A_CYCLES:   axi_rdata <= perf_cycles;
                        A_TOTAL:    axi_rdata <= perf_total;
                        A_INFO:     axi_rdata <= INFO_WORD;
                        A_ID:       axi_rdata <= 32'h4D41_4331;
                        A_CONFIG:   axi_rdata <= CONFIG_WORD;
                        default:    axi_rdata <= 32'd0;
                    endcase
                end
            end
            if (r_fire) axi_rvalid <= 1'b0;
        end
    end

    // AXI signals this slave does not need
    wire unused = &{1'b0, s_axi_awprot, s_axi_arprot, s_axi_wstrb};
endmodule
