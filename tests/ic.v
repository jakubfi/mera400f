`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg [15:0] w;
	wire [15:0] ic;
	reg cu_, l_, r;

	ic U1(
		.w(w),
		.ic(ic),
		.cu_(cu_), .l_(l_), .r(r)
	);

	initial begin
		#1 w = 16'hdead; {cu_, l_, r} = 3'b110;
		#1 w = 16'hdead; {cu_, l_, r} = 3'b100;
		#1 `tbassert(ic, 16'hdead)
		#1 w = 16'hdead; {cu_, l_, r} = 3'b010;
		#1 `tbassert(ic, 16'hdeae)
		#1 w = 16'hdead; {cu_, l_, r} = 3'b110;
		#1 w = 16'hdead; {cu_, l_, r} = 3'b010;
		#1 `tbassert(ic, 16'hdeaf)
		#1 w = 16'hdead; {cu_, l_, r} = 3'b111;
		#1 `tbassert(ic, 16'h0000)

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
