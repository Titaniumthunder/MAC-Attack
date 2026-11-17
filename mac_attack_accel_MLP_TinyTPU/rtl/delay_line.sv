`timescale 1ns/1ps
// Delays a WIDTH-bit value by DEPTH clock cycles (DEPTH must be 1 or more).
//
// RESET = 1: the stages clear to 0 on reset. Use this for control flags (valid bits).
// RESET = 0: no reset. Use this for data that only counts when a valid flag says so;
//            it keeps the reset wire short.
module delay_line #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 1,
    parameter int RESET = 1
)(
    input  logic             clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    // srl_style = "register": build the delay from flip-flops, not shift-register LUTs. A
    // shift-register LUT's output is slow (about 1.6 ns after the clock on this FPGA), and
    // with "srl_reg" Vivado moved the end flip-flop into the DSP, leaving the LUT output
    // to drive the long wire.
    (* srl_style = "register" *)
    logic [WIDTH-1:0] sh [DEPTH];             // sh[0] is the newest value
    generate
        if (RESET != 0) begin : g_rst
            always_ff @(posedge clk) begin
                if (rst) begin
                    for (int i = 0; i < DEPTH; i++) sh[i] <= '0;
                end else begin
                    sh[0] <= d;
                    for (int i = 1; i < DEPTH; i++) sh[i] <= sh[i-1];
                end
            end
        end else begin : g_norst
            /* verilator lint_off UNUSEDSIGNAL */
            logic unused_rst;
            assign unused_rst = rst;
            /* verilator lint_on UNUSEDSIGNAL */
            always_ff @(posedge clk) begin
                sh[0] <= d;
                for (int i = 1; i < DEPTH; i++) sh[i] <= sh[i-1];
            end
        end
    endgenerate
    assign q = sh[DEPTH-1];
endmodule
