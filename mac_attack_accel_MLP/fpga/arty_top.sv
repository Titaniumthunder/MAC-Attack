`timescale 1ns/1ps
// Board top for the Digilent Arty A7 (35T or 100T): the chip plus clock, reset and LEDs.
//
//   CLK100MHZ     100 MHz board clock
//   ck_rst        red RESET button (low when pressed)
//   uart_txd_in   serial data from the laptop (USB-UART)  -> chip RX
//   uart_rxd_out  serial data to the laptop                <- chip TX
//   led[0]        on while the matrix core is computing
//   led[1]        blinks about once a second: the design is running
module arty_top #(
    parameter int P = 16                 // use 8 if 16 does not fit the board
)(
    input  logic       CLK100MHZ,
    input  logic       ck_rst,
    input  logic       uart_txd_in,
    output logic       uart_rxd_out,
    output logic [3:0] led
);
    // the button is not synchronous to the clock: pass it through two flip-flops
    logic rst_meta = 1'b1, rst = 1'b1;
    always_ff @(posedge CLK100MHZ) begin
        rst_meta <= !ck_rst;
        rst      <= rst_meta;
    end

    logic [26:0] beat = '0;
    always_ff @(posedge CLK100MHZ) beat <= beat + 27'd1;

    logic busy;
    chip_top #(.P(P), .BITS(8), .ACC(32), .SAT(0), .MAXD(64), .CLKS_PER_BIT(868)) u_chip (
        .clk(CLK100MHZ), .rst(rst), .uart_rx_i(uart_txd_in), .uart_tx_o(uart_rxd_out), .busy_led(busy));

    assign led = {2'b00, beat[26], busy};
endmodule
