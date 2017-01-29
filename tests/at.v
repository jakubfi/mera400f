`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg [15:0] f;
	wire [15:0] at;
	reg s0, s1, c, sl;

	at U1(
		.f(f),
		.at(at),
		.s0(s0), .s1(s1),
		.c(c), .sl(sl)
	);

	initial begin
		#1 f = 16'b1100110010101010;
		#1 {s1, s0, sl} = 4'b110;
		#1 c = 1'b1;
		#1 `tbassert(at, 16'b1100110010101010)
		#1 c = 1'b0;

		#1 {s1, s0, sl} = 4'b000;
		#1 c = 1'b1;
		#1 c = 1'b0;
		#1 `tbassert(at, 16'b1100110010101010)

		#1 {s1, s0, sl} = 4'b010;
		#1 c = 1'b1;
		#1 c = 1'b0;
		#1 `tbassert(at, 16'b0110011001010101)

		#1 {s1, s0, sl} = 4'b011;
		#1 c = 1'b1;
		#1 c = 1'b0;
		#1 `tbassert(at, 16'b1011001100101010)

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
