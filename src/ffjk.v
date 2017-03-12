module ffjk(
	input c_, j, k, r_, s_,
	output reg q
);

	always @ (negedge c_, negedge r_, negedge s_) begin
		if (~r_) q <= 1'b0;
		else if (~s_) q <= 1'b1;
		else case ({j, k})
			2'b00 : q <= q;
			2'b01 : q <= 1'b0;
			2'b10 : q <= 1'b1;
			2'b11 : q <= ~q;
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
