/*
	Block number register (NB)

	document: 12-006368-01-8A
	unit:     P-R3-2
	pages:    2-63
*/

module nb(
	input clk,
	input [12:15] w,
	input cnb,
	input clm,
	output reg [0:3] nb
);

	always @ (posedge clk, posedge clm) begin
		if (clm) nb <= 4'd0;
		else if (cnb) nb <= w[12:15];
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
