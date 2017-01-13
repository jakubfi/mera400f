module rb(
	input [10:15] w,
	input w_rba,
	input w_rbb,
	input w_rbc,
	output reg [0:15] rb
);

	always @ (negedge w_rbc)
		rb[0:3] <= w[12:14];

	always @ (negedge w_rbb)
		rb[4:9] <= w[10:15];

	always @ (negedge w_rba)
		rb[10:15] <= w[10:15];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab