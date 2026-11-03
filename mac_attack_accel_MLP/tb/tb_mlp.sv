`timescale 1ns/1ps
// Testbench for mlp_ctrl (the on-chip MLP), driven by files so that mac.py can check every
// number against its Python model (golden_mlp).
//
// Reads (from the run directory):
//   W<l>.hex     layer l's weights, K_l x N_l values, row-major (l = 0 .. L-1)
//   Bias<l>.hex  layer l's biases, N_l values (32-bit)
//   Scl<l>.hex   layer l's {shift, m0}, N_l values (22-bit: shift in bits 21:16, m0 in 15:0)
//   X<r>.hex     the input rows for run r, M x K0 values, row-major (r = 0 .. RUNS-1)
// Plusargs: +M=<rows> +K0=<inputs> +L=<layers> +N0= +N1= +N2= +N3= (outputs of each layer)
//           +RELU=<bit l = ReLU after layer l> +RUNS=<model runs with the same weights>
// Writes, for every run r:
//   C<r>.hex      the last layer's raw sums, M x N_(L-1), row-major (read through the result port)
//   A<r>.hex      what the A buffer holds at the end: the last layer's input (L >= 2),
//                 M x K_(L-1) values, read straight out of the buffer
//   stats<r>.txt  "passes cycles total model_cycles"
// Weights and scales are loaded once, then the model runs RUNS times, each time with new inputs:
// the weights must stay in their slots.
module tb_mlp #(
    parameter int P         = 8,
    parameter int BITS      = 8,
    parameter int ACC       = 22,
    parameter int MAXD      = 64,
    parameter int PIPE      = 2,
    parameter int MEM_REG   = 2,
    parameter int PE_PRIM   = 0,
    parameter int HREAD_REG = 1,
    parameter int NL        = 4,
    parameter int PPL       = 0,
    parameter int PPIPE     = 2,
    parameter int SRAM      = 0      // 1 = the ASIC buffers (SRAM macro models)
);
    localparam int LW = (NL > 1) ? $clog2(NL) : 1;
    localparam int TM = (MAXD + P - 1) / P;

    logic clk = 1'b0;
    logic rst = 1'b1;
    always #2 clk = ~clk;                      // 250 MHz

    logic            wr_en = 1'b0, wr_sel = 1'b0, start = 1'b0, model_start = 1'b0;
    logic [LW-1:0]   wr_layer = '0, run_layer = '0, last_layer = '0, pw_layer = '0;
    logic [7:0]      wr_row = '0, wr_col = '0, dim_m = '0, dim_k = '0, dim_n = '0;
    logic [7:0]      rd_row = '0, rd_col = '0, pw_ch = '0;
    logic [BITS-1:0] wr_data = '0;
    logic            pw_en = 1'b0, pw_field = 1'b0;
    logic [31:0]     pw_data = '0;
    logic [8*NL-1:0] layer_n = '0;
    logic [NL-1:0]   layer_relu = '0;
    logic            busy, done;
    logic [ACC-1:0]  rd_data;
    logic [31:0]     perf_passes, perf_cycles, perf_total, model_cycles;

    mlp_ctrl #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(0), .MAXD(MAXD), .PIPE(PIPE), .MEM_REG(MEM_REG),
               .PE_PRIM(PE_PRIM), .HREAD_REG(HREAD_REG), .NL(NL), .PPL(PPL), .PPIPE(PPIPE), .SRAM(SRAM)) dut (
        .clk(clk), .rst(rst),
        .wr_en(wr_en), .wr_sel(wr_sel), .wr_layer(wr_layer), .wr_row(wr_row), .wr_col(wr_col), .wr_data(wr_data),
        .pw_en(pw_en), .pw_field(pw_field), .pw_layer(pw_layer), .pw_ch(pw_ch), .pw_data(pw_data),
        .start(start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n), .run_layer(run_layer),
        .model_start(model_start), .last_layer(last_layer), .layer_n(layer_n), .layer_relu(layer_relu),
        .busy(busy), .done(done),
        .rd_row(rd_row), .rd_col(rd_col), .rd_data(rd_data),
        .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total),
        .model_cycles(model_cycles));

    logic [BITS-1:0] wm [MAXD*MAXD];
    logic [31:0]     bm [MAXD];
    logic [21:0]     sm [MAXD];
    logic [BITS-1:0] xm [MAXD*MAXD];
    int M, K0, L, RUNS, RELU, N0, N1, N2, N3, NN [4], KK [4], fd, timeout;
    string fn;

    // A[i][k] straight out of mm_core's A buffer (word (i, k/P), lane k mod P)
    generate
        if (SRAM != 0) begin : g_abuf
            // the A buffer is in the SRAM macros (sram_buf.sv): a view of their arrays, word by word
            localparam int COLS = (P * BITS + 31) / 32;
            localparam int ROWS = (MAXD * TM + 511) / 512;
            wire [COLS*32-1:0] view [ROWS*512];
            for (genvar r = 0; r < ROWS; r++) begin : g_r
                for (genvar c = 0; c < COLS; c++) begin : g_c
                    for (genvar w = 0; w < 512; w++) begin : g_w
                        assign view[r*512 + w][c*32 +: 32] = dut.u_core.g_absram.u_amem.g_row[r].g_col[c].u_mem.mem[w];
                    end
                end
            end
            function automatic logic [P*BITS-1:0] word(input int a);
                return view[a][P*BITS-1:0];
            endfunction
        end else begin : g_abuf
            function automatic logic [P*BITS-1:0] word(input int a);
                return dut.u_core.amem[a];
            endfunction
        end
    endgenerate
    function automatic logic [BITS-1:0] a_buf(input int i, input int k);
        logic [P*BITS-1:0] w;
        w = g_abuf.word(i * TM + k / P);
        return w[(k % P) * BITS +: BITS];
    endfunction

    initial begin
        if (!$value$plusargs("M=%d", M)) M = 4;
        if (!$value$plusargs("K0=%d", K0)) K0 = 8;
        if (!$value$plusargs("L=%d", L)) L = 2;
        if (!$value$plusargs("N0=%d", N0)) N0 = 8;
        if (!$value$plusargs("N1=%d", N1)) N1 = 8;
        if (!$value$plusargs("N2=%d", N2)) N2 = 8;
        if (!$value$plusargs("N3=%d", N3)) N3 = 8;
        NN[0] = N0; NN[1] = N1; NN[2] = N2; NN[3] = N3;
        if (!$value$plusargs("RELU=%d", RELU)) RELU = 0;
        if (!$value$plusargs("RUNS=%d", RUNS)) RUNS = 1;
        if (L < 1 || L > NL || L > 4 || M < 1 || M > MAXD || K0 < 1 || K0 > MAXD) begin
            $display("ERROR: bad sizes (L %0d, M %0d, K0 %0d)", L, M, K0);
            $finish;
        end
        for (int l = 0; l < L; l++) begin
            KK[l] = (l == 0) ? K0 : NN[l-1];
            if (NN[l] < 1 || NN[l] > MAXD) begin
                $display("ERROR: N%0d = %0d", l, NN[l]);
                $finish;
            end
        end

        repeat (3) @(negedge clk);
        rst = 1'b0;

        // every layer's weights into its slot, through the load port, one element per clock
        for (int l = 0; l < L; l++) begin
            $sformat(fn, "W%0d.hex", l);
            $readmemh(fn, wm, 0, KK[l] * NN[l] - 1);
            for (int i = 0; i < KK[l]; i++)
                for (int j = 0; j < NN[l]; j++) begin
                    @(negedge clk);
                    wr_en = 1'b1; wr_sel = 1'b1; wr_layer = LW'(l); wr_row = 8'(i); wr_col = 8'(j);
                    wr_data = wm[i * NN[l] + j];
                end
        end
        @(negedge clk);
        wr_en = 1'b0;
        // every layer's bias and {shift, m0} into the scale memory
        for (int l = 0; l < L; l++) begin
            $sformat(fn, "Bias%0d.hex", l);
            $readmemh(fn, bm, 0, NN[l] - 1);
            $sformat(fn, "Scl%0d.hex", l);
            $readmemh(fn, sm, 0, NN[l] - 1);
            for (int c = 0; c < NN[l]; c++) begin
                @(negedge clk);
                pw_en = 1'b1; pw_field = 1'b0; pw_layer = LW'(l); pw_ch = 8'(c); pw_data = bm[c];
                @(negedge clk);
                pw_en = 1'b1; pw_field = 1'b1; pw_layer = LW'(l); pw_ch = 8'(c); pw_data = {10'd0, sm[c]};
            end
        end
        @(negedge clk);
        pw_en = 1'b0;

        // the layer table
        last_layer = LW'(L - 1);
        for (int l = 0; l < NL && l < 4; l++) layer_n[8*l +: 8] = 8'(NN[l]);
        layer_relu = NL'(RELU);

        for (int r = 0; r < RUNS; r++) begin
            // this run's inputs into A
            $sformat(fn, "X%0d.hex", r);
            $readmemh(fn, xm, 0, M * K0 - 1);
            for (int i = 0; i < M; i++)
                for (int k = 0; k < K0; k++) begin
                    @(negedge clk);
                    wr_en = 1'b1; wr_sel = 1'b0; wr_row = 8'(i); wr_col = 8'(k); wr_data = xm[i * K0 + k];
                end
            @(negedge clk);
            wr_en = 1'b0;
            dim_m = 8'(M); dim_k = 8'(K0); dim_n = 8'(NN[0]);
            repeat (2) @(negedge clk);
            model_start = 1'b1;
            @(negedge clk);
            model_start = 1'b0;
            timeout = 0;
            while (!done && timeout < 10000000) begin
                @(posedge clk);
                timeout++;
            end
            if (!done) begin
                $display("ERROR: timeout, the model never finished");
                $finish;
            end
            @(negedge clk);
            if (busy) $display("ERROR: busy after done");

            // the last layer's raw sums, through the result port (1 + HREAD_REG clocks of latency)
            $sformat(fn, "C%0d.hex", r);
            fd = $fopen(fn, "w");
            for (int i = 0; i < M; i++)
                for (int j = 0; j < NN[L-1]; j++) begin
                    @(negedge clk);
                    rd_row = 8'(i); rd_col = 8'(j);
                    // taken at the clock edge, as the hardware would (with SRAM = 1 and HREAD_REG = 0
                    // rd_data comes straight from the macro, ready only after the falling edge)
                    repeat (2 + HREAD_REG) @(posedge clk);
                    $fdisplay(fd, "%h", rd_data);
                end
            $fclose(fd);
            // the last layer's input, out of the A buffer
            $sformat(fn, "A%0d.hex", r);
            fd = $fopen(fn, "w");
            for (int i = 0; i < M; i++)
                for (int k = 0; k < KK[L-1]; k++) $fdisplay(fd, "%h", a_buf(i, k));
            $fclose(fd);
            $sformat(fn, "stats%0d.txt", r);
            fd = $fopen(fn, "w");
            $fdisplay(fd, "%0d %0d %0d %0d", perf_passes, perf_cycles, perf_total, model_cycles);
            $fclose(fd);
        end
        $display("TB_DONE runs=%0d model_cycles=%0d", RUNS, model_cycles);
        $finish;
    end
endmodule
