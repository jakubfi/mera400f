module mera400f(
	input [15:0] w,
	output [15:0] l,
	input czytrn,
	input piszrn,
	input czytrw,
	input piszrw,
	input ra, rb
);

	regs u_regs(.w(w), .l(l), .czytrn(czytrn), .piszrn(piszrn), .czytrw(czytrw), .piszrw(piszrw), .ra(ra), .rb(rb));

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
