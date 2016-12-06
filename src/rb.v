module rb(
	input [10:15] w,
	input w_rba,
	input w_rbb,
	input w_rbc,
	output [0:15] rb
);

	reg [0:15] r;

	always @ (negedge w_rbc)
		r[0:3] = w[12:14];

	always @ (negedge w_rbb)
		r[4:9] = w[10:15];

	always @ (negedge w_rba)
		r[10:15] = w[10:15];

	assign rb = r;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
