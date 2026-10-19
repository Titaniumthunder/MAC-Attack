`timescale 1ns/1ps
// Chip top: the matrix core with a serial (UART) port to a laptop.
//
//   laptop --UART--> uart_rx --> host_if --> mm_core (array, buffers, controller)
//   laptop <--UART-- uart_tx <-- host_if <--
//
// On the Arty A7 this connects to the board's USB-UART; in simulation tb_chip
// plays the laptop.
module chip_top #(
    parameter int P            = 16,
    parameter int BITS         = 8,
    parameter int ACC          = 32,
    parameter int SAT          = 0,
    parameter int MAXD         = 64,
    parameter int CLKS_PER_BIT = 868     // 100 MHz / 115200 baud
)(
    input  logic clk,
    input  logic rst,
    input  logic uart_rx_i,
    output logic uart_tx_o,
    output logic busy_led
);
    logic            rx_valid, tx_start, tx_ready;
    logic [7:0]      rx_data, tx_data;
    logic            wr_en, wr_sel, start, busy, done;
    logic [7:0]      wr_row, wr_col, dim_m, dim_k, dim_n, rd_row, rd_col;
    logic [BITS-1:0] wr_data;
    logic [ACC-1:0]  rd_data;
    logic [31:0]     perf_passes, perf_cycles, perf_total;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk), .rst(rst), .rx(uart_rx_i), .rx_valid(rx_valid), .rx_data(rx_data));

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data), .tx_ready(tx_ready), .tx(uart_tx_o));

    host_if #(.P(P), .BITS(BITS), .ACC(ACC), .MAXD(MAXD)) u_host (
        .clk(clk), .rst(rst),
        .rx_valid(rx_valid), .rx_data(rx_data), .tx_start(tx_start), .tx_data(tx_data), .tx_ready(tx_ready),
        .wr_en(wr_en), .wr_sel(wr_sel), .wr_row(wr_row), .wr_col(wr_col), .wr_data(wr_data),
        .start(start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n), .done(done),
        .rd_row(rd_row), .rd_col(rd_col), .rd_data(rd_data),
        .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total));

    mm_core #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT), .MAXD(MAXD)) u_core (
        .clk(clk), .hclk(clk), .rst(rst),
        .wr_en(wr_en), .wr_sel(wr_sel), .wr_row(wr_row), .wr_col(wr_col), .wr_data(wr_data),
        .start(start), .dim_m(dim_m), .dim_k(dim_k), .dim_n(dim_n), .busy(busy), .done(done),
        .rd_row(rd_row), .rd_col(rd_col), .rd_data(rd_data),
        .perf_passes(perf_passes), .perf_cycles(perf_cycles), .perf_total(perf_total));

    assign busy_led = busy;
endmodule
