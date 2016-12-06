/*
	MERA-400 IR register

	document: 12-006368-01-8A
	unit:     P-D2-3
	pages:    2-30
*/

/* synthesis ramstyle = "M4K" */

module ir(
	input [10:15] w,
	input strob1,
	input w_ir,
	output [0:15] ir
);

	reg [0:15] __ir;

	wire __clk = strob1 & w_ir;
	always @ (posedge __clk) begin
		__ir <= w;
	end

	assign ir = __ir;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
