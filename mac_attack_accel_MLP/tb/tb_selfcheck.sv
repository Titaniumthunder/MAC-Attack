`timescale 1ns/1ps
// Self-checking testbench for the matrix core. No Python and no input files needed:
// it makes its own test matrices, works out the correct answer itself, runs the
// hardware, and prints PASS or FAIL for every test in the Tcl console.
//
// In Vivado: set this file as the simulation top and click Run Behavioral Simulation.
// (If the simulation stops after 1 us, type  run all  in the Tcl console.)
//
// Each test checks two things:
//   1. every entry of C equals the expected answer, computed here with plain loops
//   2. the cycle count equals the equation  passes x (M + 3P - 2)
module tb_selfcheck #(
    parameter int P = 16                       // array size: try 4, 8 or 16
);
    localparam int BITS = 8, ACC = 32, MAXD = 64;

    logic clk = 1'b0, rst = 1'b1;
    always #5 clk = ~clk;                      // 100 MHz

    // ---------------------------------------------------------------- the design under test
    logic            wr_en = 1'b0, wr_sel = 1'b0, start = 1'b0;
    logic [7:0]      wr_row = '0, wr_col = '0, dim_m = '0, dim_k = '0, dim_n = '0;
    logic [7:0]      rd_row = '0, rd_col = '0;
    logic [BITS-1:0] wr_data = '0;
    logic            busy, done;
    logic [ACC-1:0]  rd_data;
    logic [31:0]     perf_passes, perf_cycles, perf_total;

    mm_core #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(0), .MAXD(MAXD)) dut (
        .clk(clk), .hclk(clk), .rst(rst),
        .wr_en(wr_en), .wr_sel(wr_sel), .wr_row(wr_row), .wr_col(wr_col), .wr_data(wr_data),
        .start(start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n), .busy(busy), .done(done),
        .rd_row(rd_row), .rd_col(rd_col), .rd_data(rd_data),
        .wr_layer('0), .aw_en(1'b0), .aw_row('0), .aw_blk('0), .aw_data('0), .wb_rd(1'b0), .wb_row('0), .wb_blk('0), .run_layer('0), .rd_word(),   // on-chip MLP ports, not used here
        .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total));

    // ---------------------------------------------------------------- signals to watch in the waveform
    int          test_number = 0;
    logic        array_loading_weights, array_streaming_inputs, array_output_ready;
    int          pass_number, cycle_in_pass, reduction_block, output_block;
    logic [31:0] c_lane0;
    assign array_loading_weights  = dut.w_load;
    assign array_streaming_inputs = dut.in_valid;
    assign array_output_ready     = dut.out_valid;
    assign pass_number            = perf_passes;
    assign cycle_in_pass          = dut.o;
    assign reduction_block        = dut.kb;
    assign output_block           = dut.nb;
    assign c_lane0                = dut.c_row[31:0];

    // ---------------------------------------------------------------- test data
    int     A [MAXD][MAXD];
    int     B [MAXD][MAXD];
    longint Cexp [MAXD][MAXD];
    longint Chw  [MAXD][MAXD];
    int unsigned seed = 32'h2468ACE1;

    // xorshift random numbers: same sequence in every simulator
    function automatic int next_rand();
        seed = seed ^ (seed << 13);
        seed = seed ^ (seed >> 17);
        seed = seed ^ (seed << 5);
        return int'(seed & 32'h7FFF_FFFF);
    endfunction

    localparam int RANDOM = 0, SMALL = 1, MINV = 2, MAXV = 3, IDENT = 4;

    task automatic make_data(input int kind, input int M, input int K, input int N);
        for (int i = 0; i < M; i++)
            for (int k = 0; k < K; k++)
                case (kind)
                    SMALL:   A[i][k] = next_rand() % 19 - 9;          // -9 .. 9, easy to check by hand
                    MINV:    A[i][k] = -128;
                    MAXV:    A[i][k] = 127;
                    default: A[i][k] = next_rand() % 256 - 128;       // any INT8 value
                endcase
        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++)
                case (kind)
                    SMALL:   B[k][j] = next_rand() % 19 - 9;
                    MINV:    B[k][j] = -128;
                    MAXV:    B[k][j] = 127;
                    IDENT:   B[k][j] = (k == j) ? 1 : 0;
                    default: B[k][j] = next_rand() % 256 - 128;
                endcase
        // the expected answer, computed the plain way
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                Cexp[i][j] = 0;
                for (int k = 0; k < K; k++) Cexp[i][j] += longint'(A[i][k]) * longint'(B[k][j]);
            end
    endtask

    // ---------------------------------------------------------------- driving the hardware
    task automatic load_and_run(input int M, input int K, input int N);
        for (int i = 0; i < M; i++)
            for (int k = 0; k < K; k++) begin
                @(negedge clk);
                wr_en = 1'b1; wr_sel = 1'b0; wr_row = 8'(i); wr_col = 8'(k); wr_data = 8'(A[i][k]);
            end
        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                wr_en = 1'b1; wr_sel = 1'b1; wr_row = 8'(k); wr_col = 8'(j); wr_data = 8'(B[k][j]);
            end
        @(negedge clk);
        wr_en = 1'b0;
        dim_m = 8'(M); dim_k = 8'(K); dim_n = 8'(N);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
        wait (done);
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                rd_row = 8'(i); rd_col = 8'(j);
                @(negedge clk);
                Chw[i][j] = longint'($signed(rd_data));
            end
    endtask

    task automatic show(input string name, input int which, input int R, input int C);
        $display("  %s", name);
        for (int i = 0; i < R; i++) begin
            $write("    ");
            for (int j = 0; j < C; j++)
                case (which)
                    0: $write("%6d", A[i][j]);
                    1: $write("%6d", B[i][j]);
                    2: $write("%6d", Chw[i][j]);
                    default: $write("%6d", Cexp[i][j]);
                endcase
            $display("");
        end
    endtask

    int tests_run = 0, tests_passed = 0;

    task automatic run_test(input string title, input int kind, input int M, input int K, input int N,
                            input bit print_matrices);
        int correct, passes_eq, cycles_eq;
        bit ok;
        test_number++;
        $display("");
        $display("Test %0d: %0dx%0d times %0dx%0d, %s", test_number, M, K, K, N, title);
        make_data(kind, M, K, N);
        load_and_run(M, K, N);
        correct = 0;
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++)
                if (Chw[i][j] == Cexp[i][j]) correct++;
        passes_eq = ((K + P - 1) / P) * ((N + P - 1) / P);
        cycles_eq = passes_eq * (M + 3 * P - 2);
        if (print_matrices) begin
            show("A =", 0, M, K);
            show("B =", 1, K, N);
            show("C from the hardware =", 2, M, N);
            show("C expected =", 3, M, N);
        end
        $display("  %s  %0d/%0d results correct", (correct == M * N) ? "PASS" : "FAIL", correct, M * N);
        $display("  %s  passes = %0d  (equation: ceil(%0d/%0d) x ceil(%0d/%0d) = %0d)",
                 (perf_passes == passes_eq) ? "PASS" : "FAIL", perf_passes, K, P, N, P, passes_eq);
        $display("  %s  cycles = %0d  (equation: passes x (M + 3P - 2) = %0d x %0d = %0d)",
                 (perf_cycles == cycles_eq) ? "PASS" : "FAIL", perf_cycles, passes_eq,
                 M + 3 * P - 2, cycles_eq);
        $display("        %0d multiply-adds; the %0d PEs were busy %0.1f%% of the time",
                 M * N * K, P * P, 100.0 * real'(M * N * K) / real'(P * P * perf_cycles));
        ok = (correct == M * N) && (perf_passes == passes_eq) && (perf_cycles == cycles_eq);
        tests_run++;
        if (ok) tests_passed++;
    endtask

    // ---------------------------------------------------------------- the tests
    initial begin
        repeat (3) @(negedge clk);
        rst = 1'b0;
        $display("");
        $display("==================================================================");
        $display(" MAC Attack accelerator: %0dx%0d systolic array (%0d PEs), INT8 inputs,", P, P, P * P);
        $display(" 32-bit accumulators. Every answer is checked against plain loops.");
        $display("==================================================================");
        run_test("small numbers (check by hand)",          SMALL,  4,  4,  4, 1'b1);
        run_test("random INT8, one tile",                  RANDOM, 16, 16, 16, 1'b0);
        run_test("random INT8, folded over 16 tiles",      RANDOM, 64, 64, 64, 1'b0);
        run_test("random INT8, odd sizes (edge tiles)",    RANDOM, 37, 50, 23, 1'b0);
        run_test("one row of A (M = 1)",                   RANDOM,  1, 64, 64, 1'b0);
        run_test("every input -128 (largest products)",    MINV,   16, 16, 16, 1'b0);
        run_test("every input 127",                        MAXV,   16, 16, 16, 1'b0);
        run_test("B = identity, so C must equal A",        IDENT,  16, 16, 16, 1'b0);
        $display("");
        $display("==================================================================");
        if (tests_passed == tests_run)
            $display(" ALL TESTS PASSED (%0d/%0d)", tests_passed, tests_run);
        else
            $display(" FAILED: %0d of %0d tests passed", tests_passed, tests_run);
        $display("==================================================================");
        $finish;
    end

    initial begin                               // safety net: never hang forever
        #50ms;
        $display("ERROR: timeout");
        $finish;
    end
endmodule
