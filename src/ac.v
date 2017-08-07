/*
	Accumulator (AC register)

	document: 12-006368-01-8A
	unit:     P-A3-2
	pages:    2-77
*/

module ac(
	input clk_sys,
	input c,
	input [0:15] w,
	output reg [0:15] ac
);

	always @ (posedge clk_sys) begin
		if (c) ac <= w;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
