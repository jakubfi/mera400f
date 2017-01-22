module latch16(
	input [0:15] d,
	input c,
	output reg [0:15] q
);

	always @ (d, c) begin
		if (c) q <= d;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
