/*
	Step counter (LK)

	document: 12-006368-01-8A
	unit:     P-M3-2
	pages:    2-20
*/

module lk(
	input clk,
	input cd,
	input [0:3] i,
	input r,
	input l,
	output lk
);

	reg [0:3] cnt;

	always @ (posedge clk, posedge r) begin
		if (r) cnt <= 4'd0;
		else if (l) cnt <= i;
		else if (cd) cnt <= cnt - 1'b1;
	end

	assign lk = |cnt;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
