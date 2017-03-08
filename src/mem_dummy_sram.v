module mem_dummy_sram(
	input clk,
	output SRAM_CE, SRAM_OE, SRAM_WE, SRAM_UB, SRAM_LB,
	output [17:0] SRAM_A,
	inout [15:0] SRAM_D,
	input [0:15] ad_,
	output [0:15] ddt_,
	input [0:15] rdt_,
	input w_, r_,
	output ok_
);

	assign SRAM_CE = 0;
	assign SRAM_UB = 0;
	assign SRAM_LB = 0;

	assign SRAM_A[17:0] = { 2'b00, ~ad_[0:15] };
	assign SRAM_D = ~w_ ? ~rdt_[0:15] : 16'hzzzz;
	assign ddt_ = ~r_ ? ~SRAM_D[15:0] : 16'hffff;

	wire we;
	assign SRAM_WE = ~we;
	univib #(.ticks(1'd1)) WE_VIB(
		.clk(clk),
		.a_(w_),
		.b(1'b1),
		.q(we)
	);

	wire re;
	assign SRAM_OE = ~re;
	univib #(.ticks(1'd1)) RE_VIB(
		.clk(clk),
		.a_(r_),
		.b(1'b1),
		.q(re)
	);

	wire ok;
	assign ok_ = ~ok;
	univib #(.ticks(1'd1)) DLY_VIB(
		.clk(clk),
		.a_(1'b0),
		.b(re | we),
		.q(ok)
	);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
