/*
	AWP FIC register

	document: 12-006370-01-4A
	unit:     F-PM2-2
	pages:    2-20
*/

module fic(
	input clk,
	input cda,
	input cua,
	input rab,
	input load,
	input [0:5] in,
	output fic
);

	reg op;
	always @ (posedge clk) begin
		op <= load | cda | cua | rab;
	end

	reg [0:5] cnt;

	always @ (posedge op) begin
		if (rab) cnt <= 0;
		else if (load) cnt <= in;
		else if (cda) cnt <= cnt - 1'd1;
		else if (cua) cnt <= cnt + 1'd1;
	end

	assign fic = |cnt;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
