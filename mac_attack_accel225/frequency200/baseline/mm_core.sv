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
// Memories have one cycle of read latency, so every read address is issued one
// cycle early from the next-cycle values of the pass counters.
module mm_core #(
    parameter int P    = 16,    // array size
    parameter int BITS = 8,     // operand width
    parameter int ACC  = 32,    // accumulator width
    parameter int SAT  = 0,     // 1 = saturating accumulators (PEs and C)
    parameter int MAXD = 64     // largest M, K or N (at most 255)
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

    // Size the controller to the public 8-bit dimension range. Keep a bit for
    // terminal counts; do not truncate the padded edge of a non-power-of-two tile.
    localparam int TW = ($clog2((255 + P - 1) / P + 1) < 1) ? 1 : $clog2((255 + P - 1) / P + 1);
    localparam int CW = $clog2(256 + 3 * P);
    logic [7:0] m, k, n, m_last;
    logic [TW-1:0] kt, nt, kt_last, nt_last;
    logic [CW-1:0] t, t_last;
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

    // read addresses and lane masks for the next cycle
    /* verilator lint_off UNUSEDSIGNAL */   // addresses are 32-bit ints; only the low bits index memory
    int           k_n, i_n, a_addr, b_addr;   // B row and A row needed next cycle
    /* verilator lint_on UNUSEDSIGNAL */
    logic         b_need, a_need;
    logic [P-1:0] a_lanes, b_lanes;
    always_comb begin
        b_need = (n_o < P);
        a_need = (n_o >= P) && (n_o < P + m);
        k_n    = b_need ? n_kb * P + (P - 1) - n_o : 0;
        i_n    = a_need ? n_o - P : 0;
        b_addr = b_need ? k_n * TM + n_nb : 0;
        a_addr = a_need ? i_n * TM + n_kb : 0;
        for (int j = 0; j < P; j++) begin
            b_lanes[j] = b_need && (k_n < k) && (n_nb * P + j < n);
            a_lanes[j] = (n_kb * P + j < k);
        end
    end

    logic [P*BITS-1:0] aq, bq;
    logic [P-1:0]      a_lanes_q, b_lanes_q;
    always_ff @(posedge clk) begin
        aq <= amem[a_addr];
        bq <= bmem[b_addr];
        a_lanes_q <= a_lanes;
        b_lanes_q <= b_lanes;
    end

    // ---------------------------------------------------------------- the array
    logic              w_load, in_valid, out_valid;
    logic [P*BITS-1:0] w_row, a_row;
    logic [P*ACC-1:0]  c_row;

    assign w_load   = (state == S_RUN) && (o < P);
    assign in_valid = (state == S_RUN) && (o >= P) && (o < P + m);
    always_comb begin
        for (int j = 0; j < P; j++) begin
            w_row[j*BITS +: BITS] = b_lanes_q[j] ? bq[j*BITS +: BITS] : '0;
            a_row[j*BITS +: BITS] = a_lanes_q[j] ? aq[j*BITS +: BITS] : '0;
        end
    end

    systolic_array #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT)) u_array (
        .clk(clk), .rst(rst), .w_load(w_load), .w_row(w_row),
        .in_valid(in_valid), .a_row(a_row), .out_valid(out_valid), .c_row(c_row));

    // ---------------------------------------------------------------- accumulators
    // An output row reaches the bottom one cycle after "out_next", so C is read one
    // cycle early (read-modify-write with a one-cycle read).
    logic out_next;
    delay_line #(.WIDTH(1), .DEPTH(2 * P - 2)) u_next (
        .clk(clk), .rst(rst), .d(in_valid), .q(out_next));

    logic [TW-1:0] cap_kb, cap_nb;             // pass whose results are draining
    logic [7:0] pre_row, out_row;              // row being read / written in C
    /* verilator lint_off UNUSEDSIGNAL */   // addresses are 32-bit ints; only the low bits index memory
    int c_raddr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [7:0] rd_lane;
    logic [P*ACC-1:0] cq;

    assign c_raddr = busy ? (out_next ? pre_row * TM + cap_nb : 0)
                          : int'(rd_row) * TM + int'(rd_col) / P;

    always_ff @(posedge clk) begin
        cq <= cmem[c_raddr];
        rd_lane <= 8'(32'(rd_col) % P);
    end
    assign rd_data = cq[rd_lane * ACC +: ACC];

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
        assign c_new[j*ACC +: ACC] = acc_add((cap_kb == 0) ? '0 : cq[j*ACC +: ACC], c_row[j*ACC +: ACC]);
    end

    always_ff @(posedge clk) begin
        if (out_valid) cmem[out_row * TM + cap_nb] <= c_new;
    end

    // ---------------------------------------------------------------- sequencer
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; busy <= 1'b0; done <= 1'b0;
            o <= 0; kb <= 0; nb <= 0;
            m <= 1; k <= 1; n <= 1; kt <= 1; nt <= 1; t <= 1;
            m_last <= 0; kt_last <= 0; nt_last <= 0; t_last <= 0;
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

            if (in_valid && o == P) begin cap_kb <= kb; cap_nb <= nb; end
            if (out_next)  pre_row <= (pre_row == m_last) ? 0 : pre_row + 1;
            if (out_valid) out_row <= (out_row == m_last) ? 0 : out_row + 1;
        end
    end
endmodule


