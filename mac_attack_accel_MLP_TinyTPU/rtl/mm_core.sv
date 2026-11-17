`timescale 1ns/1ps
// Matrix core: C = A x B on a P x P systolic array, for any M, K, N up to MAXD.
//
// Blocks inside:
//   * A, B, C buffers   on-chip memories for the matrices
//   * folding controller cuts B into P x P tiles and runs one pass per tile
//   * accumulators      add each pass's partial sums into C
//   * perf counters     passes, cycles in passes, total cycles
//
// Folding (GEMM tiling): B is cut into ceil(K/P) x ceil(N/P) tiles. One pass loads
// one tile into the array (P cycles), streams the M rows of the matching slice of A
// (M cycles), and the results drain out (2P - 2 cycles):
//
//     cycles per pass  T = M + 3P - 2
//     passes           Np = ceil(K/P) * ceil(N/P)
//     cycles in passes = Np * T                  (perf_cycles must equal this)
//
// Passes are ordered output block (nb) outer, reduction block (kb) inner. Pass kb = 0
// writes C, later passes add to it. The last output row of a pass appears in the
// first cycle of the next pass, so passes follow each other with no gap.
//
// Edge tiles: rows of B past K, columns past N, and columns of A past K are fed as
// zeros, so any M, K, N works without padding the matrices in memory.
//
// Timing (16 Oct 2026 rework, same cycle-by-cycle behaviour as before):
//   * The A and B buffers are written with one byte-enable per lane, so each buffer
//     maps to a single block RAM instead of being split into many.
//   * Memories have one cycle of read latency, so the read side runs one cycle ahead.
//     Instead of working out "next cycle" values with 32-bit arithmetic every cycle,
//     a second set of small counters (ro, rkb, rnb, ri) simply runs one cycle ahead
//     of the array. Read addresses are bit fields of those counters (for P and TM
//     powers of two), and the array's control signals are those counters' flags
//     delayed by one cycle.
//   * Limits (t - 1, kt - 1, nt - 1, M - 1) and the lane masks of the last tiles are
//     worked out once when a run starts, so nothing wide is compared every cycle.
//
// Pipelining (16 Oct 2026, second step). Neither option changes the cycles per pass, so
// perf_cycles still equals Np * (M + 3P - 2); each adds one cycle to perf_total only:
//   * PIPE = 1     two-stage PEs (multiply, then add): results leave the array 1 cycle later.
//   * MEM_REG = 1  block-RAM output register: A and B words arrive 2 cycles after their
//                  address, so the read-side counters run 2 cycles ahead of the array
//                  (one extra start-up cycle in S_PRIME).
//
// Timing, third step (16 Oct 2026, after the 142.857 MHz build). No change in cycle counts:
//   * The lane mask (zeros past K and N) is applied before the MEM_REG register, so the
//     array inputs come straight from flip-flops (no gate in front of the multipliers).
//   * The C read-modify-write is spread over more cycles: C is read one cycle earlier and
//     the word is registered (cq2), the 32-bit add is registered (wq), and the write
//     happens one cycle later. A C word is read again only in the next pass, at least
//     M + 3P - 5 cycles after it is written, so the late write is always in time.
//   * Data registers (memory outputs, array data) have no reset; only control does.
//
// Timing, fourth step (16 Oct 2026, toward 200 MHz):
//   * MEM_REG = 2 adds one more register on the A and B feed (and on the control flags), so a
//     long wire from the block RAMs to far DSPs is split in two. One more start-up cycle:
//     perf_total = perf_cycles + 3 + PIPE + MEM_REG.
//   * In the first pass of an output block the old C word is not added: cq2 is cleared by its
//     synchronous reset instead of a mux in front of the 32-bit adder.
//
// Timing, step 9 (17 Oct 2026, after the 200 MHz build). No change in cycle counts or results:
//   * The start-of-run limits (last-tile lane masks, tile counts, thr) are bit fields of
//     dim - 1 when P and TM are powers of two, instead of 32-bit int arithmetic and compares.
//     With D = dim - 1 (8-bit, so dim = 0 gives D = 255 exactly as before):
//         ceil(dim/P) - 1        = D >> log2(P)
//         lanes of the last tile = 0 .. (D mod P)       (lane j is inside if j <= D mod P)
//         thr = ceil(dim/P)*P - dim = P - 1 - (D mod P) = ~D[log2(P)-1:0]
//     Checked against the old formulas for every dim from 0 to 255.
//
// Accumulator width (step 10): every result is exact (never wraps) when
//     ACC >= 2*BITS + clog2(MAXD)
// because one product is at most (-2^(BITS-1))^2 = 2^(2*BITS-2) and a C value is a sum of at
// most MAXD products: |C| <= MAXD * 2^(2*BITS-2) <= 2^(ACC-2) < 2^(ACC-1) - 1.
// For INT8 and MAXD = 64 that is 22 bits. (Narrower widths are allowed on purpose, e.g. to
// show wrapping and saturation in tb_extras.) The host's read of one C lane is written as a
// P-to-1 mux of whole lanes, so it stays a plain mux when ACC is not a power of two.
//
// Step 10b (17 Oct 2026): w_load (the weight registers' enable in every PE) comes straight from
// a flip-flop. The weight-load flag is gated with r_active on the read side, where it is made,
// so it no longer needs "state == S_RUN" at the array side: the read side is active exactly in
// the cycles whose flags reach the array while the state is S_RUN (S_PRIME lasts 1 + MEM_REG
// cycles, the same as the flag delay). No change in any cycle.
//
// Step 12 (17 Oct 2026): hclk, the host's clock. The load port (wr_*) writes the A and B
// buffers on hclk, and the host reads C on hclk; everything else runs on clk. For one clock,
// connect hclk to clk (HCLK_SEP = 0: the design is the same as before). With HCLK_SEP = 1 the two
// clocks may be unrelated: A and B are dual-clock block RAMs (written on hclk, read on clk), and C
// gets a second copy (written on clk together with the working copy, read on hclk), because the
// working copy's two ports are both needed on clk. start, dim_*, busy, done and perf_* stay on
// clk; the wrapper (mac_axi) synchronizes start and done and only changes dim_* while idle.
//
// Step 13 (17 Oct 2026, after the 250 MHz build). Three shorter control and feed paths, no change
// in any cycle or result:
//   * Last-row flags: out_last = (out_row == M - 1) and pre_last = (pre_row == M - 1) are kept in
//     flip-flops, worked out one step ahead (row == M - 2), so S_LAST and the row wraps no longer
//     compare out_row with M - 1 in front of the state register and the counters' reset.
//   * idle_q = (state == S_IDLE) as its own flip-flop, so the read-side counters' clear does not
//     decode the 3-bit state register (which also drives about 50 other loads).
//   * MEM_REG = 2: the plain register comes right after the A and B block RAMs (so the tool can
//     use the block RAM's own output register: about 0.9 ns clock-to-out instead of 2.45 ns) and
//     the lane mask is applied in the second register (with the masks delayed one cycle to match).
//     Same two registers, same read latency.
//
// Step 14 (18 Oct 2026, for one clock at 250 MHz): HREAD_REG = 1 puts a register on the host's
// read of C between the C block RAM and the lane select. At 250 MHz the path block RAM ->
// lane select -> the wrapper's register failed by 0.263 ns (the block RAM has no output register
// here because its read port also feeds the accumulator). rd_data then appears 2 cycles after
// rd_row/rd_col instead of 1, so the wrapper waits one clock more per read. HREAD_REG = 0 (the
// default) is the design exactly as before, for every other user of this module.
//
// On-chip MLP (21 Oct 2026): three additions so that mlp_ctrl.sv can run a whole multilayer
// perceptron without the ARM between layers. With the defaults (NL = 1, AWR = 0) none of them is
// built and the design is exactly the step 14 design; the new inputs are then not used.
//   * NL weight slots: the B buffer holds NL matrices (one per layer), each in its own slot of
//     2^AW words (DEPTH when P or TM is not a power of two). The host writes slot wr_layer; a run
//     uses slot run_layer, taken at start like the sizes. With powers of two the slot number is
//     just the top bits of the address ({layer, kb, k, nb}), so there is still no adder in front of
//     the block RAM.
//   * AWR = 1: a word write port into A (aw_*), on hclk like the load port. It writes a whole A word
//     (i, blk), all P lanes at once: mlp_ctrl uses it to put a layer's outputs back into A as the
//     next layer's inputs. It shares the block RAM's write port with the load port (the load port is
//     never used while mlp_ctrl writes) and wins if both are used in the same clock.
//   * rd_word: the whole C word (row rd_row, columns rd_col - rd_col mod P ...) that the host read
//     port fetched, before the lane select. Same timing as rd_data. Always there (just wires).
//   * AWR = 1 also adds wb_rd / wb_row / wb_blk: while idle with wb_rd = 1, the C read port fetches
//     word (wb_row, wb_blk) instead of the host's (rd_row, rd_col), straight from bit fields: no adder
//     and only one more input on the existing address mux, so the C read address path is no longer
//     than in step 14. mlp_ctrl's writeback reads C this way (on rd_word, same timing).
//
// Step 16 (Nov 2026, for the ASIC): SRAM = 1 builds the A, B and C buffers from SKY130 SRAM macros
// (sram_buf.sv) instead of inferred memories. OpenLane has no RAM to infer, so with SRAM = 0 every
// buffer bit became a flip-flop with a write mux and a read mux tree (268k flip-flops at MAXD = 64).
// The macros read like the block RAMs (data one clock after the address), so no cycle changes.
// SRAM = 0 (the default) is the design exactly as before, for the FPGA.
module mm_core #(
    parameter int P       = 16,  // array size
    parameter int BITS    = 8,   // operand width
    parameter int ACC     = 32,  // accumulator width (exact when ACC >= 2*BITS + clog2(MAXD))
    parameter int SAT     = 0,   // 1 = saturating accumulators (PEs and C)
    parameter int MAXD    = 64,  // largest M, K or N (at most 255)
    parameter int PIPE    = 1,   // PE pipeline: 0, 1 or 2 (see pe.sv); needs PIPE <= P
    parameter int MEM_REG = 1,   // registers after the A and B block-RAM reads: 0, 1 or 2
    parameter int HCLK_SEP = 0,  // 1 = hclk is a separate clock (step 12); 0 = hclk is clk
    parameter int PE_PRIM  = 0,  // 1 = PEs as DSP48E1 primitives (zed/pe_dsp48.sv, FPGA only; PIPE must be 2)
    parameter int HREAD_REG = 0, // 1 = one more register on the host's C read (rd_data 2 cycles later)
    parameter int NL       = 1,  // weight slots in the B buffer (layers of a model); 1 = one matrix, as before
    parameter int AWR      = 0,  // 1 = word write port into A (aw_*), for mlp_ctrl's writeback; needs HCLK_SEP = 0
    parameter int SRAM     = 0   // 1 = A, B and C are SKY130 SRAM macros (sram_buf.sv), for the ASIC (step 16)
)(
    input  logic             clk,          // core clock
    input  logic             hclk,         // host clock: load port and C read port (connect to clk for one clock)
    input  logic             rst,          // synchronous to clk
    // load port: one element per cycle
    input  logic             wr_en,
    input  logic             wr_sel,       // 0 = A[row][col] (M x K), 1 = B[row][col] (K x N)
    input  logic [7:0]       wr_row,
    input  logic [7:0]       wr_col,
    input  logic [BITS-1:0]  wr_data,
    input  logic [((NL > 1) ? $clog2(NL) : 1)-1:0] wr_layer,   // weight slot written (B only; NL > 1)
    // word write into A (AWR = 1): A word (aw_row, aw_blk) = aw_data, lane j = A[aw_row][aw_blk*P + j]
    input  logic             aw_en,
    input  logic [7:0]       aw_row,
    input  logic [7:0]       aw_blk,
    input  logic [P*BITS-1:0] aw_data,
    // word read of C for the writeback (AWR = 1): while idle, wb_rd = 1 reads C word (wb_row, wb_blk)
    input  logic             wb_rd,
    input  logic [7:0]       wb_row,
    input  logic [7:0]       wb_blk,
    // run
    input  logic             start,        // one-cycle pulse while idle
    input  logic [7:0]       dim_m,        // 1 .. MAXD
    input  logic [7:0]       dim_k,
    input  logic [7:0]       dim_n,
    input  logic [((NL > 1) ? $clog2(NL) : 1)-1:0] run_layer,  // weight slot this run uses (taken at start; NL > 1)
    output logic             busy,
    output logic             done,         // one-cycle pulse when C is complete
    // result read port: C[rd_row][rd_col] appears on rd_data 1 + HREAD_REG cycles later (while idle)
    input  logic [7:0]       rd_row,
    input  logic [7:0]       rd_col,
    output logic [ACC-1:0]   rd_data,
    output logic [P*ACC-1:0] rd_word,      // the whole C word that rd_data's lane comes from (same timing)
    // performance counters, valid after done
    output logic [31:0]      perf_passes,
    output logic [31:0]      perf_cycles,
    output logic [31:0]      perf_total
);
    localparam int TM = (MAXD + P - 1) / P;   // most tiles along one dimension
    localparam int DEPTH = MAXD * TM;         // words per buffer

    // Bit widths of the small counters (instead of 32-bit ints)
    localparam int LP = (P > 1) ? $clog2(P) : 1;            // a row inside a tile: 0 .. P-1
    localparam int OW = $clog2(MAXD + 3 * P);               // cycle inside a pass: 0 .. M+3P-3
    localparam int KW = (TM > 1) ? $clog2(TM) : 1;          // a tile index: 0 .. TM-1
    localparam int MW = (MAXD > 1) ? $clog2(MAXD) : 1;      // a row of A: 0 .. MAXD-1
    localparam int AW = (DEPTH > 1) ? $clog2(DEPTH) : 1;    // buffer address
    // With P and TM powers of two, read addresses are plain bit fields (no adders)
    localparam bit POW2 = (P == (1 << LP)) && (TM == (1 << KW));

    // ---------------------------------------------------------------- buffers
    // A word (i, kb) holds A[i][kb*P .. kb*P+P-1]; B word (k, nb) holds B[k][nb*P ..];
    // C word (i, nb) holds C[i][nb*P ..]. Element j of a word sits in lane j.
    // B holds NL weight slots (NL = 1: one matrix, exactly as before).
    localparam int LW     = (NL > 1) ? $clog2(NL) : 1;                // slot number width
    localparam int BSLOT  = (NL > 1 && POW2) ? (1 << AW) : DEPTH;     // words per slot
    localparam int BDEPTH = NL * BSLOT;
    localparam int BAW    = (BDEPTH > 1) ? $clog2(BDEPTH) : 1;        // B address width
    (* ram_style = "block" *) logic [P*BITS-1:0] amem [DEPTH];
    (* ram_style = "block" *) logic [P*BITS-1:0] bmem [BDEPTH];
    logic [P*ACC-1:0]  cmem [DEPTH];

    /* verilator lint_off UNUSEDSIGNAL */   // addresses are 32-bit ints; only the low bits index memory
    logic [31:0] wr_addr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [7:0]  wr_lane;
    assign wr_addr = 32'(wr_row) * TM + 32'(wr_col) / P;
    assign wr_lane = 8'(32'(wr_col) % P);

    // SRAM = 1: the write side of A and B (address, data, lane enables), for the macros
    /* verilator lint_off UNUSEDSIGNAL */
    /* verilator lint_off UNDRIVEN */
    logic [AW-1:0]     sa_waddr;
    logic [P*BITS-1:0] sa_wdata;
    logic [P-1:0]      sa_we;
    logic [BAW-1:0]    sb_waddr;
    logic [P-1:0]      sb_we;
    /* verilator lint_on UNDRIVEN */
    /* verilator lint_on UNUSEDSIGNAL */

    // Byte-write-enable style: lane j is a fixed slice, picked by a write enable.
    // (Writing a variable slice made the synthesis tool split each buffer into many
    // block RAMs, which put a long, high-fanout wire on the read address.)
    logic [P*BITS-1:0] wr_word;
    assign wr_word = {P{wr_data}};

    generate
        if (AWR != 0) begin : g_awr
            // A: the load port's byte, or a whole word from the word write port (mlp_ctrl's writeback).
            // One write port: address and data are picked, and each lane has its own write enable.
            logic [AW-1:0] aw_addr;
            if (POW2) begin : g_awa_bits
                assign aw_addr = AW'({aw_row[MW-1:0], aw_blk[KW-1:0]});
                wire unused_awhi = &{1'b0, aw_row, aw_blk};   // the top bits are 0 for any real size
            end else begin : g_awa_math
                assign aw_addr = AW'(int'(aw_row) * TM + int'(aw_blk));
            end
            logic [AW-1:0]     a_waddr;
            logic [P*BITS-1:0] a_wdata;
            logic [P-1:0]      a_we;
            assign a_waddr = aw_en ? aw_addr : AW'(wr_addr);
            assign a_wdata = aw_en ? aw_data : wr_word;
            for (genvar j = 0; j < P; j++) begin : g_awe
                assign a_we[j] = aw_en || (wr_en && !wr_sel && wr_lane == 8'(j));
            end
            if (SRAM != 0) begin : g_asram
                assign sa_waddr = a_waddr;
                assign sa_wdata = a_wdata;
                assign sa_we    = a_we;
            end else begin : g_aram
                always_ff @(posedge hclk) begin   // the block RAM byte-write template: one address, one enable per lane
                    for (int j = 0; j < P; j++)
                        if (a_we[j]) amem[a_waddr][j*BITS +: BITS] <= a_wdata[j*BITS +: BITS];
                end
            end
        end else begin : g_aw0
            if (SRAM != 0) begin : g_asram
                assign sa_waddr = AW'(wr_addr);
                assign sa_wdata = wr_word;
                for (genvar j = 0; j < P; j++) begin : g_awe
                    assign sa_we[j] = wr_en && !wr_sel && wr_lane == 8'(j);
                end
            end else begin : g_aram
                always_ff @(posedge hclk) begin   // load port: host clock
                    if (wr_en && !wr_sel)
                        for (int j = 0; j < P; j++)
                            if (wr_lane == 8'(j)) amem[wr_addr][j*BITS +: BITS] <= wr_word[j*BITS +: BITS];
                end
            end
        end

        if (NL > 1) begin : g_bslots
            // B: the slot number goes on top of the address (powers of two) or adds slot * DEPTH
            logic [BAW-1:0] wr_baddr;
            if (POW2) begin : g_bwa_bits
                assign wr_baddr = BAW'({wr_layer, AW'(wr_addr)});
            end else begin : g_bwa_math
                assign wr_baddr = BAW'(int'(wr_layer) * DEPTH + int'(wr_addr));
            end
            if (SRAM != 0) begin : g_bsram
                assign sb_waddr = wr_baddr;
            end else begin : g_bram
                always_ff @(posedge hclk) begin
                    if (wr_en && wr_sel)
                        for (int j = 0; j < P; j++)
                            if (wr_lane == 8'(j)) bmem[wr_baddr][j*BITS +: BITS] <= wr_word[j*BITS +: BITS];
                end
            end
        end else begin : g_bslot1
            if (SRAM != 0) begin : g_bsram
                assign sb_waddr = BAW'(wr_addr);
            end else begin : g_bram
                always_ff @(posedge hclk) begin
                    if (wr_en && wr_sel)
                        for (int j = 0; j < P; j++)
                            if (wr_lane == 8'(j)) bmem[wr_addr][j*BITS +: BITS] <= wr_word[j*BITS +: BITS];
                end
            end
        end
        for (genvar j = 0; j < P; j++) begin : g_sbwe     // B's lane enables (used with SRAM = 1)
            assign sb_we[j] = (SRAM != 0) && wr_en && wr_sel && wr_lane == 8'(j);
        end
    endgenerate

    // ---------------------------------------------------------------- controller
    typedef enum logic [2:0] {S_IDLE, S_PRIME, S_RUN, S_LAST, S_DONE} state_t;
    state_t state;
    logic [1:0] prime_left;                   // S_PRIME lasts 1 + MEM_REG cycles (the read latency)
    logic       idle_q;                       // state == S_IDLE, as its own flip-flop (step 13)

    // Limits, worked out once when a run starts
    logic [OW-1:0] tm1;                       // t - 1, where t = M + 3P - 2 cycles per pass
    logic [MW-1:0] m_m1;                      // M - 1
    logic [KW-1:0] kt_m1, nt_m1;              // ceil(K/P) - 1, ceil(N/P) - 1
    logic [LP-1:0] thr;                       // in the last K tile, weight-load cycles o >= thr carry real rows of B
    logic [P-1:0]  amask_last;                // lanes of A inside K, in the last K tile
    logic [P-1:0]  nmask_last;                // lanes of B inside N, in the last N tile

    int ktv, ntv;                             // tile counts from the inputs (used only at start, any P)
    assign ktv = (int'(dim_k) + P - 1) / P;
    assign ntv = (int'(dim_n) + P - 1) / P;
    logic [7:0] k_m1, n_m1;                   // K - 1 and N - 1 (8 bits), for the powers-of-two case
    assign k_m1 = dim_k - 8'd1;
    assign n_m1 = dim_n - 8'd1;

    // Read side: counters that run one cycle AHEAD of the array, so that the buffers
    // (one cycle of read latency) deliver each word exactly when the array needs it.
    //   ro  cycle inside the pass       rkb  reduction block (tile row)
    //   rnb output block (tile column)  ri   row of A while A is streamed
    //   rw  "loading weights" (ro < P)   ra   "streaming A" (P <= ro < P + M)
    logic [OW-1:0] ro;
    logic [KW-1:0] rkb, rnb;
    logic [MW-1:0] ri;
    logic          rw, ra, rfirst, r_active;

    logic r_wrap, rkb_last, rnb_last, r_final;
    assign r_wrap   = (ro == tm1);            // last cycle of a pass
    assign rkb_last = (rkb == kt_m1);
    assign rnb_last = (rnb == nt_m1);
    assign r_final  = r_wrap && rkb_last && rnb_last;   // last cycle of the last pass

    always_ff @(posedge clk) begin
        if (rst) begin
            ro <= '0; rkb <= '0; rnb <= '0; ri <= '0;
            rw <= 1'b1; ra <= 1'b0; rfirst <= 1'b1; r_active <= 1'b0;
        end else if (idle_q) begin
            ro <= '0; rkb <= '0; rnb <= '0; ri <= '0;
            rw <= 1'b1; ra <= 1'b0; rfirst <= 1'b1;
            r_active <= start;                // starts with the run (S_PRIME reads pass 0, cycle 0)
        end else if (r_active) begin
            if (r_wrap) begin                 // next pass (or stop after the last one)
                ro <= '0; ri <= '0; rw <= 1'b1; ra <= 1'b0; rfirst <= 1'b1;
                if (r_final)       begin rkb <= '0; rnb <= '0; r_active <= 1'b0; end
                else if (rkb_last) begin rkb <= '0; rnb <= rnb + 1'b1; end
                else                     rkb <= rkb + 1'b1;
            end else begin
                ro     <= ro + 1'b1;
                rfirst <= 1'b0;
                rw     <= rw && (ro != OW'(P - 1));
                ra     <= (rw && ro == OW'(P - 1)) || (ra && ri != m_m1);
                ri     <= (ra && ri != m_m1) ? ri + 1'b1 : '0;
            end
        end
    end

    // Read addresses and lane masks, straight from the read-side counters
    logic [LP-1:0] k_low;                     // row of B inside the tile: P-1-o while loading weights
    assign k_low = LP'(P - 1) - ro[LP-1:0];

    logic [AW-1:0]  a_addr, b_addr1;          // b_addr1: the address inside a weight slot
    logic [BAW-1:0] b_addr;
    generate
        if (POW2) begin : g_addr_bits         // B word (kb*P + P-1-o, nb), A word (i, kb) as bit fields
            assign b_addr1 = rw ? AW'({rkb, k_low, rnb}) : '0;
            assign a_addr  = ra ? AW'({ri, rkb}) : '0;
        end else begin : g_addr_math          // any P: small multiply-adds
            assign b_addr1 = rw ? AW'((int'(rkb) * P + int'(k_low)) * TM + int'(rnb)) : '0;
            assign a_addr  = ra ? AW'(int'(ri) * TM + int'(rkb)) : '0;
        end
        if (NL > 1) begin : g_bslot_rd
            // The run's weight slot, taken at start like the sizes (a flip-flop, constant during a run)
            logic [LW-1:0] layer_q;
            always_ff @(posedge clk) if (idle_q && start) layer_q <= run_layer;
            if (POW2) begin : g_bra_bits
                assign b_addr = rw ? BAW'({layer_q, b_addr1}) : '0;
            end else begin : g_bra_math
                assign b_addr = rw ? BAW'(int'(layer_q) * DEPTH + int'(b_addr1)) : '0;
            end
        end else begin : g_bslot1_rd
            assign b_addr = b_addr1;
            wire unused_layer = &{1'b0, run_layer, wr_layer};
        end
        if (AWR == 0) begin : g_aw0_unused
            wire unused_aw = &{1'b0, aw_en, aw_row, aw_blk, aw_data};
        end
    endgenerate

    logic [P-1:0] a_lanes, b_lanes;
    assign a_lanes = rkb_last ? amask_last : '1;
    assign b_lanes = (rw && (!rkb_last || ro[LP-1:0] >= thr)) ? (rnb_last ? nmask_last : '1) : '0;

    // Block-RAM read (aq1, bq1). With MEM_REG = 1 a second register follows, and the lane
    // mask is applied in front of it, so the array's inputs come straight from flip-flops.
    // MEM_REG = 2: a plain register right after the block RAM (the tool can put it inside the
    // block RAM as its output register), then the masked register that feeds the array (step 13).
    // (Without MEM_REG the mask sits between the block RAM and the array.)
    logic [P*BITS-1:0] aq1, bq1;
    logic [P-1:0]      a_lanes_q1, b_lanes_q1;
    logic [P*BITS-1:0] w_row, a_row;          // inputs of the array
    generate
        if (SRAM != 0) begin : g_absram
            // the macros' read is the same register: aq1 / bq1 = the word at a_addr / b_addr one clock later
            sram_buf #(.W(P*BITS), .D(DEPTH), .NWE(P)) u_amem (
                .wclk(hclk), .we(sa_we), .waddr(sa_waddr), .wdata(sa_wdata),
                .rclk(clk), .raddr(a_addr), .rdata(aq1));
            sram_buf #(.W(P*BITS), .D(BDEPTH), .NWE(P)) u_bmem (
                .wclk(hclk), .we(sb_we), .waddr(sb_waddr), .wdata(wr_word),
                .rclk(clk), .raddr(b_addr), .rdata(bq1));
        end else begin : g_abram
            always_ff @(posedge clk) begin
                aq1 <= amem[a_addr];
                bq1 <= bmem[b_addr];
            end
        end
    endgenerate
    always_ff @(posedge clk) begin
        a_lanes_q1 <= a_lanes;
        b_lanes_q1 <= b_lanes;
    end
    generate
        if (MEM_REG >= 2) begin : g_memreg2
            logic [P*BITS-1:0] aqr, bqr;          // plain: the block RAM's output register
            logic [P-1:0]      a_lanes_q2, b_lanes_q2;
            logic [P*BITS-1:0] aq, bq;            // masked: feeds the array
            always_ff @(posedge clk) begin
                aqr <= aq1;
                bqr <= bq1;
                a_lanes_q2 <= a_lanes_q1;
                b_lanes_q2 <= b_lanes_q1;
            end
            always_ff @(posedge clk) begin
                for (int j = 0; j < P; j++) begin
                    aq[j*BITS +: BITS] <= a_lanes_q2[j] ? aqr[j*BITS +: BITS] : '0;
                    bq[j*BITS +: BITS] <= b_lanes_q2[j] ? bqr[j*BITS +: BITS] : '0;
                end
            end
            assign a_row = aq;
            assign w_row = bq;
        end else if (MEM_REG == 1) begin : g_memreg
            logic [P*BITS-1:0] aq, bq;
            always_ff @(posedge clk) begin
                for (int j = 0; j < P; j++) begin
                    aq[j*BITS +: BITS] <= a_lanes_q1[j] ? aq1[j*BITS +: BITS] : '0;
                    bq[j*BITS +: BITS] <= b_lanes_q1[j] ? bq1[j*BITS +: BITS] : '0;
                end
            end
            assign a_row = aq;
            assign w_row = bq;
        end else begin : g_nomemreg
            always_comb begin
                for (int j = 0; j < P; j++) begin
                    w_row[j*BITS +: BITS] = b_lanes_q1[j] ? bq1[j*BITS +: BITS] : '0;
                    a_row[j*BITS +: BITS] = a_lanes_q1[j] ? aq1[j*BITS +: BITS] : '0;
                end
            end
        end
    endgenerate

    // Array side: the read-side flags, 1 + MEM_REG cycles later (the same delay as the data)
    logic          a_phase1, pass_first1, a_first1, fin1;
    logic [KW-1:0] kb1, nb1;
    logic [OW-1:0] o1;
    always_ff @(posedge clk) begin
        if (rst) begin
            a_phase1 <= 1'b0; pass_first1 <= 1'b0; a_first1 <= 1'b0; fin1 <= 1'b0;
            kb1 <= '0; nb1 <= '0; o1 <= '0;
        end else begin
            o1          <= ro;
            a_phase1    <= ra;
            pass_first1 <= rfirst;
            a_first1    <= ra && (ri == '0);
            fin1        <= r_active && r_final;
            kb1         <= rkb;
            nb1         <= rnb;
        end
    end

    logic          a_phase;                   // streaming A, for the array
    logic          pass_first;                // first cycle of a pass
    logic          a_first;                   // first row of A of a pass
    logic          fin;                       // last cycle of the last pass
    logic [KW-1:0] kb, nb;                    // pass the array is working on
    /* verilator lint_off UNUSEDSIGNAL */
    logic [OW-1:0] o;                         // cycle inside the pass, for waveforms only (tb_selfcheck shows it)
    /* verilator lint_on UNUSEDSIGNAL */
    localparam int FW = OW + 2 * KW + 4;      // all the flags as one vector
    generate
        if (MEM_REG != 0) begin : g_arr2
            logic [FW-1:0] flags1, flags;
            assign flags1 = {o1, kb1, nb1, a_phase1, pass_first1, a_first1, fin1};
            delay_line #(.WIDTH(FW), .DEPTH(MEM_REG), .RESET(1)) u_flags (
                .clk(clk), .rst(rst), .d(flags1), .q(flags));
            assign {o, kb, nb, a_phase, pass_first, a_first, fin} = flags;
        end else begin : g_arr1
            assign o = o1;  assign a_phase = a_phase1;
            assign pass_first = pass_first1;  assign a_first = a_first1;  assign fin = fin1;
            assign kb = kb1;  assign nb = nb1;
        end
    endgenerate

    // ---------------------------------------------------------------- the array
    logic              w_load, in_valid, out_valid;
    logic [P*ACC-1:0]  c_row;

    // Weight-load enable (step 10b). Made on the read side as rw && r_active, then delayed
    // 1 + MEM_REG clocks like the other flags, so it is high in exactly the cycles where
    // (state == S_RUN) && (weight-load flag) used to be. Its own chain of flip-flops, ending in a
    // register the tool may copy (max_fanout), because it drives the weight register of every PE.
    logic wl_d;
    generate
        if (MEM_REG == 0) begin : g_wl0
            assign wl_d = rw && r_active;
        end else begin : g_wl
            delay_line #(.WIDTH(1), .DEPTH(MEM_REG), .RESET(1)) u_wl (
                .clk(clk), .rst(rst), .d(rw && r_active), .q(wl_d));
        end
    endgenerate
    (* max_fanout = 16 *)
    logic w_load_q;
    always_ff @(posedge clk) begin
        if (rst) w_load_q <= 1'b0;
        else     w_load_q <= wl_d;
    end
    assign w_load   = w_load_q;
    assign in_valid = (state == S_RUN) && a_phase;

    systolic_array #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT), .PIPE(PIPE), .PE_PRIM(PE_PRIM)) u_array (
        .clk(clk), .rst(rst), .w_load(w_load), .w_row(w_row),
        .in_valid(in_valid), .a_row(a_row), .out_valid(out_valid), .c_row(c_row));

    // ---------------------------------------------------------------- accumulators
    // Read-modify-write of C, spread out so that no path holds a block-RAM read and a
    // 32-bit add together. For an output row that leaves the array in cycle t:
    //   t-2  the C read address goes out ("out_next2")
    //   t-1  the block RAM delivers the word; it is registered (cq2)
    //   t    out_valid: c_new = cq2 + c_row (or just c_row in the first pass); registered (wq)
    //   t+1  wq is written to C
    // The same C word is read again only in the next pass, M + 3P - 2 cycles later.
    logic out_next2;
    delay_line #(.WIDTH(1), .DEPTH(2 * P - 3 + PIPE), .RESET(1)) u_next (
        .clk(clk), .rst(rst), .d(in_valid), .q(out_next2));

    (* max_fanout = 32 *)                     // drives the clear of every cq2 bit: let the tool copy it
    logic          cap_first;                 // the draining pass is the first of its output block (kb = 0)
    logic [KW-1:0] cap_nb;                    // output block of the draining pass
    logic [MW-1:0] pre_row, out_row;          // row being read / leaving the array
    logic          pre_last, out_last;        // pre_row == M - 1, out_row == M - 1, kept in flip-flops
    logic [MW-1:0] m_m2;                      // M - 2: the row before the last
    logic          m_one;                     // M = 1 (M - 1 = 0)

    // C word (row, nb): bit fields for powers of two, small multiply-add otherwise
    function automatic logic [AW-1:0] c_addr(input logic [MW-1:0] row, input logic [KW-1:0] blk);
        if (POW2) c_addr = AW'({row, blk});
        else      c_addr = AW'(int'(row) * TM + int'(blk));
    endfunction

    /* verilator lint_off UNUSEDSIGNAL */   // host read address is a 32-bit int; only the low bits index memory
    int host_raddr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [AW-1:0] c_raddr;
    logic [LP-1:0] rd_lane;                   // lane of the C word the host reads (rd_col mod P)
    logic [P*ACC-1:0] cq1, cq2;
    logic [P*ACC-1:0] hq1;                    // the C word the host reads

    assign host_raddr = int'(rd_row) * TM + int'(rd_col) / P;

    generate
        if (SRAM == 0) begin : g_cread        // (with SRAM = 1, cq1 is the macros' read, below)
            always_ff @(posedge clk) cq1 <= cmem[c_raddr];   // block-RAM read (with HCLK_SEP = 0 the host reads this one too)
        end
    endgenerate
    always_ff @(posedge clk) begin
        // Registered copy for the accumulator. In the first pass of an output block the old word
        // must not be added, so it is cleared here (a synchronous reset on these flip-flops)
        // instead of through a mux in front of the adder.
        if (cap_first) cq2 <= '0;
        else           cq2 <= cq1;
    end

    localparam logic signed [ACC:0] MAXV = {2'b00, {(ACC-1){1'b1}}};
    localparam logic signed [ACC:0] MINV = {2'b11, {(ACC-1){1'b0}}};

    function automatic logic [ACC-1:0] acc_add(input logic [ACC-1:0] x, input logic [ACC-1:0] y);
        logic signed [ACC:0] s;
        s = $signed({x[ACC-1], x}) + $signed({y[ACC-1], y});
        if (SAT != 0 && s > MAXV)      acc_add = MAXV[ACC-1:0];
        else if (SAT != 0 && s < MINV) acc_add = MINV[ACC-1:0];
        else                           acc_add = s[ACC-1:0];
    endfunction

    logic [P*ACC-1:0] c_new;
    for (genvar j = 0; j < P; j++) begin : g_acc
        assign c_new[j*ACC +: ACC] = acc_add(cq2[j*ACC +: ACC], c_row[j*ACC +: ACC]);
    end

    // Write one cycle later, from registers
    logic             wq_en;
    logic [AW-1:0]    wq_addr;
    logic [P*ACC-1:0] wq;
    always_ff @(posedge clk) begin
        wq      <= c_new;
        wq_addr <= c_addr(out_row, cap_nb);
        if (rst) wq_en <= 1'b0;
        else     wq_en <= out_valid;
    end
    generate
        if (SRAM != 0) begin : g_csram
            sram_buf #(.W(P*ACC), .D(DEPTH), .NWE(1)) u_cmem (
                .wclk(clk), .we(wq_en), .waddr(wq_addr), .wdata(wq),
                .rclk(clk), .raddr(c_raddr), .rdata(cq1));
        end else begin : g_cram
            always_ff @(posedge clk) begin
                if (wq_en) cmem[wq_addr] <= wq;
            end
        end
    endgenerate

    // Host read of C (1 cycle on hclk), and which read port it uses
    generate
        if (HCLK_SEP == 0) begin : g_hread1
            // One clock: while idle the host (or mlp_ctrl's writeback, AWR = 1) uses the working copy's read port
            if (AWR != 0) begin : g_wbrd
                assign c_raddr = busy ? (out_next2 ? c_addr(pre_row, cap_nb) : '0) :
                                 (wb_rd ? c_addr(wb_row[MW-1:0], wb_blk[KW-1:0]) : AW'(host_raddr));
                wire unused_wbhi = &{1'b0, wb_row, wb_blk};   // the top bits are 0 for any real size
            end else begin : g_hostrd
                assign c_raddr = busy ? (out_next2 ? c_addr(pre_row, cap_nb) : '0) : AW'(host_raddr);
                wire unused_wb = &{1'b0, wb_rd, wb_row, wb_blk};
            end
            assign hq1 = cq1;
            always_ff @(posedge clk) rd_lane <= LP'(32'(rd_col) % P);
        end else begin : g_hread2
            // Two clocks: the host reads a copy of C that is written together with the working
            // copy (same address, same data, same cycle) and read on hclk.
            assign c_raddr = busy ? (out_next2 ? c_addr(pre_row, cap_nb) : '0) : '0;
            wire unused_wb = &{1'b0, wb_rd, wb_row, wb_blk};      // the writeback needs one clock
            (* ram_style = "block" *) logic [P*ACC-1:0] cres [DEPTH];
            logic [P*ACC-1:0] hq;
            logic [AW-1:0]    h_raddr;           // unsigned (a cast of the int would stay signed)
            assign h_raddr = AW'(host_raddr);
            always_ff @(posedge clk) begin
                if (wq_en) cres[wq_addr] <= wq;
            end
            always_ff @(posedge hclk) begin
                hq      <= cres[h_raddr];
                rd_lane <= LP'(32'(rd_col) % P);
            end
            assign hq1 = hq;
        end
    endgenerate
    // Step 14: with HREAD_REG = 1 the C word and its lane number are registered once more (on
    // hclk) before the lane select, so the select starts from flip-flops instead of from the
    // block RAM's output.
    logic [P*ACC-1:0] hq_sel;                 // the C word the lane select uses
    logic [LP-1:0]    rd_lane_sel;            // and its lane
    generate
        if (HREAD_REG != 0) begin : g_hreadreg
            always_ff @(posedge hclk) begin
                hq_sel      <= hq1;
                rd_lane_sel <= rd_lane;
            end
        end else begin : g_hreaddirect
            assign hq_sel      = hq1;
            assign rd_lane_sel = rd_lane;
        end
    endgenerate
    // Host read: pick lane rd_lane_sel of the C word. Written as a P-to-1 mux of whole lanes, so it
    // stays a plain mux when ACC is not a power of two (a part-select at rd_lane * ACC becomes
    // a general shifter when ACC = 22).
    logic [ACC-1:0] hq1_lane [P];
    for (genvar j = 0; j < P; j++) begin : g_rdlane
        assign hq1_lane[j] = hq_sel[j*ACC +: ACC];
    end
    assign rd_data = hq1_lane[rd_lane_sel];
    assign rd_word = hq_sel;                  // the whole word, for mlp_ctrl's writeback

    // ---------------------------------------------------------------- sequencer
    // idle_q follows the state register: it is 1 exactly when state == S_IDLE (the same next-state
    // rules as the case below: S_IDLE stays unless start, S_DONE and any other code go to S_IDLE).
    always_ff @(posedge clk) begin
        if (rst) idle_q <= 1'b1;
        else case (state)
            S_IDLE:                 idle_q <= !start;
            S_PRIME, S_RUN, S_LAST: idle_q <= 1'b0;
            default:                idle_q <= 1'b1;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; busy <= 1'b0; done <= 1'b0; prime_left <= '0;
            tm1 <= '0; m_m1 <= '0; kt_m1 <= '0; nt_m1 <= '0;
            thr <= LP'(P - 1); amask_last <= P'(1); nmask_last <= P'(1);   // as for K = N = 1
            cap_first <= 1'b1; cap_nb <= '0; pre_row <= '0; out_row <= '0;
            m_m2 <= '1; m_one <= 1'b1; pre_last <= 1'b1; out_last <= 1'b1;   // as for M = 1
            perf_passes <= '0; perf_cycles <= '0; perf_total <= '0;
        end else begin
            done <= 1'b0;
            if (busy) perf_total <= perf_total + 32'd1;

            case (state)
                S_IDLE: if (start) begin
                    tm1   <= OW'(int'(dim_m) + 3 * P - 3);
                    m_m1  <= MW'(int'(dim_m) - 1);
                    m_m2  <= MW'(int'(dim_m) - 2);
                    m_one <= (MW'(int'(dim_m) - 1) == '0);
                    if (POW2) begin               // bit fields of K - 1 and N - 1 (see the header)
                        kt_m1 <= KW'(k_m1 >> LP);
                        nt_m1 <= KW'(n_m1 >> LP);
                        thr   <= ~k_m1[LP-1:0];
                        for (int j = 0; j < P; j++) begin
                            amask_last[j] <= (LP'(j) <= k_m1[LP-1:0]);
                            nmask_last[j] <= (LP'(j) <= n_m1[LP-1:0]);
                        end
                    end else begin                // any P: the general formulas
                        kt_m1 <= KW'(ktv - 1);
                        nt_m1 <= KW'(ntv - 1);
                        thr   <= LP'(ktv * P - int'(dim_k));
                        for (int j = 0; j < P; j++) begin
                            amask_last[j] <= ((ktv - 1) * P + j < int'(dim_k));
                            nmask_last[j] <= ((ntv - 1) * P + j < int'(dim_n));
                        end
                    end
                    busy <= 1'b1; state <= S_PRIME; prime_left <= 2'(MEM_REG);
                    pre_row <= '0; out_row <= '0;
                    pre_last <= (MW'(int'(dim_m) - 1) == '0); out_last <= (MW'(int'(dim_m) - 1) == '0);
                    perf_passes <= '0; perf_cycles <= '0; perf_total <= '0;
                end
                S_PRIME: begin                    // first read addresses go out; wait for the read latency
                    if (prime_left == 2'd0) state <= S_RUN;
                    else                    prime_left <= prime_left - 2'd1;
                end
                S_RUN: begin
                    perf_cycles <= perf_cycles + 32'd1;
                    if (pass_first) perf_passes <= perf_passes + 32'd1;
                    if (fin) state <= S_LAST;
                end
                // Wait for the last row (row M-1) of the last pass; with PIPE, earlier rows
                // of that pass can still be leaving the array here.
                S_LAST: if (out_valid && out_last) state <= S_DONE;
                S_DONE: begin
                    done <= 1'b1; busy <= 1'b0; state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase

            if (in_valid && a_first) begin cap_first <= (kb == '0); cap_nb <= nb; end
            if (out_next2) begin
                if (pre_last) begin pre_row <= '0;            pre_last <= m_one;            end
                else          begin pre_row <= pre_row + 1'b1; pre_last <= (pre_row == m_m2); end
            end
            if (out_valid) begin
                if (out_last) begin out_row <= '0;            out_last <= m_one;            end
                else          begin out_row <= out_row + 1'b1; out_last <= (out_row == m_m2); end
            end
        end
    end
endmodule
