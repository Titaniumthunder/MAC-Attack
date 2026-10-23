`timescale 1ns/1ps
// mlp_ctrl: runs a whole multilayer perceptron (MLP) on the matrix core, with no help from the ARM
// between layers (the "on-chip MLP", 21 Oct 2026). It wraps mm_core and adds three blocks:
//   * a layer sequencer: a small state machine that steps through the layers,
//   * a scale memory: bias, m0 and shift for every output channel of every layer,
//   * LANES postproc units that turn a layer's C words back into INT8 A words (the writeback).
// The PE array, the folding controller and the buffers are mm_core's, unchanged.
//
// One model run (model_start). Before it: the M input rows are in A (loaded as usual, M x K_0),
// layer l's weights are in weight slot l (K_l x N_l), and the scale memory holds every layer's
// bias, m0 and shift. Then, with no host involvement:
//   for l = 0 .. last_layer:
//       C = A x W_l                       mm_core, weight slot l, sizes M x K_l x N_l
//       if l < last_layer:  A <- postproc(C)
//   The last layer's C stays in the C buffer: the host reads it through the usual result port
//   (rd_row, rd_col, rd_data), as raw sums. The ARM adds that layer's bias itself.
// Sizes: K_0 = dim_k (DIMS.K), K_l = N_(l-1) for l >= 1, so a layer's input is always exactly the
// previous layer's output. N_l = layer_n[l]. M = dim_m for every layer.
//
// Writeback (between layers). C word (i, nb) holds C[i][nb*P .. nb*P+P-1] and A word (i, nb) holds
// A[i][nb*P ..], and layer l's N is layer l+1's K, so the writeback is word for word:
//     A word (i, nb) = postproc( C word (i, nb) ),   lane j = output channel nb*P + j
//   for i = 0 .. M-1, nb = 0 .. ceil(N_l / P) - 1
// Lane j uses channel (nb*P + j)'s bias, m0 and shift; relu is per layer:
//     y = clamp( round( (C + bias) * m0 / 2^shift ), relu ? 0 : -128, 127 )     (see postproc.sv)
// With LANES = P (the FPGA default) one C word goes through per clock. With fewer lanes (LANES must
// divide P; LANES = 1 for a small chip) each C word takes P / LANES clocks: the word is held and
// LANES channels go through per clock, and the A word is written when all its lanes are done.
//
// Writeback pipeline, for a "token" (i, nb, s) made in clock c (s = which LANES-wide part of the
// word, always 0 when LANES = P):
//   c                 C word (i, nb) read address goes to mm_core (wb_row, wb_blk; wb_rd = 1 all model long)
//   c + RL            the C word arrives on rd_word (RL = 1 + HREAD_REG); the lane values and the
//                     scale memory's outputs for those channels are registered
//   c + RL + 1        into the postproc units
//   c + RL + 1 + PPD  out of the postproc units (PPD = 3, 7 or 9, see postproc.sv): assembled
//   c + RL + 2 + PPD  A word written (mm_core's aw_* port)
// The C buffer is final when mm_core says done: its last word is written in the clock before
// done is high, and the first writeback read is two clocks after that.
//
// Plain multiplies (start, sizes dim_m, dim_k, dim_n, weight slot run_layer) go to mm_core as
// before. dim_k, dim_n and the slot reach mm_core through registers (one clock later): they are
// only used when a run starts, and the host never changes them within 2 clocks of a start.
//
// busy covers the whole model run; done is one pulse at its end (the per-layer done pulses of
// mm_core are not passed on during a model run). After a model run the performance outputs are
// sums over all layers (passes, cycles in passes, busy cycles of the matrix core);
// model_cycles counts every clock of the model run, writebacks included. Each layer's counts are
// added one clock after its done (step 15c), so the sums are final one clock after the model's
// done; the host reads them many clocks later (after it has seen done in STATUS).
module mlp_ctrl #(
    parameter int P         = 8,
    parameter int BITS      = 8,
    parameter int ACC       = 22,   // accumulator width (at most 32: postproc takes up to 32)
    parameter int SAT       = 0,
    parameter int MAXD      = 64,
    parameter int PIPE      = 2,
    parameter int MEM_REG   = 2,
    parameter int PE_PRIM   = 0,
    parameter int HREAD_REG = 1,
    parameter int NL        = 4,    // layers (weight slots in B, layer table entries)
    parameter int PPL       = 0,    // postproc lanes; 0 = P (one C word per clock). Must divide P.
    parameter int PPIPE     = 2     // postproc pipeline: 0 = 3 stages, 1 = 7, 2 = 9 stages (for 250 MHz)
)(
    input  logic             clk,
    input  logic             rst,
    // load port (as mm_core's), plus the weight slot for B
    input  logic             wr_en,
    input  logic             wr_sel,        // 0 = A, 1 = B
    input  logic [((NL > 1) ? $clog2(NL) : 1)-1:0] wr_layer,
    input  logic [7:0]       wr_row,
    input  logic [7:0]       wr_col,
    input  logic [BITS-1:0]  wr_data,
    // scale memory write: channel pw_ch of layer pw_layer; pw_field 0 = bias (32 bits),
    // 1 = m0 (bits 15:0) and shift (bits 21:16)
    input  logic             pw_en,
    input  logic             pw_field,
    input  logic [((NL > 1) ? $clog2(NL) : 1)-1:0] pw_layer,
    input  logic [7:0]       pw_ch,
    input  logic [31:0]      pw_data,
    // plain multiply
    input  logic             start,
    input  logic [7:0]       dim_m,
    input  logic [7:0]       dim_k,
    input  logic [7:0]       dim_n,
    input  logic [((NL > 1) ? $clog2(NL) : 1)-1:0] run_layer,
    // model run
    input  logic             model_start,
    input  logic [((NL > 1) ? $clog2(NL) : 1)-1:0] last_layer,  // number of layers - 1
    input  logic [8*NL-1:0]  layer_n,       // N of layer l in bits 8l+7 : 8l
    input  logic [NL-1:0]    layer_relu,    // ReLU after layer l (not used for the last layer)
    output logic             busy,
    output logic             done,
    // result read port (as mm_core's)
    input  logic [7:0]       rd_row,
    input  logic [7:0]       rd_col,
    output logic [ACC-1:0]   rd_data,
    // performance
    output logic [31:0]      perf_passes,
    output logic [31:0]      perf_cycles,
    output logic [31:0]      perf_total,
    output logic [31:0]      model_cycles
);
    localparam int LW    = (NL > 1) ? $clog2(NL) : 1;
    localparam int TM    = (MAXD + P - 1) / P;                  // most P-wide blocks along a dimension
    localparam int LANES = (PPL == 0) ? P : PPL;                // postproc units
    localparam int S     = P / LANES;                           // clocks per C word in the writeback
    localparam int SW    = (S > 1) ? $clog2(S) : 1;
    localparam int LP    = (P > 1) ? $clog2(P) : 1;
    localparam int KW    = (TM > 1) ? $clog2(TM) : 1;
    localparam int MW    = (MAXD > 1) ? $clog2(MAXD) : 1;
    localparam bit PPOW2 = (P == (1 << LP));
    localparam int NWL   = TM * S;                              // scale memory words per layer
    localparam int WW    = (NWL > 1) ? $clog2(NWL) : 1;
    localparam bit WPOW2 = (NWL == (1 << WW));
    localparam int NSD   = WPOW2 ? (NL << WW) : NL * NWL;       // scale memory depth
    localparam int SAW   = (NSD > 1) ? $clog2(NSD) : 1;
    localparam int RL    = 1 + HREAD_REG;                       // C read latency (rd_word)
    localparam int PPD   = (PPIPE == 0) ? 3 : (PPIPE == 1) ? 7 : 9;   // postproc latency
    localparam int DRAIN = RL + PPD;                            // see the state machine

    // ================================================================ the matrix core
    logic             core_start, core_busy, core_done;
    logic [7:0]       core_k, core_n;           // sizes and slot for mm_core: registers (see the header)
    logic [LW-1:0]    core_layer;
    logic [P*ACC-1:0] rd_word;
    logic             aw_en;
    logic [7:0]       aw_row, aw_blk;
    logic [P*BITS-1:0] aw_data;
    logic [31:0]      c_passes, c_cycles, c_total;

    mm_core #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT), .MAXD(MAXD), .PIPE(PIPE), .MEM_REG(MEM_REG),
              .HCLK_SEP(0), .PE_PRIM(PE_PRIM), .HREAD_REG(HREAD_REG), .NL(NL), .AWR(1)) u_core (
        .clk(clk), .hclk(clk), .rst(rst),
        .wr_en(wr_en), .wr_sel(wr_sel), .wr_row(wr_row), .wr_col(wr_col), .wr_data(wr_data),
        .wr_layer(wr_layer),
        .aw_en(aw_en), .aw_row(aw_row), .aw_blk(aw_blk), .aw_data(aw_data),
        .wb_rd(m_busy), .wb_row(8'(tk_i)), .wb_blk(8'(tk_nb)),
        .start(core_start), .dim_m(dim_m), .dim_k(core_k), .dim_n(core_n), .run_layer(core_layer),
        .busy(core_busy), .done(core_done),
        .rd_row(rd_row), .rd_col(rd_col), .rd_data(rd_data), .rd_word(rd_word),
        .perf_passes(c_passes), .perf_cycles(c_cycles), .perf_total(c_total));

    // ================================================================ layer sequencer
    typedef enum logic [2:0] {Q_IDLE, Q_SETUP, Q_GO, Q_RUN, Q_WB, Q_DRAIN} qstate_t;
    qstate_t        q;
    logic           m_busy;                     // a model run is going on
    logic           m_done;                     // one-clock pulse at the end of a model run
    logic           go;                         // starts mm_core for the current layer
    logic           m_last;                     // the last command was a model run (performance outputs)
    logic [LW-1:0]  layer, last_q;              // current layer, last layer
    logic [MW-1:0]  m_m1;                       // M - 1
    logic [KW-1:0]  nt_m1;                      // ceil(N_l / P) - 1 for the current layer
    logic           relu_q;                     // ReLU for the current layer's writeback
    logic [7:0]     drain;
    // writeback token (row, block, part) and its valid flag
    logic           tk_v;
    logic [MW-1:0]  tk_i;
    logic [KW-1:0]  tk_nb;
    logic [SW-1:0]  tk_s;
    logic [31:0]    sum_passes, sum_cycles, sum_total, mcyc;
    logic           sum_add;                // add the layer that finished last clock (step 15c)

    // mm_core's counters, copied every clock (step 15c, timing at 250 MHz). In the clock after a
    // layer's done the copies hold that layer's final counts, so the sums are added from registers
    // next to them instead of from mm_core's registers across the chip. Same sums, one clock later.
    logic [31:0]    cq_passes, cq_cycles, cq_total;
    always_ff @(posedge clk) begin
        cq_passes <= c_passes;
        cq_cycles <= c_cycles;
        cq_total  <= c_total;
    end

    // N of layer l
    function automatic logic [7:0] n_of(input logic [LW-1:0] l);
        n_of = layer_n[8 * int'(l) +: 8];
    endfunction
    function automatic logic [KW-1:0] blocks_m1(input logic [7:0] n);   // ceil(n / P) - 1
        if (PPOW2) blocks_m1 = KW'((n - 8'd1) >> LP);
        else       blocks_m1 = KW'((int'(n) + P - 1) / P - 1);
    endfunction

    always_ff @(posedge clk) begin
        if (rst) begin
            q <= Q_IDLE; m_busy <= 1'b0; m_done <= 1'b0; go <= 1'b0; m_last <= 1'b0;
            layer <= '0; last_q <= '0; m_m1 <= '0; nt_m1 <= '0; relu_q <= 1'b0; drain <= '0;
            tk_v <= 1'b0; tk_i <= '0; tk_nb <= '0; tk_s <= '0;
            sum_passes <= '0; sum_cycles <= '0; sum_total <= '0; mcyc <= '0; sum_add <= 1'b0;
        end else begin
            m_done  <= 1'b0;
            go      <= 1'b0;
            sum_add <= 1'b0;
            if (sum_add) begin              // a new model's clear (Q_IDLE, below) still wins
                sum_passes <= sum_passes + cq_passes;
                sum_cycles <= sum_cycles + cq_cycles;
                sum_total  <= sum_total  + cq_total;
            end
            if (m_busy) mcyc <= mcyc + 32'd1;
            if (start && !m_busy) m_last <= 1'b0;
            case (q)
                Q_IDLE: if (model_start && !core_busy) begin
                    m_busy <= 1'b1; m_last <= 1'b1;
                    layer  <= '0;
                    last_q <= (int'(last_layer) > NL - 1) ? LW'(NL - 1) : last_layer;
                    m_m1   <= MW'(int'(dim_m) - 1);
                    sum_passes <= '0; sum_cycles <= '0; sum_total <= '0; mcyc <= '0;
                    q <= Q_SETUP;
                end
                Q_SETUP: begin                  // core_k, core_n, core_layer take this layer's values now
                    nt_m1  <= blocks_m1(n_of(layer));
                    relu_q <= layer_relu[layer];
                    go     <= 1'b1;
                    q      <= Q_GO;
                end
                Q_GO: q <= Q_RUN;               // go is high in this clock: mm_core starts
                Q_RUN: if (core_done) begin
                    sum_add <= 1'b1;            // this layer's counts, added next clock
                    if (layer == last_q) begin  // finished: the last layer's C stays in C
                        m_busy <= 1'b0; m_done <= 1'b1;
                        q <= Q_IDLE;
                    end else begin
                        tk_v <= 1'b1; tk_i <= '0; tk_nb <= '0; tk_s <= '0;
                        q <= Q_WB;
                    end
                end
                Q_WB: begin                     // one token per clock: s fastest, then nb, then i
                    if (int'(tk_s) == S - 1) begin
                        tk_s <= '0;
                        if (tk_nb == nt_m1) begin
                            tk_nb <= '0;
                            if (tk_i == m_m1) begin
                                tk_v <= 1'b0; drain <= 8'(DRAIN);
                                q <= Q_DRAIN;
                            end else tk_i <= tk_i + 1'b1;
                        end else tk_nb <= tk_nb + 1'b1;
                    end else tk_s <= tk_s + 1'b1;
                end
                // Wait until the last A word is written: the last token was made in clock c, its
                // word is written at the end of clock c + RL + 2 + PPD, and the next layer's start
                // (Q_GO) comes DRAIN + 3 clocks after c, which is later.
                Q_DRAIN: if (drain == 8'd0) begin
                    layer <= layer + 1'b1;
                    q <= Q_SETUP;
                end else drain <= drain - 8'd1;
                default: q <= Q_IDLE;
            endcase
        end
    end

    // Sizes and slot for mm_core, registered: the current layer's during a model run, the host's otherwise
    always_ff @(posedge clk) begin
        if (m_busy) begin
            core_k     <= (layer == '0) ? dim_k : n_of(layer - 1'b1);
            core_n     <= n_of(layer);
            core_layer <= layer;
        end else begin
            core_k     <= dim_k;
            core_n     <= dim_n;
            core_layer <= run_layer;
        end
    end

    assign core_start = start || go;

    assign busy = core_busy || m_busy;
    assign done = (core_done && !m_busy) || m_done;
    assign perf_passes  = m_last ? sum_passes : c_passes;
    assign perf_cycles  = m_last ? sum_cycles : c_cycles;
    assign perf_total   = m_last ? sum_total  : c_total;
    assign model_cycles = mcyc;

    // ================================================================ scale memory
    // Word (layer, w) holds channels w*LANES .. w*LANES+LANES-1 of that layer, one lane each:
    // a 32-bit bias and a 22-bit {shift, m0}. Small: kept in LUTs (distributed RAM), read without a clock.
    function automatic logic [SAW-1:0] s_addr(input logic [LW-1:0] l, input int w);
        if (WPOW2) s_addr = SAW'({l, WW'(w)});
        else       s_addr = SAW'(int'(l) * NWL + w);
    endfunction
    logic           pw_ok;
    logic [SAW-1:0] pw_addr;
    logic [7:0]     pw_lane;
    assign pw_ok   = int'(pw_ch) < TM * P;      // channels past the last one are ignored
    assign pw_addr = s_addr(pw_layer, int'(pw_ch) / LANES);
    assign pw_lane = 8'(int'(pw_ch) % LANES);

    // ================================================================ writeback
    // Token delayed to the clock its C word arrives (RL clocks)
    localparam int TKW = 1 + MW + KW + SW;
    logic           h_v;
    logic [MW-1:0]  h_i;
    logic [KW-1:0]  h_nb;
    logic [SW-1:0]  h_s;
    delay_line #(.WIDTH(TKW), .DEPTH(RL), .RESET(1)) u_tk_h (
        .clk(clk), .rst(rst), .d({tk_v, tk_i, tk_nb, tk_s}), .q({h_v, h_i, h_nb, h_s}));

    // The C word: straight from mm_core for part 0, held for the later parts (LANES < P)
    logic [P*ACC-1:0] src;
    generate
        if (S > 1) begin : g_hold
            logic [P*ACC-1:0] cword;
            always_ff @(posedge clk) if (h_v && h_s == '0) cword <= rd_word;
            assign src = (h_s == '0) ? rd_word : cword;
        end else begin : g_nohold
            assign src = rd_word;
        end
    endgenerate

    // Registers in front of the postproc units: lane values, scale memory outputs, valid
    logic                    pp_v, pp_relu;
    logic signed [ACC-1:0]   pp_acc   [LANES];
    logic signed [31:0]      pp_bias  [LANES];
    logic [15:0]             pp_m0    [LANES];
    logic [5:0]              pp_sh    [LANES];
    logic [LANES-1:0]        pp_ov;
    logic signed [BITS-1:0]  pp_q     [LANES];
    logic [SAW-1:0]          h_addr;
    assign h_addr = s_addr(layer, int'(h_nb) * S + int'(h_s));

    always_ff @(posedge clk) begin
        if (rst) pp_v <= 1'b0;
        else     pp_v <= h_v;
        pp_relu <= relu_q;
    end

    for (genvar g = 0; g < LANES; g++) begin : g_lane
        (* ram_style = "distributed" *) logic [31:0] bias_mem [NSD];
        (* ram_style = "distributed" *) logic [21:0] scl_mem  [NSD];
        // This lane's own copy of the write (step 15b, 22 Oct, timing at 250 MHz): one register per lane,
        // placed next to its LUT RAM, instead of one AXI register driving the write address of every
        // lane's memory. The write lands one clock later; scale writes are dropped while busy and the
        // next AXI write is many clocks away, so nothing reads the word in between. keep: stops
        // synthesis merging the identical copies back into one.
        (* keep = "true" *) logic           lw_en, lw_field;
        (* keep = "true" *) logic [SAW-1:0] lw_addr;
        (* keep = "true" *) logic [31:0]    lw_data;
        always_ff @(posedge clk) begin
            if (rst) lw_en <= 1'b0;
            else     lw_en <= pw_en && pw_ok && pw_lane == 8'(g);
            lw_field <= pw_field;
            lw_addr  <= pw_addr;
            lw_data  <= pw_data;
        end
        always_ff @(posedge clk) begin
            if (lw_en) begin
                if (!lw_field) bias_mem[lw_addr] <= lw_data;
                else           scl_mem[lw_addr]  <= lw_data[21:0];
            end
        end
        // this lane's value: channel h_s*LANES + g of the word (h_s is always 0 when LANES = P)
        logic signed [ACC-1:0] lane_part [S];
        for (genvar s = 0; s < S; s++) begin : g_part
            assign lane_part[s] = src[(s*LANES + g)*ACC +: ACC];
        end
        logic signed [ACC-1:0] lane_val;
        if (S > 1) begin : g_sel
            assign lane_val = lane_part[h_s];
        end else begin : g_one
            assign lane_val = lane_part[0];
        end
        always_ff @(posedge clk) begin
            pp_acc[g]  <= lane_val;
            pp_bias[g] <= bias_mem[h_addr];
            {pp_sh[g], pp_m0[g]} <= scl_mem[h_addr];
        end
        postproc #(.ACC(ACC), .OBITS(BITS), .PPIPE(PPIPE)) u_pp (
            .clk(clk), .rst(rst), .in_valid(pp_v), .in_acc(pp_acc[g]), .in_bias(pp_bias[g]),
            .m0(pp_m0[g]), .shift(pp_sh[g]), .relu(pp_relu), .out_valid(pp_ov[g]), .out_q(pp_q[g]));
    end

    // Token delayed to the clock the postproc results come out (1 + PPD clocks after the C word)
    logic           o_v;
    logic [MW-1:0]  o_i;
    logic [KW-1:0]  o_nb;
    logic [SW-1:0]  o_s;
    delay_line #(.WIDTH(TKW), .DEPTH(1 + PPD), .RESET(1)) u_tk_o (
        .clk(clk), .rst(rst), .d({h_v, h_i, h_nb, h_s}), .q({o_v, o_i, o_nb, o_s}));

    // Assemble the A word and write it (all from registers)
    logic [P*BITS-1:0] asm_word;
    logic              aw_en_q;
    logic [MW-1:0]     aw_i_q;
    logic [KW-1:0]     aw_nb_q;
    always_ff @(posedge clk) begin
        if (o_v)
            for (int s = 0; s < S; s++)
                if (int'(o_s) == s)
                    for (int g = 0; g < LANES; g++) asm_word[(s*LANES + g)*BITS +: BITS] <= pp_q[g];
        if (rst) aw_en_q <= 1'b0;
        else     aw_en_q <= o_v && (int'(o_s) == S - 1);
        aw_i_q  <= o_i;
        aw_nb_q <= o_nb;
    end
    assign aw_en   = aw_en_q;
    assign aw_row  = 8'(aw_i_q);
    assign aw_blk  = 8'(aw_nb_q);
    assign aw_data = asm_word;

`ifndef SYNTHESIS
    // The token and the postproc units must stay in step (simulation only)
    always @(posedge clk)
        if (!rst && pp_ov[0] !== o_v)
            $display("ERROR: mlp_ctrl: postproc output valid (%b) and writeback token (%b) out of step at %0t",
                     pp_ov[0], o_v, $time);
`endif
    wire unused_pp = &{1'b0, pp_ov};
endmodule
