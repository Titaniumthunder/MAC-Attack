`timescale 1ns/1ps
// tb_tinytpu: the Tiny-TPU RSCL model (INT4 8 -> 4 -> 2) on the MAC Attack accelerator (mac_axi).
// It plays the ARM over AXI4-Lite, in the same order of register writes as the board program
// (mac_zed.sdk/MAC_model_TinyTPU/src/tinytpu_test.c), and checks every value the chip returns.
//
// The model and the 64 test rows come from tinytpu_vectors_pkg.sv, written by
// tinytpu/mac_mlp/export_mac_mlp.py (rows 0-11: the professor's golden vectors; 12-63: random INT4 rows).
//
//   1. Host mode (the professor's contract): layer 0 as a plain multiply (64 x 8 times 8 x 4), the host's
//      float step between the layers (here: the hidden INT4 values the contract gives, from the package),
//      layer 1 as a plain multiply (64 x 4 times 4 x 2). All 256 + 128 sums must be exact, and the class
//      from the logits must equal the contract's (golden rows: golden_vectors.json).
//   2. On-chip mode: the whole model in one CTRL write (mlp_ctrl), 64 rows, then 8, then 1 at a time.
//      All 128 final sums must equal the integer path computed by the script, and the class too.
//
// In Vivado: this is the simulation top of this project's sim_1. Run Behavioral Simulation and read the
// Tcl Console. The last line must be ALL TINY-TPU MODEL TESTS PASSED.
module tb_tinytpu;
    import tinytpu_vectors_pkg::*;
    localparam int P = 8, MAXD = 64;
    localparam logic [6:0] CTRL = 7'h00, STATUS = 7'h04, DIMS = 7'h08, LOAD_PTR = 7'h0C,
                           LOAD_DATA = 7'h10, RES_PTR = 7'h14, RES_DATA = 7'h18, ID = 7'h2C,
                           CONFIG = 7'h30, MODEL = 7'h34, LAYER0 = 7'h38, PARAM_PTR = 7'h48,
                           PARAM_DATA = 7'h4C, MCYCLES = 7'h50;

    logic clk = 1'b0, aresetn = 1'b0;
    always #10 clk = ~clk;                       // 50 MHz

    logic [6:0]  awaddr = '0, araddr = '0;
    logic        awvalid = 1'b0, wvalid = 1'b0, bready = 1'b0, arvalid = 1'b0, rready = 1'b0;
    logic [31:0] wdata = '0;
    wire         awready, wready, bvalid, arready, rvalid;
    wire [1:0]   bresp, rresp;
    wire [31:0]  rdata;

    mac_axi #(.P(P), .MAXD(MAXD)) dut (
        .s_axi_aclk(clk), .s_axi_aresetn(aresetn),
        .s_axi_awaddr(awaddr), .s_axi_awprot(3'b000), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arprot(3'b000), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready),
        .core_clk(1'b0), .core_locked(1'b1));

    // ---------------------------------------------------------------- bus (as in tb_axi.sv)
    int bus_errors = 0;

    task automatic axi_write(input logic [6:0] addr, input logic [31:0] data);
        @(negedge clk);
        awaddr = addr; wdata = data; awvalid = 1'b1; wvalid = 1'b1; bready = 1'b1;
        do @(posedge clk); while (!(awready && wready));
        @(negedge clk);
        awvalid = 1'b0; wvalid = 1'b0;
        while (!bvalid) @(negedge clk);
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

    // n values as one byte stream, 4 per LOAD_DATA write
    int stream [MAXD * MAXD];
    task automatic load_stream(input logic [31:0] ptr, input int n);
        logic [31:0] w = '0;
        axi_write(LOAD_PTR, ptr);
        for (int i = 0; i < n; i++) begin
            w[8*(i%4) +: 8] = 8'(stream[i]);
            if (i % 4 == 3) begin axi_write(LOAD_DATA, w); w = '0; end
        end
        if (n % 4 != 0) axi_write(LOAD_DATA, w);
    endtask

    task automatic wait_done(output logic [31:0] st);
        int polls = 0;
        do begin axi_read(STATUS, st); polls++; end while (!st[1] && polls < 100000);
    endtask

    int tests_run = 0, tests_passed = 0;
    int got [MAXD * MAXD];

    task automatic read_c(input int m, input int n);
        logic [31:0] v;
        axi_write(RES_PTR, 32'd0);
        for (int i = 0; i < m * n; i++) begin axi_read(RES_DATA, v); got[i] = $signed(v); end
    endtask

    // class the host makes of two layer-1 sums: argmax of acc * S_A1 * S_W1 + bias (ties: class 0, like argmax)
    function automatic int host_class(int a0, int a1);
        real l0, l1;
        l0 = real'(a0) * S_A1 * S_W1 + B1F[0];
        l1 = real'(a1) * S_A1 * S_W1 + B1F[1];
        return (l1 > l0) ? 1 : 0;
    endfunction

    // ---------------------------------------------------------------- 1. host mode
    task automatic host_mode();
        logic [31:0] st;
        int ok0 = 0, ok1 = 0, okc = 0;
        bit ok;
        // layer 0: C (64 x 4) = X (64 x 8) x W0 (8 x 4), weights in slot 0
        axi_write(DIMS, {8'd0, 8'(N0), 8'(K0), 8'(ROWS)});
        for (int i = 0; i < ROWS * K0; i++) stream[i] = X[i];
        load_stream(32'h0, ROWS * K0);
        for (int i = 0; i < K0 * N0; i++) stream[i] = W0[i];
        load_stream(32'h1, K0 * N0);
        axi_write(CTRL, 32'd1);
        wait_done(st);
        read_c(ROWS, N0);
        for (int i = 0; i < ROWS * N0; i++) ok0 += (got[i] == ACC0[i]);
        // the host's float step gives H (INT4, from the package); layer 1: C (64 x 2) = H (64 x 4) x W1 (4 x 2)
        axi_write(DIMS, {8'd0, 8'(N1), 8'(N0), 8'(ROWS)});
        for (int i = 0; i < ROWS * N0; i++) stream[i] = H[i];
        load_stream(32'h0, ROWS * N0);
        for (int i = 0; i < N0 * N1; i++) stream[i] = W1[i];
        load_stream(32'h1, N0 * N1);
        axi_write(CTRL, 32'd1);
        wait_done(st);
        read_c(ROWS, N1);
        for (int i = 0; i < ROWS * N1; i++) ok1 += (got[i] == ACC1[i]);
        for (int r = 0; r < ROWS; r++) okc += (host_class(got[2*r], got[2*r+1]) == CLS[r]);
        ok = ok0 == ROWS * N0 && ok1 == ROWS * N1 && okc == ROWS && !st[2];
        tests_run++; if (ok) tests_passed++;
        $display("  %s  host mode (professor's contract)  layer 0 %3d/%0d sums, layer 1 %3d/%0d sums, class %2d/%0d",
                 ok ? "PASS" : "FAIL", ok0, ROWS * N0, ok1, ROWS * N1, okc, ROWS);
    endtask

    // ---------------------------------------------------------------- 2. on-chip mode
    task automatic load_model();
        // layer 0: weights in slot 0, bias + (m0, shift) per channel, ReLU
        axi_write(DIMS, {8'd0, 8'(N0), 8'(K0), 8'd1});
        for (int i = 0; i < K0 * N0; i++) stream[i] = W0[i];
        load_stream(32'h1 | (32'd0 << 24), K0 * N0);
        axi_write(PARAM_PTR, 32'h0 << 8);
        for (int j = 0; j < N0; j++) begin
            axi_write(PARAM_DATA, 32'(BIAS0[j]));
            axi_write(PARAM_DATA, (32'(SHIFT) << 16) | 32'(M0));
        end
        axi_write(LAYER0, {23'd0, 1'b1, 8'(N0)});
        // layer 1: weights in slot 1; raw sums come back, so bias 0 and any valid scale
        axi_write(DIMS, {8'd0, 8'(N1), 8'(N0), 8'd1});
        for (int i = 0; i < N0 * N1; i++) stream[i] = W1[i];
        load_stream(32'h1 | (32'd1 << 24), N0 * N1);
        axi_write(PARAM_PTR, 32'h1 << 8);
        for (int j = 0; j < N1; j++) begin
            axi_write(PARAM_DATA, 32'd0);
            axi_write(PARAM_DATA, 32'h10001);
        end
        axi_write(LAYER0 + 7'd4, {23'd0, 1'b0, 8'(N1)});
        axi_write(MODEL, 32'd1);
    endtask

    task automatic chip_mode(input int batch);
        logic [31:0] st, mcyc;
        int oks = 0, okc = 0, okg = 0, err = 0;
        bit ok;
        for (int r0 = 0; r0 < ROWS; r0 += batch) begin
            axi_write(DIMS, {8'd0, 8'(N1), 8'(K0), 8'(batch)});
            for (int i = 0; i < batch * K0; i++) stream[i] = X[r0 * K0 + i];
            load_stream(32'h0, batch * K0);
            axi_write(CTRL, 32'd2);
            wait_done(st);
            err |= st[2];
            read_c(batch, N1);
            for (int r = 0; r < batch; r++) begin
                bit row_ok = got[2*r] == ACC1C[2*(r0+r)] && got[2*r+1] == ACC1C[2*(r0+r)+1];
                oks += row_ok * 2;
                okc += (host_class(got[2*r], got[2*r+1]) == CLSC[r0+r]);
                // golden rows: the chip's integer path must give the contract's sums exactly
                if (r0 + r < GOLDEN) okg += (got[2*r] == ACC1[2*(r0+r)] && got[2*r+1] == ACC1[2*(r0+r)+1]);
            end
        end
        axi_read(MCYCLES, mcyc);
        ok = oks == ROWS * N1 && okc == ROWS && okg == GOLDEN && !err;
        tests_run++; if (ok) tests_passed++;
        $display("  %s  on-chip MLP, %2d row%s per run       %3d/%0d sums, class %2d/%0d, golden rows = contract %2d/%0d, %0d clocks per run",
                 ok ? "PASS" : "FAIL", batch, batch == 1 ? " " : "s", oks, ROWS * N1, okc, ROWS, okg, GOLDEN, mcyc);
    endtask

    // ---------------------------------------------------------------- main
    initial begin
        logic [31:0] v;
        repeat (5) @(posedge clk);
        aresetn = 1'b1;
        repeat (5) @(posedge clk);
        $display("");
        $display("==================================================================");
        $display(" Tiny-TPU RSCL model (INT4 8-4-2) on mac_axi, %0d rows (%0d golden)", ROWS, GOLDEN);
        $display("==================================================================");
        axi_read(ID, v);
        if (v != 32'h4D414331) begin $display(" FAILED: ID 0x%08h", v); $finish; end
        axi_read(CONFIG, v);
        host_mode();
        if (!v[18]) $display("  SKIP  on-chip mode: this mac_axi has no on-chip MLP (CONFIG bit 18 = 0)");
        else begin
            load_model();
            chip_mode(64);
            chip_mode(8);
            chip_mode(1);
            $display("  note: on %0d random rows a hidden value is above 7; the contract clamps it at 7, the chip at 127",
                     CHIP_DIFF_ROWS);
            $display("        (expected sums differ there, the classes do not). None of the golden rows.");
        end
        $display("==================================================================");
        if (tests_passed == tests_run && bus_errors == 0) $display(" ALL TINY-TPU MODEL TESTS PASSED (%0d/%0d)", tests_passed, tests_run);
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
