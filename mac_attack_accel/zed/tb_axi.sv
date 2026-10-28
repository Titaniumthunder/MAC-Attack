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
module tb_axi #(
    parameter int P            = 8,
    parameter int CORE_CLK     = 0,     // 1 = separate core clock (mac_axi CORE_CLK = 1)
    parameter int CORE_HALF_PS = 2000,  // core clock half period in ps (2000 = 250 MHz)
    parameter int LOCK_NS      = 700    // core clock "locked" this long after time 0
);
    localparam int MAXD = 64;
    localparam logic [5:0] CTRL = 6'h00, STATUS = 6'h04, DIMS = 6'h08, LOAD_PTR = 6'h0C,
                           LOAD_DATA = 6'h10, RES_PTR = 6'h14, RES_DATA = 6'h18,
                           PASSES = 6'h1C, CYCLES = 6'h20, TOTAL = 6'h24, INFO = 6'h28, ID = 6'h2C;

    logic clk = 1'b0, aresetn = 1'b0;
    always #10 clk = ~clk;                       // 50 MHz, the planned ZedBoard clock
    logic core_clk = 1'b0, core_locked = 1'b0;
    always #(CORE_HALF_PS * 1.0ps) core_clk = ~core_clk;
    initial #(LOCK_NS * 1.0ns) core_locked = 1'b1;

    logic [5:0]  awaddr = '0, araddr = '0;
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

    task automatic axi_write(input logic [5:0] addr, input logic [31:0] data);
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

    task automatic axi_read(input logic [5:0] addr, output logic [31:0] data);
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
    task automatic load_matrix(input bit isB, input int R, input int Cn);
        logic [31:0] w; int n = 0;
        axi_write(LOAD_PTR, {8'd0, 8'd0, 8'd0, 7'd0, isB});
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
