module rb(
	input [10:15] w,
	input w_rba_,
	input w_rbb_,
	input w_rbc_,
	output reg [0:15] rb
);

	always @ (posedge w_rbc_)
		rb[0:3] <= w[12:14];

	always @ (posedge w_rbb_)
		rb[4:9] <= w[10:15];

	always @ (posedge w_rba_)
		rb[10:15] <= w[10:15];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
