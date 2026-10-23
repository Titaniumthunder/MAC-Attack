`timescale 1ns/1ps
// The other chip blocks we have started, each checked on its own:
//   Part 1  saturating accumulators versus wrapping ones (16-bit accumulators)
//   Part 2  post-processing unit: bias + requantize + ReLU
//   Part 3  the whole chip driven over a serial line, the way a laptop would talk to it
//
// In Vivado: set this file as the simulation top and click Run Behavioral Simulation.
module tb_extras;
    localparam int MAXD = 64;

    logic clk = 1'b0, rst = 1'b1;
    always #5 clk = ~clk;

    int unsigned seed = 32'h0BAD_5EED;
    function automatic int next_rand();
        seed = seed ^ (seed << 13);
        seed = seed ^ (seed >> 17);
        seed = seed ^ (seed << 5);
        return int'(seed & 32'h7FFF_FFFF);
    endfunction

    int     A [MAXD][MAXD];
    int     B [MAXD][MAXD];
    longint Ctrue [MAXD][MAXD];

    int fails = 0;

    // =====================================================================================
    // Part 1: two 4x4 cores with 16-bit accumulators. Core 0 wraps, core 1 saturates.
    // =====================================================================================
    localparam int SP = 4, SACC = 16;
    logic            s_wr_en [2], s_wr_sel [2], s_start [2], s_busy [2], s_done [2];
    logic [7:0]      s_wr_row [2], s_wr_col [2], s_rd_row [2], s_rd_col [2], s_m [2], s_k [2], s_n [2];
    logic [7:0]      s_wr_data [2];
    logic [SACC-1:0] s_rd_data [2];
    logic [31:0]     s_passes [2], s_cycles [2], s_total [2];

    for (genvar g = 0; g < 2; g++) begin : g_sat
        mm_core #(.P(SP), .BITS(8), .ACC(SACC), .SAT(g), .MAXD(MAXD)) u_core (
            .clk(clk), .hclk(clk), .rst(rst),
            .wr_en(s_wr_en[g]), .wr_sel(s_wr_sel[g]), .wr_row(s_wr_row[g]), .wr_col(s_wr_col[g]),
            .wr_data(s_wr_data[g]), .start(s_start[g]), .dim_m(s_m[g]), .dim_k(s_k[g]), .dim_n(s_n[g]),
            .busy(s_busy[g]), .done(s_done[g]), .rd_row(s_rd_row[g]), .rd_col(s_rd_col[g]),
            .rd_data(s_rd_data[g]), .wr_layer('0), .aw_en(1'b0), .aw_row('0), .aw_blk('0), .aw_data('0), .wb_rd(1'b0), .wb_row('0), .wb_blk('0), .run_layer('0), .rd_word(),   // on-chip MLP ports, not used here
            .perf_passes(s_passes[g]), .perf_cycles(s_cycles[g]), .perf_total(s_total[g]));
    end

    longint Chw [2][MAXD][MAXD];                 // hardware results of core 0 and core 1
    longint Cmodel [2][MAXD][MAXD];              // what each core should produce

    function automatic longint wrap16(input longint x);
        return longint'($signed(x[15:0]));
    endfunction
    function automatic longint clamp16(input longint x);
        return (x > 32767) ? 32767 : (x < -32768) ? -32768 : x;
    endfunction

    // Expected results: wrapping = exact answer modulo 2^16. Saturating = clamp after every
    // addition, in the hardware's order: down each column of a tile, then across tiles.
    task automatic sat_models(input int M, input int K, input int N);
        longint s, c;
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                Ctrue[i][j] = 0;
                for (int k = 0; k < K; k++) Ctrue[i][j] += longint'(A[i][k]) * longint'(B[k][j]);
                Cmodel[0][i][j] = wrap16(Ctrue[i][j]);
                c = 0;
                for (int kb = 0; kb < (K + SP - 1) / SP; kb++) begin
                    s = 0;
                    for (int k = kb * SP; k < kb * SP + SP && k < K; k++)
                        s = clamp16(s + longint'(A[i][k]) * longint'(B[k][j]));
                    c = (kb == 0) ? s : clamp16(c + s);
                end
                Cmodel[1][i][j] = c;
            end
    endtask

    task automatic sat_run(input int c, input int M, input int K, input int N);
        for (int i = 0; i < M; i++)
            for (int k = 0; k < K; k++) begin
                @(negedge clk);
                s_wr_en[c] = 1'b1; s_wr_sel[c] = 1'b0; s_wr_row[c] = 8'(i); s_wr_col[c] = 8'(k); s_wr_data[c] = 8'(A[i][k]);
            end
        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                s_wr_en[c] = 1'b1; s_wr_sel[c] = 1'b1; s_wr_row[c] = 8'(k); s_wr_col[c] = 8'(j); s_wr_data[c] = 8'(B[k][j]);
            end
        @(negedge clk);
        s_wr_en[c] = 1'b0; s_m[c] = 8'(M); s_k[c] = 8'(K); s_n[c] = 8'(N); s_start[c] = 1'b1;
        @(negedge clk);
        s_start[c] = 1'b0;
        wait (s_done[c]);
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                @(negedge clk);
                s_rd_row[c] = 8'(i); s_rd_col[c] = 8'(j);
                @(negedge clk);
                Chw[c][i][j] = longint'($signed(s_rd_data[c]));
            end
    endtask

    task automatic part1();
        int match0, match1, over, wrong0, wrong1, hidden;
        longint worst0, worst1, d;
        $display("");
        $display("==================================================================");
        $display(" Part 1: overflow versus saturation (4x4 array, INT8, 16-bit accumulators)");
        $display("==================================================================");
        for (int i = 0; i < 4; i++) for (int k = 0; k < 8; k++) A[i][k] = -128;
        for (int k = 0; k < 8; k++) for (int j = 0; j < 4; j++) B[k][j] = -128;
        sat_models(4, 8, 4);
        sat_run(0, 4, 8, 4);
        sat_run(1, 4, 8, 4);
        $display("  Every input is -128 and K = 8, so each output is 8 x 16,384 = %0d", Ctrue[0][0]);
        $display("  True answer (no limit)              %7d", Ctrue[0][0]);
        $display("  Hardware, wrapping accumulators     %7d   %s", Chw[0][0][0],
                 (Chw[0][0][0] == Cmodel[0][0][0]) ? "(as expected)" : "MISMATCH");
        $display("  Hardware, saturating accumulators   %7d   %s", Chw[1][0][0],
                 (Chw[1][0][0] == Cmodel[1][0][0]) ? "(as expected)" : "MISMATCH");
        $display("  Wrapping turns 131,072 into 0. Saturating stops at the largest 16-bit value:");
        $display("  still wrong, but by the least possible amount, and the sign never flips.");

        for (int i = 0; i < 32; i++) for (int k = 0; k < 32; k++) A[i][k] = next_rand() % 256 - 128;
        for (int k = 0; k < 32; k++) for (int j = 0; j < 32; j++) B[k][j] = next_rand() % 256 - 128;
        sat_models(32, 32, 32);
        sat_run(0, 32, 32, 32);
        sat_run(1, 32, 32, 32);
        match0 = 0; match1 = 0; over = 0; wrong0 = 0; wrong1 = 0; hidden = 0; worst0 = 0; worst1 = 0;
        for (int i = 0; i < 32; i++)
            for (int j = 0; j < 32; j++) begin
                if (Chw[0][i][j] == Cmodel[0][i][j]) match0++;
                if (Chw[1][i][j] == Cmodel[1][i][j]) match1++;
                if (Ctrue[i][j] > 32767 || Ctrue[i][j] < -32768) over++;
                if (Chw[0][i][j] != Ctrue[i][j]) wrong0++;
                if (Chw[1][i][j] != Ctrue[i][j]) begin
                    wrong1++;
                    if (Ctrue[i][j] <= 32767 && Ctrue[i][j] >= -32768) hidden++;
                end
                d = Chw[0][i][j] - Ctrue[i][j]; if (d < 0) d = -d; if (d > worst0) worst0 = d;
                d = Chw[1][i][j] - Ctrue[i][j]; if (d < 0) d = -d; if (d > worst1) worst1 = d;
            end
        $display("");
        $display("  Random 32x32 times 32x32: %0d of 1024 true answers do not fit in 16 bits.", over);
        $display("    wrapping:   %0d wrong, worst error %0d", wrong0, worst0);
        $display("    saturating: %0d wrong, worst error %0d", wrong1, worst1);
        $display("  Saturation also broke %0d results whose final value fits in 16 bits: a partial", hidden);
        $display("  sum overflowed on the way and was clamped. Wrapping gets those right because the");
        $display("  overflows cancel out. So saturation bounds the error but depends on the order.");
        $display("  %s  wrapping hardware matches its model (%0d/1024)", (match0 == 1024) ? "PASS" : "FAIL", match0);
        $display("  %s  saturating hardware matches its model (%0d/1024)", (match1 == 1024) ? "PASS" : "FAIL", match1);
        if (match0 != 1024 || match1 != 1024 || Chw[0][0][0] != Cmodel[0][0][0]) fails++;
    endtask

    // =====================================================================================
    // Part 2: post-processing unit
    // =====================================================================================
    logic               pp_in_valid = 1'b0, pp_relu = 1'b0, pp_out_valid;
    logic signed [31:0] pp_acc = '0, pp_bias = '0;
    logic [15:0]        pp_m0 = 16'd16384;
    logic [5:0]         pp_shift = 6'd22;
    logic signed [7:0]  pp_out;

    postproc #(.ACC(32), .OBITS(8)) u_pp (
        .clk(clk), .rst(rst), .in_valid(pp_in_valid), .in_acc(pp_acc), .in_bias(pp_bias),
        .m0(pp_m0), .shift(pp_shift), .relu(pp_relu), .out_valid(pp_out_valid), .out_q(pp_out));

    localparam int NPP = 400;
    longint pp_a [NPP], pp_b [NPP];
    int     pp_got [NPP];
    int     pp_n = 0;
    always @(posedge clk) if (pp_out_valid) begin pp_got[pp_n] = int'(pp_out); pp_n = pp_n + 1; end

    function automatic int pp_model(input longint x, input bit relu);
        longint y;
        y = ((x * 16384) + (longint'(1) <<< 21)) >>> 22;
        if (y > 127) y = 127;
        if (relu && y < 0) y = 0;
        if (!relu && y < -128) y = -128;
        return int'(y);
    endfunction

    task automatic part2();
        int good, out_relu_off [10];
        $display("");
        $display("==================================================================");
        $display(" Part 2: post-processing unit (bias + requantize + ReLU)");
        $display("   y = clamp( round( (acc + bias) x 16384 / 2^22 ), lo, 127 )   scale = 1/256");
        $display("==================================================================");
        for (int i = 0; i < NPP; i++) begin
            pp_a[i] = longint'(next_rand() % 80000) - 40000;
            pp_b[i] = longint'(next_rand() % 4000) - 2000;
        end
        // edge cases: zero, exact halves (rounding ties), far out of range
        pp_a[0] = 0;   pp_a[1] = 128; pp_a[2] = 384; pp_a[3] = -128; pp_a[4] = -384;
        pp_a[5] = 64'sd1 <<< 30; pp_a[6] = -(64'sd1 <<< 30); pp_a[7] = 255;
        for (int i = 0; i < 8; i++) pp_b[i] = 0;
        for (int r = 1; r >= 0; r--) begin
            pp_n = 0;
            pp_relu = r[0];
            for (int i = 0; i < NPP; i++) begin
                @(negedge clk);
                pp_in_valid = 1'b1; pp_acc = 32'(pp_a[i]); pp_bias = 32'(pp_b[i]);
            end
            @(negedge clk);
            pp_in_valid = 1'b0;
            repeat (6) @(negedge clk);
            good = 0;
            for (int i = 0; i < NPP; i++) if (pp_got[i] == pp_model(pp_a[i] + pp_b[i], r[0])) good++;
            if (r == 0) for (int i = 0; i < 10; i++) out_relu_off[i] = pp_got[i];
            $display("  %s  ReLU %s: %0d/%0d outputs correct", (good == NPP && pp_n == NPP) ? "PASS" : "FAIL",
                     r ? "on " : "off", good, NPP);
            if (good != NPP || pp_n != NPP) fails++;
        end
        $display("");
        $display("        acc + bias   exact value   ReLU off   ReLU on");
        for (int i = 0; i < 10; i++)
            $display("  %16d  %12.2f  %9d  %8d", pp_a[i] + pp_b[i],
                     real'(pp_a[i] + pp_b[i]) / 256.0, out_relu_off[i], pp_model(pp_a[i] + pp_b[i], 1'b1));
        $display("  Halves round up (0.5 -> 1, -0.5 -> 0). Results outside -128..127 are clamped,");
        $display("  and ReLU sets negatives to 0. One result per clock; 3 pipeline stages.");
    endtask

    // =====================================================================================
    // Part 3: the whole chip over a serial line (UART), with a 16x16 core
    // =====================================================================================
    localparam int CPB = 4;                      // clocks per bit: a fast line for simulation
    logic rx_line = 1'b1, tx_line, chip_busy;

    chip_top #(.P(16), .BITS(8), .ACC(32), .SAT(0), .MAXD(MAXD), .CLKS_PER_BIT(CPB)) u_chip (
        .clk(clk), .rst(rst), .uart_rx_i(rx_line), .uart_tx_o(tx_line), .busy_led(chip_busy));

    logic [7:0] got [20000];
    int         ngot = 0;

    initial begin : laptop_receiver           // decode every byte the chip sends
        logic [7:0] b;
        @(negedge rst);
        forever begin
            @(negedge tx_line);
            repeat (CPB / 2) @(posedge clk);
            for (int i = 0; i < 8; i++) begin
                repeat (CPB) @(posedge clk);
                b[i] = tx_line;
            end
            repeat (CPB) @(posedge clk);
            got[ngot] = b;
            ngot = ngot + 1;
        end
    end

    task automatic send_byte(input logic [7:0] b);
        rx_line = 1'b0;
        repeat (CPB) @(posedge clk);
        for (int i = 0; i < 8; i++) begin
            rx_line = b[i];
            repeat (CPB) @(posedge clk);
        end
        rx_line = 1'b1;
        repeat (2 * CPB) @(posedge clk);
    endtask

    task automatic wait_bytes(input int n);
        int t = 0;
        while (ngot < n && t < 2000000) begin @(posedge clk); t++; end
    endtask

    function automatic int u32(input int at);
        return int'({got[at + 3], got[at + 2], got[at + 1], got[at]});
    endfunction

    task automatic part3();
        int M = 8, K = 8, N = 8, correct, passes, cycles, eqc;
        $display("");
        $display("==================================================================");
        $display(" Part 3: whole chip over a serial line: laptop <-> UART <-> host interface <-> 16x16 core");
        $display("==================================================================");
        for (int i = 0; i < M; i++) for (int k = 0; k < K; k++) A[i][k] = next_rand() % 256 - 128;
        for (int k = 0; k < K; k++) for (int j = 0; j < N; j++) B[k][j] = next_rand() % 256 - 128;
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++) begin
                Ctrue[i][j] = 0;
                for (int k = 0; k < K; k++) Ctrue[i][j] += longint'(A[i][k]) * longint'(B[k][j]);
            end
        ngot = 0;
        send_byte("I"); wait_bytes(7);
        $display("  laptop sends               chip replies");
        $display("  'I'  (identify)            '%s%s%s'  P=%0d BITS=%0d ACC=%0d MAXD=%0d",
                 got[0], got[1], got[2], got[3], got[4], got[5], got[6]);
        send_byte("D"); send_byte(8'(M)); send_byte(8'(K)); send_byte(8'(N)); wait_bytes(8);
        $display("  %-26s '%s'", $sformatf("'D' %0d %0d %0d  (sizes)", M, K, N), got[7]);
        send_byte("A");
        for (int i = 0; i < M; i++) for (int k = 0; k < K; k++) send_byte(8'(A[i][k]));
        wait_bytes(9);
        $display("  %-26s '%s'", $sformatf("'A' + %0d bytes", M * K), got[8]);
        send_byte("B");
        for (int k = 0; k < K; k++) for (int j = 0; j < N; j++) send_byte(8'(B[k][j]));
        wait_bytes(10);
        $display("  %-26s '%s'", $sformatf("'B' + %0d bytes", K * N), got[9]);
        send_byte("G"); wait_bytes(23);
        passes = u32(11); cycles = u32(15);
        $display("  'G'  (run)                 '%s'  passes=%0d cycles=%0d total=%0d", got[10], passes, cycles, u32(19));
        send_byte("C"); wait_bytes(23 + 4 * M * N);
        $display("  'C'  (read result)         %0d bytes = %0d results", ngot - 23, M * N);
        correct = 0;
        for (int i = 0; i < M; i++)
            for (int j = 0; j < N; j++)
                if (longint'(u32(23 + 4 * (i * N + j))) == Ctrue[i][j]) correct++;
        eqc = 1 * (M + 3 * 16 - 2);
        $display("  %s  %0d/%0d results correct; cycles %0d, equation %0d",
                 (correct == M * N && cycles == eqc) ? "PASS" : "FAIL", correct, M * N, cycles, eqc);
        if (correct != M * N || cycles != eqc) fails++;
    endtask

    initial begin
        for (int c = 0; c < 2; c++) begin
            s_wr_en[c] = 1'b0; s_wr_sel[c] = 1'b0; s_start[c] = 1'b0; s_wr_row[c] = '0; s_wr_col[c] = '0;
            s_rd_row[c] = '0; s_rd_col[c] = '0; s_m[c] = '0; s_k[c] = '0; s_n[c] = '0; s_wr_data[c] = '0;
        end
        repeat (3) @(negedge clk);
        rst = 1'b0;
        repeat (3) @(negedge clk);
        part1();
        part2();
        part3();
        $display("");
        $display("==================================================================");
        if (fails == 0) $display(" ALL PARTS PASSED");
        else            $display(" %0d PART(S) FAILED", fails);
        $display("==================================================================");
        $finish;
    end
endmodule
