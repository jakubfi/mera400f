module mc(
	input clk,
	input inc,
	input reset,
	output mc_3,
	output mc_0
);

	reg [1:0] mc;

	always @ (posedge clk, posedge reset) begin
		if (reset) mc <= 2'd0;
		else if (inc) mc <= mc + 1'b1;
	end

	assign mc_3 = (mc == 3);
	assign mc_0 = (mc == 0);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
