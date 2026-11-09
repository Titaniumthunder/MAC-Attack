// Watches tb_axi.dut: the step 14 loader flags must equal their definitions whenever a byte is written
module mon_axi;
    longint nflag = 0; int err = 0;
    always @(posedge tb_axi.clk) if (tb_axi.aresetn && tb_axi.dut.ld_left != 3'd0) begin
        nflag++;
        if (tb_axi.dut.ld_inside !== ((tb_axi.dut.ld_row < tb_axi.dut.ld_rows) && (tb_axi.dut.ld_col < tb_axi.dut.ld_rowlen)) ||
            tb_axi.dut.ld_col_last !== (tb_axi.dut.ld_col == tb_axi.dut.ld_collast) ||
            tb_axi.dut.ld_row_last !== (tb_axi.dut.ld_row == 8'(tb_axi.dut.ld_rows - 8'd1))) err++;
    end
    final $display("MON flag checks %0d, mismatches %0d", nflag, err);
endmodule
