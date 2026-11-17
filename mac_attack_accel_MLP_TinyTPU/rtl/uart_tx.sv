`timescale 1ns/1ps
// UART transmitter: 8N1, least significant bit first.
// tx_start is accepted only while tx_ready is high; tx_ready drops on the next cycle
// and comes back when the stop bit has been sent.
module uart_tx #(
    parameter int CLKS_PER_BIT = 868
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_ready,
    output logic       tx            // serial line, idles high
);
    logic [9:0] frame;               // stop bit, 8 data bits, start bit
    int         cnt, bitn;
    logic       active;

    assign tx_ready = !active;

    always_ff @(posedge clk) begin
        if (rst) begin
            active <= 1'b0; tx <= 1'b1; frame <= '1; cnt <= 0; bitn <= 0;
        end else if (!active) begin
            tx <= 1'b1;
            if (tx_start) begin
                frame  <= {1'b1, tx_data, 1'b0};
                active <= 1'b1; cnt <= 0; bitn <= 0;
                tx     <= 1'b0;                  // start bit goes out right away
            end
        end else begin
            if (cnt == CLKS_PER_BIT - 1) begin
                cnt <= 0;
                if (bitn == 9) begin
                    active <= 1'b0; tx <= 1'b1;
                end else begin
                    bitn <= bitn + 1;
                    tx   <= frame[bitn + 1];
                end
            end else cnt <= cnt + 1;
        end
    end
endmodule
