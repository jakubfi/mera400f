module ir(
	input [0:15] d,
	input c,
	output reg [0:15] q
);

	always @ (c, d) begin
		if (c) q <= d;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
