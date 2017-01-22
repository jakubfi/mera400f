module decoder8(
	input en_,
	input [0:2] i,
	output [0:7] o
);

	assign o[0] = ~en_ & ~i[0] & ~i[1] & ~i[2];
	assign o[1] = ~en_ & ~i[0] & ~i[1] &  i[2];
	assign o[2] = ~en_ & ~i[0] &  i[1] & ~i[2];
	assign o[3] = ~en_ & ~i[0] &  i[1] &  i[2];
	assign o[4] = ~en_ &  i[0] & ~i[1] & ~i[2];
	assign o[5] = ~en_ &  i[0] & ~i[1] &  i[2];
	assign o[6] = ~en_ &  i[0] &  i[1] & ~i[2];
	assign o[7] = ~en_ &  i[0] &  i[1] &  i[2];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
