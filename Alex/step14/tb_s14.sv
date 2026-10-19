`timescale 1ns/1ps
// Step 14 checks for mac_axi (not part of the repo; used to verify the change).
//   MODE 0: lockstep. mac_axi_old (step 13) and mac_axi (HREAD_REG = HREG, use 0) get the same AXI
//           inputs in every clock; every AXI output and the loader, core-port and read-pointer
//           registers must be equal in every clock.
//   MODE 1: mac_axi_old alone.  MODE 2: mac_axi alone (HREAD_REG = HREG).
//           The master writes every read whose value does not depend on timing to LOGFILE; the logs
//           of MODE 1 and MODE 2 must be identical.
// In MODE 0 and 2 the new loader flags are checked against their definitions in every clock where
// a byte is written.
// The master is aggressive: a new write or read is offered as soon as the previous one is
// accepted (it does not wait for the response unless the test needs the order), with random
// gaps and random bready/rready.
module tb_s14 #(
    parameter int MODE    = 0,
    parameter int HREG    = 0,
    parameter int P       = 8,
    parameter int PE_PRIM = 0,
    parameter int SEED    = 1,
    parameter int NSCEN   = 40,
    parameter int FAST    = 0       // 1 = no random gaps, bready/rready always 1
);
    localparam logic [5:0] CTRL = 6'h00, STATUS = 6'h04, DIMS = 6'h08, LOAD_PTR = 6'h0C,
                           LOAD_DATA = 6'h10, RES_PTR = 6'h14, RES_DATA = 6'h18,
                           PASSES = 6'h1C, CYCLES = 6'h20, TOTAL = 6'h24, INFO = 6'h28, ID = 6'h2C,
                           CONFIG = 6'h30;
    logic clk = 1'b0, aresetn = 1'b0;
    always #2 clk = ~clk;

    logic [5:0]  awaddr = '0, araddr = '0;
    logic        awvalid = 1'b0, wvalid = 1'b0, bready = 1'b0, arvalid = 1'b0, rready = 1'b0;
    logic [31:0] wdata = '0;
    wire o_awready, o_wready, o_bvalid, o_arready, o_rvalid; wire [1:0] o_bresp, o_rresp; wire [31:0] o_rdata;
    wire n_awready, n_wready, n_bvalid, n_arready, n_rvalid; wire [1:0] n_bresp, n_rresp; wire [31:0] n_rdata;
    int errors = 0;
    longint ncmp = 0, nflag = 0;

    generate
        if (MODE != 2) begin : g_old
            mac_axi_old #(.P(P), .MAXD(64), .PE_PRIM(PE_PRIM)) u (
                .s_axi_aclk(clk), .s_axi_aresetn(aresetn),
                .s_axi_awaddr(awaddr), .s_axi_awprot(3'b000), .s_axi_awvalid(awvalid), .s_axi_awready(o_awready),
                .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(o_wready),
                .s_axi_bresp(o_bresp), .s_axi_bvalid(o_bvalid), .s_axi_bready(bready),
                .s_axi_araddr(araddr), .s_axi_arprot(3'b000), .s_axi_arvalid(arvalid), .s_axi_arready(o_arready),
                .s_axi_rdata(o_rdata), .s_axi_rresp(o_rresp), .s_axi_rvalid(o_rvalid), .s_axi_rready(rready),
                .core_clk(1'b0), .core_locked(1'b0));
        end else begin : g_old_off
            assign {o_awready, o_wready, o_bvalid, o_arready, o_rvalid, o_bresp, o_rresp, o_rdata} = '0;
        end
        if (MODE != 1) begin : g_new
            mac_axi #(.P(P), .MAXD(64), .PE_PRIM(PE_PRIM), .HREAD_REG(HREG)) u (
                .s_axi_aclk(clk), .s_axi_aresetn(aresetn),
                .s_axi_awaddr(awaddr), .s_axi_awprot(3'b000), .s_axi_awvalid(awvalid), .s_axi_awready(n_awready),
                .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(n_wready),
                .s_axi_bresp(n_bresp), .s_axi_bvalid(n_bvalid), .s_axi_bready(bready),
                .s_axi_araddr(araddr), .s_axi_arprot(3'b000), .s_axi_arvalid(arvalid), .s_axi_arready(n_arready),
                .s_axi_rdata(n_rdata), .s_axi_rresp(n_rresp), .s_axi_rvalid(n_rvalid), .s_axi_rready(rready),
                .core_clk(1'b0), .core_locked(1'b0));
            // The loader flags must equal their definitions whenever a byte is written
            always @(posedge clk) if (aresetn && u.ld_left != 3'd0) begin
                nflag++;
                if (u.ld_inside !== ((u.ld_row < u.ld_rows) && (u.ld_col < u.ld_rowlen)) ||
                    u.ld_col_last !== (u.ld_col == u.ld_collast) ||
                    u.ld_row_last !== (u.ld_row == 8'(u.ld_rows - 8'd1))) begin
                    errors++;
                    if (errors < 10) $display("FLAG MISMATCH t=%0t row %0d col %0d rows %0d rowlen %0d: inside %b col_last %b row_last %b",
                        $time, u.ld_row, u.ld_col, u.ld_rows, u.ld_rowlen, u.ld_inside, u.ld_col_last, u.ld_row_last);
                end
            end
        end else begin : g_new_off
            assign {n_awready, n_wready, n_bvalid, n_arready, n_rvalid, n_bresp, n_rresp, n_rdata} = '0;
        end
        if (MODE == 0) begin : g_cmp
            // Lockstep: outputs and internal registers equal in every clock
            always @(negedge clk) if (aresetn) begin
                ncmp++;
                if ({o_awready, o_wready, o_bvalid, o_arready, o_rvalid, o_bresp, o_rresp, o_rdata} !==
                    {n_awready, n_wready, n_bvalid, n_arready, n_rvalid, n_bresp, n_rresp, n_rdata} ||
                    {g_old.u.ld_row, g_old.u.ld_col, g_old.u.ld_left, g_old.u.ld_word, g_old.u.ld_sel} !==
                    {g_new.u.ld_row, g_new.u.ld_col, g_new.u.ld_left, g_new.u.ld_word, g_new.u.ld_sel} ||
                    {g_old.u.core_wr_en, g_old.u.core_wr_sel, g_old.u.core_wr_row, g_old.u.core_wr_col, g_old.u.core_wr_data} !==
                    {g_new.u.core_wr_en, g_new.u.core_wr_sel, g_new.u.core_wr_row, g_new.u.core_wr_col, g_new.u.core_wr_data} ||
                    {g_old.u.core_start, g_old.u.rd_row, g_old.u.rd_col, g_old.u.done_flag, g_old.u.load_err,
                     g_old.u.dim_m, g_old.u.dim_k, g_old.u.dim_n, g_old.u.busy_h, g_old.u.core_rd_data} !==
                    {g_new.u.core_start, g_new.u.rd_row, g_new.u.rd_col, g_new.u.done_flag, g_new.u.load_err,
                     g_new.u.dim_m, g_new.u.dim_k, g_new.u.dim_n, g_new.u.busy_h, g_new.u.core_rd_data} ||
                    {g_old.u.perf_passes, g_old.u.perf_cycles, g_old.u.perf_total} !==
                    {g_new.u.perf_passes, g_new.u.perf_cycles, g_new.u.perf_total}) begin
                    errors++;
                    if (errors < 10) $display("LOCKSTEP MISMATCH at t=%0t (cycle %0d)", $time, ncmp);
                end
            end
        end
    endgenerate

    // The master follows the old design in MODE 0 and 1, the new one in MODE 2
    wire awready = (MODE == 2) ? n_awready : o_awready;
    wire wready  = (MODE == 2) ? n_wready  : o_wready;
    wire bvalid  = (MODE == 2) ? n_bvalid  : o_bvalid;
    wire arready = (MODE == 2) ? n_arready : o_arready;
    wire rvalid  = (MODE == 2) ? n_rvalid  : o_rvalid;
    wire [31:0] rdata = (MODE == 2) ? n_rdata : o_rdata;

    // ---------------------------------------------------------------- master
    int gseed = SEED, wseed = SEED * 3 + 1, rseed = SEED * 7 + 2, bseed = SEED * 11 + 3, kseed = SEED * 13 + 5;
    function automatic int rnd(input int n);         // 0 .. n-1, from the generator's own seed
        int x;
        x = $random(gseed);
        if (x < 0) x = -x;
        return (n <= 1) ? 0 : x % n;
    endfunction
    logic [37:0] wq [$];                             // {address, data}
    logic [6:0]  rq [$];                             // {log, address}
    logic [6:0]  rmeta [$];                          // reads offered, in order
    int w_issued = 0, w_done = 0, r_issued = 0, r_done = 0;
    longint ntx = 0;
    logic [31:0] last_rdata;
    integer logf;

    always @(negedge clk) begin
        bready <= (FAST != 0) ? 1'b1 : (($random(bseed) & 3) != 0);
        rready <= (FAST != 0) ? 1'b1 : (($random(kseed) & 3) != 0);
    end
    always @(posedge clk) if (bvalid && bready) w_done = w_done + 1;
    always @(posedge clk) if (rvalid && rready) begin
        logic [6:0] m;
        m = rmeta.pop_front();
        last_rdata = rdata;
        if (m[6] && MODE != 0) $fdisplay(logf, "R %h %h", m[5:0], rdata);
        r_done = r_done + 1;
    end
    initial begin : wdrv
        logic [37:0] t;
        int dly;
        wait (aresetn);
        forever begin
            @(negedge clk);
            if (wq.size() > 0) begin
                t = wq.pop_front();
                dly = (FAST != 0) ? 0 : ((($random(wseed) & 3) == 0) ? ($random(wseed) & 1) + 1 : 0);
                repeat (dly) @(negedge clk);
                awaddr = t[37:32]; wdata = t[31:0]; awvalid = 1'b1; wvalid = 1'b1;
                do @(posedge clk); while (!(awready && wready));
                @(negedge clk);
                awvalid = 1'b0; wvalid = 1'b0;
            end
        end
    end
    initial begin : rdrv
        logic [6:0] t;
        int dly;
        wait (aresetn);
        forever begin
            @(negedge clk);
            if (rq.size() > 0) begin
                t = rq.pop_front();
                dly = (FAST != 0) ? 0 : ((($random(rseed) & 3) == 0) ? ($random(rseed) & 1) + 1 : 0);
                repeat (dly) @(negedge clk);
                araddr = t[5:0]; arvalid = 1'b1;
                rmeta.push_back(t);
                do @(posedge clk); while (!arready);
                @(negedge clk);
                arvalid = 1'b0;
            end
        end
    end

    bit ordered = 1'b0;                              // like the ARM program: a write waits for earlier reads
    task automatic flush_r_now(); while (r_done != r_issued) @(posedge clk); endtask
    task automatic w(input logic [5:0] a, input logic [31:0] d);
        if (ordered) flush_r_now();
        wq.push_back({a, d}); w_issued++; ntx++;
    endtask
    task automatic r(input logic [5:0] a, input bit lg);
        rq.push_back({lg, a}); r_issued++; ntx++;
    endtask
    task automatic flush_w(); while (w_done != w_issued) @(posedge clk); endtask
    task automatic flush_r(); while (r_done != r_issued) @(posedge clk); endtask
    task automatic rd_now(input logic [5:0] a, output logic [31:0] v);
        flush_r(); r(a, 1'b0); flush_r(); v = last_rdata;
    endtask
    task automatic idle(input int n); repeat (n) @(posedge clk); endtask

    function automatic int pick_dim();
        int c;
        c = rnd(4);
        return (c == 0) ? 64 : (c == 1) ? rnd(8) + 1 : rnd(64) + 1;
    endfunction

    int lastM = 1, lastN = 1;
    // A whole run: sizes, A and B (sometimes from an offset, with extra or missing bytes), start,
    // poll, counters, pointer read-back, results from a random place
    task automatic scen_run(input bit order);
        int M, K, N, r0, c0, nb, nr, passes, cyc;
        logic [31:0] v;
        M = pick_dim(); K = pick_dim(); N = pick_dim();
        lastM = M; lastN = N;
        w(DIMS, {8'd0, 8'(N), 8'(K), 8'(M)});
        for (int s = 0; s < 2; s++) begin
            int R, Cn;
            R = (s == 0) ? M : K; Cn = (s == 0) ? K : N;
            r0 = (rnd(8) == 0) ? rnd(R + 2) : 0;
            c0 = (rnd(8) == 0) ? rnd(Cn + 2) : 0;
            w(LOAD_PTR, {8'd0, 8'(c0), 8'(r0), 7'd0, 1'(s)});
            nb = R * Cn + ((rnd(4) == 0) ? rnd(9) : 0) - ((rnd(8) == 0) ? rnd(5) : 0);
            for (int i = 0; i < (nb + 3) / 4; i++) w(LOAD_DATA, $random(gseed));
        end
        passes = ((K + P - 1) / P) * ((N + P - 1) / P);
        cyc = passes * (M + 3 * P - 2);
        w(CTRL, 32'd1);
        if (cyc > 500 && rnd(3) == 0) begin           // during the run: a second start and a load (both refused)
            w(CTRL, 32'd1);
            w(LOAD_DATA, $random(gseed));
        end
        if (order || rnd(2)) flush_w();
        do rd_now(STATUS, v); while (!v[1]);
        r(STATUS, 1'b1); r(PASSES, 1'b1); r(CYCLES, 1'b1); r(TOTAL, 1'b1); r(DIMS, 1'b1); r(LOAD_PTR, 1'b1);
        r0 = (rnd(4) == 0) ? rnd(M) : 0;
        c0 = (rnd(4) == 0) ? rnd(N) : 0;
        w(RES_PTR, {16'd0, 8'(c0), 8'(r0)});
        if (order || rnd(2)) flush_w();
        nr = M * N - (r0 * N + c0);
        if (rnd(3) == 0) nr = rnd(nr + 1);
        for (int i = 0; i < nr; i++) r(RES_DATA, 1'b1);
        flush_r();
    endtask
    // Register odds and ends
    task automatic scen_misc(input bit order);
        repeat (rnd(8) + 1) begin
            case (rnd(8))
                0: begin w(DIMS, {8'd0, 8'(rnd(65)), 8'(rnd(65)), 8'(rnd(65))}); if (order) flush_w(); r(DIMS, 1'b1); end
                1: begin w(LOAD_PTR, {8'd0, 8'(rnd(70)), 8'(rnd(70)), 7'd0, 1'(rnd(2))}); if (order) flush_w(); r(LOAD_PTR, 1'b1); end
                2: begin
                       w(DIMS, {8'd0, 8'(rnd(64) + 1), 8'(rnd(64) + 1), 8'(rnd(64) + 1)});
                       w(LOAD_PTR, {8'd0, 8'(rnd(66)), 8'(rnd(66)), 7'd0, 1'(rnd(2))});
                       repeat (rnd(6) + 1) w(LOAD_DATA, $random(gseed));
                       if (order) begin flush_w(); idle(8); end
                       r(LOAD_PTR, 1'b1);
                   end
                3: begin
                       w(RES_PTR, {16'd0, 8'(rnd(lastN)), 8'(rnd(lastM))});
                       if (order) flush_w();
                       repeat (rnd(6)) r(RES_DATA, 1'b1);
                   end
                4: r(INFO, 1'b1);
                5: r(ID, 1'b1);
                6: r(CONFIG, 1'b1);
                default: if (order) begin flush_w(); idle(8); r(STATUS, 1'b1); end
            endcase
        end
        flush_r();
    endtask

    initial begin
        if (MODE != 0) begin
            string fn;
            if (!$value$plusargs("LOGFILE=%s", fn)) fn = "tb_s14.log";
            logf = $fopen(fn, "w");
        end
        repeat (5) @(posedge clk);
        aresetn = 1'b1;
        repeat (5) @(posedge clk);
        for (int s = 0; s < NSCEN; s++) begin
            bit order;
            order = (MODE != 0) ? 1'b1 : 1'(rnd(2));
            ordered = order;
            if (rnd(3) == 0) scen_misc(order);
            else             scen_run(order);
        end
        flush_w(); flush_r();
        idle(20);
        if (MODE != 0) $fclose(logf);
        $display("tb_s14 MODE %0d HREG %0d P %0d PE_PRIM %0d SEED %0d FAST %0d: %0d scenarios, %0d transactions, %0d lockstep clocks, %0d flag checks, %0d errors",
                 MODE, HREG, P, PE_PRIM, SEED, FAST, NSCEN, ntx, ncmp, nflag, errors);
        if (errors == 0) $display("TB_S14 PASS"); else $display("TB_S14 FAIL");
        $finish;
    end
endmodule
