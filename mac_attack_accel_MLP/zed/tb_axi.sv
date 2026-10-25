`timescale 1ns/1ps
// Self-checking testbench for mac_axi. It plays the ARM processor: every access goes over
// AXI4-Lite exactly as the C program on the ZedBoard will do it (same registers, same order).
//
// In Vivado: this is the simulation top of the ZedBoard project. Run Behavioral Simulation and
// read the Tcl Console. The last line should be ALL AXI TESTS PASSED.
//
// Besides correctness, it counts clock cycles for each phase (loading over the bus, computing,
// reading back), which shows how much of the time is moving data rather than doing math.
//
// CORE_CLK = 1 (step 12): the core gets its own clock, with a half period of CORE_HALF_PS
// picoseconds, unrelated to the 50 MHz bus clock here, and a "locked" signal that rises after
// LOCK_NS. The bus clock counts for "run" then depend on the core clock; everything else is the same.
// In Vivado: Simulation Settings > Elaboration > More options, e.g.
//   -generic_top "CORE_CLK=1" -generic_top "CORE_HALF_PS=2000"
//
// On-chip MLP (21 Oct 2026): when CONFIG says the model hardware is built, the last part loads a
// 3-layer model (weights in slots 0-2, biases and scales through PARAM_DATA), runs it with one
// CTRL write for 8 rows and for 1 row, and checks every output against the same model computed
// here, plus the counters, plain multiplies from another slot afterwards, and loads during a run.
module tb_axi #(
    parameter int P            = 8,
    parameter int CORE_CLK     = 0,     // 1 = separate core clock (mac_axi CORE_CLK = 1)
    parameter int CORE_HALF_PS = 2000,  // core clock half period in ps (2000 = 250 MHz)
    parameter int LOCK_NS      = 700    // core clock "locked" this long after time 0
);
    localparam int MAXD = 64;
    localparam logic [6:0] CTRL = 7'h00, STATUS = 7'h04, DIMS = 7'h08, LOAD_PTR = 7'h0C,
                           LOAD_DATA = 7'h10, RES_PTR = 7'h14, RES_DATA = 7'h18,
                           PASSES = 7'h1C, CYCLES = 7'h20, TOTAL = 7'h24, INFO = 7'h28, ID = 7'h2C,
                           CONFIG = 7'h30, MODEL = 7'h34, LAYER0 = 7'h38, PARAM_PTR = 7'h48,
                           PARAM_DATA = 7'h4C, MCYCLES = 7'h50;

    logic clk = 1'b0, aresetn = 1'b0;
    always #10 clk = ~clk;                       // 50 MHz, the planned ZedBoard clock
    logic core_clk = 1'b0, core_locked = 1'b0;
    always #(CORE_HALF_PS * 1.0ps) core_clk = ~core_clk;
    initial #(LOCK_NS * 1.0ns) core_locked = 1'b1;

    logic [6:0]  awaddr = '0, araddr = '0;
    logic        awvalid = 1'b0, wvalid = 1'b0, bready = 1'b0, arvalid = 1'b0, rready = 1'b0;
    logic [31:0] wdata = '0;
    wire         awready, wready, bvalid, arready, rvalid;
    wire [1:0]   bresp, rresp;
    wire [31:0]  rdata;

    mac_axi #(.P(P), .MAXD(MAXD), .CORE_CLK(CORE_CLK)) dut (
        .s_axi_aclk(clk), .s_axi_aresetn(aresetn),
        .s_axi_awaddr(awaddr), .s_axi_awprot(3'b000), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arprot(3'b000), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready),
        .core_clk(core_clk), .core_locked(core_locked));

    // ---------------------------------------------------------------- bus transactions
    int bus_errors = 0;
    longint cycle = 0;
    always @(posedge clk) cycle <= cycle + 1;

    task automatic axi_write(input logic [6:0] addr, input logic [31:0] data);
        @(negedge clk);
        awaddr = addr; wdata = data; awvalid = 1'b1; wvalid = 1'b1; bready = 1'b1;
        do @(posedge clk); while (!(awready && wready));   // address and data accepted
        @(negedge clk);
        awvalid = 1'b0; wvalid = 1'b0;
        while (!bvalid) @(negedge clk);                     // write response
        if (bresp != 2'b00) bus_errors++;
        @(posedge clk);
        @(negedge clk);
        bready = 1'b0;
    endtask

    task automatic axi_read(input logic [6:0] addr, output logic [31:0] data);
        @(negedge clk);
        araddr = addr; arvalid = 1'b1; rready = 1'b1;
        do @(posedge clk); while (!arready);
        @(negedge clk);
        arvalid = 1'b0;
        while (!rvalid) @(negedge clk);
        data = rdata;
        if (rresp != 2'b00) bus_errors++;
        @(posedge clk);
        @(negedge clk);
        rready = 1'b0;
    endtask

    // ---------------------------------------------------------------- test data
    int     A [MAXD][MAXD], B [MAXD][MAXD];
    longint Cexp [MAXD][MAXD];
    int unsigned seed = 32'h2468ACE1;
    function automatic int next_rand();
        seed = seed ^ (seed << 13); seed = seed ^ (seed >> 17); seed = seed ^ (seed << 5);
        return int'(seed & 32'h7FFF_FFFF);
    endfunction
    localparam int RANDOM = 0, SMALL = 1, MINV = 2, MAXV = 3, IDENT = 4, MIXV = 5;   // MIXV: A = 127, B = -128

    task automatic make_data(input int kind, input int M, input int K, input int N);
        for (int i = 0; i < M; i++) for (int k = 0; k < K; k++)
            A[i][k] = (kind == SMALL) ? next_rand() % 19 - 9 : (kind == MINV) ? -128 : (kind == MAXV || kind == MIXV) ? 127 : next_rand() % 256 - 128;
        for (int k = 0; k < K; k++) for (int j = 0; j < N; j++)
            B[k][j] = (kind == SMALL) ? next_rand() % 19 - 9 : (kind == MINV || kind == MIXV) ? -128 : (kind == MAXV) ? 127 :
                      (kind == IDENT) ? ((k == j) ? 1 : 0) : next_rand() % 256 - 128;
        for (int i = 0; i < M; i++) for (int j = 0; j < N; j++) begin
            Cexp[i][j] = 0;
            for (int k = 0; k < K; k++) Cexp[i][j] += longint'(A[i][k]) * longint'(B[k][j]);
        end
    endtask

    // stream a matrix as bytes in row order, 4 per LOAD_DATA write (like the C program)
    task automatic load_matrix(input bit isB, input int R, input int Cn, input int slot = 0);
        logic [31:0] w; int n = 0;
        axi_write(LOAD_PTR, {6'd0, 2'(slot), 8'd0, 8'd0, 7'd0, isB});
        w = '0;
        for (int r = 0; r < R; r++) for (int c = 0; c < Cn; c++) begin
            w[8*(n%4) +: 8] = isB ? 8'(B[r][c]) : 8'(A[r][c]);
            n++;
            if (n % 4 == 0) begin axi_write(LOAD_DATA, w); w = '0; end
        end
        if (n % 4 != 0) axi_write(LOAD_DATA, w);   // last partial word; extra bytes are dropped
    endtask

    int tests_run = 0, tests_passed = 0;
    longint t_load_total = 0, t_comp_total = 0, t_read_total = 0;

    task automatic run_test(input string title, input int kind, input int M, input int K, input int N);
        logic [31:0] v, passes, cycles, status;
        longint t0, t1, t2, t3;
        int correct, eqp, eqc, polls;
        bit ok;
        make_data(kind, M, K, N);
        t0 = cycle;
        axi_write(DIMS, {8'd0, 8'(N), 8'(K), 8'(M)});
        load_matrix(1'b0, M, K);
        load_matrix(1'b1, K, N);
        t1 = cycle;
        axi_write(CTRL, 32'd1);
        polls = 0;
        do begin axi_read(STATUS, status); polls++; end while (!status[1] && polls < 100000);
        t2 = cycle;
        axi_write(RES_PTR, 32'd0);
        correct = 0;
        for (int i = 0; i < M; i++) for (int j = 0; j < N; j++) begin
            axi_read(RES_DATA, v);
            if (longint'($signed(v)) == Cexp[i][j]) correct++;
        end
        t3 = cycle;
        axi_read(PASSES, passes); axi_read(CYCLES, cycles);
        eqp = ((K + P - 1) / P) * ((N + P - 1) / P);
        eqc = eqp * (M + 3 * P - 2);
        ok = (correct == M * N) && (passes == eqp) && (cycles == eqc) && !status[2];
        tests_run++; if (ok) tests_passed++;
        t_load_total += t1 - t0; t_comp_total += t2 - t1; t_read_total += t3 - t2;
        $display("  %s  %-30s %2dx%2dx%2d  %4d/%-4d correct  passes %3d (eq %3d)  cycles %5d (eq %5d)  bus: load %6d, run %5d, read %6d clocks",
                 ok ? "PASS" : "FAIL", title, M, K, N, correct, M * N, passes, eqp, cycles, eqc, t1 - t0, t2 - t1, t3 - t2);
    endtask

    // ---------------------------------------------------------------- on-chip MLP
    int     Wl [3][MAXD][MAXD];                 // weights of each layer, K_l x N_l
    longint bias_l [3][MAXD];
    int     m0_l [3][MAXD], sh_l [3][MAXD];
    int     Xin [MAXD][MAXD];                   // input rows
    longint Cm [MAXD][MAXD];                    // the last layer's raw sums, computed here
    int     act [MAXD][MAXD];                   // a layer's INT8 output, computed here
    int     Cmid [MAXD][MAXD];                  // a hidden layer's INT8 output, before it becomes act
    localparam int NLAY = 3;
    int     Kl [NLAY];                          // K of each layer (layer 0: inputs per row): 40, 64, 64
    int     Nl [NLAY];                          // N of each layer: 64, 64, 6
    bit     Rl [NLAY];                          // ReLU after the layer (not used for the last): 1, 1, 0
    initial begin
        Kl[0] = 40; Kl[1] = 64; Kl[2] = 64;
        Nl[0] = 64; Nl[1] = 64; Nl[2] = 6;
        Rl[0] = 1'b1; Rl[1] = 1'b1; Rl[2] = 1'b0;
    end

    // postproc.sv: y = clamp(((acc + bias) * m0 + 2^(shift-1)) >> shift, relu ? 0 : -128, 127)
    function automatic int requant(longint acc, longint bias, int m0, int sh, bit relu);
        longint y;
        y = ((acc + bias) * longint'(m0) + (longint'(1) <<< (sh - 1))) >>> sh;
        if (y > 127) y = 127;
        if (relu && y < 0) y = 0;
        if (!relu && y < -128) y = -128;
        return int'(y);
    endfunction

    // Random weights and biases; each channel's scale maps its largest |sum + bias| on these
    // inputs to about 127, so the outputs use the whole INT8 range (some channels saturate).
    task automatic make_model(input int M);
        longint peak, c;
        for (int i = 0; i < M; i++) for (int k = 0; k < Kl[0]; k++) begin
            Xin[i][k] = next_rand() % 256 - 128;
            act[i][k] = Xin[i][k];
            A[i][k]   = Xin[i][k];                      // load_matrix sends A
        end
        for (int l = 0; l < NLAY; l++) begin
            for (int k = 0; k < Kl[l]; k++) for (int j = 0; j < Nl[l]; j++) Wl[l][k][j] = next_rand() % 256 - 128;
            for (int j = 0; j < Nl[l]; j++) begin
                bias_l[l][j] = longint'(next_rand() % 20001) - 10000;
                peak = 1;
                for (int i = 0; i < M; i++) begin
                    c = bias_l[l][j];
                    for (int k = 0; k < Kl[l]; k++) c += longint'(act[i][k]) * Wl[l][k][j];
                    if (c < 0) c = -c;
                    if (c > peak) peak = c;
                end
                peak = peak * (2 + next_rand() % 3) / 3;          // 0.67 .. 1.33 of the peak
                if (peak < 1) peak = 1;
                sh_l[l][j] = 1;                                     // m0 / 2^shift = 127 / peak, m0 >= 2^15
                while (sh_l[l][j] < 48 && ((longint'(127) <<< sh_l[l][j]) / peak) < 32768) sh_l[l][j]++;
                m0_l[l][j] = int'((longint'(127) <<< sh_l[l][j]) / peak);
                if (m0_l[l][j] > 65535) m0_l[l][j] = 65535;
            end
            // this layer's output
            for (int i = 0; i < M; i++) for (int j = 0; j < Nl[l]; j++) begin
                c = 0;
                for (int k = 0; k < Kl[l]; k++) c += longint'(act[i][k]) * Wl[l][k][j];
                if (l == NLAY - 1) Cm[i][j] = c;
                else Cmid[i][j] = requant(c, bias_l[l][j], m0_l[l][j], sh_l[l][j], Rl[l]);
            end
            if (l < NLAY - 1) for (int i = 0; i < M; i++) for (int j = 0; j < Nl[l]; j++) act[i][j] = Cmid[i][j];
        end
    endtask

    // The model's weights, scales and layer table, once
    task automatic load_model();
        logic [31:0] w; int n;
        for (int l = 0; l < NLAY; l++) begin
            axi_write(DIMS, {8'd0, 8'(Nl[l]), 8'(Kl[l]), 8'd1});
            axi_write(LOAD_PTR, {6'd0, 2'(l), 8'd0, 8'd0, 7'd0, 1'b1});     // B, slot l, row 0, column 0
            n = 0; w = '0;
            for (int k = 0; k < Kl[l]; k++) for (int j = 0; j < Nl[l]; j++) begin
                w[8*(n%4) +: 8] = 8'(Wl[l][k][j]);
                n++;
                if (n % 4 == 0) begin axi_write(LOAD_DATA, w); w = '0; end
            end
            if (n % 4 != 0) axi_write(LOAD_DATA, w);
            axi_write(PARAM_PTR, {15'd0, 1'b0, 6'd0, 2'(l), 8'd0});             // bias of channel 0
            for (int j = 0; j < Nl[l]; j++) begin
                axi_write(PARAM_DATA, 32'(bias_l[l][j]));
                axi_write(PARAM_DATA, {10'd0, 6'(sh_l[l][j]), 16'(m0_l[l][j])});
            end
            axi_write(LAYER0 + 7'(4 * l), {23'd0, Rl[l], 8'(Nl[l])});
        end
        axi_write(MODEL, NLAY - 1);
    endtask

    task automatic run_model(input string title, input int M);
        logic [31:0] v, st, passes, cycles, total, mcyc;
        longint t0, t1, t2;
        int correct, polls, eqp, eqc, eqt, eqm, np, drain;
        logic [31:0] cf;
        bit ok;
        make_model(M);
        // weights and scales are loaded again for every model here (the C program loads them once)
        load_model();
        t0 = cycle;
        axi_write(DIMS, {8'd0, 8'(Nl[NLAY-1]), 8'(Kl[0]), 8'(M)});
        load_matrix(1'b0, M, Kl[0]);                    // not the A of the multiplies above:
        t1 = cycle;
        axi_write(CTRL, 32'd2);                         // run the model
        polls = 0;
        do begin axi_read(STATUS, st); polls++; end while (!st[1] && polls < 100000);
        t2 = cycle;
        axi_write(RES_PTR, 32'd0);
        correct = 0;
        for (int i = 0; i < M; i++) for (int j = 0; j < Nl[NLAY-1]; j++) begin
            axi_read(RES_DATA, v);
            if (longint'($signed(v)) == Cm[i][j]) correct++;
        end
        axi_read(PASSES, passes); axi_read(CYCLES, cycles); axi_read(TOTAL, total); axi_read(MCYCLES, mcyc);
        // drain between layers: C read (1 or 2) + postproc stages (3, 7 or 9) + 1, from CONFIG as in mac_test.c
        axi_read(CONFIG, cf);
        drain = (cf[23] ? 2 : 1) + (cf[29] ? 9 : cf[19] ? 7 : 3) + 1;
        eqp = 0; eqc = 0; eqt = 0; eqm = 0;
        for (int l = 0; l < NLAY; l++) begin
            np = ((Kl[l] + P - 1) / P) * ((Nl[l] + P - 1) / P);
            eqp += np;
            eqc += np * (M + 3 * P - 2);
            eqt += np * (M + 3 * P - 2) + 7;                       // + 3 + PIPE + MEM_REG
            eqm += np * (M + 3 * P - 2) + 7 + 3;                   // + set up, start, done
            if (l < NLAY - 1) eqm += M * ((Nl[l] + P - 1) / P) + drain;  // writeback + drain (12 by default)
        end
        ok = (correct == M * Nl[NLAY-1]) && passes == eqp && cycles == eqc && total == eqt && mcyc == eqm && !st[2];
        tests_run++; if (ok) tests_passed++;
        $display("  %s  %-30s %2d rows %0d-%0d-%0d-%0d  %4d/%-4d correct  passes %3d (eq %3d)  array %5d (eq %5d)  model %5d clocks (eq %5d)  bus: load %5d, run %5d",
                 ok ? "PASS" : "FAIL", title, M, Kl[0], Nl[0], Nl[1], Nl[2], correct, M * Nl[NLAY-1], passes, eqp,
                 cycles, eqc, mcyc, eqm, t1 - t0, t2 - t1);
    endtask

    task automatic model_tests(input logic [31:0] cfg);
        logic [31:0] v, st;
        $display("");
        $display("  On-chip MLP: %0d weight slots, %0d postproc lanes, %0d-stage postproc",
                 cfg[22:20], cfg[28:24], cfg[29] ? 9 : cfg[19] ? 7 : 3);
        run_model("model, 8 rows",  8);
        run_model("model, 1 row",   1);
        // the pointer moved on by itself: after layer 2's 6 channels it points at channel 6, bias
        axi_read(PARAM_PTR, v);
        $display("  %s  PARAM_PTR moved on to layer %0d channel %0d field %0d", (v == {15'd0, 1'b0, 6'd0, 2'd2, 8'd6}) ? "PASS" : "FAIL",
                 v[9:8], v[7:0], v[16]);
        tests_run++; if (v == {15'd0, 1'b0, 6'd0, 2'd2, 8'd6}) tests_passed++;
        // a plain multiply with the weights in slot 2, then one in slot 0 (the model left both alone)
        make_data(RANDOM, 9, 20, 13);
        axi_write(DIMS, {6'd0, 2'd2, 8'd13, 8'd20, 8'd9});
        load_matrix(1'b0, 9, 20);
        load_matrix(1'b1, 20, 13, 2);
        axi_write(CTRL, 32'd1);
        do axi_read(STATUS, st); while (!st[1]);
        begin
            int correct;
            axi_write(RES_PTR, 32'd0);
            correct = 0;
            for (int i = 0; i < 9; i++) for (int j = 0; j < 13; j++) begin
                axi_read(RES_DATA, v);
                if (longint'($signed(v)) == Cexp[i][j]) correct++;
            end
            $display("  %s  plain multiply from weight slot 2 after the model   %0d/117 correct", (correct == 117) ? "PASS" : "FAIL", correct);
            tests_run++; if (correct == 117) tests_passed++;
        end
        run_test("plain multiply, slot 0, after the model", RANDOM, 16, 16, 16);
        // loads during a model run are dropped and flagged
        make_model(8);
        load_model();
        axi_write(DIMS, {8'd0, 8'(Nl[NLAY-1]), 8'(Kl[0]), 8'd8});
        load_matrix(1'b0, 8, Kl[0]);
        axi_write(CTRL, 32'd2);
        axi_write(LOAD_DATA, 32'h01020304);
        axi_write(PARAM_DATA, 32'h0);
        do axi_read(STATUS, st); while (!st[1]);
        begin
            int correct;
            axi_write(RES_PTR, 32'd0);
            correct = 0;
            for (int i = 0; i < 8; i++) for (int j = 0; j < Nl[NLAY-1]; j++) begin
                axi_read(RES_DATA, v);
                if (longint'($signed(v)) == Cm[i][j]) correct++;
            end
            $display("  %s  loads during a model run are dropped and flagged (STATUS = 0x%0h), results %0d/%0d", (st[2] && correct == 8 * Nl[NLAY-1]) ? "PASS" : "FAIL",
                     st, correct, 8 * Nl[NLAY-1]);
            tests_run++; if (st[2] && correct == 8 * Nl[NLAY-1]) tests_passed++;
        end
    endtask

    initial begin
        logic [31:0] v, st;
        repeat (5) @(posedge clk);
        aresetn = 1'b1;
        repeat (5) @(posedge clk);
        $display("");
        $display("==================================================================");
        $display(" mac_axi on a %0dx%0d array: the ARM's view over AXI4-Lite (50 MHz)", P, P);
        $display("==================================================================");
        axi_read(ID, v);
        $display("  ID   = 0x%08h %s", v, (v == 32'h4D414331) ? "(MAC1)" : "(WRONG)");
        tests_run++; if (v == 32'h4D414331) tests_passed++;
        if (CORE_CLK != 0) begin                   // wait for the core clock (STATUS bit 3)
            int waits;
            waits = 0;
            do begin axi_read(STATUS, st); waits++; end while (st[3] && waits < 10000);
            $display("  core clock: half period %0d ps, ready after %0d STATUS reads %s", CORE_HALF_PS, waits,
                     st[3] ? "(NEVER READY)" : "(ok)");
            tests_run++; if (!st[3]) tests_passed++;
        end
        axi_read(INFO, v);
        $display("  INFO = P %0d, %0d-bit inputs, %0d-bit sums, matrices up to %0d", v[7:0], v[15:8], v[23:16], v[31:24]);
        tests_run++; if (v[7:0] == P && v[31:24] == MAXD) tests_passed++;
        axi_write(DIMS, 32'h00_05_06_07);
        axi_read(DIMS, v);
        $display("  DIMS write then read back: 0x%06h %s", v[23:0], (v[23:0] == 24'h050607) ? "(ok)" : "(WRONG)");
        tests_run++; if (v[23:0] == 24'h050607) tests_passed++;
        $display("");
        run_test("small numbers",                 SMALL,  4,  4,  4);
        run_test("random INT8, one 16x16",        RANDOM, 16, 16, 16);
        run_test("random INT8, 64x64 folded",     RANDOM, 64, 64, 64);
        run_test("odd sizes (edge tiles)",        RANDOM, 37, 50, 23);
        run_test("one row of A",                  RANDOM,  1, 64, 64);
        run_test("every input -128",              MINV,   16, 16, 16);
        run_test("every input 127",               MAXV,   16, 16, 16);
        run_test("B = identity",                  IDENT,  16, 16, 16);
        // a load attempted while the core is busy must be dropped and flagged
        make_data(RANDOM, 64, 64, 64);
        axi_write(DIMS, {8'd0, 8'd64, 8'd64, 8'd64});
        axi_write(CTRL, 32'd1);
        axi_write(LOAD_DATA, 32'h01020304);
        do axi_read(STATUS, st); while (!st[1]);
        $display("  %s  load during a run is dropped and flagged (STATUS = 0x%0h)", st[2] ? "PASS" : "FAIL", st);
        tests_run++; if (st[2]) tests_passed++;
        $display("");
        $display("  Clocks over all 8 multiplies: loading %0d, computing %0d, reading %0d", t_load_total, t_comp_total, t_read_total);
        $display("  Moving data takes %0.1fx as long as the computing, even with an ideal bus.",
                 real'(t_load_total + t_read_total) / real'(t_comp_total));
        $display("");
        // The two largest sums possible with K = 64 (after the totals above, so those stay comparable
        // with earlier runs). They need every accumulator bit: 64 x 16384 = 1,048,576 and
        // 64 x (-16256) = -1,040,384, so a 21-bit accumulator fails the first one.
        $display("  Largest possible sums (accumulator width check):");
        run_test("every input -128, K = 64",      MINV,   64, 64, 64);
        run_test("A = 127, B = -128, K = 64",     MIXV,   64, 64, 64);
        axi_read(CONFIG, v);
        if (v[18]) model_tests(v);
        $display("");
        $display("==================================================================");
        if (tests_passed == tests_run && bus_errors == 0) $display(" ALL AXI TESTS PASSED (%0d/%0d)", tests_passed, tests_run);
        else $display(" FAILED: %0d of %0d passed, %0d bus errors", tests_passed, tests_run, bus_errors);
        $display("==================================================================");
        $finish;
    end

    initial begin
        #200ms;
        $display("ERROR: timeout");
        $finish;
    end
endmodule
