`timescale 1ns/1ps
// Explicit Zynq-7000 DSP pipeline. Same activation/product/sum latency as
// pe(EARLY_MAC=2), with dedicated PCOUT-to-PCIN links between array rows.
module dsp_cascade_pe #(
    parameter int BITS = 8,
    parameter bit FIRST = 0,
    parameter bit LAST = 0
)(
    input logic clk, rst, w_load,
    input logic signed [BITS-1:0] w_in, a_in,
    output logic signed [BITS-1:0] w_out, a_out,
    input logic signed [47:0] psum_in,
    output wire signed [47:0] psum_out
);
    wire [47:0] result, cascade;
    always_ff @(posedge clk) begin
        if (rst) begin w_out <= '0; a_out <= '0; end
        else begin
            if (w_load) w_out <= w_in;
            a_out <= a_in;
        end
    end
    assign psum_out = LAST ? result : cascade;
    DSP48E1 #(
        .AREG(1), .ACASCREG(1), .BREG(1), .BCASCREG(1),
        .MREG(1), .PREG(1), .CREG(0), .DREG(0), .ADREG(0),
        .ALUMODEREG(0), .OPMODEREG(0), .INMODEREG(0),
        .CARRYINREG(0), .CARRYINSELREG(0),
        .USE_DPORT("FALSE"), .USE_MULT("MULTIPLY"), .USE_SIMD("ONE48")
    ) u_dsp (
        .CLK(clk), .A({{(30-BITS){a_in[BITS-1]}},a_in}),
        .B({{(18-BITS){w_in[BITS-1]}},w_in}),
        .C(48'd0), .D(25'd0), .ACIN(30'd0), .BCIN(18'd0),
        .PCIN(psum_in), .P(result), .PCOUT(cascade),
        .OPMODE(FIRST ? 7'b0000101 : 7'b0010101), .ALUMODE(4'b0000),
        .INMODE(5'b00000), .CARRYINSEL(3'b000), .CARRYIN(1'b0),
        .CARRYCASCIN(1'b0), .MULTSIGNIN(1'b0),
        .CEA1(1'b1), .CEA2(1'b1), .CEB1(w_load), .CEB2(w_load),
        .CEM(1'b1), .CEP(1'b1), .CEC(1'b0), .CED(1'b0), .CEAD(1'b0),
        .CEALUMODE(1'b0), .CECTRL(1'b0), .CEINMODE(1'b0), .CECARRYIN(1'b0),
        .RSTA(rst), .RSTB(rst), .RSTM(rst), .RSTP(rst), .RSTC(rst),
        .RSTD(rst), .RSTALUMODE(rst), .RSTCTRL(rst), .RSTINMODE(rst),
        .RSTALLCARRYIN(rst)
    );
endmodule
