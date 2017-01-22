/*
	MERA-400 IR register

	document: 12-006368-01-8A
	unit:     P-D2-3
	pages:    2-30
*/

module ir(
	input [0:15] w,
	input c,
	input w_ir,
	output reg [0:15] ir
);

	always @ (posedge c) begin
		ir <= w;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
