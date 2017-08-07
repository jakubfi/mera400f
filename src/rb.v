/*
	Binary load register (RB)

	document: 12-006368-01-8A
	unit:     P-R2-3
	pages:    2-63
*/

module rb(
	input clk_sys,
	input [10:15] w,
	input w_rba,
	input w_rbb,
	input w_rbc,
	output reg [0:15] rb
);

	always @ (posedge clk_sys) begin
		if (w_rbc) rb[0:3] <= w[12:15];
		if (w_rbb) rb[4:9] <= w[10:15];
		if (w_rba) rb[10:15] <= w[10:15];
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
