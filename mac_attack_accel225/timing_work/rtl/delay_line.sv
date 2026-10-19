`timescale 1ns/1ps
// Delays a WIDTH-bit value by DEPTH clock cycles (DEPTH must be 1 or more).
module delay_line #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 1
)(
    input  logic             clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    logic [WIDTH-1:0] sh [DEPTH];             // sh[0] is the newest value
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < DEPTH; i++) sh[i] <= '0;
        end else begin
            sh[0] <= d;
            for (int i = 1; i < DEPTH; i++) sh[i] <= sh[i-1];
        end
    end
    assign q = sh[DEPTH-1];
endmodule
