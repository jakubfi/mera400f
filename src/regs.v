/*
	User registers

	document: 12-006368-01-8A
	unit:     P-R2-3
	pages:    2-59..2-62
*/

module regs(
	input clk_sys,
	input [0:15] w,
	input [0:2] addr,
	input we,
	output [0:15] l
);

	reg [0:15] mem [0:7];

	always @ (posedge clk_sys) begin
		if (we) mem[addr] <= w;
	end

	assign l = mem[addr];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
