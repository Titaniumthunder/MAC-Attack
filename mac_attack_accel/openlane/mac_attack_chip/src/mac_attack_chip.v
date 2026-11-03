// MAC Attack accelerator: a small but complete chip for OpenLane 2 (SKY130).
//
// Generated from the team's SystemVerilog (rtl/*.sv plus source/mac_attack_chip.sv)
// with sv2v 0.0.13.1, because OpenLane's synthesizer (Yosys) reads plain Verilog best:
//
//   sv2v --top=mac_attack_chip rtl/delay_line.sv rtl/pe.sv rtl/systolic_array.sv rtl/mm_core.sv \
//        rtl/uart_rx.sv rtl/uart_tx.sv rtl/host_if.sv rtl/chip_top.sv source/mac_attack_chip.sv
//
// 250 MHz version (20 Oct 2026): the core settings of the ZedBoard build that met 250 MHz
// (step 14: PIPE = 2, MEM_REG = 2, HREAD_REG = 1, exact 19-bit accumulators), with pe.sv
// PEs instead of DSP48E1s. 4x4 array (16 PEs), INT8 inputs, matrices up to 8x8, serial
// port at 115,200 baud from a 250 MHz clock (CLKS_PER_BIT = 2170).
// Checked before release: RTL simulation of this file over the serial port (6/6 tests pass).
// Do not edit by hand except the three parameters of mac_attack_chip below.

// Top level for OpenLane. Change P (array size) and MAXD (largest matrix) here.
module mac_attack_chip (
	clk,
	rst,
	uart_rx_i,
	uart_tx_o,
	busy_led
);
	parameter signed [31:0] P = 4;
	parameter signed [31:0] MAXD = 8;
	parameter signed [31:0] CLKS_PER_BIT = 2170;
	input wire clk;
	input wire rst;
	input wire uart_rx_i;
	output wire uart_tx_o;
	output wire busy_led;
	chip_top #(
		.P(P),
		.BITS(8),
		.ACC(16 + $clog2(MAXD)),
		.SAT(0),
		.MAXD(MAXD),
		.CLKS_PER_BIT(CLKS_PER_BIT),
		.PIPE(2),
		.MEM_REG(2),
		.HREAD_REG(1)
	) u_chip(
		.clk(clk),
		.rst(rst),
		.uart_rx_i(uart_rx_i),
		.uart_tx_o(uart_tx_o),
		.busy_led(busy_led)
	);
endmodule

// The chip: serial receiver and transmitter, host interface, matrix core.
module chip_top (
	clk,
	rst,
	uart_rx_i,
	uart_tx_o,
	busy_led
);
	parameter signed [31:0] P = 16;
	parameter signed [31:0] BITS = 8;
	parameter signed [31:0] ACC = 32;
	parameter signed [31:0] SAT = 0;
	parameter signed [31:0] MAXD = 64;
	parameter signed [31:0] CLKS_PER_BIT = 868;
	parameter signed [31:0] PIPE = 1;
	parameter signed [31:0] MEM_REG = 1;
	parameter signed [31:0] HREAD_REG = 0;
	input wire clk;
	input wire rst;
	input wire uart_rx_i;
	output wire uart_tx_o;
	output wire busy_led;
	wire rx_valid;
	wire tx_start;
	wire tx_ready;
	wire [7:0] rx_data;
	wire [7:0] tx_data;
	wire wr_en;
	wire wr_sel;
	wire start;
	wire busy;
	wire done;
	wire [7:0] wr_row;
	wire [7:0] wr_col;
	wire [7:0] dim_m;
	wire [7:0] dim_k;
	wire [7:0] dim_n;
	wire [7:0] rd_row;
	wire [7:0] rd_col;
	wire [BITS - 1:0] wr_data;
	wire [ACC - 1:0] rd_data;
	wire [31:0] perf_passes;
	wire [31:0] perf_cycles;
	wire [31:0] perf_total;
	uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx(
		.clk(clk),
		.rst(rst),
		.rx(uart_rx_i),
		.rx_valid(rx_valid),
		.rx_data(rx_data)
	);
	uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx(
		.clk(clk),
		.rst(rst),
		.tx_start(tx_start),
		.tx_data(tx_data),
		.tx_ready(tx_ready),
		.tx(uart_tx_o)
	);
	host_if #(
		.P(P),
		.BITS(BITS),
		.ACC(ACC),
		.MAXD(MAXD),
		.HREAD_REG(HREAD_REG)
	) u_host(
		.clk(clk),
		.rst(rst),
		.rx_valid(rx_valid),
		.rx_data(rx_data),
		.tx_start(tx_start),
		.tx_data(tx_data),
		.tx_ready(tx_ready),
		.wr_en(wr_en),
		.wr_sel(wr_sel),
		.wr_row(wr_row),
		.wr_col(wr_col),
		.wr_data(wr_data),
		.start(start),
		.dim_m(dim_m),
		.dim_k(dim_k),
		.dim_n(dim_n),
		.done(done),
		.rd_row(rd_row),
		.rd_col(rd_col),
		.rd_data(rd_data),
		.perf_passes(perf_passes),
		.perf_cycles(perf_cycles),
		.perf_total(perf_total)
	);
	mm_core #(
		.P(P),
		.BITS(BITS),
		.ACC(ACC),
		.SAT(SAT),
		.MAXD(MAXD),
		.PIPE(PIPE),
		.MEM_REG(MEM_REG),
		.HREAD_REG(HREAD_REG)
	) u_core(
		.clk(clk),
		.hclk(clk),
		.rst(rst),
		.wr_en(wr_en),
		.wr_sel(wr_sel),
		.wr_row(wr_row),
		.wr_col(wr_col),
		.wr_data(wr_data),
		.start(start),
		.dim_m(dim_m),
		.dim_k(dim_k),
		.dim_n(dim_n),
		.busy(busy),
		.done(done),
		.rd_row(rd_row),
		.rd_col(rd_col),
		.rd_data(rd_data),
		.perf_passes(perf_passes),
		.perf_cycles(perf_cycles),
		.perf_total(perf_total)
	);
	assign busy_led = busy;
endmodule

// Host interface: decodes the serial commands I, D, A, B, G, C and sends replies.
module host_if (
	clk,
	rst,
	rx_valid,
	rx_data,
	tx_start,
	tx_data,
	tx_ready,
	wr_en,
	wr_sel,
	wr_row,
	wr_col,
	wr_data,
	start,
	dim_m,
	dim_k,
	dim_n,
	done,
	rd_row,
	rd_col,
	rd_data,
	perf_passes,
	perf_cycles,
	perf_total
);
	parameter signed [31:0] P = 16;
	parameter signed [31:0] BITS = 8;
	parameter signed [31:0] ACC = 32;
	parameter signed [31:0] MAXD = 64;
	parameter signed [31:0] HREAD_REG = 0;
	input wire clk;
	input wire rst;
	input wire rx_valid;
	input wire [7:0] rx_data;
	output reg tx_start;
	output reg [7:0] tx_data;
	input wire tx_ready;
	output reg wr_en;
	output reg wr_sel;
	output reg [7:0] wr_row;
	output reg [7:0] wr_col;
	output reg [BITS - 1:0] wr_data;
	output reg start;
	output reg [7:0] dim_m;
	output reg [7:0] dim_k;
	output reg [7:0] dim_n;
	input wire done;
	output reg [7:0] rd_row;
	output reg [7:0] rd_col;
	input wire [ACC - 1:0] rd_data;
	input wire [31:0] perf_passes;
	input wire [31:0] perf_cycles;
	input wire [31:0] perf_total;
	reg [3:0] state;
	reg [3:0] ret;
	reg [7:0] rbuf [0:12];
	reg signed [31:0] rlen;
	reg signed [31:0] ridx;
	reg signed [31:0] cnt;
	reg signed [31:0] row;
	reg signed [31:0] col;
	reg signed [31:0] rows;
	reg signed [31:0] cols;
	reg [7:0] dbuf [0:2];
	wire [31:0] cval;
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	assign cval = sv2v_cast_32_signed($signed(rd_data));
	function automatic signed [7:0] sv2v_cast_8_signed;
		input reg signed [7:0] inp;
		sv2v_cast_8_signed = inp;
	endfunction
	function automatic [BITS - 1:0] sv2v_cast_9E780;
		input reg [BITS - 1:0] inp;
		sv2v_cast_9E780 = inp;
	endfunction
	always @(posedge clk)
		if (rst) begin
			state <= 4'd0;
			ret <= 4'd0;
			tx_start <= 1'b0;
			tx_data <= 1'sb0;
			wr_en <= 1'b0;
			wr_sel <= 1'b0;
			wr_row <= 1'sb0;
			wr_col <= 1'sb0;
			wr_data <= 1'sb0;
			start <= 1'b0;
			dim_m <= 8'd1;
			dim_k <= 8'd1;
			dim_n <= 8'd1;
			rd_row <= 1'sb0;
			rd_col <= 1'sb0;
			rlen <= 0;
			ridx <= 0;
			cnt <= 0;
			row <= 0;
			col <= 0;
			rows <= 1;
			cols <= 1;
		end
		else begin
			wr_en <= 1'b0;
			start <= 1'b0;
			tx_start <= 1'b0;
			case (state)
				4'd0:
					if (rx_valid)
						case (rx_data)
							8'h49: begin
								rbuf[0] <= 8'h4d;
								rbuf[1] <= 8'h41;
								rbuf[2] <= 8'h43;
								rbuf[3] <= sv2v_cast_8_signed(P);
								rbuf[4] <= sv2v_cast_8_signed(BITS);
								rbuf[5] <= sv2v_cast_8_signed(ACC);
								rbuf[6] <= sv2v_cast_8_signed(MAXD);
								rlen <= 7;
								ridx <= 0;
								ret <= 4'd0;
								state <= 4'd9;
							end
							8'h44: begin
								cnt <= 0;
								state <= 4'd1;
							end
							8'h41, 8'h42: begin
								wr_sel <= rx_data == 8'h42;
								rows <= (rx_data == 8'h42 ? sv2v_cast_32_signed(dim_k) : sv2v_cast_32_signed(dim_m));
								cols <= (rx_data == 8'h42 ? sv2v_cast_32_signed(dim_n) : sv2v_cast_32_signed(dim_k));
								row <= 0;
								col <= 0;
								state <= 4'd2;
							end
							8'h47: begin
								start <= 1'b1;
								state <= 4'd3;
							end
							8'h43: begin
								row <= 0;
								col <= 0;
								state <= 4'd4;
							end
							default: begin
								rbuf[0] <= 8'h3f;
								rlen <= 1;
								ridx <= 0;
								ret <= 4'd0;
								state <= 4'd9;
							end
						endcase
				4'd1:
					if (rx_valid) begin
						dbuf[cnt] <= rx_data;
						if (cnt == 2) begin
							if ((((((dbuf[0] == 0) || (dbuf[1] == 0)) || (rx_data == 0)) || (sv2v_cast_32_signed(dbuf[0]) > MAXD)) || (sv2v_cast_32_signed(dbuf[1]) > MAXD)) || (sv2v_cast_32_signed(rx_data) > MAXD))
								rbuf[0] <= 8'h65;
							else begin
								dim_m <= dbuf[0];
								dim_k <= dbuf[1];
								dim_n <= rx_data;
								rbuf[0] <= 8'h6b;
							end
							rlen <= 1;
							ridx <= 0;
							ret <= 4'd0;
							state <= 4'd9;
						end
						else
							cnt <= cnt + 1;
					end
				4'd2:
					if (rx_valid) begin
						wr_en <= 1'b1;
						wr_row <= sv2v_cast_8_signed(row);
						wr_col <= sv2v_cast_8_signed(col);
						wr_data <= sv2v_cast_9E780(rx_data);
						if (col == (cols - 1)) begin
							col <= 0;
							if (row == (rows - 1)) begin
								rbuf[0] <= 8'h6b;
								rlen <= 1;
								ridx <= 0;
								ret <= 4'd0;
								state <= 4'd9;
							end
							else
								row <= row + 1;
						end
						else
							col <= col + 1;
					end
				4'd3:
					if (done) begin
						rbuf[0] <= 8'h67;
						begin : sv2v_autoblock_1
							reg signed [31:0] b;
							for (b = 0; b < 4; b = b + 1)
								begin
									rbuf[1 + b] <= perf_passes[8 * b+:8];
									rbuf[5 + b] <= perf_cycles[8 * b+:8];
									rbuf[9 + b] <= perf_total[8 * b+:8];
								end
						end
						rlen <= 13;
						ridx <= 0;
						ret <= 4'd0;
						state <= 4'd9;
					end
				4'd4: begin
					rd_row <= sv2v_cast_8_signed(row);
					rd_col <= sv2v_cast_8_signed(col);
					state <= 4'd5;
				end
				4'd5: state <= (HREAD_REG != 0 ? 4'd6 : 4'd7);
				4'd6: state <= 4'd7;
				4'd7: begin
					begin : sv2v_autoblock_2
						reg signed [31:0] b;
						for (b = 0; b < 4; b = b + 1)
							rbuf[b] <= cval[8 * b+:8];
					end
					rlen <= 4;
					ridx <= 0;
					ret <= 4'd8;
					state <= 4'd9;
				end
				4'd8:
					if (col == (sv2v_cast_32_signed(dim_n) - 1)) begin
						col <= 0;
						if (row == (sv2v_cast_32_signed(dim_m) - 1))
							state <= 4'd0;
						else begin
							row <= row + 1;
							state <= 4'd4;
						end
					end
					else begin
						col <= col + 1;
						state <= 4'd4;
					end
				4'd9:
					if (tx_ready) begin
						tx_data <= rbuf[ridx];
						tx_start <= 1'b1;
						state <= 4'd10;
					end
				4'd10: state <= 4'd11;
				4'd11:
					if (tx_ready) begin
						if (ridx == (rlen - 1))
							state <= ret;
						else begin
							ridx <= ridx + 1;
							state <= 4'd9;
						end
					end
				default: state <= 4'd0;
			endcase
		end
endmodule

// Serial receiver, 8N1.
module uart_rx (
	clk,
	rst,
	rx,
	rx_valid,
	rx_data
);
	parameter signed [31:0] CLKS_PER_BIT = 868;
	input wire clk;
	input wire rst;
	input wire rx;
	output reg rx_valid;
	output reg [7:0] rx_data;
	reg [1:0] state;
	reg rx_s1;
	reg rx_s2;
	reg signed [31:0] cnt;
	reg signed [31:0] bitn;
	always @(posedge clk)
		if (rst) begin
			rx_s1 <= 1'b1;
			rx_s2 <= 1'b1;
			state <= 2'd0;
			cnt <= 0;
			bitn <= 0;
			rx_valid <= 1'b0;
			rx_data <= 1'sb0;
		end
		else begin
			rx_s1 <= rx;
			rx_s2 <= rx_s1;
			rx_valid <= 1'b0;
			case (state)
				2'd0:
					if (!rx_s2) begin
						state <= 2'd1;
						cnt <= 0;
					end
				2'd1:
					if (cnt == ((CLKS_PER_BIT / 2) - 1)) begin
						if (!rx_s2) begin
							state <= 2'd2;
							cnt <= 0;
							bitn <= 0;
						end
						else
							state <= 2'd0;
					end
					else
						cnt <= cnt + 1;
				2'd2:
					if (cnt == (CLKS_PER_BIT - 1)) begin
						cnt <= 0;
						rx_data <= {rx_s2, rx_data[7:1]};
						if (bitn == 7)
							state <= 2'd3;
						else
							bitn <= bitn + 1;
					end
					else
						cnt <= cnt + 1;
				2'd3:
					if (cnt == (CLKS_PER_BIT - 1)) begin
						state <= 2'd0;
						cnt <= 0;
						if (rx_s2)
							rx_valid <= 1'b1;
					end
					else
						cnt <= cnt + 1;
				default: state <= 2'd0;
			endcase
		end
endmodule

// Serial transmitter, 8N1.
module uart_tx (
	clk,
	rst,
	tx_start,
	tx_data,
	tx_ready,
	tx
);
	parameter signed [31:0] CLKS_PER_BIT = 868;
	input wire clk;
	input wire rst;
	input wire tx_start;
	input wire [7:0] tx_data;
	output wire tx_ready;
	output reg tx;
	reg [9:0] frame;
	reg signed [31:0] cnt;
	reg signed [31:0] bitn;
	reg active;
	assign tx_ready = !active;
	always @(posedge clk)
		if (rst) begin
			active <= 1'b0;
			tx <= 1'b1;
			frame <= 1'sb1;
			cnt <= 0;
			bitn <= 0;
		end
		else if (!active) begin
			tx <= 1'b1;
			if (tx_start) begin
				frame <= {1'b1, tx_data, 1'b0};
				active <= 1'b1;
				cnt <= 0;
				bitn <= 0;
				tx <= 1'b0;
			end
		end
		else if (cnt == (CLKS_PER_BIT - 1)) begin
			cnt <= 0;
			if (bitn == 9) begin
				active <= 1'b0;
				tx <= 1'b1;
			end
			else begin
				bitn <= bitn + 1;
				tx <= frame[bitn + 1];
			end
		end
		else
			cnt <= cnt + 1;
endmodule

// Matrix core: A, B, C buffers, folding controller, accumulators, performance counters.
module mm_core (
	clk,
	hclk,
	rst,
	wr_en,
	wr_sel,
	wr_row,
	wr_col,
	wr_data,
	start,
	dim_m,
	dim_k,
	dim_n,
	busy,
	done,
	rd_row,
	rd_col,
	rd_data,
	perf_passes,
	perf_cycles,
	perf_total
);
	reg _sv2v_0;
	parameter signed [31:0] P = 16;
	parameter signed [31:0] BITS = 8;
	parameter signed [31:0] ACC = 32;
	parameter signed [31:0] SAT = 0;
	parameter signed [31:0] MAXD = 64;
	parameter signed [31:0] PIPE = 1;
	parameter signed [31:0] MEM_REG = 1;
	parameter signed [31:0] HCLK_SEP = 0;
	parameter signed [31:0] PE_PRIM = 0;
	parameter signed [31:0] HREAD_REG = 0;
	input wire clk;
	input wire hclk;
	input wire rst;
	input wire wr_en;
	input wire wr_sel;
	input wire [7:0] wr_row;
	input wire [7:0] wr_col;
	input wire [BITS - 1:0] wr_data;
	input wire start;
	input wire [7:0] dim_m;
	input wire [7:0] dim_k;
	input wire [7:0] dim_n;
	output reg busy;
	output reg done;
	input wire [7:0] rd_row;
	input wire [7:0] rd_col;
	output wire [ACC - 1:0] rd_data;
	output reg [31:0] perf_passes;
	output reg [31:0] perf_cycles;
	output reg [31:0] perf_total;
	localparam signed [31:0] TM = ((MAXD + P) - 1) / P;
	localparam signed [31:0] DEPTH = MAXD * TM;
	localparam signed [31:0] LP = (P > 1 ? $clog2(P) : 1);
	localparam signed [31:0] OW = $clog2(MAXD + (3 * P));
	localparam signed [31:0] KW = (TM > 1 ? $clog2(TM) : 1);
	localparam signed [31:0] MW = (MAXD > 1 ? $clog2(MAXD) : 1);
	localparam signed [31:0] AW = (DEPTH > 1 ? $clog2(DEPTH) : 1);
	localparam [0:0] POW2 = (P == (1 << LP)) && (TM == (1 << KW));
	(* ram_style = "block" *) reg [(P * BITS) - 1:0] amem [0:DEPTH - 1];
	(* ram_style = "block" *) reg [(P * BITS) - 1:0] bmem [0:DEPTH - 1];
	reg [(P * ACC) - 1:0] cmem [0:DEPTH - 1];
	wire [31:0] wr_addr;
	wire [7:0] wr_lane;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	assign wr_addr = (sv2v_cast_32(wr_row) * TM) + (sv2v_cast_32(wr_col) / P);
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	assign wr_lane = sv2v_cast_8(sv2v_cast_32(wr_col) % P);
	wire [(P * BITS) - 1:0] wr_word;
	assign wr_word = {P {wr_data}};
	function automatic signed [7:0] sv2v_cast_8_signed;
		input reg signed [7:0] inp;
		sv2v_cast_8_signed = inp;
	endfunction
	always @(posedge hclk)
		if (wr_en && !wr_sel) begin : sv2v_autoblock_1
			reg signed [31:0] j;
			for (j = 0; j < P; j = j + 1)
				if (wr_lane == sv2v_cast_8_signed(j))
					amem[wr_addr][j * BITS+:BITS] <= wr_word[j * BITS+:BITS];
		end
	always @(posedge hclk)
		if (wr_en && wr_sel) begin : sv2v_autoblock_2
			reg signed [31:0] j;
			for (j = 0; j < P; j = j + 1)
				if (wr_lane == sv2v_cast_8_signed(j))
					bmem[wr_addr][j * BITS+:BITS] <= wr_word[j * BITS+:BITS];
		end
	reg [2:0] state;
	reg [1:0] prime_left;
	reg idle_q;
	reg [OW - 1:0] tm1;
	reg [MW - 1:0] m_m1;
	reg [KW - 1:0] kt_m1;
	reg [KW - 1:0] nt_m1;
	reg [LP - 1:0] thr;
	reg [P - 1:0] amask_last;
	reg [P - 1:0] nmask_last;
	wire signed [31:0] ktv;
	wire signed [31:0] ntv;
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	assign ktv = ((sv2v_cast_32_signed(dim_k) + P) - 1) / P;
	assign ntv = ((sv2v_cast_32_signed(dim_n) + P) - 1) / P;
	wire [7:0] k_m1;
	wire [7:0] n_m1;
	assign k_m1 = dim_k - 8'd1;
	assign n_m1 = dim_n - 8'd1;
	reg [OW - 1:0] ro;
	reg [KW - 1:0] rkb;
	reg [KW - 1:0] rnb;
	reg [MW - 1:0] ri;
	reg rw;
	reg ra;
	reg rfirst;
	reg r_active;
	wire r_wrap;
	wire rkb_last;
	wire rnb_last;
	wire r_final;
	assign r_wrap = ro == tm1;
	assign rkb_last = rkb == kt_m1;
	assign rnb_last = rnb == nt_m1;
	assign r_final = (r_wrap && rkb_last) && rnb_last;
	function automatic signed [OW - 1:0] sv2v_cast_33497_signed;
		input reg signed [OW - 1:0] inp;
		sv2v_cast_33497_signed = inp;
	endfunction
	always @(posedge clk)
		if (rst) begin
			ro <= 1'sb0;
			rkb <= 1'sb0;
			rnb <= 1'sb0;
			ri <= 1'sb0;
			rw <= 1'b1;
			ra <= 1'b0;
			rfirst <= 1'b1;
			r_active <= 1'b0;
		end
		else if (idle_q) begin
			ro <= 1'sb0;
			rkb <= 1'sb0;
			rnb <= 1'sb0;
			ri <= 1'sb0;
			rw <= 1'b1;
			ra <= 1'b0;
			rfirst <= 1'b1;
			r_active <= start;
		end
		else if (r_active) begin
			if (r_wrap) begin
				ro <= 1'sb0;
				ri <= 1'sb0;
				rw <= 1'b1;
				ra <= 1'b0;
				rfirst <= 1'b1;
				if (r_final) begin
					rkb <= 1'sb0;
					rnb <= 1'sb0;
					r_active <= 1'b0;
				end
				else if (rkb_last) begin
					rkb <= 1'sb0;
					rnb <= rnb + 1'b1;
				end
				else
					rkb <= rkb + 1'b1;
			end
			else begin
				ro <= ro + 1'b1;
				rfirst <= 1'b0;
				rw <= rw && (ro != sv2v_cast_33497_signed(P - 1));
				ra <= (rw && (ro == sv2v_cast_33497_signed(P - 1))) || (ra && (ri != m_m1));
				ri <= (ra && (ri != m_m1) ? ri + 1'b1 : {MW {1'sb0}});
			end
		end
	wire [LP - 1:0] k_low;
	function automatic signed [LP - 1:0] sv2v_cast_6A2A1_signed;
		input reg signed [LP - 1:0] inp;
		sv2v_cast_6A2A1_signed = inp;
	endfunction
	assign k_low = sv2v_cast_6A2A1_signed(P - 1) - ro[LP - 1:0];
	wire [AW - 1:0] a_addr;
	wire [AW - 1:0] b_addr;
	function automatic signed [AW - 1:0] sv2v_cast_3F9C3_signed;
		input reg signed [AW - 1:0] inp;
		sv2v_cast_3F9C3_signed = inp;
	endfunction
	function automatic [AW - 1:0] sv2v_cast_3F9C3;
		input reg [AW - 1:0] inp;
		sv2v_cast_3F9C3 = inp;
	endfunction
	generate
		if (POW2) begin : g_addr_bits
			assign b_addr = (rw ? sv2v_cast_3F9C3({rkb, k_low, rnb}) : {AW {1'sb0}});
			assign a_addr = (ra ? sv2v_cast_3F9C3({ri, rkb}) : {AW {1'sb0}});
		end
		else begin : g_addr_math
			assign b_addr = (rw ? sv2v_cast_3F9C3_signed((((sv2v_cast_32_signed(rkb) * P) + sv2v_cast_32_signed(k_low)) * TM) + sv2v_cast_32_signed(rnb)) : {AW {1'sb0}});
			assign a_addr = (ra ? sv2v_cast_3F9C3_signed((sv2v_cast_32_signed(ri) * TM) + sv2v_cast_32_signed(rkb)) : {AW {1'sb0}});
		end
	endgenerate
	wire [P - 1:0] a_lanes;
	wire [P - 1:0] b_lanes;
	assign a_lanes = (rkb_last ? amask_last : {P {1'sb1}});
	assign b_lanes = (rw && (!rkb_last || (ro[LP - 1:0] >= thr)) ? (rnb_last ? nmask_last : {P {1'sb1}}) : {P {1'sb0}});
	reg [(P * BITS) - 1:0] aq1;
	reg [(P * BITS) - 1:0] bq1;
	reg [P - 1:0] a_lanes_q1;
	reg [P - 1:0] b_lanes_q1;
	reg [(P * BITS) - 1:0] w_row;
	reg [(P * BITS) - 1:0] a_row;
	always @(posedge clk) begin
		aq1 <= amem[a_addr];
		bq1 <= bmem[b_addr];
		a_lanes_q1 <= a_lanes;
		b_lanes_q1 <= b_lanes;
	end
	generate
		if (MEM_REG >= 2) begin : g_memreg2
			reg [(P * BITS) - 1:0] aqr;
			reg [(P * BITS) - 1:0] bqr;
			reg [P - 1:0] a_lanes_q2;
			reg [P - 1:0] b_lanes_q2;
			reg [(P * BITS) - 1:0] aq;
			reg [(P * BITS) - 1:0] bq;
			always @(posedge clk) begin
				aqr <= aq1;
				bqr <= bq1;
				a_lanes_q2 <= a_lanes_q1;
				b_lanes_q2 <= b_lanes_q1;
			end
			always @(posedge clk) begin : sv2v_autoblock_3
				reg signed [31:0] j;
				for (j = 0; j < P; j = j + 1)
					begin
						aq[j * BITS+:BITS] <= (a_lanes_q2[j] ? aqr[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
						bq[j * BITS+:BITS] <= (b_lanes_q2[j] ? bqr[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
					end
			end
			wire [P * BITS:1] sv2v_tmp_DC5CD;
			assign sv2v_tmp_DC5CD = aq;
			always @(*) a_row = sv2v_tmp_DC5CD;
			wire [P * BITS:1] sv2v_tmp_6109C;
			assign sv2v_tmp_6109C = bq;
			always @(*) w_row = sv2v_tmp_6109C;
		end
		else if (MEM_REG == 1) begin : g_memreg
			reg [(P * BITS) - 1:0] aq;
			reg [(P * BITS) - 1:0] bq;
			always @(posedge clk) begin : sv2v_autoblock_4
				reg signed [31:0] j;
				for (j = 0; j < P; j = j + 1)
					begin
						aq[j * BITS+:BITS] <= (a_lanes_q1[j] ? aq1[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
						bq[j * BITS+:BITS] <= (b_lanes_q1[j] ? bq1[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
					end
			end
			wire [P * BITS:1] sv2v_tmp_DC5CD;
			assign sv2v_tmp_DC5CD = aq;
			always @(*) a_row = sv2v_tmp_DC5CD;
			wire [P * BITS:1] sv2v_tmp_6109C;
			assign sv2v_tmp_6109C = bq;
			always @(*) w_row = sv2v_tmp_6109C;
		end
		else begin : g_nomemreg
			always @(*) begin
				if (_sv2v_0)
					;
				begin : sv2v_autoblock_5
					reg signed [31:0] j;
					for (j = 0; j < P; j = j + 1)
						begin
							w_row[j * BITS+:BITS] = (b_lanes_q1[j] ? bq1[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
							a_row[j * BITS+:BITS] = (a_lanes_q1[j] ? aq1[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
						end
				end
			end
		end
	endgenerate
	reg a_phase1;
	reg pass_first1;
	reg a_first1;
	reg fin1;
	reg [KW - 1:0] kb1;
	reg [KW - 1:0] nb1;
	reg [OW - 1:0] o1;
	always @(posedge clk)
		if (rst) begin
			a_phase1 <= 1'b0;
			pass_first1 <= 1'b0;
			a_first1 <= 1'b0;
			fin1 <= 1'b0;
			kb1 <= 1'sb0;
			nb1 <= 1'sb0;
			o1 <= 1'sb0;
		end
		else begin
			o1 <= ro;
			a_phase1 <= ra;
			pass_first1 <= rfirst;
			a_first1 <= ra && (ri == {MW {1'sb0}});
			fin1 <= r_active && r_final;
			kb1 <= rkb;
			nb1 <= rnb;
		end
	wire a_phase;
	wire pass_first;
	wire a_first;
	wire fin;
	wire [KW - 1:0] kb;
	wire [KW - 1:0] nb;
	wire [OW - 1:0] o;
	localparam signed [31:0] FW = (OW + (2 * KW)) + 4;
	generate
		if (MEM_REG != 0) begin : g_arr2
			wire [FW - 1:0] flags1;
			wire [FW - 1:0] flags;
			assign flags1 = {o1, kb1, nb1, a_phase1, pass_first1, a_first1, fin1};
			delay_line #(
				.WIDTH(FW),
				.DEPTH(MEM_REG),
				.RESET(1)
			) u_flags(
				.clk(clk),
				.rst(rst),
				.d(flags1),
				.q(flags)
			);
			assign {o, kb, nb, a_phase, pass_first, a_first, fin} = flags;
		end
		else begin : g_arr1
			assign o = o1;
			assign a_phase = a_phase1;
			assign pass_first = pass_first1;
			assign a_first = a_first1;
			assign fin = fin1;
			assign kb = kb1;
			assign nb = nb1;
		end
	endgenerate
	wire w_load;
	wire in_valid;
	wire out_valid;
	wire [(P * ACC) - 1:0] c_row;
	wire wl_d;
	generate
		if (MEM_REG == 0) begin : g_wl0
			assign wl_d = rw && r_active;
		end
		else begin : g_wl
			delay_line #(
				.WIDTH(1),
				.DEPTH(MEM_REG),
				.RESET(1)
			) u_wl(
				.clk(clk),
				.rst(rst),
				.d(rw && r_active),
				.q(wl_d)
			);
		end
	endgenerate
	(* max_fanout = 16 *) reg w_load_q;
	always @(posedge clk)
		if (rst)
			w_load_q <= 1'b0;
		else
			w_load_q <= wl_d;
	assign w_load = w_load_q;
	assign in_valid = (state == 3'd2) && a_phase;
	systolic_array #(
		.P(P),
		.BITS(BITS),
		.ACC(ACC),
		.SAT(SAT),
		.PIPE(PIPE),
		.PE_PRIM(PE_PRIM)
	) u_array(
		.clk(clk),
		.rst(rst),
		.w_load(w_load),
		.w_row(w_row),
		.in_valid(in_valid),
		.a_row(a_row),
		.out_valid(out_valid),
		.c_row(c_row)
	);
	wire out_next2;
	delay_line #(
		.WIDTH(1),
		.DEPTH(((2 * P) - 3) + PIPE),
		.RESET(1)
	) u_next(
		.clk(clk),
		.rst(rst),
		.d(in_valid),
		.q(out_next2)
	);
	(* max_fanout = 32 *) reg cap_first;
	reg [KW - 1:0] cap_nb;
	reg [MW - 1:0] pre_row;
	reg [MW - 1:0] out_row;
	reg pre_last;
	reg out_last;
	reg [MW - 1:0] m_m2;
	reg m_one;
	function automatic [AW - 1:0] c_addr;
		input reg [MW - 1:0] row;
		input reg [KW - 1:0] blk;
		if (POW2)
			c_addr = sv2v_cast_3F9C3({row, blk});
		else
			c_addr = sv2v_cast_3F9C3_signed((sv2v_cast_32_signed(row) * TM) + sv2v_cast_32_signed(blk));
	endfunction
	wire signed [31:0] host_raddr;
	wire [AW - 1:0] c_raddr;
	reg [LP - 1:0] rd_lane;
	reg [(P * ACC) - 1:0] cq1;
	reg [(P * ACC) - 1:0] cq2;
	wire [(P * ACC) - 1:0] hq1;
	assign host_raddr = (sv2v_cast_32_signed(rd_row) * TM) + (sv2v_cast_32_signed(rd_col) / P);
	always @(posedge clk) begin
		cq1 <= cmem[c_raddr];
		if (cap_first)
			cq2 <= 1'sb0;
		else
			cq2 <= cq1;
	end
	localparam signed [ACC:0] MAXV = {2'b00, {ACC - 1 {1'b1}}};
	localparam signed [ACC:0] MINV = {2'b11, {ACC - 1 {1'b0}}};
	function automatic [ACC - 1:0] acc_add;
		input reg [ACC - 1:0] x;
		input reg [ACC - 1:0] y;
		reg signed [ACC:0] s;
		begin
			s = $signed({x[ACC - 1], x}) + $signed({y[ACC - 1], y});
			if ((SAT != 0) && (s > MAXV))
				acc_add = MAXV[ACC - 1:0];
			else if ((SAT != 0) && (s < MINV))
				acc_add = MINV[ACC - 1:0];
			else
				acc_add = s[ACC - 1:0];
		end
	endfunction
	wire [(P * ACC) - 1:0] c_new;
	genvar _gv_j_2;
	generate
		for (_gv_j_2 = 0; _gv_j_2 < P; _gv_j_2 = _gv_j_2 + 1) begin : g_acc
			localparam j = _gv_j_2;
			assign c_new[j * ACC+:ACC] = acc_add(cq2[j * ACC+:ACC], c_row[j * ACC+:ACC]);
		end
	endgenerate
	reg wq_en;
	reg [AW - 1:0] wq_addr;
	reg [(P * ACC) - 1:0] wq;
	always @(posedge clk) begin
		wq <= c_new;
		wq_addr <= c_addr(out_row, cap_nb);
		if (rst)
			wq_en <= 1'b0;
		else
			wq_en <= out_valid;
	end
	always @(posedge clk)
		if (wq_en)
			cmem[wq_addr] <= wq;
	function automatic [LP - 1:0] sv2v_cast_6A2A1;
		input reg [LP - 1:0] inp;
		sv2v_cast_6A2A1 = inp;
	endfunction
	generate
		if (HCLK_SEP == 0) begin : g_hread1
			assign c_raddr = (busy ? (out_next2 ? c_addr(pre_row, cap_nb) : {AW {1'sb0}}) : sv2v_cast_3F9C3_signed(host_raddr));
			assign hq1 = cq1;
			always @(posedge clk) rd_lane <= sv2v_cast_6A2A1(sv2v_cast_32(rd_col) % P);
		end
		else begin : g_hread2
			assign c_raddr = (busy ? (out_next2 ? c_addr(pre_row, cap_nb) : {AW {1'sb0}}) : {AW {1'sb0}});
			(* ram_style = "block" *) reg [(P * ACC) - 1:0] cres [0:DEPTH - 1];
			reg [(P * ACC) - 1:0] hq;
			wire [AW - 1:0] h_raddr;
			assign h_raddr = sv2v_cast_3F9C3_signed(host_raddr);
			always @(posedge clk)
				if (wq_en)
					cres[wq_addr] <= wq;
			always @(posedge hclk) begin
				hq <= cres[h_raddr];
				rd_lane <= sv2v_cast_6A2A1(sv2v_cast_32(rd_col) % P);
			end
			assign hq1 = hq;
		end
	endgenerate
	reg [(P * ACC) - 1:0] hq_sel;
	reg [LP - 1:0] rd_lane_sel;
	generate
		if (HREAD_REG != 0) begin : g_hreadreg
			always @(posedge hclk) begin
				hq_sel <= hq1;
				rd_lane_sel <= rd_lane;
			end
		end
		else begin : g_hreaddirect
			wire [P * ACC:1] sv2v_tmp_149A9;
			assign sv2v_tmp_149A9 = hq1;
			always @(*) hq_sel = sv2v_tmp_149A9;
			wire [LP:1] sv2v_tmp_7DBF4;
			assign sv2v_tmp_7DBF4 = rd_lane;
			always @(*) rd_lane_sel = sv2v_tmp_7DBF4;
		end
	endgenerate
	wire [ACC - 1:0] hq1_lane [0:P - 1];
	genvar _gv_j_3;
	generate
		for (_gv_j_3 = 0; _gv_j_3 < P; _gv_j_3 = _gv_j_3 + 1) begin : g_rdlane
			localparam j = _gv_j_3;
			assign hq1_lane[j] = hq_sel[j * ACC+:ACC];
		end
	endgenerate
	assign rd_data = hq1_lane[rd_lane_sel];
	always @(posedge clk)
		if (rst)
			idle_q <= 1'b1;
		else
			case (state)
				3'd0: idle_q <= !start;
				3'd1, 3'd2, 3'd3: idle_q <= 1'b0;
				default: idle_q <= 1'b1;
			endcase
	function automatic signed [P - 1:0] sv2v_cast_D1198_signed;
		input reg signed [P - 1:0] inp;
		sv2v_cast_D1198_signed = inp;
	endfunction
	function automatic signed [MW - 1:0] sv2v_cast_82E88_signed;
		input reg signed [MW - 1:0] inp;
		sv2v_cast_82E88_signed = inp;
	endfunction
	function automatic [KW - 1:0] sv2v_cast_0B087;
		input reg [KW - 1:0] inp;
		sv2v_cast_0B087 = inp;
	endfunction
	function automatic signed [KW - 1:0] sv2v_cast_0B087_signed;
		input reg signed [KW - 1:0] inp;
		sv2v_cast_0B087_signed = inp;
	endfunction
	function automatic signed [1:0] sv2v_cast_2_signed;
		input reg signed [1:0] inp;
		sv2v_cast_2_signed = inp;
	endfunction
	always @(posedge clk)
		if (rst) begin
			state <= 3'd0;
			busy <= 1'b0;
			done <= 1'b0;
			prime_left <= 1'sb0;
			tm1 <= 1'sb0;
			m_m1 <= 1'sb0;
			kt_m1 <= 1'sb0;
			nt_m1 <= 1'sb0;
			thr <= sv2v_cast_6A2A1_signed(P - 1);
			amask_last <= sv2v_cast_D1198_signed(1);
			nmask_last <= sv2v_cast_D1198_signed(1);
			cap_first <= 1'b1;
			cap_nb <= 1'sb0;
			pre_row <= 1'sb0;
			out_row <= 1'sb0;
			m_m2 <= 1'sb1;
			m_one <= 1'b1;
			pre_last <= 1'b1;
			out_last <= 1'b1;
			perf_passes <= 1'sb0;
			perf_cycles <= 1'sb0;
			perf_total <= 1'sb0;
		end
		else begin
			done <= 1'b0;
			if (busy)
				perf_total <= perf_total + 32'd1;
			case (state)
				3'd0:
					if (start) begin
						tm1 <= sv2v_cast_33497_signed((sv2v_cast_32_signed(dim_m) + (3 * P)) - 3);
						m_m1 <= sv2v_cast_82E88_signed(sv2v_cast_32_signed(dim_m) - 1);
						m_m2 <= sv2v_cast_82E88_signed(sv2v_cast_32_signed(dim_m) - 2);
						m_one <= sv2v_cast_82E88_signed(sv2v_cast_32_signed(dim_m) - 1) == {MW {1'sb0}};
						if (POW2) begin
							kt_m1 <= sv2v_cast_0B087(k_m1 >> LP);
							nt_m1 <= sv2v_cast_0B087(n_m1 >> LP);
							thr <= ~k_m1[LP - 1:0];
							begin : sv2v_autoblock_6
								reg signed [31:0] j;
								for (j = 0; j < P; j = j + 1)
									begin
										amask_last[j] <= sv2v_cast_6A2A1_signed(j) <= k_m1[LP - 1:0];
										nmask_last[j] <= sv2v_cast_6A2A1_signed(j) <= n_m1[LP - 1:0];
									end
							end
						end
						else begin
							kt_m1 <= sv2v_cast_0B087_signed(ktv - 1);
							nt_m1 <= sv2v_cast_0B087_signed(ntv - 1);
							thr <= sv2v_cast_6A2A1_signed((ktv * P) - sv2v_cast_32_signed(dim_k));
							begin : sv2v_autoblock_7
								reg signed [31:0] j;
								for (j = 0; j < P; j = j + 1)
									begin
										amask_last[j] <= (((ktv - 1) * P) + j) < sv2v_cast_32_signed(dim_k);
										nmask_last[j] <= (((ntv - 1) * P) + j) < sv2v_cast_32_signed(dim_n);
									end
							end
						end
						busy <= 1'b1;
						state <= 3'd1;
						prime_left <= sv2v_cast_2_signed(MEM_REG);
						pre_row <= 1'sb0;
						out_row <= 1'sb0;
						pre_last <= sv2v_cast_82E88_signed(sv2v_cast_32_signed(dim_m) - 1) == {MW {1'sb0}};
						out_last <= sv2v_cast_82E88_signed(sv2v_cast_32_signed(dim_m) - 1) == {MW {1'sb0}};
						perf_passes <= 1'sb0;
						perf_cycles <= 1'sb0;
						perf_total <= 1'sb0;
					end
				3'd1:
					if (prime_left == 2'd0)
						state <= 3'd2;
					else
						prime_left <= prime_left - 2'd1;
				3'd2: begin
					perf_cycles <= perf_cycles + 32'd1;
					if (pass_first)
						perf_passes <= perf_passes + 32'd1;
					if (fin)
						state <= 3'd3;
				end
				3'd3:
					if (out_valid && out_last)
						state <= 3'd4;
				3'd4: begin
					done <= 1'b1;
					busy <= 1'b0;
					state <= 3'd0;
				end
				default: state <= 3'd0;
			endcase
			if (in_valid && a_first) begin
				cap_first <= kb == {KW {1'sb0}};
				cap_nb <= nb;
			end
			if (out_next2) begin
				if (pre_last) begin
					pre_row <= 1'sb0;
					pre_last <= m_one;
				end
				else begin
					pre_row <= pre_row + 1'b1;
					pre_last <= pre_row == m_m2;
				end
			end
			if (out_valid) begin
				if (out_last) begin
					out_row <= 1'sb0;
					out_last <= m_one;
				end
				else begin
					out_row <= out_row + 1'b1;
					out_last <= out_row == m_m2;
				end
			end
		end
	initial _sv2v_0 = 0;
endmodule

// P x P weight-stationary systolic array with input skew and output deskew.
module systolic_array (
	clk,
	rst,
	w_load,
	w_row,
	in_valid,
	a_row,
	out_valid,
	c_row
);
	parameter signed [31:0] P = 4;
	parameter signed [31:0] BITS = 8;
	parameter signed [31:0] ACC = 32;
	parameter signed [31:0] SAT = 0;
	parameter signed [31:0] PIPE = 1;
	parameter signed [31:0] PE_PRIM = 0;
	input wire clk;
	input wire rst;
	input wire w_load;
	input wire [(P * BITS) - 1:0] w_row;
	input wire in_valid;
	input wire [(P * BITS) - 1:0] a_row;
	output wire out_valid;
	output wire [(P * ACC) - 1:0] c_row;
	wire signed [BITS - 1:0] a_h [0:P - 1][0:P + 0];
	wire signed [ACC - 1:0] psum_v [0:P + 0][0:P - 1];
	wire signed [BITS - 1:0] w_v [0:P + 0][0:P - 1];
	genvar _gv_k_1;
	genvar _gv_j_1;
	generate
		for (_gv_k_1 = 0; _gv_k_1 < P; _gv_k_1 = _gv_k_1 + 1) begin : g_skew
			localparam k = _gv_k_1;
			if (k == 0) begin : g_none
				assign a_h[0][0] = a_row[BITS - 1:0];
			end
			else begin : g_dly
				delay_line #(
					.WIDTH(BITS),
					.DEPTH(k),
					.RESET(0)
				) u_skew(
					.clk(clk),
					.rst(rst),
					.d(a_row[k * BITS+:BITS]),
					.q(a_h[k][0])
				);
			end
		end
		for (_gv_j_1 = 0; _gv_j_1 < P; _gv_j_1 = _gv_j_1 + 1) begin : g_top
			localparam j = _gv_j_1;
			assign psum_v[0][j] = 1'sb0;
			assign w_v[0][j] = w_row[j * BITS+:BITS];
		end
		if (PE_PRIM == 0) begin : g_pes
			for (_gv_k_1 = 0; _gv_k_1 < P; _gv_k_1 = _gv_k_1 + 1) begin : g_r
				localparam k = _gv_k_1;
				for (_gv_j_1 = 0; _gv_j_1 < P; _gv_j_1 = _gv_j_1 + 1) begin : g_c
					localparam j = _gv_j_1;
					pe #(
						.BITS(BITS),
						.ACC(ACC),
						.SAT(SAT),
						.PIPE(PIPE)
					) u_pe(
						.clk(clk),
						.rst(rst),
						.w_load(w_load),
						.w_in(w_v[k][j]),
						.w_out(w_v[k + 1][j]),
						.a_in(a_h[k][j]),
						.a_out(a_h[k][j + 1]),
						.psum_in(psum_v[k][j]),
						.psum_out(psum_v[k + 1][j])
					);
				end
			end
		end
		else begin : g_dsp
			wire [17:0] bc [0:P + 0][0:P - 1];
			wire [47:0] pc [0:P + 0][0:P - 1];
			for (_gv_j_1 = 0; _gv_j_1 < P; _gv_j_1 = _gv_j_1 + 1) begin : g_c0
				localparam j = _gv_j_1;
				assign bc[0][j] = 1'sb0;
				assign pc[0][j] = 1'sb0;
				for (_gv_k_1 = 1; _gv_k_1 <= P; _gv_k_1 = _gv_k_1 + 1) begin : g_unused_w
					localparam k = _gv_k_1;
					assign w_v[k][j] = 1'sb0;
				end
			end
			for (_gv_k_1 = 0; _gv_k_1 < P; _gv_k_1 = _gv_k_1 + 1) begin : g_r
				localparam k = _gv_k_1;
				for (_gv_j_1 = 0; _gv_j_1 < P; _gv_j_1 = _gv_j_1 + 1) begin : g_c
					localparam j = _gv_j_1;
					pe_dsp48 #(
						.BITS(BITS),
						.ACC(ACC),
						.FIRST_ROW((k == 0 ? 1 : 0))
					) u_pe(
						.clk(clk),
						.w_load(w_load),
						.w_in(w_v[0][j]),
						.bcin(bc[k][j]),
						.bcout(bc[k + 1][j]),
						.a_in(a_h[k][j]),
						.a_out(a_h[k][j + 1]),
						.pcin(pc[k][j]),
						.pcout(pc[k + 1][j]),
						.psum_out(psum_v[k + 1][j])
					);
				end
			end
		end
		for (_gv_j_1 = 0; _gv_j_1 < P; _gv_j_1 = _gv_j_1 + 1) begin : g_out
			localparam j = _gv_j_1;
			if (j == (P - 1)) begin : g_none
				assign c_row[j * ACC+:ACC] = psum_v[P][j];
			end
			else begin : g_dly
				delay_line #(
					.WIDTH(ACC),
					.DEPTH((P - 1) - j),
					.RESET(0)
				) u_deskew(
					.clk(clk),
					.rst(rst),
					.d(psum_v[P][j]),
					.q(c_row[j * ACC+:ACC])
				);
			end
		end
	endgenerate
	delay_line #(
		.WIDTH(1),
		.DEPTH(((2 * P) - 1) + PIPE),
		.RESET(1)
	) u_valid(
		.clk(clk),
		.rst(rst),
		.d(in_valid),
		.q(out_valid)
	);
endmodule

// Processing element: psum_out <= psum_in + a_in * w (one multiply-add per clock).
module pe (
	clk,
	rst,
	w_load,
	w_in,
	w_out,
	a_in,
	a_out,
	psum_in,
	psum_out
);
	parameter signed [31:0] BITS = 8;
	parameter signed [31:0] ACC = 32;
	parameter signed [31:0] SAT = 0;
	parameter signed [31:0] PIPE = 1;
	input wire clk;
	input wire rst;
	input wire w_load;
	input wire signed [BITS - 1:0] w_in;
	output wire signed [BITS - 1:0] w_out;
	input wire signed [BITS - 1:0] a_in;
	output reg signed [BITS - 1:0] a_out;
	input wire signed [ACC - 1:0] psum_in;
	output reg signed [ACC - 1:0] psum_out;
	reg signed [BITS - 1:0] w;
	wire signed [(2 * BITS) - 1:0] prod_use;
	wire signed [ACC - 1:0] prod_ext;
	wire signed [ACC:0] sum;
	assign w_out = w;
	generate
		if (PIPE >= 2) begin : g_pipe2
			reg signed [BITS - 1:0] a_q;
			(* use_dsp = "yes" *) reg signed [(2 * BITS) - 1:0] m_q;
			always @(posedge clk) begin
				a_q <= a_in;
				m_q <= a_q * w;
			end
			assign prod_use = m_q;
		end
		else begin : g_pipe01
			(* use_dsp = "yes" *) wire signed [(2 * BITS) - 1:0] prod;
			assign prod = a_in * w;
			if (PIPE != 0) begin : g_pipe
				reg signed [(2 * BITS) - 1:0] prod_q;
				always @(posedge clk) prod_q <= prod;
				assign prod_use = prod_q;
			end
			else begin : g_nopipe
				assign prod_use = prod;
			end
		end
		if (ACC > (2 * BITS)) begin : g_ext
			assign prod_ext = {{ACC - (2 * BITS) {prod_use[(2 * BITS) - 1]}}, prod_use};
		end
		else begin : g_same
			assign prod_ext = prod_use;
		end
		if (PIPE >= 2) begin : g_add_dsp
			(* use_dsp = "yes" *) wire signed [ACC:0] s;
			assign s = {psum_in[ACC - 1], psum_in} + {prod_ext[ACC - 1], prod_ext};
			assign sum = s;
		end
		else begin : g_add_lut
			(* use_dsp = "no" *) wire signed [ACC:0] s;
			assign s = {psum_in[ACC - 1], psum_in} + {prod_ext[ACC - 1], prod_ext};
			assign sum = s;
		end
	endgenerate
	localparam signed [ACC:0] MAXV = {2'b00, {ACC - 1 {1'b1}}};
	localparam signed [ACC:0] MINV = {2'b11, {ACC - 1 {1'b0}}};
	always @(posedge clk) begin
		if (w_load)
			w <= w_in;
		a_out <= a_in;
		if ((SAT != 0) && (sum > MAXV))
			psum_out <= MAXV[ACC - 1:0];
		else if ((SAT != 0) && (sum < MINV))
			psum_out <= MINV[ACC - 1:0];
		else
			psum_out <= sum[ACC - 1:0];
	end
	wire unused_rst;
	assign unused_rst = rst;
endmodule

// Shift register: delays a value by DEPTH clocks.
module delay_line (
	clk,
	rst,
	d,
	q
);
	parameter signed [31:0] WIDTH = 8;
	parameter signed [31:0] DEPTH = 1;
	parameter signed [31:0] RESET = 1;
	input wire clk;
	input wire rst;
	input wire [WIDTH - 1:0] d;
	output wire [WIDTH - 1:0] q;
	(* srl_style = "register" *) reg [WIDTH - 1:0] sh [0:DEPTH - 1];
	generate
		if (RESET != 0) begin : g_rst
			always @(posedge clk)
				if (rst) begin : sv2v_autoblock_1
					reg signed [31:0] i;
					for (i = 0; i < DEPTH; i = i + 1)
						sh[i] <= 1'sb0;
				end
				else begin
					sh[0] <= d;
					begin : sv2v_autoblock_2
						reg signed [31:0] i;
						for (i = 1; i < DEPTH; i = i + 1)
							sh[i] <= sh[i - 1];
					end
				end
		end
		else begin : g_norst
			wire unused_rst;
			assign unused_rst = rst;
			always @(posedge clk) begin
				sh[0] <= d;
				begin : sv2v_autoblock_3
					reg signed [31:0] i;
					for (i = 1; i < DEPTH; i = i + 1)
						sh[i] <= sh[i - 1];
				end
			end
		end
	endgenerate
	assign q = sh[DEPTH - 1];
endmodule
