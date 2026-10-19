`timescale 1ns/1ps
module tb_dsp_pipeline;
    logic clk=0, rst=1, w_load=0;
    always #2 clk=~clk;
    logic signed [7:0] a=0,w=0;
    logic signed [47:0] ps=0;
    wire signed [47:0] got[4], expected[4];
    wire signed [7:0] ga[4],gw[4],ea[4],ew[4];
    for(genvar g=0;g<4;g++) begin
        wire signed [47:0] pin = (g/2) ? 48'sd0 : ps;
        dsp_cascade_pe #(.FIRST(g/2),.LAST(g%2)) dut(
            .clk(clk),.rst(rst),.w_load(w_load),.w_in(w),.a_in(a),
            .w_out(gw[g]),.a_out(ga[g]),.psum_in(pin),.psum_out(got[g]));
        pe #(.BITS(8),.ACC(48),.SAT(0),.EARLY_MAC(2)) reference_pe(
            .clk(clk),.rst(rst),.w_load(w_load),.w_in(w),.a_in(a),
            .w_out(ew[g]),.a_out(ea[g]),.psum_in(pin),.psum_out(expected[g]));
    end
    initial begin
        repeat(60) @(posedge clk); // allow the vendor global startup reset to expire
        for(int t=0;t<2000;t++) begin
            @(negedge clk);
            rst=(t%127<3); w_load=($urandom_range(0,3)==0);
            a=$urandom; w=$urandom; ps={$urandom,$urandom};
            @(posedge clk); #1;
            for(int g=0;g<4;g++)
                if(got[g]!==expected[g] || ga[g]!==ea[g] || gw[g]!==ew[g])
                    $fatal(1,"FAIL DSP equivalence cycle %0d mode %0d: got %h expected %h",t,g,got[g],expected[g]);
        end
        $display("ALL TESTS PASSED: DSP primitive equivalence, 2000 cycles x 4 modes at 250 MHz");
        $finish;
    end
endmodule
