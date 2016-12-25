module ffjk(
	input clk, j, k, r, s,
	output reg q
);

	initial begin
		q = 1'b0;
	end

	always @ (posedge clk, posedge r, posedge s) begin
		if (r) q <= 1'b0;
		else if (s) q <= 1'b1;
		else case ({j, k})
			2'b00 : q <= q;
			2'b01 : q <= 1'b0;
			2'b10 : q <= 1'b1;
			2'b11 : q <= ~q;
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
