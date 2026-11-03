`timescale 1ns/1ps
// Testbench for chip_top: plays the laptop on the other end of the UART.
//
// Reads uart_script.hex, one 32-bit word per step:
//   0000_00xx  send byte xx to the chip
//   4nnn_nnnn  wait until n reply bytes have arrived in total
//   C000_0000  end
// Writes uart_out.hex: every byte the chip sent, one per line.
module tb_chip #(
    parameter int P            = 16,
    parameter int BITS         = 8,
    parameter int ACC          = 32,
    parameter int SAT          = 0,
    parameter int MAXD         = 64,
    parameter int CLKS_PER_BIT = 4,  // fast serial line for simulation
    parameter int PIPE         = 1,
    parameter int MEM_REG      = 1,
    parameter int HREAD_REG    = 0
);
    localparam int MAXS = 40000;

    logic clk = 1'b0, rst = 1'b1;
    always #5 clk = ~clk;

    logic rx_line = 1'b1;                    // laptop -> chip
    logic tx_line;                           // chip -> laptop
    logic busy_led;

    chip_top #(.P(P), .BITS(BITS), .ACC(ACC), .SAT(SAT), .MAXD(MAXD), .CLKS_PER_BIT(CLKS_PER_BIT),
              .PIPE(PIPE), .MEM_REG(MEM_REG), .HREAD_REG(HREAD_REG)) dut (
        .clk(clk), .rst(rst), .uart_rx_i(rx_line), .uart_tx_o(tx_line), .busy_led(busy_led));

    logic [31:0] script [MAXS];
    logic [7:0]  got [MAXS];
    int          ngot = 0;

    // laptop receiver: decode every byte the chip sends
    initial begin
        logic [7:0] b;
        @(negedge rst);
        forever begin
            @(negedge tx_line);
            repeat (CLKS_PER_BIT / 2) @(posedge clk);
            for (int i = 0; i < 8; i++) begin
                repeat (CLKS_PER_BIT) @(posedge clk);
                b[i] = tx_line;
            end
            repeat (CLKS_PER_BIT) @(posedge clk);
            got[ngot] = b;
            ngot = ngot + 1;
        end
    end

    task automatic send_byte(input logic [7:0] b);
        rx_line = 1'b0;
        repeat (CLKS_PER_BIT) @(posedge clk);
        for (int i = 0; i < 8; i++) begin
            rx_line = b[i];
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        rx_line = 1'b1;
        repeat (2 * CLKS_PER_BIT) @(posedge clk);   // stop bit plus a short gap
    endtask

    int fd, step, waited;
    initial begin
        for (int i = 0; i < MAXS; i++) script[i] = 32'hC000_0000;
        $readmemh("uart_script.hex", script);
        repeat (4) @(posedge clk);
        rst = 1'b0;
        repeat (4) @(posedge clk);
        step = 0;
        while (script[step][31:30] != 2'b11) begin
            if (script[step][31:30] == 2'b00) begin
                send_byte(script[step][7:0]);
            end else begin
                waited = 0;
                while (ngot < int'(script[step][29:0]) && waited < 5000000) begin
                    @(posedge clk);
                    waited++;
                end
                if (ngot < int'(script[step][29:0])) begin
                    $display("ERROR: timeout waiting for %0d reply bytes (got %0d)", script[step][29:0], ngot);
                    step = MAXS - 1;
                end
            end
            step++;
        end
        repeat (20) @(posedge clk);
        fd = $fopen("uart_out.hex", "w");
        for (int i = 0; i < ngot; i++) $fdisplay(fd, "%h", got[i]);
        $fclose(fd);
        $display("TB_DONE received=%0d", ngot);
        $finish;
    end
endmodule
