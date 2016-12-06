module decoder8(
	input en,
	input [0:3] i,
	output [0:7] o
);

	assign o[0] = en & ~i[1] & ~i[2] & ~i[3];
	assign o[1] = en & ~i[1] & ~i[2] &  i[3];
	assign o[2] = en & ~i[1] &  i[2] & ~i[3];
	assign o[3] = en & ~i[1] &  i[2] &  i[3];
	assign o[4] = en &  i[1] & ~i[2] & ~i[3];
	assign o[5] = en &  i[1] & ~i[2] &  i[3];
	assign o[6] = en &  i[1] &  i[2] & ~i[3];
	assign o[7] = en &  i[1] &  i[2] &  i[3];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
