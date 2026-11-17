`timescale 1ns/1ps
// tb_cosim: runs an ARM board program (sw/*.c, unchanged) against the Tiny-TPU V1 RTL in Vivado's simulator.
// The C program is compiled into the simulation (DPI-C, xsc); every Xil_Out32 / Xil_In32 it makes becomes an
// AXI4-Lite write or read on tiny_tpu_axi here, so the RTL sees exactly the bus traffic the ZedBoard's ARM
// will send. The same harness as ../../../fpga_zed_v2/sim/xsim_cosim (Version 2).
//
// Run: run_xsim_cosim.bat <program>, e.g. run_xsim_cosim.bat tinytpu_model_test (see README.md in this folder).
// The program's printf output appears in the console; the run ends with "program returned 0" on success.
module tb_cosim;
    logic clk = 1'b0, aresetn = 1'b0;
    always #5 clk = ~clk;                        // 100 MHz, the board build's PL clock (FCLK_MHZ)

    logic [3:0]  awaddr = '0, araddr = '0;
    logic        awvalid = 1'b0, wvalid = 1'b0, bready = 1'b0, arvalid = 1'b0, rready = 1'b0;
    logic [31:0] wdata = '0;
    wire         awready, wready, bvalid, arready, rvalid;
    wire [1:0]   bresp, rresp;
    wire [31:0]  rdata;

    tiny_tpu_axi dut (
        .s_axi_aclk(clk), .s_axi_aresetn(aresetn),
        .s_axi_awaddr(awaddr), .s_axi_awprot(3'b000), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arprot(3'b000), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready));

    longint cycle = 0;
    int bus_errors = 0;
    always @(posedge clk) cycle <= cycle + 1;

    // ------------------------------------------------------------ called from the C program (shim.c)
    export "DPI-C" task sv_axi_write;
    export "DPI-C" task sv_axi_read;
    export "DPI-C" function sv_cycles;
    import "DPI-C" context task c_run_program(output int rc);

    task automatic sv_axi_write(input int unsigned addr, input int unsigned data);
        int t = 0;
        @(negedge clk);
        awaddr = 4'(addr); wdata = data; awvalid = 1'b1; wvalid = 1'b1; bready = 1'b1;
        do begin @(posedge clk); t++; end while (!(awready && wready) && t < 10000);
        @(negedge clk);
        awvalid = 1'b0; wvalid = 1'b0;
        while (!bvalid && t < 10000) begin @(negedge clk); t++; end
        if (bresp != 2'b00 || t >= 10000) bus_errors++;
        @(posedge clk);
        @(negedge clk);
        bready = 1'b0;
    endtask

    task automatic sv_axi_read(input int unsigned addr, output int unsigned data);
        int t = 0;
        @(negedge clk);
        araddr = 4'(addr); arvalid = 1'b1; rready = 1'b1;
        do begin @(posedge clk); t++; end while (!arready && t < 10000);
        @(negedge clk);
        arvalid = 1'b0;
        while (!rvalid && t < 10000) begin @(negedge clk); t++; end
        data = rdata;
        if (rresp != 2'b00 || t >= 10000) bus_errors++;
        @(posedge clk);
        @(negedge clk);
        rready = 1'b0;
    endtask

    function longint sv_cycles();
        return cycle;
    endfunction

    initial begin
        int rc;
        repeat (5) @(posedge clk);
        aresetn = 1'b1;
        repeat (5) @(posedge clk);
        c_run_program(rc);
        $display("[xsim cosim] program returned %0d, %0d bus errors, %0d clocks", rc, bus_errors, cycle);
        $finish;
    end
endmodule
