`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg [15:0] w;
	wire [15:0] l;
	reg czytrn_;
	reg piszrn_;
	reg czytrw_;
	reg piszrw_;
	reg ra, rb;

	regs U1(
		.w(w),
		.l(l),
		.czytrn_(czytrn_), .piszrn_(piszrn_),
		.czytrw_(czytrw_), .piszrw_(piszrw_),
		.ra(ra), .rb(rb)
	);

	initial begin
		#1 w = 16'hbeef; {ra, rb} = 2'b01; {czytrn_, piszrn_, czytrw_, piszrw_} = 4'b1111;
		#1 `tbassert(l, 16'hffff)

		#1 w = 16'hbeef; {ra, rb} = 2'b01; {czytrn_, piszrn_, czytrw_, piszrw_} = 4'b1011;
		#1 `tbassert(l, 16'hffff)
		#1 w = 16'hbeef; {ra, rb} = 2'b01; {czytrn_, piszrn_, czytrw_, piszrw_} = 4'b0111;
		#1 `tbassert(l, 16'hbeef)

		#1 w = 16'hdead; {ra, rb} = 2'b01; {czytrn_, piszrn_, czytrw_, piszrw_} = 4'b1111;
		#1 `tbassert(l, 16'hffff)

		#1 w = 16'hdead; {ra, rb} = 2'b01; {czytrn_, piszrn_, czytrw_, piszrw_} = 4'b1110;
		#1 `tbassert(l, 16'hffff)
		#1 w = 16'h1111; {ra, rb} = 2'b01; {czytrn_, piszrn_, czytrw_, piszrw_} = 4'b1101;
		#1 `tbassert(l, 16'hdead)

		#1 w = 16'h1111; {ra, rb} = 2'b01; {czytrn_, piszrn_, czytrw_, piszrw_} = 4'b0111;
		#1 `tbassert(l, 16'hbeef)

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
