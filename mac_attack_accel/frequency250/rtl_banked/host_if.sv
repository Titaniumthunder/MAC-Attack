`timescale 1ns/1ps
// Host interface: turns bytes from a laptop (over the UART) into commands for mm_core.
//
//   Laptop sends              Chip replies
//   'I'                       'M' 'A' 'C' P BITS ACC MAXD          (identify)
//   'D' m k n                 'k', or 'e' if a size is 0 or > MAXD (set sizes)
//   'A' + m*k bytes           'k'                                  (load A, row by row)
//   'B' + k*n bytes           'k'                                  (load B, row by row)
//   'G'                       'g' + passes + cycles + total        (run; 4 bytes each, LSB first)
//   'C'                       m*n results, 4 bytes each, LSB first (read C, row by row)
//   anything else             '?'
module host_if #(
    parameter int P    = 16,
    parameter int BITS = 8,
    parameter int ACC  = 32,      // at most 32
    parameter int MAXD = 64
)(
    input  logic            clk,
    input  logic            rst,
    // UART side
    input  logic            rx_valid,
    input  logic [7:0]      rx_data,
    output logic            tx_start,
    output logic [7:0]      tx_data,
    input  logic            tx_ready,
    // mm_core side
    output logic            wr_en,
    output logic            wr_sel,
    output logic [7:0]      wr_row,
    output logic [7:0]      wr_col,
    output logic [BITS-1:0] wr_data,
    output logic            start,
    output logic [7:0]      dim_m,
    output logic [7:0]      dim_k,
    output logic [7:0]      dim_n,
    input  logic            done,
    output logic [7:0]      rd_row,
    output logic [7:0]      rd_col,
    input  logic [ACC-1:0]  rd_data,
    input  logic [31:0]     perf_passes,
    input  logic [31:0]     perf_cycles,
    input  logic [31:0]     perf_total
);
    typedef enum logic [3:0] {
        S_CMD, S_DIMS, S_LOAD, S_RUN, S_CREAD, S_CW1, S_CW2, S_CNEXT,
        S_SEND_GO, S_SEND_HOLD, S_SEND_WAIT
    } state_t;
    state_t state, ret;

    logic [7:0] rbuf [13];          // reply bytes waiting to be sent
    int         rlen, ridx;
    int         cnt, row, col, rows, cols;
    logic [7:0] dbuf [3];
    logic [31:0] cval;
    assign cval = 32'(signed'(rd_data));     // C value sign-extended to 4 bytes

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_CMD; ret <= S_CMD;
            tx_start <= 1'b0; tx_data <= '0;
            wr_en <= 1'b0; wr_sel <= 1'b0; wr_row <= '0; wr_col <= '0; wr_data <= '0;
            start <= 1'b0; dim_m <= 8'd1; dim_k <= 8'd1; dim_n <= 8'd1;
            rd_row <= '0; rd_col <= '0;
            rlen <= 0; ridx <= 0; cnt <= 0; row <= 0; col <= 0; rows <= 1; cols <= 1;
        end else begin
            wr_en <= 1'b0;
            start <= 1'b0;
            tx_start <= 1'b0;
            case (state)
                S_CMD: if (rx_valid) begin
                    case (rx_data)
                        8'h49: begin                                   // 'I'
                            rbuf[0] <= 8'h4D; rbuf[1] <= 8'h41; rbuf[2] <= 8'h43;
                            rbuf[3] <= 8'(P); rbuf[4] <= 8'(BITS); rbuf[5] <= 8'(ACC); rbuf[6] <= 8'(MAXD);
                            rlen <= 7; ridx <= 0; ret <= S_CMD; state <= S_SEND_GO;
                        end
                        8'h44: begin cnt <= 0; state <= S_DIMS; end    // 'D'
                        8'h41, 8'h42: begin                            // 'A', 'B'
                            wr_sel <= (rx_data == 8'h42);
                            rows <= (rx_data == 8'h42) ? int'(dim_k) : int'(dim_m);
                            cols <= (rx_data == 8'h42) ? int'(dim_n) : int'(dim_k);
                            row <= 0; col <= 0; state <= S_LOAD;
                        end
                        8'h47: begin start <= 1'b1; state <= S_RUN; end   // 'G'
                        8'h43: begin row <= 0; col <= 0; state <= S_CREAD; end  // 'C'
                        default: begin
                            rbuf[0] <= 8'h3F; rlen <= 1; ridx <= 0; ret <= S_CMD; state <= S_SEND_GO;
                        end
                    endcase
                end
                S_DIMS: if (rx_valid) begin
                    dbuf[cnt] <= rx_data;
                    if (cnt == 2) begin
                        if (dbuf[0] == 0 || dbuf[1] == 0 || rx_data == 0 ||
                            int'(dbuf[0]) > MAXD || int'(dbuf[1]) > MAXD || int'(rx_data) > MAXD) begin
                            rbuf[0] <= 8'h65;                          // 'e'
                        end else begin
                            dim_m <= dbuf[0]; dim_k <= dbuf[1]; dim_n <= rx_data;
                            rbuf[0] <= 8'h6B;                          // 'k'
                        end
                        rlen <= 1; ridx <= 0; ret <= S_CMD; state <= S_SEND_GO;
                    end else cnt <= cnt + 1;
                end
                S_LOAD: if (rx_valid) begin
                    wr_en <= 1'b1; wr_row <= 8'(row); wr_col <= 8'(col); wr_data <= BITS'(rx_data);
                    if (col == cols - 1) begin
                        col <= 0;
                        if (row == rows - 1) begin
                            rbuf[0] <= 8'h6B; rlen <= 1; ridx <= 0; ret <= S_CMD; state <= S_SEND_GO;
                        end else row <= row + 1;
                    end else col <= col + 1;
                end
                S_RUN: if (done) begin
                    rbuf[0] <= 8'h67;                                  // 'g'
                    for (int b = 0; b < 4; b++) begin
                        rbuf[1 + b] <= perf_passes[8*b +: 8];
                        rbuf[5 + b] <= perf_cycles[8*b +: 8];
                        rbuf[9 + b] <= perf_total[8*b +: 8];
                    end
                    rlen <= 13; ridx <= 0; ret <= S_CMD; state <= S_SEND_GO;
                end
                S_CREAD: begin rd_row <= 8'(row); rd_col <= 8'(col); state <= S_CW1; end
                S_CW1:   state <= S_CW2;                           // C word is being read
                S_CW2: begin                                       // rd_data is valid now
                    for (int b = 0; b < 4; b++) rbuf[b] <= cval[8*b +: 8];
                    rlen <= 4; ridx <= 0; ret <= S_CNEXT; state <= S_SEND_GO;
                end
                S_CNEXT: begin
                    if (col == int'(dim_n) - 1) begin
                        col <= 0;
                        if (row == int'(dim_m) - 1) state <= S_CMD;
                        else begin row <= row + 1; state <= S_CREAD; end
                    end else begin col <= col + 1; state <= S_CREAD; end
                end
                // send rbuf[0 .. rlen-1], then go to ret
                S_SEND_GO: if (tx_ready) begin
                    tx_data <= rbuf[ridx]; tx_start <= 1'b1; state <= S_SEND_HOLD;
                end
                S_SEND_HOLD: state <= S_SEND_WAIT;                 // transmitter takes the byte
                S_SEND_WAIT: if (tx_ready) begin
                    if (ridx == rlen - 1) state <= ret;
                    else begin ridx <= ridx + 1; state <= S_SEND_GO; end
                end
                default: state <= S_CMD;
            endcase
        end
    end
endmodule
