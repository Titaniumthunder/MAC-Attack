// MAC Attack accelerator: a small but complete chip for OpenLane 2 (SKY130).
//
// Generated from the team's SystemVerilog (rtl/*.sv plus source/mac_attack_chip.sv)
// with sv2v 0.0.13, because OpenLane's synthesizer (Yosys) reads plain Verilog best:
//
//   sv2v --top=mac_attack_chip rtl/delay_line.sv rtl/pe.sv rtl/systolic_array.sv rtl/mm_core.sv \
//        rtl/uart_rx.sv rtl/uart_tx.sv rtl/host_if.sv rtl/chip_top.sv source/mac_attack_chip.sv
//
// Same design as the Vivado version, smaller sizes: 4x4 array (16 PEs), INT8 inputs,
// 32-bit accumulators, matrices up to 8x8, serial port at 115,200 baud from a 40 MHz clock.
// Checked before release: RTL simulation and Yosys gate-level simulation over the serial
// port (6/6 tests pass), Verilator lint (0 errors), no latches.
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
	parameter signed [31:0] CLKS_PER_BIT = 347;
	input wire clk;
	input wire rst;
	input wire uart_rx_i;
	output wire uart_tx_o;
	output wire busy_led;
	chip_top #(
		.P(P),
		.BITS(8),
		.ACC(32),
		.SAT(0),
		.MAXD(MAXD),
		.CLKS_PER_BIT(CLKS_PER_BIT)
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
		.MAXD(MAXD)
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
		.MAXD(MAXD)
	) u_core(
		.clk(clk),
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
	function automatic [BITS - 1:0] sv2v_cast_3727D;
		input reg [BITS - 1:0] inp;
		sv2v_cast_3727D = inp;
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
								state <= 4'd8;
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
								state <= 4'd8;
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
							state <= 4'd8;
						end
						else
							cnt <= cnt + 1;
					end
				4'd2:
					if (rx_valid) begin
						wr_en <= 1'b1;
						wr_row <= sv2v_cast_8_signed(row);
						wr_col <= sv2v_cast_8_signed(col);
						wr_data <= sv2v_cast_3727D(rx_data);
						if (col == (cols - 1)) begin
							col <= 0;
							if (row == (rows - 1)) begin
								rbuf[0] <= 8'h6b;
								rlen <= 1;
								ridx <= 0;
								ret <= 4'd0;
								state <= 4'd8;
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
						state <= 4'd8;
					end
				4'd4: begin
					rd_row <= sv2v_cast_8_signed(row);
					rd_col <= sv2v_cast_8_signed(col);
					state <= 4'd5;
				end
				4'd5: state <= 4'd6;
				4'd6: begin
					begin : sv2v_autoblock_2
						reg signed [31:0] b;
						for (b = 0; b < 4; b = b + 1)
							rbuf[b] <= cval[8 * b+:8];
					end
					rlen <= 4;
					ridx <= 0;
					ret <= 4'd7;
					state <= 4'd8;
				end
				4'd7:
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
				4'd8:
					if (tx_ready) begin
						tx_data <= rbuf[ridx];
						tx_start <= 1'b1;
						state <= 4'd9;
					end
				4'd9: state <= 4'd10;
				4'd10:
					if (tx_ready) begin
						if (ridx == (rlen - 1))
							state <= ret;
						else begin
							ridx <= ridx + 1;
							state <= 4'd8;
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
	input wire clk;
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
	reg [(P * BITS) - 1:0] amem [0:DEPTH - 1];
	reg [(P * BITS) - 1:0] bmem [0:DEPTH - 1];
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
	always @(posedge clk) begin
		if (wr_en && !wr_sel)
			amem[wr_addr][wr_lane * BITS+:BITS] <= wr_data;
		if (wr_en && wr_sel)
			bmem[wr_addr][wr_lane * BITS+:BITS] <= wr_data;
	end
	reg [2:0] state;
	reg signed [31:0] m;
	reg signed [31:0] k;
	reg signed [31:0] n;
	reg signed [31:0] kt;
	reg signed [31:0] nt;
	reg signed [31:0] t;
	reg signed [31:0] o;
	reg signed [31:0] kb;
	reg signed [31:0] nb;
	wire last_pass;
	assign last_pass = (kb == (kt - 1)) && (nb == (nt - 1));
	reg signed [31:0] n_o;
	reg signed [31:0] n_kb;
	reg signed [31:0] n_nb;
	always @(*) begin
		if (_sv2v_0)
			;
		n_o = 0;
		n_kb = 0;
		n_nb = 0;
		if ((state == 3'd2) && !((o == (t - 1)) && last_pass)) begin
			if (o == (t - 1)) begin
				n_o = 0;
				if (kb == (kt - 1)) begin
					n_kb = 0;
					n_nb = nb + 1;
				end
				else begin
					n_kb = kb + 1;
					n_nb = nb;
				end
			end
			else begin
				n_o = o + 1;
				n_kb = kb;
				n_nb = nb;
			end
		end
	end
	reg signed [31:0] k_n;
	reg signed [31:0] i_n;
	reg signed [31:0] a_addr;
	reg signed [31:0] b_addr;
	reg b_need;
	reg a_need;
	reg [P - 1:0] a_lanes;
	reg [P - 1:0] b_lanes;
	always @(*) begin
		if (_sv2v_0)
			;
		b_need = n_o < P;
		a_need = (n_o >= P) && (n_o < (P + m));
		k_n = (b_need ? ((n_kb * P) + (P - 1)) - n_o : 0);
		i_n = (a_need ? n_o - P : 0);
		b_addr = (b_need ? (k_n * TM) + n_nb : 0);
		a_addr = (a_need ? (i_n * TM) + n_kb : 0);
		begin : sv2v_autoblock_1
			reg signed [31:0] j;
			for (j = 0; j < P; j = j + 1)
				begin
					b_lanes[j] = (b_need && (k_n < k)) && (((n_nb * P) + j) < n);
					a_lanes[j] = ((n_kb * P) + j) < k;
				end
		end
	end
	reg [(P * BITS) - 1:0] aq;
	reg [(P * BITS) - 1:0] bq;
	reg [P - 1:0] a_lanes_q;
	reg [P - 1:0] b_lanes_q;
	always @(posedge clk) begin
		aq <= amem[a_addr];
		bq <= bmem[b_addr];
		a_lanes_q <= a_lanes;
		b_lanes_q <= b_lanes;
	end
	wire w_load;
	wire in_valid;
	wire out_valid;
	reg [(P * BITS) - 1:0] w_row;
	reg [(P * BITS) - 1:0] a_row;
	wire [(P * ACC) - 1:0] c_row;
	assign w_load = (state == 3'd2) && (o < P);
	assign in_valid = ((state == 3'd2) && (o >= P)) && (o < (P + m));
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_2
			reg signed [31:0] j;
			for (j = 0; j < P; j = j + 1)
				begin
					w_row[j * BITS+:BITS] = (b_lanes_q[j] ? bq[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
					a_row[j * BITS+:BITS] = (a_lanes_q[j] ? aq[j * BITS+:BITS] : {BITS * 1 {1'sb0}});
				end
		end
	end
	systolic_array #(
		.P(P),
		.BITS(BITS),
		.ACC(ACC),
		.SAT(SAT)
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
	wire out_next;
	delay_line #(
		.WIDTH(1),
		.DEPTH((2 * P) - 2)
	) u_next(
		.clk(clk),
		.rst(rst),
		.d(in_valid),
		.q(out_next)
	);
	reg signed [31:0] cap_kb;
	reg signed [31:0] cap_nb;
	reg signed [31:0] pre_row;
	reg signed [31:0] out_row;
	wire signed [31:0] c_raddr;
	reg [7:0] rd_lane;
	reg [(P * ACC) - 1:0] cq;
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	assign c_raddr = (busy ? (out_next ? (pre_row * TM) + cap_nb : 0) : (sv2v_cast_32_signed(rd_row) * TM) + (sv2v_cast_32_signed(rd_col) / P));
	always @(posedge clk) begin
		cq <= cmem[c_raddr];
		rd_lane <= sv2v_cast_8(sv2v_cast_32(rd_col) % P);
	end
	assign rd_data = cq[rd_lane * ACC+:ACC];
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
			assign c_new[j * ACC+:ACC] = acc_add((cap_kb == 0 ? {ACC * 1 {1'sb0}} : cq[j * ACC+:ACC]), c_row[j * ACC+:ACC]);
		end
	endgenerate
	always @(posedge clk)
		if (out_valid)
			cmem[(out_row * TM) + cap_nb] <= c_new;
	always @(posedge clk)
		if (rst) begin
			state <= 3'd0;
			busy <= 1'b0;
			done <= 1'b0;
			o <= 0;
			kb <= 0;
			nb <= 0;
			m <= 1;
			k <= 1;
			n <= 1;
			kt <= 1;
			nt <= 1;
			t <= 1;
			cap_kb <= 0;
			cap_nb <= 0;
			pre_row <= 0;
			out_row <= 0;
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
						m <= sv2v_cast_32_signed(dim_m);
						k <= sv2v_cast_32_signed(dim_k);
						n <= sv2v_cast_32_signed(dim_n);
						kt <= ((sv2v_cast_32_signed(dim_k) + P) - 1) / P;
						nt <= ((sv2v_cast_32_signed(dim_n) + P) - 1) / P;
						t <= (sv2v_cast_32_signed(dim_m) + (3 * P)) - 2;
						busy <= 1'b1;
						state <= 3'd1;
						pre_row <= 0;
						out_row <= 0;
						perf_passes <= 1'sb0;
						perf_cycles <= 1'sb0;
						perf_total <= 1'sb0;
					end
				3'd1: begin
					o <= 0;
					kb <= 0;
					nb <= 0;
					state <= 3'd2;
				end
				3'd2: begin
					perf_cycles <= perf_cycles + 32'd1;
					if (o == 0)
						perf_passes <= perf_passes + 32'd1;
					if ((o == (t - 1)) && last_pass)
						state <= 3'd3;
					o <= n_o;
					kb <= n_kb;
					nb <= n_nb;
				end
				3'd3:
					if (out_valid)
						state <= 3'd4;
				3'd4: begin
					done <= 1'b1;
					busy <= 1'b0;
					state <= 3'd0;
				end
				default: state <= 3'd0;
			endcase
			if (in_valid && (o == P)) begin
				cap_kb <= kb;
				cap_nb <= nb;
			end
			if (out_next)
				pre_row <= (pre_row == (m - 1) ? 0 : pre_row + 1);
			if (out_valid)
				out_row <= (out_row == (m - 1) ? 0 : out_row + 1);
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
					.DEPTH(k)
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
		for (_gv_k_1 = 0; _gv_k_1 < P; _gv_k_1 = _gv_k_1 + 1) begin : g_r
			localparam k = _gv_k_1;
			for (_gv_j_1 = 0; _gv_j_1 < P; _gv_j_1 = _gv_j_1 + 1) begin : g_c
				localparam j = _gv_j_1;
				pe #(
					.BITS(BITS),
					.ACC(ACC),
					.SAT(SAT)
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
		for (_gv_j_1 = 0; _gv_j_1 < P; _gv_j_1 = _gv_j_1 + 1) begin : g_out
			localparam j = _gv_j_1;
			if (j == (P - 1)) begin : g_none
				assign c_row[j * ACC+:ACC] = psum_v[P][j];
			end
			else begin : g_dly
				delay_line #(
					.WIDTH(ACC),
					.DEPTH((P - 1) - j)
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
		.DEPTH((2 * P) - 1)
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
	wire signed [(2 * BITS) - 1:0] prod;
	wire signed [ACC - 1:0] prod_ext;
	wire signed [ACC:0] sum;
	assign prod = a_in * w;
	assign w_out = w;
	generate
		if (ACC > (2 * BITS)) begin : g_ext
			assign prod_ext = {{ACC - (2 * BITS) {prod[(2 * BITS) - 1]}}, prod};
		end
		else begin : g_same
			assign prod_ext = prod;
		end
	endgenerate
	assign sum = {psum_in[ACC - 1], psum_in} + {prod_ext[ACC - 1], prod_ext};
	localparam signed [ACC:0] MAXV = {2'b00, {ACC - 1 {1'b1}}};
	localparam signed [ACC:0] MINV = {2'b11, {ACC - 1 {1'b0}}};
	always @(posedge clk)
		if (rst) begin
			w <= 1'sb0;
			a_out <= 1'sb0;
			psum_out <= 1'sb0;
		end
		else begin
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
	input wire clk;
	input wire rst;
	input wire [WIDTH - 1:0] d;
	output wire [WIDTH - 1:0] q;
	reg [WIDTH - 1:0] sh [0:DEPTH - 1];
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
	assign q = sh[DEPTH - 1];
endmodule
