`timescale 1ns/1ps
// sram_buf: one of mm_core's buffers (W bits x D words, one write port, one read port) built from
// SKY130 SRAM macros, for the ASIC (mm_core's SRAM = 1, step 16). The FPGA build does not use it.
//
// The macro is sky130_sram_2kbyte_1rw1r_32x512_8 (OpenRAM, in the PDK's sky130_sram_macros):
// 512 words of 32 bits, port 0 read/write with a 4-byte write mask, port 1 read only. Here port 0
// only writes (on wclk) and port 1 only reads (on rclk). Both ports take their inputs on the rising
// edge; the read data comes out after the falling edge of that clock. So rdata is the word at raddr
// one clock later, as with the FPGA buffers' registered read (q <= mem[addr]), and no cycle changes.
//
// The word is split over COLS = ceil(W / 32) macros side by side, and the depth over
// ROWS = ceil(D / 512) macros stacked (the top address bits pick the row; on the read side they are
// registered to pick that row's data one clock later). we[l] writes lane l (W / NWE bits) through the
// byte masks, so with NWE > 1 a lane must be a whole number of bytes. Unused bits of the last macro
// column are written with 0 and never read.
//
// A word must not be read in the clock it is written (the macro's read data is then undefined).
// mm_core never needs such a read: A and B are only written while the core is idle and only read
// while it runs, and a C word is read again only in a later pass, long after its write.
module sram_buf #(
    parameter int W   = 64,     // word width
    parameter int D   = 512,    // words
    parameter int NWE = 8,      // write enables, one per lane of W / NWE bits
    parameter int AW  = (D > 1) ? $clog2(D) : 1   // address width (leave as is)
)(
    input  logic           wclk,
    input  logic [NWE-1:0] we,
    input  logic [AW-1:0]  waddr,
    input  logic [W-1:0]   wdata,
    input  logic           rclk,
    input  logic [AW-1:0]  raddr,
    output logic [W-1:0]   rdata
);
    localparam int MW   = 32;                     // macro: word width
    localparam int MAW  = 9;                      //        address width (512 words)
    localparam int COLS = (W + MW - 1) / MW;
    localparam int ROWS = (D + (1 << MAW) - 1) >> MAW;
    localparam int LW   = W / NWE;                // lane width

    // Write data padded to whole macros, and one byte-mask bit per byte: the lane it belongs to
    logic [COLS*MW-1:0] wd;
    logic [COLS*4-1:0]  bmask;
    assign wd = (COLS*MW)'(wdata);
    for (genvar g = 0; g < COLS * 4; g++) begin : g_mask
        if (g * 8 < W) begin : g_used
            assign bmask[g] = we[(g * 8) / LW];
        end else begin : g_pad
            assign bmask[g] = |we;
        end
    end

    wire [ROWS*COLS*MW-1:0] q;                    // read data of every macro, row after row
    for (genvar r = 0; r < ROWS; r++) begin : g_row
        logic wsel;                               // this row holds the written word
        if (ROWS > 1) begin : g_wsel
            assign wsel = (waddr >> MAW) == r;
        end else begin : g_wsel1
            assign wsel = 1'b1;
        end
        for (genvar c = 0; c < COLS; c++) begin : g_col
            logic [3:0] m;
            logic       wr;
            assign m  = wsel ? bmask[c*4 +: 4] : 4'b0;
            assign wr = |m;
            sky130_sram_2kbyte_1rw1r_32x512_8
`ifndef SYNTHESIS
                // simulation model only: quiet, and read data in time for a 4 ns clock
                #(.VERBOSE(0), .DELAY(1))
`endif
                u_mem (
                .clk0(wclk), .csb0(!wr), .web0(!wr), .wmask0(m), .addr0(MAW'(waddr)),
                .din0(wd[c*MW +: MW]), .dout0(),
                .clk1(rclk), .csb1(1'b0), .addr1(MAW'(raddr)), .dout1(q[(r*COLS + c)*MW +: MW]));
        end
    end

    if (ROWS > 1) begin : g_rsel
        localparam int RW = $clog2(ROWS);
        logic [RW-1:0] rrow;                      // row of the word being read, one clock later
        always_ff @(posedge rclk) rrow <= RW'(raddr >> MAW);
        assign rdata = q[rrow * (COLS*MW) +: W];
    end else begin : g_rsel1
        assign rdata = q[W-1:0];
    end
endmodule
