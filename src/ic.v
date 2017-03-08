module ic(
	input cu_,
	input l_,
	input r,
	input [0:15] w,
	output reg [0:15] ic
);

	// NOTE: Sensitivities are different for the FPGA implementation.
	//       Idea behind it is to always be front-edge sensitive
	wire clk = ~cu_ | ~l_ | r;
	always @ (posedge clk) begin
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
