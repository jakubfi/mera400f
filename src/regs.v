/*
	MERA-400 user registers

	document:	12-006368-01-8A
	unit:			P-R2-3
	pages:		2-59..2-62
*/

/* synthesis ramstyle = "M4K" */

module regs (
	output [0:15] l,
	input [0:15] w,
	input ra, rb,
	input piszrn, czytrn,
	input piszrw, czytrw
);

	reg [0:2] read_add;
	reg [0:15] mem [0:15];

	wire wr = piszrn | piszrw;
	wire rd = czytrn | czytrw;
	wire h = czytrw | piszrw;
	wire [0:2] addr = {h, ra, rb};
	wire strobe = wr | rd;

	always @ (posedge strobe) 
	begin
		if (wr) mem[addr] <= w;
		read_add <= addr;
	end

	assign l = rd ? mem[read_add] : 16'b1;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
