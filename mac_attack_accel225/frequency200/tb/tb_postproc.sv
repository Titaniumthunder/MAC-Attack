`timescale 1ns/1ps
// Testbench for postproc, driven by files so that mac.py can check it against Python.
//
// Reads:     pp_acc.hex, pp_bias.hex   N values each, 32-bit hex, one per line
// Plusargs:  +N=<count> +M0=<m0> +SH=<shift> +RELU=<0|1>
// Writes:    pp_out.hex                N outputs, one per line
// Feeds one value per cycle to show the unit keeps up at full rate.
module tb_postproc #(
    parameter int ACC   = 32,
    parameter int OBITS = 8
);
    localparam int MAXN = 4096;

    logic clk = 1'b0, rst = 1'b1;
    always #5 clk = ~clk;

    logic                    in_valid = 1'b0, relu = 1'b0;
    logic signed [ACC-1:0]   in_acc = '0;
    logic signed [31:0]      in_bias = '0;
    logic [15:0]             m0 = '0;
    logic [5:0]              shift = 6'd1;
    logic                    out_valid;
    logic signed [OBITS-1:0] out_q;

    postproc #(.ACC(ACC), .OBITS(OBITS)) dut (
        .clk(clk), .rst(rst), .in_valid(in_valid), .in_acc(in_acc), .in_bias(in_bias),
        .m0(m0), .shift(shift), .relu(relu), .out_valid(out_valid), .out_q(out_q));

    logic [31:0] accs  [MAXN];
    logic [31:0] biass [MAXN];
    int N, M0, SH, RELU, fd, got;

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
        $readmemh("pp_acc.hex", accs, 0, N - 1);
        $readmemh("pp_bias.hex", biass, 0, N - 1);
        fd = $fopen("pp_out.hex", "w");
        got = 0;
        m0 = 16'(M0); shift = 6'(SH); relu = (RELU != 0);
        repeat (3) @(negedge clk);
        rst = 1'b0;
        for (int i = 0; i < N; i++) begin
            @(negedge clk);
            in_valid = 1'b1; in_acc = ACC'(accs[i]); in_bias = biass[i];
        end
        @(negedge clk);
        in_valid = 1'b0;
        repeat (6) @(negedge clk);
        $fclose(fd);
        $display("TB_DONE outputs=%0d", got);
        $finish;
    end
endmodule
