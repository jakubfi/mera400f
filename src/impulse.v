/*
	1-clock impulse generator
*/

module impulse(
	input clk,
	input in,
	output reg q
);

	reg r;
	always @ (posedge clk) begin
		r <= in;
		q <= ~r & in;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
