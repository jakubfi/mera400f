module ffd(
	input clk, d, r, s,
	output reg q
);

	initial begin
		q = 1'b0;
	end

	always @ (posedge clk, posedge r, posedge s) begin
		if (r) q <= 1'b0;
		else if (s) q <= 1'b1;
		else q <= d;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
