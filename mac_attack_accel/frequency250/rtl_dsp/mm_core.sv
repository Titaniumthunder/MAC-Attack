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
// Prefetch pointers issue A/B reads ahead of the pipelined DSPs. C is read two
// cycles ahead so its RAM output can be registered before accumulation.
module mm_core #(
    parameter int P    = 16,    // array size
    parameter int BITS = 8,     // operand width
    parameter int ACC  = 32,    // accumulator width
    parameter int SAT  = 0,     // 1 = saturating accumulators (PEs and C)
    parameter int MAXD = 64,    // largest M, K or N (at most 255)
    parameter int READ_PIPELINE = 0, // optional extra result-read register
    parameter int DSP_CASCADE = 0 // explicit 7-series DSP path when enabled
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

    // ---------------------------------------------------------------- buffers
    // A word (i, kb) holds A[i][kb*P .. kb*P+P-1]; B word (k, nb) holds B[k][nb*P ..];
    // C word (i, nb) holds C[i][nb*P ..]. Element j of a word sits in lane j.
    logic [P*BITS-1:0] amem [DEPTH];
    logic [P*BITS-1:0] bmem [DEPTH];
    logic [P*ACC-1:0]  cmem [DEPTH];

    /* verilator lint_off UNUSEDSIGNAL */   // addresses are 32-bit ints; only the low bits index memory
    logic [31:0] wr_addr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [7:0]  wr_lane;
    assign wr_addr = 32'(wr_row) * TM + 32'(wr_col) / P;
    assign wr_lane = 8'(32'(wr_col) % P);

    // Static slices expose independent lane write enables to RAM inference.
    // A variable part-select can turn every data bit into a separate RAM bank.
    for (genvar lane = 0; lane < P; lane++) begin : g_write_lane
        always_ff @(posedge clk) begin
            if (wr_en && !wr_sel && wr_lane == lane)
                amem[wr_addr][lane * BITS +: BITS] <= wr_data;
            if (wr_en && wr_sel && wr_lane == lane)
                bmem[wr_addr][lane * BITS +: BITS] <= wr_data;
        end
    end

    // ---------------------------------------------------------------- controller
    typedef enum logic [2:0] {S_IDLE, S_PRIME, S_RUN, S_LAST, S_DONE} state_t;
    state_t state;

    // Size the controller to MAXD. Keep a bit for
    // terminal counts; do not truncate the padded edge of a non-power-of-two tile.
    localparam int TW = ($clog2(TM + 1) < 1) ? 1 : $clog2(TM + 1);
    localparam int CW = $clog2(MAXD + 3 * P);
    localparam int DW = ($clog2(MAXD+1) < 1) ? 1 : $clog2(MAXD+1);
    logic [DW-1:0] m, k, n, m_last;
    logic [TW-1:0] kt, nt, kt_last, nt_last;
    logic [CW-1:0] t, t_last, t_before_last;
    logic [CW-1:0] o;                         // cycle within pass
    logic [TW-1:0] kb, nb;                    // tile indices
    logic last_pass;
    assign last_pass = (kb == kt_last) && (nb == nt_last);

    // next-cycle pass counters
    logic [CW-1:0] n_o;
    logic [TW-1:0] n_kb, n_nb;
    always_comb begin
        n_o = 0; n_kb = 0; n_nb = 0;
        if (state == S_RUN && !(o == t_last && last_pass)) begin
            if (o == t_last) begin
                n_o = 0;
                if (kb == kt_last) begin n_kb = 0;      n_nb = nb + 1; end
                else              begin n_kb = kb + 1; n_nb = nb;     end
            end else begin
                n_o = o + 1; n_kb = kb; n_nb = nb;
            end
        end
    end

    // Independent prefetch pointers remove next-state arithmetic from RAM inputs.
    // A is supplied EARLY cycles before in_valid; weights load one cycle early.
    localparam int EARLY = (P >= 3) ? 2 : 1;
    localparam int AW = ($clog2(DEPTH) < 1) ? 1 : $clog2(DEPTH);
    localparam int IXW = $clog2(MAXD + 2*P + 1);
    logic [AW-1:0] a_addr, b_addr, next_b_first;
    logic [TW-1:0] ahead_kb, ahead_nb;
    logic [P-1:0] a_lanes, b_lanes;
    logic [P-1:0] b_rows, b_cols, next_b_rows, next_b_cols;
    logic [CW-1:0] a_first, a_last, in_last;
    wire first_read = (state == S_IDLE && start);
    wire [AW-1:0] b_read_addr = first_read ? AW'((P-1)*TM) : b_addr;
    for (genvar lane = 0; lane < P; lane++) begin : g_b_mask
        assign b_lanes[lane] = first_read
            ? ((P-1 < int'(dim_k)) && (lane < int'(dim_n)))
            : (b_cols[lane] && b_rows[P-1]);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            a_addr <= '0; b_addr <= '0; next_b_first <= '0;
            ahead_kb <= '0; ahead_nb <= '0;
            a_lanes <= '0; b_rows <= '0; b_cols <= '0;
            next_b_rows <= '0; next_b_cols <= '0;
            a_first <= CW'(P-EARLY-1); a_last <= CW'(P-EARLY-1); in_last <= '0;
        end else begin
            if (state == S_IDLE && start) begin
                a_addr <= '0;
                b_addr <= AW'((P-2)*TM);
                a_first <= CW'(P-EARLY-1);
                a_last <= CW'(int'(dim_m)+P-EARLY-2);
                in_last <= CW'(int'(dim_m)+P-1);
                for (int j=0; j<P; j++) begin
                    a_lanes[j] <= (j < int'(dim_k));
                    b_rows[j] <= (j > 0 && j-1 < int'(dim_k));
                    b_cols[j] <= (j < int'(dim_n));
                end
            end
            // Start reads row P-1; PRIME and early RUN cycles read the remaining rows.
            if (state == S_PRIME || (state == S_RUN && o < P-2)) begin
                b_addr <= b_addr - AW'(TM);
                b_rows <= b_rows << 1;
            end
            if (state == S_RUN) begin
                // Prepare the following tile in separate clocks, during this tile.
                if (o == 0) begin
                    ahead_kb <= (kb == kt_last) ? '0 : kb + 1'b1;
                    ahead_nb <= (kb == kt_last) ? nb + 1'b1 : nb;
                end
                if (o == 1) begin
                    next_b_first <= AW'((ahead_kb*P+P-1)*TM+ahead_nb);
                    for (int j=0; j<P; j++) begin
                        next_b_rows[j] <= (IXW'(ahead_kb*P+j) < IXW'(k));
                        next_b_cols[j] <= (IXW'(ahead_nb*P+j) < IXW'(n));
                    end
                end
                if (o == P) begin
                    b_addr <= next_b_first;
                    b_rows <= next_b_rows;
                    b_cols <= next_b_cols;
                end
                // The end-of-pass read fetches the next tile's first weight row.
                if (o == t_last || o == t_before_last) begin
                    b_addr <= b_addr - AW'(TM);
                    b_rows <= b_rows << 1;
                end
                if (o == t_last) begin
                    a_addr <= AW'(ahead_kb);
                    a_lanes <= next_b_rows;
                end else if (o >= a_first && o < a_last) begin
                    a_addr <= a_addr + AW'(TM);
                end
            end
        end
    end
    logic [P*BITS-1:0] aq, bq;
    logic [P-1:0]      a_lanes_q, b_lanes_q;
    always_ff @(posedge clk) begin
        aq <= amem[a_addr];
        bq <= bmem[b_read_addr];
        a_lanes_q <= a_lanes;
        b_lanes_q <= b_lanes;
    end

    // ---------------------------------------------------------------- the array
    (* max_fanout = 8 *) logic w_load;
    logic in_valid, out_valid;
    logic [P*BITS-1:0] w_row, a_row;
    logic [P*ACC-1:0]  c_row;

    // Predict the next cycle's load phase, so the DSP enables are driven by
    // local replicated flops rather than the terminal-count compare network.
    always_ff @(posedge clk) begin
        if (rst) w_load <= 1'b0;
        else begin
            case (state)
                S_IDLE:  w_load <= start;
                S_PRIME: w_load <= 1'b1;
                S_RUN:   w_load <= (o < P-2) ||
                    (((o == t_before_last) || (o == t_last)) && !last_pass);
                default: w_load <= 1'b0;
            endcase
        end
    end
    // Predict the activation-valid window; do not add M to P on each cycle.
    always_ff @(posedge clk) begin
        if (rst || state != S_RUN) in_valid <= 1'b0;
        else if (o == P-1) in_valid <= (m != 0);
        else if (o == in_last) in_valid <= 1'b0;
    end
    always_comb begin
        for (int j = 0; j < P; j++) begin
            w_row[j*BITS +: BITS] = b_lanes_q[j] ? bq[j*BITS +: BITS] : '0;
            a_row[j*BITS +: BITS] = a_lanes_q[j] ? aq[j*BITS +: BITS] : '0;
        end
    end

    systolic_array #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT), .EARLY_MAC(EARLY), .DSP_CASCADE(DSP_CASCADE)) u_array (
        .clk(clk), .rst(rst), .w_load(w_load), .w_row(w_row),
        .in_valid(in_valid), .a_row(a_row), .out_valid(out_valid), .c_row(c_row));

    // ---------------------------------------------------------------- accumulators
    // Read C two cycles before out_valid: RAM read, then an output register.
    // Host reads retain their original one-cycle latency through cq.
    logic out_next;
    delay_line #(.WIDTH(1), .DEPTH(2 * P - 3)) u_next (
        .clk(clk), .rst(rst), .d(in_valid), .q(out_next));

    logic [TW-1:0] cap_kb, cap_nb;             // pass whose results are draining
    logic [DW-1:0] pre_row, out_row;              // row being read / written in C
    /* verilator lint_off UNUSEDSIGNAL */   // addresses are 32-bit ints; only the low bits index memory
    int c_raddr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [7:0] rd_lane, rd_lane_pipe;
    logic [P*ACC-1:0] cq, cq_pipe;

    assign c_raddr = busy ? (out_next ? pre_row * TM + cap_nb : 0)
                          : int'(rd_row) * TM + int'(rd_col) / P;

    always_ff @(posedge clk) begin
        cq <= cmem[c_raddr];
        cq_pipe <= cq;
        rd_lane_pipe <= rd_lane;
        rd_lane <= 8'(32'(rd_col) % P);
    end
    generate
        if (READ_PIPELINE != 0) begin : g_read_pipe
            assign rd_data = cq_pipe[rd_lane_pipe * ACC +: ACC];
        end else begin : g_read_direct
            assign rd_data = cq[rd_lane * ACC +: ACC];
        end
    endgenerate

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
        assign c_new[j*ACC +: ACC] = acc_add((cap_kb == 0) ? '0 : cq_pipe[j*ACC +: ACC], c_row[j*ACC +: ACC]);
    end

    // The existing S_DONE cycle can commit a registered C write without delaying
    // done or changing any pass counts. Separate BRAM-read/add from BRAM-write.
    logic c_write_valid;
    logic [AW-1:0] c_write_addr;
    logic [P*ACC-1:0] c_write_data;
    always_ff @(posedge clk) begin
        if (rst) c_write_valid <= 1'b0;
        else c_write_valid <= out_valid;
        c_write_addr <= AW'(out_row * TM + cap_nb);
        c_write_data <= c_new;
        if (c_write_valid && !rst) cmem[c_write_addr] <= c_write_data;
    end

    // ---------------------------------------------------------------- sequencer
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; busy <= 1'b0; done <= 1'b0;
            o <= 0; kb <= 0; nb <= 0;
            m <= 1; k <= 1; n <= 1; kt <= 1; nt <= 1; t <= 1;
            m_last <= 0; kt_last <= 0; nt_last <= 0; t_last <= 0; t_before_last <= 0;
            cap_kb <= 0; cap_nb <= 0; pre_row <= 0; out_row <= 0;
            perf_passes <= '0; perf_cycles <= '0; perf_total <= '0;
        end else begin
            done <= 1'b0;
            if (busy) perf_total <= perf_total + 32'd1;

            case (state)
                S_IDLE: if (start) begin
                    m <= dim_m; k <= dim_k; n <= dim_n;
                    // Compute terminal values once, outside the per-cycle address path.
                    m_last <= dim_m - 8'd1;
                    kt_last <= TW'((int'(dim_k) + P - 1) / P - 1);
                    nt_last <= TW'((int'(dim_n) + P - 1) / P - 1);
                    t_last <= CW'(int'(dim_m) + 3 * P - 3);
                    t_before_last <= CW'(int'(dim_m) + 3 * P - 4);
                    kt <= (int'(dim_k) + P - 1) / P;
                    nt <= (int'(dim_n) + P - 1) / P;
                    t  <= int'(dim_m) + 3 * P - 2;
                    busy <= 1'b1; state <= S_PRIME;
                    pre_row <= 0; out_row <= 0;
                    perf_passes <= '0; perf_cycles <= '0; perf_total <= '0;
                end
                S_PRIME: begin                    // first read addresses go out this cycle
                    o <= 0; kb <= 0; nb <= 0; state <= S_RUN;
                end
                S_RUN: begin
                    perf_cycles <= perf_cycles + 32'd1;
                    if (o == 0) perf_passes <= perf_passes + 32'd1;
                    if (o == t_last && last_pass) state <= S_LAST;
                    o <= n_o; kb <= n_kb; nb <= n_nb;
                end
                S_LAST: if (out_valid) state <= S_DONE;   // last row of the last pass
                S_DONE: begin
                    done <= 1'b1; busy <= 1'b0; state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase

            if (state == S_RUN && o == P && m != 0) begin cap_kb <= kb; cap_nb <= nb; end
            if (out_next)  pre_row <= (pre_row == m_last) ? 0 : pre_row + 1;
            if (out_valid) out_row <= (out_row == m_last) ? 0 : out_row + 1;
        end
    end
endmodule






