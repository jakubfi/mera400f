module decoder16(
	input en1_, en2_,
	input a, // LSB
	input b,
	input c,
	input d, // MSB
	output [0:15] o_
);

	wire s = ~en1_ & ~en2_;
	assign o_[0]  = ~(s & ~d & ~c & ~b & ~a);
	assign o_[1]  = ~(s & ~d & ~c & ~b &  a);
	assign o_[2]  = ~(s & ~d & ~c &  b & ~a);
	assign o_[3]  = ~(s & ~d & ~c &  b &  a);
	assign o_[4]  = ~(s & ~d &  c & ~b & ~a);
	assign o_[5]  = ~(s & ~d &  c & ~b &  a);
	assign o_[6]  = ~(s & ~d &  c &  b & ~a);
	assign o_[7]  = ~(s & ~d &  c &  b &  a);
	assign o_[8]  = ~(s &  d & ~c & ~b & ~a);
	assign o_[9]  = ~(s &  d & ~c & ~b &  a);
	assign o_[10] = ~(s &  d & ~c &  b & ~a);
	assign o_[11] = ~(s &  d & ~c &  b &  a);
	assign o_[12] = ~(s &  d &  c & ~b & ~a);
	assign o_[13] = ~(s &  d &  c & ~b &  a);
	assign o_[14] = ~(s &  d &  c &  b & ~a);
	assign o_[15] = ~(s &  d &  c &  b &  a);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
