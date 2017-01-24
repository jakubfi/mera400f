`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg m;
	reg [3:0] s;
	reg [15:0] a;
	reg [15:0] b;
	wire [15:0] f;
	wire cn4_, eq;
	wire c1, c2, c3;
	wire x1, x2, x3, x4;
	wire y1, y2, y3, y4;

	alu181 u1(.m(m), .s(s), .a(a[3:0]), .b(b[3:0]), .cn_(1), .f(f[3:0]), .x(x1), .y(y1));
	alu181 u2(.m(m), .s(s), .a(a[7:4]), .b(b[7:4]), .cn_(c1), .f(f[7:4]), .x(x2), .y(y2));
	alu181 u3(.m(m), .s(s), .a(a[11:8]), .b(b[11:8]), .cn_(c2), .f(f[11:8]), .x(x3), .y(y3));
	alu181 u4(.m(m), .s(s), .a(a[15:12]), .b(b[15:12]), .cn_(c3), .f(f[15:12]), .x(x4), .y(y4), .cn4_(cn4_));
	carry182 u5(.x({x4, x3, x2, x1}), .y({y4, y3, y2, y1}), .cn_(1), .cnx_(c1), .cny_(c2), .cnz_(c3));

	initial begin
		#1 m = 0; s=9; a=32000; b=33535;
		#1 `tbassert(f, 65535)
		#1 `tbassert(cn4_, 1)
		#1 m = 0; s=9; a=32000; b=33536;
		#1 `tbassert(f, 0)
		#1 `tbassert(cn4_, 0)
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
