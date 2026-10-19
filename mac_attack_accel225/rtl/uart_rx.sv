`timescale 1ns/1ps
// UART receiver: 8 data bits, no parity, 1 stop bit (8N1), least significant bit first.
// CLKS_PER_BIT = clock frequency / baud rate (868 for 100 MHz and 115200 baud).
module uart_rx #(
    parameter int CLKS_PER_BIT = 868
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,          // serial line, idles high
    output logic       rx_valid,    // one-cycle pulse when rx_data holds a new byte
    output logic [7:0] rx_data
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    logic   rx_s1, rx_s2;            // two flip-flops: the line comes from outside the clock domain
    int     cnt, bitn;

    always_ff @(posedge clk) begin
        if (rst) begin
            rx_s1 <= 1'b1; rx_s2 <= 1'b1;
            state <= IDLE; cnt <= 0; bitn <= 0; rx_valid <= 1'b0; rx_data <= '0;
        end else begin
            rx_s1 <= rx; rx_s2 <= rx_s1;
            rx_valid <= 1'b0;
            case (state)
                IDLE: if (!rx_s2) begin state <= START; cnt <= 0; end
                START: begin                        // check the start bit in its middle
                    if (cnt == CLKS_PER_BIT / 2 - 1) begin
                        if (!rx_s2) begin state <= DATA; cnt <= 0; bitn <= 0; end
                        else state <= IDLE;         // glitch, not a start bit
                    end else cnt <= cnt + 1;
                end
                DATA: begin                         // sample each bit in its middle
                    if (cnt == CLKS_PER_BIT - 1) begin
                        cnt <= 0;
                        rx_data <= {rx_s2, rx_data[7:1]};
                        if (bitn == 7) state <= STOP; else bitn <= bitn + 1;
                    end else cnt <= cnt + 1;
                end
                STOP: begin
                    if (cnt == CLKS_PER_BIT - 1) begin
                        state <= IDLE; cnt <= 0;
                        if (rx_s2) rx_valid <= 1'b1;   // drop the byte if the stop bit is wrong
                    end else cnt <= cnt + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
