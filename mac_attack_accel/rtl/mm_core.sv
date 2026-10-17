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
module mm_core #(
    parameter int P       = 16,  // array size
    parameter int BITS    = 8,   // operand width
    parameter int ACC     = 32,  // accumulator width
    parameter int SAT     = 0,   // 1 = saturating accumulators (PEs and C)
    parameter int MAXD    = 64,  // largest M, K or N (at most 255)
    parameter int PIPE    = 1,   // 1 = two-stage PEs
    parameter int MEM_REG = 1    // registers after the A and B block-RAM reads: 0, 1 or 2
)(
    input  logic             clk,
    input  logic             rst,
    // load port: one element per cycle
    input  logic             wr_en,
    input  logic             wr_sel,       // 0 = A[row][col] (M x K), 1 = B[row][col] (K x N)
    input  logic [7:0]       wr_row,
    input  logic [7:0]       wr_col,
    input  logic [BITS-1:0]  wr_data,
    // run
    input  logic             start,        // one-cycle pulse while idle
    input  logic [7:0]       dim_m,        // 1 .. MAXD
    input  logic [7:0]       dim_k,
    input  logic [7:0]       dim_n,
    output logic             busy,
    output logic             done,         // one-cycle pulse when C is complete
    // result read port: C[rd_row][rd_col] appears on rd_data one cycle later (while idle)
    input  logic [7:0]       rd_row,
    input  logic [7:0]       rd_col,
    output logic [ACC-1:0]   rd_data,
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
    (* ram_style = "block" *) logic [P*BITS-1:0] amem [DEPTH];
    (* ram_style = "block" *) logic [P*BITS-1:0] bmem [DEPTH];
    logic [P*ACC-1:0]  cmem [DEPTH];

    /* verilator lint_off UNUSEDSIGNAL */   // addresses are 32-bit ints; only the low bits index memory
    logic [31:0] wr_addr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [7:0]  wr_lane;
    assign wr_addr = 32'(wr_row) * TM + 32'(wr_col) / P;
    assign wr_lane = 8'(32'(wr_col) % P);

    // Byte-write-enable style: lane j is a fixed slice, picked by a write enable.
    // (Writing a variable slice made the synthesis tool split each buffer into many
    // block RAMs, which put a long, high-fanout wire on the read address.)
    logic [P*BITS-1:0] wr_word;
    assign wr_word = {P{wr_data}};

    always_ff @(posedge clk) begin
        if (wr_en && !wr_sel)
            for (int j = 0; j < P; j++)
                if (wr_lane == 8'(j)) amem[wr_addr][j*BITS +: BITS] <= wr_word[j*BITS +: BITS];
    end

    always_ff @(posedge clk) begin
        if (wr_en && wr_sel)
            for (int j = 0; j < P; j++)
                if (wr_lane == 8'(j)) bmem[wr_addr][j*BITS +: BITS] <= wr_word[j*BITS +: BITS];
    end

    // ---------------------------------------------------------------- controller
    typedef enum logic [2:0] {S_IDLE, S_PRIME, S_RUN, S_LAST, S_DONE} state_t;
    state_t state;
    logic [1:0] prime_left;                   // S_PRIME lasts 1 + MEM_REG cycles (the read latency)

    // Limits, worked out once when a run starts
    logic [OW-1:0] tm1;                       // t - 1, where t = M + 3P - 2 cycles per pass
    logic [MW-1:0] m_m1;                      // M - 1
    logic [KW-1:0] kt_m1, nt_m1;              // ceil(K/P) - 1, ceil(N/P) - 1
    logic [LP-1:0] thr;                       // in the last K tile, weight-load cycles o >= thr carry real rows of B
    logic [P-1:0]  amask_last;                // lanes of A inside K, in the last K tile
    logic [P-1:0]  nmask_last;                // lanes of B inside N, in the last N tile

    int ktv, ntv;                             // tile counts from the inputs (used only at start)
    assign ktv = (int'(dim_k) + P - 1) / P;
    assign ntv = (int'(dim_n) + P - 1) / P;

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
        end else if (state == S_IDLE) begin
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

    logic [AW-1:0] a_addr, b_addr;
    generate
        if (POW2) begin : g_addr_bits         // B word (kb*P + P-1-o, nb), A word (i, kb) as bit fields
            assign b_addr = rw ? AW'({rkb, k_low, rnb}) : '0;
            assign a_addr = ra ? AW'({ri, rkb}) : '0;
        end else begin : g_addr_math          // any P: small multiply-adds
            assign b_addr = rw ? AW'((int'(rkb) * P + int'(k_low)) * TM + int'(rnb)) : '0;
            assign a_addr = ra ? AW'(int'(ri) * TM + int'(rkb)) : '0;
        end
    endgenerate

    logic [P-1:0] a_lanes, b_lanes;
    assign a_lanes = rkb_last ? amask_last : '1;
    assign b_lanes = (rw && (!rkb_last || ro[LP-1:0] >= thr)) ? (rnb_last ? nmask_last : '1) : '0;

    // Block-RAM read (aq1, bq1). With MEM_REG >= 1 a second register follows, and the lane
    // mask is applied in front of it, so the array's inputs come straight from flip-flops.
    // MEM_REG = 2 adds a third register (no logic) to split a long wire.
    // (Without MEM_REG the mask sits between the block RAM and the array.)
    logic [P*BITS-1:0] aq1, bq1;
    logic [P-1:0]      a_lanes_q1, b_lanes_q1;
    logic [P*BITS-1:0] w_row, a_row;          // inputs of the array
    always_ff @(posedge clk) begin
        aq1 <= amem[a_addr];
        bq1 <= bmem[b_addr];
        a_lanes_q1 <= a_lanes;
        b_lanes_q1 <= b_lanes;
    end
    generate
        if (MEM_REG != 0) begin : g_memreg
            logic [P*BITS-1:0] aq, bq;
            always_ff @(posedge clk) begin
                for (int j = 0; j < P; j++) begin
                    aq[j*BITS +: BITS] <= a_lanes_q1[j] ? aq1[j*BITS +: BITS] : '0;
                    bq[j*BITS +: BITS] <= b_lanes_q1[j] ? bq1[j*BITS +: BITS] : '0;
                end
            end
            if (MEM_REG >= 2) begin : g_feed2
                logic [P*BITS-1:0] aq2, bq2;
                always_ff @(posedge clk) begin
                    aq2 <= aq;
                    bq2 <= bq;
                end
                assign a_row = aq2;
                assign w_row = bq2;
            end else begin : g_feed1
                assign a_row = aq;
                assign w_row = bq;
            end
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
    logic          w_phase1, a_phase1, pass_first1, a_first1, fin1;
    logic [KW-1:0] kb1, nb1;
    logic [OW-1:0] o1;
    always_ff @(posedge clk) begin
        if (rst) begin
            w_phase1 <= 1'b0; a_phase1 <= 1'b0; pass_first1 <= 1'b0; a_first1 <= 1'b0; fin1 <= 1'b0;
            kb1 <= '0; nb1 <= '0; o1 <= '0;
        end else begin
            o1          <= ro;
            w_phase1    <= rw;
            a_phase1    <= ra;
            pass_first1 <= rfirst;
            a_first1    <= ra && (ri == '0);
            fin1        <= r_active && r_final;
            kb1         <= rkb;
            nb1         <= rnb;
        end
    end

    logic          w_phase, a_phase;          // loading weights / streaming A, for the array
    logic          pass_first;                // first cycle of a pass
    logic          a_first;                   // first row of A of a pass
    logic          fin;                       // last cycle of the last pass
    logic [KW-1:0] kb, nb;                    // pass the array is working on
    /* verilator lint_off UNUSEDSIGNAL */
    logic [OW-1:0] o;                         // cycle inside the pass, for waveforms only (tb_selfcheck shows it)
    /* verilator lint_on UNUSEDSIGNAL */
    localparam int FW = OW + 2 * KW + 5;      // all the flags as one vector
    generate
        if (MEM_REG != 0) begin : g_arr2
            logic [FW-1:0] flags1, flags;
            assign flags1 = {o1, kb1, nb1, w_phase1, a_phase1, pass_first1, a_first1, fin1};
            delay_line #(.WIDTH(FW), .DEPTH(MEM_REG), .RESET(1)) u_flags (
                .clk(clk), .rst(rst), .d(flags1), .q(flags));
            assign {o, kb, nb, w_phase, a_phase, pass_first, a_first, fin} = flags;
        end else begin : g_arr1
            assign o = o1;  assign w_phase = w_phase1;  assign a_phase = a_phase1;
            assign pass_first = pass_first1;  assign a_first = a_first1;  assign fin = fin1;
            assign kb = kb1;  assign nb = nb1;
        end
    endgenerate

    // ---------------------------------------------------------------- the array
    logic              w_load, in_valid, out_valid;
    logic [P*ACC-1:0]  c_row;

    assign w_load   = (state == S_RUN) && w_phase;
    assign in_valid = (state == S_RUN) && a_phase;

    systolic_array #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT), .PIPE(PIPE)) u_array (
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

    // C word (row, nb): bit fields for powers of two, small multiply-add otherwise
    function automatic logic [AW-1:0] c_addr(input logic [MW-1:0] row, input logic [KW-1:0] blk);
        if (POW2) c_addr = AW'({row, blk});
        else      c_addr = AW'(int'(row) * TM + int'(blk));
    endfunction

    /* verilator lint_off UNUSEDSIGNAL */   // host read address is a 32-bit int; only the low bits index memory
    int host_raddr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [AW-1:0] c_raddr;
    logic [7:0] rd_lane;
    logic [P*ACC-1:0] cq1, cq2;

    assign host_raddr = int'(rd_row) * TM + int'(rd_col) / P;
    assign c_raddr = busy ? (out_next2 ? c_addr(pre_row, cap_nb) : '0) : AW'(host_raddr);

    always_ff @(posedge clk) begin
        cq1 <= cmem[c_raddr];                 // block-RAM read (the host reads this one, 1 cycle)
        // Registered copy for the accumulator. In the first pass of an output block the old word
        // must not be added, so it is cleared here (a synchronous reset on these flip-flops)
        // instead of through a mux in front of the adder.
        if (cap_first) cq2 <= '0;
        else           cq2 <= cq1;
        rd_lane <= 8'(32'(rd_col) % P);
    end
    assign rd_data = cq1[rd_lane * ACC +: ACC];

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
    always_ff @(posedge clk) begin
        if (wq_en) cmem[wq_addr] <= wq;
    end

    // ---------------------------------------------------------------- sequencer
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; busy <= 1'b0; done <= 1'b0; prime_left <= '0;
            tm1 <= '0; m_m1 <= '0; kt_m1 <= '0; nt_m1 <= '0;
            thr <= LP'(P - 1); amask_last <= P'(1); nmask_last <= P'(1);   // as for K = N = 1
            cap_first <= 1'b1; cap_nb <= '0; pre_row <= '0; out_row <= '0;
            perf_passes <= '0; perf_cycles <= '0; perf_total <= '0;
        end else begin
            done <= 1'b0;
            if (busy) perf_total <= perf_total + 32'd1;

            case (state)
                S_IDLE: if (start) begin
                    tm1   <= OW'(int'(dim_m) + 3 * P - 3);
                    m_m1  <= MW'(int'(dim_m) - 1);
                    kt_m1 <= KW'(ktv - 1);
                    nt_m1 <= KW'(ntv - 1);
                    thr   <= LP'(ktv * P - int'(dim_k));
                    for (int j = 0; j < P; j++) begin
                        amask_last[j] <= ((ktv - 1) * P + j < int'(dim_k));
                        nmask_last[j] <= ((ntv - 1) * P + j < int'(dim_n));
                    end
                    busy <= 1'b1; state <= S_PRIME; prime_left <= 2'(MEM_REG);
                    pre_row <= '0; out_row <= '0;
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
                S_LAST: if (out_valid && out_row == m_m1) state <= S_DONE;
                S_DONE: begin
                    done <= 1'b1; busy <= 1'b0; state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase

            if (in_valid && a_first) begin cap_first <= (kb == '0); cap_nb <= nb; end
            if (out_next2) pre_row <= (pre_row == m_m1) ? '0 : pre_row + 1'b1;
            if (out_valid) out_row <= (out_row == m_m1) ? '0 : out_row + 1'b1;
        end
    end
endmodule
