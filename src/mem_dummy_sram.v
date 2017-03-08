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

	assign SRAM_A[17:0] = { 2'b00, ~ad_[0:15] };
	assign SRAM_CE = w_ & r_;
	assign SRAM_OE = r_;
	assign SRAM_WE = w_;
	assign SRAM_UB = w_ & r_;
	assign SRAM_LB = w_ & r_;
	assign SRAM_D = ~w_ ? ~rdt_[0:15] : 16'hzzzz;
	assign ddt_ = ~r_ ? ~SRAM_D[15:0] : 16'hffff;

	wire ok_dly;
	dly #(.ticks(2'd2)) DLY_OK(
		.clk(clk),
		.i(~SRAM_CE),
		.o(ok_dly)
	);

	wire ok;
	assign ok_ = ~ok;
	univib #(.ticks(2'd2)) DLY_VIB(
		.clk(clk),
		.a_(1'b0),
		.b(ok_dly),
		.q(ok)
	);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
