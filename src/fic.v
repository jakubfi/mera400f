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
	output reg [0:5] out,
	output fic
);

	reg op;
	always @ (posedge clk) begin
		op <= load | cda | cua | rab;
	end

	always @ (posedge op) begin
		if (rab) out <= 0;
		else if (load) out <= in;
		else if (cda) out <= out - 1'd1;
		else if (cua) out <= out + 1'd1;
	end

	assign fic = |out;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
