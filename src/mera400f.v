module mera400f(input dummy);

	wire [15:0] w;
	wire [15:0] l;
	wire czytrn;
	wire piszrn;
	wire czytrw;
	wire piszrw;
	wire ra, rb;

	regs u_regs(.w(w), .l(l), .czytrn(czytrn), .piszrn(piszrn), .czytrw(czytrw), .piszrw(piszrw), .ra(ra), .rb(rb), .rc(0));

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
