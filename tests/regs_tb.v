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

	regs U1(.w(w), .l(l), .czytrn(czytrn), .piszrn(piszrn), .czytrw(czytrw), .piszrw(piszrw), .ra(ra), .rb(rb), .rc(0));


	initial begin
		$display("    w\tczytrn\tpiszrn\tczytrw\tpiszrw\tra\trb\t    l");
		$display("--------------------------------------------------------------");
		$monitor("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", w, czytrn, piszrn, czytrw, piszrw, ra, rb, l);
		w = 0;
		czytrn = 0;
		czytrw = 0;
		piszrn = 0;
		piszrw = 0;
		ra = 0;
		rb = 0;

		#1 w = 15; ra = 1; rb = 0; piszrn = 1; czytrn = 0;
		#1 piszrn = 0;
		#1 w = 33; ra = 0; rb = 1; piszrn = 1; czytrn = 0;
		#1 piszrn = 0;
		#1 w = 44; ra = 1; rb = 1; piszrn = 1; czytrn = 0;
		#1 piszrn = 0;

		#1 ra = 1; rb = 0; piszrn = 0; czytrn = 1;
		#1 czytrn = 0;
		#1 ra = 0; rb = 1; piszrn = 0; czytrn = 1;
		#1 czytrn = 0;
		#1 ra = 1; rb = 1; piszrn = 0; czytrn = 1;
		#1 czytrn = 0;

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
