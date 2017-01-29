module ic(
	input cu,
	input l_,
	input r,
	input [0:15] w,
	output reg [0:15] ic
);

	always @ (posedge cu, negedge l_, posedge r) begin
		if (r) ic <= 16'd0;
		else if (~l_) ic <= w;
		else ic <= ic + 1'b1;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
