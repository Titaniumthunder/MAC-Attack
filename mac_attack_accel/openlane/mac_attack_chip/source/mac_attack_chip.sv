`timescale 1ns/1ps
// Top level for the OpenLane 2 run (SKY130): a small but complete version of the chip.
//
//   serial line in -> uart_rx -> host_if -> mm_core (A, B, C buffers + P x P systolic array)
//   serial line out <- uart_tx <----'
//
// Same RTL as the FPGA/simulation version; only the sizes are smaller so the layout runs
// in minutes. Change P and MAXD here to try other sizes (P = 8, MAXD = 16 is about 4x bigger).
//
// 250 MHz (20 Oct 2026): the core settings of the ZedBoard build that met 250 MHz (step 14):
// PIPE = 2, MEM_REG = 2, HREAD_REG = 1 and exact accumulators (ACC = 2*8 + clog2(MAXD)).
// The PEs are pe.sv (standard cells), not the FPGA's DSP48E1 primitives.
module mac_attack_chip #(
    parameter int P            = 4,     // P x P systolic array
    parameter int MAXD         = 8,     // largest matrix: MAXD x MAXD
    parameter int CLKS_PER_BIT = 2170   // 250 MHz clock / 115,200 baud
)(
    input  logic clk,
    input  logic rst,                   // active high, synchronous
    input  logic uart_rx_i,             // serial data from the host
    output logic uart_tx_o,             // serial data to the host
    output logic busy_led               // high while the core computes
);
    chip_top #(.P(P), .BITS(8), .ACC(16 + $clog2(MAXD)), .SAT(0), .MAXD(MAXD), .CLKS_PER_BIT(CLKS_PER_BIT),
               .PIPE(2), .MEM_REG(2), .HREAD_REG(1)) u_chip (
        .clk(clk), .rst(rst), .uart_rx_i(uart_rx_i), .uart_tx_o(uart_tx_o), .busy_led(busy_led));
endmodule
