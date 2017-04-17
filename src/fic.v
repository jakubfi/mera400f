/*
	AWP FIC register

	document: 12-006370-01-4A
	unit:     F-PM2-2
	pages:    2-20
*/

module fic(
	input clk,
	input cda,
	input cua_,
	input rab_,
	input load_,
	input [0:5] in,
	output reg [0:5] out
);

	reg op;
	always @ (posedge clk) begin
		op <= ~load_ | ~cda | ~cua_ | rab_;
	end

	always @ (posedge op) begin
		if (rab_) out <= 0;
		else if (~load_) out <= in;
		else if (~cda) out <= out - 1'd1;
		else if (~cua_) out <= out + 1'd1;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
