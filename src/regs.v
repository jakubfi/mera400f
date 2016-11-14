/*
	MERA-400 user registers

	unit:		P-R2-3
	document:	12-006368-01-8A
	pages:		2-59, 2-60, 2-61, 2-62
*/

module regs (
	output [15:0] l,
	input [15:0] w,
	input ra, rb, rc, // rc is unused here. Added only to force auto-M4K storage on Altera devices
	input piszrn, czytrn,
	input piszrw, czytrw
);

	reg [3:0] read_add;
	reg [15:0] mem [15:0];

	wire wr = piszrn | piszrw;
	wire rd = czytrn | czytrw;
	wire h = czytrw | piszrw;
	wire [3:0] addr = {h, ra, rb, rc};
	wire strobe = wr | rd;

	always @ (posedge strobe) 
	begin
		if (wr) mem[addr] <= w;
		read_add <= addr;
	end

	assign l = rd ? mem[read_add] : 'bz;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
