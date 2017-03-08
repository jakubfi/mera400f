`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg [15:0] w;
	wire [15:0] ar;
	reg p1, m4_, l_;

	ar U1(
		.w(w),
		.ar(ar),
		.p1(p1), .m4_(m4_), .l_(l_)
	);

	initial begin
		#1 w = 16'hbeef; {p1, m4_, l_} = 3'b011;
		#1 l_ = 0; #1 l_ = 1; // load
		#1 `tbassert(ar, 16'hbeef)
		#1 p1 = 1; #1 p1 = 0; // +1
		#1 `tbassert(ar, 16'hbef0)
		#1 m4_ = 0; #1 m4_ = 1; // -4
		#1 `tbassert(ar, 16'hbeec)
		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
