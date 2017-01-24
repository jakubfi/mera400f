`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg en1_, en2_;
	reg a, b, c, d;
	wire [0:15] o_;

	decoder16 U1(
		.en1_(en1_),
		.en2_(en2_),
		.a(a),
		.b(b),
		.c(c),
		.d(d),
		.o_(o_)
	);

	initial begin
		#1 en1_ = 1'b1; en2_ = 1'b1; #1 `tbassert(o_, 16'b1111111111111111)
		#1 en1_ = 1'b0; en2_ = 1'b1; #1 `tbassert(o_, 16'b1111111111111111)
		#1 en1_ = 1'b1; en2_ = 1'b0; #1 `tbassert(o_, 16'b1111111111111111)

		#1 en1_ = 1'b0; en2_ = 1'b0;

		#1 {d, c, b, a} = 4'd0;  #1 `tbassert(o_, 16'b0111111111111111)
		#1 {d, c, b, a} = 4'd1;  #1 `tbassert(o_, 16'b1011111111111111)
		#1 {d, c, b, a} = 4'd2;  #1 `tbassert(o_, 16'b1101111111111111)
		#1 {d, c, b, a} = 4'd3;  #1 `tbassert(o_, 16'b1110111111111111)
		#1 {d, c, b, a} = 4'd4;  #1 `tbassert(o_, 16'b1111011111111111)
		#1 {d, c, b, a} = 4'd5;  #1 `tbassert(o_, 16'b1111101111111111)
		#1 {d, c, b, a} = 4'd6;  #1 `tbassert(o_, 16'b1111110111111111)
		#1 {d, c, b, a} = 4'd7;  #1 `tbassert(o_, 16'b1111111011111111)
		#1 {d, c, b, a} = 4'd8;  #1 `tbassert(o_, 16'b1111111101111111)
		#1 {d, c, b, a} = 4'd9;  #1 `tbassert(o_, 16'b1111111110111111)
		#1 {d, c, b, a} = 4'd10; #1 `tbassert(o_, 16'b1111111111011111)
		#1 {d, c, b, a} = 4'd11; #1 `tbassert(o_, 16'b1111111111101111)
		#1 {d, c, b, a} = 4'd12; #1 `tbassert(o_, 16'b1111111111110111)
		#1 {d, c, b, a} = 4'd13; #1 `tbassert(o_, 16'b1111111111111011)
		#1 {d, c, b, a} = 4'd14; #1 `tbassert(o_, 16'b1111111111111101)
		#1 {d, c, b, a} = 4'd15; #1 `tbassert(o_, 16'b1111111111111110)

		#1 en1_ = 1'b1; en2_ = 1'b0; #1 `tbassert(o_, 16'b1111111111111111)
		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
