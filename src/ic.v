module ic(
	input cu_,
	input l_,
	input r,
	input [0:15] w,
	output reg [0:15] ic
);

	// NOTE: Sensitivities are different for the FPGA implementation.
	//       Idea behind it is to always be front-edge sensitive
	always @ (negedge cu_, negedge l_, posedge r) begin
		if (~l_) begin
			ic <= w;
		end else if (r) begin
			ic <= 16'd0;
		end else begin
			ic <= ic + 1'b1;
		end
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
