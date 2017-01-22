module decoder16(
	input [0:1] en_,
	input [0:3] i,
	output [0:15] o
);

	wire s = &(~en_);
	assign o[0]  = s & ~i[0] & ~i[1] & ~i[2] & ~i[3];
	assign o[1]  = s & ~i[0] & ~i[1] & ~i[2] &  i[3];
	assign o[2]  = s & ~i[0] & ~i[1] &  i[2] & ~i[3];
	assign o[3]  = s & ~i[0] & ~i[1] &  i[2] &  i[3];
	assign o[4]  = s & ~i[0] &  i[1] & ~i[2] & ~i[3];
	assign o[5]  = s & ~i[0] &  i[1] & ~i[2] &  i[3];
	assign o[6]  = s & ~i[0] &  i[1] &  i[2] & ~i[3];
	assign o[7]  = s & ~i[0] &  i[1] &  i[2] &  i[3];
	assign o[8]  = s &  i[0] & ~i[1] & ~i[2] & ~i[3];
	assign o[9]  = s &  i[0] & ~i[1] & ~i[2] &  i[3];
	assign o[10] = s &  i[0] & ~i[1] &  i[2] & ~i[3];
	assign o[11] = s &  i[0] & ~i[1] &  i[2] &  i[3];
	assign o[12] = s &  i[0] &  i[1] & ~i[2] & ~i[3];
	assign o[13] = s &  i[0] &  i[1] & ~i[2] &  i[3];
	assign o[14] = s &  i[0] &  i[1] &  i[2] & ~i[3];
	assign o[15] = s &  i[0] &  i[1] &  i[2] &  i[3];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
