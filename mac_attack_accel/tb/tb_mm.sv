`timescale 1ns/1ps
// Testbench for mm_core, driven by files so that mac.py can run it.
//
// Reads (from the run directory):  A.hex  M*K values, row-major, one per line
//                                  B.hex  K*N values, row-major, one per line
// Plusargs:                        +M=<m> +K=<k> +N=<n>
// Writes:                          C.hex      M*N results, row-major, one per line
//                                  stats.txt  "passes cycles total"
// Parameters (set at elaboration): P, BITS, ACC, SAT, MAXD
module tb_mm #(
    parameter int P    = 16,
    parameter int BITS = 8,
    parameter int ACC  = 32,
    parameter int SAT  = 0,
    parameter int MAXD = 64
);

    logic clk = 1'b0;
    logic rst = 1'b1;
    always #5 clk = ~clk;                      // 100 MHz

    logic            wr_en = 1'b0, wr_sel = 1'b0, start = 1'b0;
    logic [7:0]      wr_row = '0, wr_col = '0, dim_m = '0, dim_k = '0, dim_n = '0;
    logic [7:0]      rd_row = '0, rd_col = '0;
    logic [BITS-1:0] wr_data = '0;
    logic            busy, done;
    logic [ACC-1:0]  rd_data;
    logic [31:0]     perf_passes, perf_cycles, perf_total;

    mm_core #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT), .MAXD(MAXD)) dut (
        .clk(clk), .hclk(clk), .rst(rst),
        .wr_en(wr_en), .wr_sel(wr_sel), .wr_row(wr_row), .wr_col(wr_col), .wr_data(wr_data),
        .start(start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n), .busy(busy), .done(done),
        .rd_row(rd_row), .rd_col(rd_col), .rd_data(rd_data),
        .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total));

    logic [BITS-1:0] am [MAXD*MAXD];
    logic [BITS-1:0] bm [MAXD*MAXD];
    int M, K, N, fd, timeout;

    initial begin
        if (!$value$plusargs("M=%d", M)) M = 4;
        if (!$value$plusargs("K=%d", K)) K = 4;
        if (!$value$plusargs("N=%d", N)) N = 4;
        if (M < 1 || K < 1 || N < 1 || M > MAXD || K > MAXD || N > MAXD) begin
            $display("ERROR: M, K and N must be between 1 and %0d", MAXD);
            $finish;
        end
        $readmemh("A.hex", am, 0, M * K - 1);
        $readmemh("B.hex", bm, 0, K * N - 1);

        repeat (3) @(negedge clk);
        rst = 1'b0;

        // load A and B through the load port, one element per cycle
        for (int i = 0; i < M; i++)
            for (int j = 0; j < K; j++) begin
                @(negedge clk);
                wr_en = 1'b1; wr_sel = 1'b0; wr_row = 8'(i); wr_col = 8'(j); wr_data = am[i*K + j];
            end
        for (int i = 0; i < K; i++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                wr_en = 1'b1; wr_sel = 1'b1; wr_row = 8'(i); wr_col = 8'(j); wr_data = bm[i*N + j];
            end
        @(negedge clk);
        wr_en = 1'b0;

        // run
        dim_m = 8'(M); dim_k = 8'(K); dim_n = 8'(N);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
        timeout = 0;
        while (!done && timeout < 10000000) begin
            @(posedge clk);
            timeout++;
        end
        if (!done) begin
            $display("ERROR: timeout, the core never finished");
            $finish;
        end

        // read C back, one element per cycle (one cycle of read latency)
        fd = $fopen("C.hex", "w");
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                rd_row = 8'(i); rd_col = 8'(j);
                @(negedge clk);
                $fdisplay(fd, "%h", rd_data);
            end
        $fclose(fd);
        fd = $fopen("stats.txt", "w");
        $fdisplay(fd, "%0d %0d %0d", perf_passes, perf_cycles, perf_total);
        $fclose(fd);
        $display("TB_DONE passes=%0d cycles=%0d total=%0d", perf_passes, perf_cycles, perf_total);
        $finish;
    end
endmodule
