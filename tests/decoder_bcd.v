`timescale 1ns/100ps

module decoder_bcd_test();

`define tbassert(signal, value) \
	if (signal !== value) begin \
		$display("FAILED: got %d, expected %d!", signal, value); \
		$finish; \
	end

	reg a, b, c, d;
	wire [0:9] o_;

	decoder_bcd U1(
		.a(a),
		.b(b),
		.c(c),
		.d(d),
		.o_(o_)
	);

	initial begin
		#1 {d, c, b, a} = 4'd0;  #1 `tbassert(o_, 10'b0111111111)
		#1 {d, c, b, a} = 4'd1;  #1 `tbassert(o_, 10'b1011111111)
		#1 {d, c, b, a} = 4'd2;  #1 `tbassert(o_, 10'b1101111111)
		#1 {d, c, b, a} = 4'd3;  #1 `tbassert(o_, 10'b1110111111)
		#1 {d, c, b, a} = 4'd4;  #1 `tbassert(o_, 10'b1111011111)
		#1 {d, c, b, a} = 4'd5;  #1 `tbassert(o_, 10'b1111101111)
		#1 {d, c, b, a} = 4'd6;  #1 `tbassert(o_, 10'b1111110111)
		#1 {d, c, b, a} = 4'd7;  #1 `tbassert(o_, 10'b1111111011)
		#1 {d, c, b, a} = 4'd8;  #1 `tbassert(o_, 10'b1111111101)
		#1 {d, c, b, a} = 4'd9;  #1 `tbassert(o_, 10'b1111111110)
		#1 {d, c, b, a} = 4'd10; #1 `tbassert(o_, 10'b1111111111)
		#1 {d, c, b, a} = 4'd11; #1 `tbassert(o_, 10'b1111111111)
		#1 {d, c, b, a} = 4'd12; #1 `tbassert(o_, 10'b1111111111)
		#1 {d, c, b, a} = 4'd13; #1 `tbassert(o_, 10'b1111111111)
		#1 {d, c, b, a} = 4'd14; #1 `tbassert(o_, 10'b1111111111)
		#1 {d, c, b, a} = 4'd15; #1 `tbassert(o_, 10'b1111111111)
		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
