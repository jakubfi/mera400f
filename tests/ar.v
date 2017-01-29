`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg [15:0] w;
	wire [15:0] ar;
	reg p1, m4, l_;

	ar U1(
		.w(w),
		.ar(ar),
		.p1(p1), .m4(m4), .l_(l_)
	);

	initial begin
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b000;
		#1 `tbassert(ar, 16'hbeef)
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b001;
		#1 `tbassert(ar, 16'hbeef)
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b101;
		#1 `tbassert(ar, 16'hbeef)
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b001;
		#1 `tbassert(ar, 16'hbef0)
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b101;
		#1 `tbassert(ar, 16'hbef0)
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b001;
		#1 `tbassert(ar, 16'hbef1)
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b011;
		#1 `tbassert(ar, 16'hbeed)
		#1 w = 16'hbeef; {p1, m4, l_} = 3'b001;

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
