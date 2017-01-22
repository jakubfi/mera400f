`timescale 1ns/100ps

// -----------------------------------------------------------------------
module regs_tb();

	reg [15:0] w;
	wire [15:0] l;
	reg czytrn;
	reg piszrn;
	reg czytrw;
	reg piszrw;
	reg ra, rb;

	regs U1(.w(w), .l(l), .czytrn(czytrn), .piszrn(piszrn), .czytrw(czytrw), .piszrw(piszrw), .ra(ra), .rb(rb));

	initial begin
		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
