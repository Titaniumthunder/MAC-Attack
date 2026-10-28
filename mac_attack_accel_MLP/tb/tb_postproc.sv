`timescale 1ns/1ps
// Testbench for postproc, driven by files so that mac.py can check it against Python.
//
// Reads:     pp_acc.hex, pp_bias.hex   N values each, 32-bit hex, one per line
//            with +PERCH=1 also pp_m0.hex (16-bit), pp_shift.hex (6-bit), pp_relu.hex (1-bit):
//            a different scale and ReLU for every value, as for one scale per output channel
// Plusargs:  +N=<count> +M0=<m0> +SH=<shift> +RELU=<0|1> (used when +PERCH is not given)
// Writes:    pp_out.hex                N outputs, one per line
// Feeds one value per cycle to show the unit keeps up at full rate.
// PPIPE: 0 = the 3-stage unit, 1 = the 7-stage unit, 2 = the 9-stage unit (see postproc.sv).
module tb_postproc #(
    parameter int ACC   = 32,
    parameter int OBITS = 8,
    parameter int PPIPE = 0
);
    localparam int MAXN = 4096;
    localparam int LAT  = (PPIPE == 0) ? 3 : (PPIPE == 1) ? 7 : 9;

    logic clk = 1'b0, rst = 1'b1;
    always #5 clk = ~clk;

    logic                    in_valid = 1'b0, relu = 1'b0;
    logic signed [ACC-1:0]   in_acc = '0;
    logic signed [31:0]      in_bias = '0;
    logic [15:0]             m0 = '0;
    logic [5:0]              shift = 6'd1;
    logic                    out_valid;
    logic signed [OBITS-1:0] out_q;

    postproc #(.ACC(ACC), .OBITS(OBITS), .PPIPE(PPIPE)) dut (
        .clk(clk), .rst(rst), .in_valid(in_valid), .in_acc(in_acc), .in_bias(in_bias),
        .m0(m0), .shift(shift), .relu(relu), .out_valid(out_valid), .out_q(out_q));

    logic [31:0] accs  [MAXN];
    logic [31:0] biass [MAXN];
    logic [15:0] m0s   [MAXN];
    logic [5:0]  shs   [MAXN];
    logic [0:0]  relus [MAXN];
    int N, M0, SH, RELU, PERCH, fd, got;

    // collect outputs as they appear
    always @(posedge clk) begin
        if (out_valid) begin
            $fdisplay(fd, "%h", out_q);
            got <= got + 1;
        end
    end

    initial begin
        if (!$value$plusargs("N=%d", N)) N = 1;
        if (!$value$plusargs("M0=%d", M0)) M0 = 16384;
        if (!$value$plusargs("SH=%d", SH)) SH = 15;
        if (!$value$plusargs("RELU=%d", RELU)) RELU = 0;
        if (!$value$plusargs("PERCH=%d", PERCH)) PERCH = 0;
        $readmemh("pp_acc.hex", accs, 0, N - 1);
        $readmemh("pp_bias.hex", biass, 0, N - 1);
        if (PERCH != 0) begin
            $readmemh("pp_m0.hex", m0s, 0, N - 1);
            $readmemh("pp_shift.hex", shs, 0, N - 1);
            $readmemh("pp_relu.hex", relus, 0, N - 1);
        end
        fd = $fopen("pp_out.hex", "w");
        got = 0;
        m0 = 16'(M0); shift = 6'(SH); relu = (RELU != 0);
        repeat (3) @(negedge clk);
        rst = 1'b0;
        for (int i = 0; i < N; i++) begin
            @(negedge clk);
            in_valid = 1'b1; in_acc = ACC'(accs[i]); in_bias = biass[i];
            if (PERCH != 0) begin m0 = m0s[i]; shift = shs[i]; relu = relus[i][0]; end
        end
        @(negedge clk);
        in_valid = 1'b0;
        // change the scale inputs while nothing is valid: no output may change
        if (PERCH != 0) begin m0 = 16'hFFFF; shift = 6'd1; relu = 1'b0; end
        repeat (LAT + 3) @(negedge clk);
        $fclose(fd);
        $display("TB_DONE outputs=%0d", got);
        $finish;
    end
endmodule
