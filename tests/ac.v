`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg [15:0] w;
	wire [15:0] ac;
	reg c;

	ac U1(
		.w(w),
		.ac(ac),
		.c(c)
	);

	initial begin
		#1 w = 16'hdead;
		c = 1'b0;
		c = 1'b1;
		#1 `tbassert(ac, 16'hdead)
		#1 w = 16'hbeef;
		c = 1'b0;
		c = 1'b1;
		#1 `tbassert(ac, 16'hbeef)

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
