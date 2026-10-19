`timescale 1ns/1ps
// Same matrix multiply on three array sizes (4x4, 8x8, 16x16), side by side.
// This is the trade-off the project studies: more PEs finish sooner, but each pass
// also spends 3P - 2 cycles loading weights, filling and draining.
//
// In Vivado: set this file as the simulation top and click Run Behavioral Simulation.
module tb_compare #(
    parameter int M = 64,
    parameter int K = 64,
    parameter int N = 64
);
    localparam int NS = 3, BITS = 8, ACC = 32, MAXD = 64;

    logic clk = 1'b0, rst = 1'b1;
    always #5 clk = ~clk;

    // one set of control signals per core
    logic            wr_en [NS], wr_sel [NS], start [NS], busy [NS], done [NS];
    logic [7:0]      wr_row [NS], wr_col [NS], rd_row [NS], rd_col [NS];
    logic [7:0]      dim_m [NS], dim_k [NS], dim_n [NS];
    logic [BITS-1:0] wr_data [NS];
    logic [ACC-1:0]  rd_data [NS];
    logic [31:0]     perf_passes [NS], perf_cycles [NS], perf_total [NS];

    function automatic int psize(input int c);
        return (c == 0) ? 4 : (c == 1) ? 8 : 16;
    endfunction

    for (genvar g = 0; g < NS; g++) begin : g_core
        localparam int PG = (g == 0) ? 4 : (g == 1) ? 8 : 16;
        mm_core #(.P(PG), .BITS(BITS), .ACC(ACC), .SAT(0), .MAXD(MAXD)) u_core (
            .clk(clk), .rst(rst),
            .wr_en(wr_en[g]), .wr_sel(wr_sel[g]), .wr_row(wr_row[g]), .wr_col(wr_col[g]), .wr_data(wr_data[g]),
            .start(start[g]), .dim_m(dim_m[g]), .dim_k(dim_k[g]), .dim_n(dim_n[g]),
            .busy(busy[g]), .done(done[g]),
            .rd_row(rd_row[g]), .rd_col(rd_col[g]), .rd_data(rd_data[g]),
            .perf_passes(perf_passes[g]), .perf_cycles(perf_cycles[g]), .perf_total(perf_total[g]));
    end

    int     A [MAXD][MAXD];
    int     B [MAXD][MAXD];
    longint Cexp [MAXD][MAXD];
    int unsigned seed = 32'h1357_9BDF;

    function automatic int next_rand();
        seed = seed ^ (seed << 13);
        seed = seed ^ (seed >> 17);
        seed = seed ^ (seed << 5);
        return int'(seed & 32'h7FFF_FFFF);
    endfunction

    // load A and B into core c, run it, and count correct results
    task automatic run_core(input int c, output int correct);
        for (int i = 0; i < M; i++)
            for (int k = 0; k < K; k++) begin
                @(negedge clk);
                wr_en[c] = 1'b1; wr_sel[c] = 1'b0; wr_row[c] = 8'(i); wr_col[c] = 8'(k); wr_data[c] = 8'(A[i][k]);
            end
        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                wr_en[c] = 1'b1; wr_sel[c] = 1'b1; wr_row[c] = 8'(k); wr_col[c] = 8'(j); wr_data[c] = 8'(B[k][j]);
            end
        @(negedge clk);
        wr_en[c] = 1'b0;
        dim_m[c] = 8'(M); dim_k[c] = 8'(K); dim_n[c] = 8'(N);
        start[c] = 1'b1;
        @(negedge clk);
        start[c] = 1'b0;
        wait (done[c]);
        correct = 0;
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                rd_row[c] = 8'(i); rd_col[c] = 8'(j);
                @(negedge clk);
                if (longint'($signed(rd_data[c])) == Cexp[i][j]) correct++;
            end
    endtask

    initial begin
        int correct, p, eqp, eqc, all_ok;
        real base;
        for (int c = 0; c < NS; c++) begin
            wr_en[c] = 1'b0; wr_sel[c] = 1'b0; start[c] = 1'b0; wr_row[c] = '0; wr_col[c] = '0;
            rd_row[c] = '0; rd_col[c] = '0; dim_m[c] = '0; dim_k[c] = '0; dim_n[c] = '0; wr_data[c] = '0;
        end
        for (int i = 0; i < M; i++) for (int k = 0; k < K; k++) A[i][k] = next_rand() % 256 - 128;
        for (int k = 0; k < K; k++) for (int j = 0; j < N; j++) B[k][j] = next_rand() % 256 - 128;
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                Cexp[i][j] = 0;
                for (int k = 0; k < K; k++) Cexp[i][j] += longint'(A[i][k]) * longint'(B[k][j]);
            end
        repeat (3) @(negedge clk);
        rst = 1'b0;

        $display("");
        $display("Same %0dx%0d times %0dx%0d multiply (random INT8) on three array sizes", M, K, K, N);
        $display("");
        $display("  %7s  %5s  %6s  %7s  %8s  %-14s  %7s  %7s",
                 "array", "PEs", "passes", "cycles", "equation", "results", "busy", "speedup");
        all_ok = 1;
        for (int c = 0; c < NS; c++) begin
            run_core(c, correct);
            p   = psize(c);
            eqp = ((K + p - 1) / p) * ((N + p - 1) / p);
            eqc = eqp * (M + 3 * p - 2);
            if (c == 0) base = real'(perf_cycles[0]);
            if (correct != M * N || perf_cycles[c] != eqc) all_ok = 0;
            $display("  %3dx%-3d  %5d  %6d  %7d  %8d  %4d/%-4d %s  %6.1f%%  %6.1fx",
                     p, p, p * p, perf_passes[c], perf_cycles[c], eqc, correct, M * N,
                     (correct == M * N && perf_cycles[c] == eqc) ? "PASS" : "FAIL",
                     100.0 * real'(M * K * N) / real'(p * p * perf_cycles[c]),
                     base / real'(perf_cycles[c]));
        end
        $display("");
        $display("  More PEs finish in fewer cycles, but every pass also spends 3P - 2 cycles");
        $display("  loading weights, filling and draining. So the speedup is smaller than the");
        $display("  increase in PEs, and the PEs are busy a smaller share of the time.");
        $display("");
        if (all_ok) $display(" ALL SIZES PASSED");
        else        $display(" SOME SIZES FAILED");
        $finish;
    end
endmodule
