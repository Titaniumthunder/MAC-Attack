`timescale 1ns/1ps
// pe_dsp48: one PE as one DSP48E1, placed directly (step 11b, 17 Oct 2026). FPGA only (Vivado / 7-series).
//
// It is the same circuit as pe.sv with PIPE = 2, cycle for cycle:
//
//   pe.sv, PIPE = 2                         DSP48E1 here
//   a_q      <= a_in                        A2 register  (AREG = 1, CEA2 = 1)
//   w        <= w_in   when w_load          B2 register  (BREG = 1, CEB2 = w_load)
//   m_q      <= a_q * w                     M register   (MREG = 1)
//   psum_out <= psum_in + m_q               P register   (PREG = 1): P = PCIN + M (row 0: P = 0 + M)
//   w_out     = w                           BCOUT -> BCIN of the PE below (weight shift chain)
//   psum_out -> psum_in of the PE below     PCOUT -> PCIN of the PE below (partial sum)
//   a_out    <= a_in                        a flip-flop in the fabric (to the PE on the right)
//
// Why it is placed by hand: from pe.sv (PIPE = 2) Vivado 2019.1 built two DSPs per PE (the multiply in
// one, the add in another) with the product crossing the general routing between them, which is the
// path that failed at 200 MHz in step 6. Here each PE is exactly one DSP and both chains (weights and
// partial sums) use the dedicated cascade wires between DSPs stacked in one column.
//
// Numbers: A is the activation sign-extended to 30 bits, B the weight sign-extended to 18 bits, the
// product and the sums are 48 bits inside the DSP; psum_out is the low ACC bits. Two's-complement
// sums wrap the same way at any width, so the low ACC bits are exactly what pe.sv computes.
//
// Simulation needs Xilinx's DSP48E1 model: Vivado's simulator has it; for Icarus use DSP48E1.v and
// glbl.v from github.com/Xilinx/XilinxUnisimLibrary (the model holds its registers in reset for the
// first 100 ns, the global set/reset).
module pe_dsp48 #(
    parameter int BITS      = 8,
    parameter int ACC       = 22,   // at most 48
    parameter int FIRST_ROW = 0     // 1 = top row: weights come from w_in, nothing to add from above
)(
    input  logic                   clk,
    input  logic                   w_load,    // 1: take a new weight from above
    input  logic signed [BITS-1:0] w_in,      // weight from the B buffer (top row only)
    /* verilator lint_off UNUSEDSIGNAL */      // bcin, pcin: not used in the top row; w_in: only in the top row
    input  logic [17:0]            bcin,      // weight cascade from the PE above (other rows; top row: unused)
    output logic [17:0]            bcout,     // weight cascade to the PE below
    input  logic signed [BITS-1:0] a_in,
    output logic signed [BITS-1:0] a_out,     // to the PE on the right
    input  logic [47:0]            pcin,      // partial sum cascade from the PE above (other rows; top row: unused)
    /* verilator lint_on UNUSEDSIGNAL */
    output logic [47:0]            pcout,     // partial sum cascade to the PE below
    output logic signed [ACC-1:0]  psum_out   // the partial sum (used from the bottom row)
);
    // OPMODE: X = M, Y = M (the multiplier), Z = PCIN for rows below the top, 0 for the top row
    localparam logic [6:0] OPM = (FIRST_ROW != 0) ? 7'b000_01_01 : 7'b001_01_01;

    logic [29:0] a_ext;
    /* verilator lint_off UNUSEDSIGNAL */
    logic [17:0] b_ext;                       // used by the top row only
    /* verilator lint_on UNUSEDSIGNAL */
    logic [47:0] p;
    assign a_ext = {{(30 - BITS){a_in[BITS-1]}}, a_in};
    assign b_ext = {{(18 - BITS){w_in[BITS-1]}}, w_in};

    always_ff @(posedge clk) a_out <= a_in;

    // Two copies that differ only in B_INPUT (a string parameter, so it is chosen by generate).
    // Unused DSP pins are left open on purpose (cascade inputs must not be tied in the fabric).
    /* verilator lint_off PINCONNECTEMPTY */
    generate
        if (FIRST_ROW != 0) begin : g_top     // weights from w_in
            DSP48E1 #(
                .A_INPUT("DIRECT"), .B_INPUT("DIRECT"),
                .AREG(1), .ACASCREG(1), .BREG(1), .BCASCREG(1), .MREG(1), .PREG(1),
                .CREG(0), .DREG(0), .ADREG(0),
                .OPMODEREG(0), .ALUMODEREG(0), .CARRYINREG(0), .CARRYINSELREG(0), .INMODEREG(0),
                .USE_MULT("MULTIPLY"), .USE_DPORT("FALSE"), .USE_SIMD("ONE48"),
                .USE_PATTERN_DETECT("NO_PATDET")
            ) u_dsp (
                .CLK(clk),
                .A(a_ext), .B(b_ext), .C(48'd0), .D(25'd0),
                .ACIN(), .BCIN(), .PCIN(), .CARRYCASCIN(), .MULTSIGNIN(),   // cascade inputs: not used
                .OPMODE(OPM), .ALUMODE(4'b0000), .INMODE(5'b00000), .CARRYIN(1'b0), .CARRYINSEL(3'b000),
                .CEA1(1'b0), .CEA2(1'b1), .CEB1(1'b0), .CEB2(w_load), .CEC(1'b0), .CED(1'b0), .CEAD(1'b0),
                .CEM(1'b1), .CEP(1'b1), .CECTRL(1'b0), .CEALUMODE(1'b0), .CECARRYIN(1'b0), .CEINMODE(1'b0),
                .RSTA(1'b0), .RSTB(1'b0), .RSTC(1'b0), .RSTD(1'b0), .RSTM(1'b0), .RSTP(1'b0),
                .RSTCTRL(1'b0), .RSTALLCARRYIN(1'b0), .RSTALUMODE(1'b0), .RSTINMODE(1'b0),
                .P(p), .PCOUT(pcout), .BCOUT(bcout),
                .ACOUT(), .CARRYCASCOUT(), .MULTSIGNOUT(), .OVERFLOW(), .UNDERFLOW(),
                .PATTERNDETECT(), .PATTERNBDETECT(), .CARRYOUT()
            );
        end else begin : g_below              // weights from the PE above, on the B cascade
            DSP48E1 #(
                .A_INPUT("DIRECT"), .B_INPUT("CASCADE"),
                .AREG(1), .ACASCREG(1), .BREG(1), .BCASCREG(1), .MREG(1), .PREG(1),
                .CREG(0), .DREG(0), .ADREG(0),
                .OPMODEREG(0), .ALUMODEREG(0), .CARRYINREG(0), .CARRYINSELREG(0), .INMODEREG(0),
                .USE_MULT("MULTIPLY"), .USE_DPORT("FALSE"), .USE_SIMD("ONE48"),
                .USE_PATTERN_DETECT("NO_PATDET")
            ) u_dsp (
                .CLK(clk),
                .A(a_ext), .B(18'd0), .C(48'd0), .D(25'd0),
                .ACIN(), .BCIN(bcin), .PCIN(pcin), .CARRYCASCIN(), .MULTSIGNIN(),
                .OPMODE(OPM), .ALUMODE(4'b0000), .INMODE(5'b00000), .CARRYIN(1'b0), .CARRYINSEL(3'b000),
                .CEA1(1'b0), .CEA2(1'b1), .CEB1(1'b0), .CEB2(w_load), .CEC(1'b0), .CED(1'b0), .CEAD(1'b0),
                .CEM(1'b1), .CEP(1'b1), .CECTRL(1'b0), .CEALUMODE(1'b0), .CECARRYIN(1'b0), .CEINMODE(1'b0),
                .RSTA(1'b0), .RSTB(1'b0), .RSTC(1'b0), .RSTD(1'b0), .RSTM(1'b0), .RSTP(1'b0),
                .RSTCTRL(1'b0), .RSTALLCARRYIN(1'b0), .RSTALUMODE(1'b0), .RSTINMODE(1'b0),
                .P(p), .PCOUT(pcout), .BCOUT(bcout),
                .ACOUT(), .CARRYCASCOUT(), .MULTSIGNOUT(), .OVERFLOW(), .UNDERFLOW(),
                .PATTERNDETECT(), .PATTERNBDETECT(), .CARRYOUT()
            );
        end
    endgenerate
    /* verilator lint_on PINCONNECTEMPTY */
    /* verilator lint_off UNUSEDSIGNAL */
    logic [47-ACC:0] unused_p;
    assign unused_p = p[47:ACC];                // the DSP keeps 48 bits; the low ACC bits are the result
    /* verilator lint_on UNUSEDSIGNAL */
    assign psum_out = p[ACC-1:0];
endmodule
