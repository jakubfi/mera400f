/*
	D flip-flop
*/

module ffd(
	input c, d, r_, s_,
	output reg q
);

	always @ (posedge c, negedge r_, negedge s_) begin
		if (~r_) q <= 1'b0;
		else if (~s_) q <= 1'b1;
		else q <= d;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
