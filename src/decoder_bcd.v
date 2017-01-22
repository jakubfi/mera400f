module decoder_bcd(
	input a, // LSB
	input b,
	input c,
	input d, // MSB
	output [0:9] o_
);

	assign o_[0] = ~(~d & ~c & ~b & ~a);
	assign o_[1] = ~(~d & ~c & ~b &  a);
	assign o_[2] = ~(~d & ~c &  b & ~a);
	assign o_[3] = ~(~d & ~c &  b &  a);
	assign o_[4] = ~(~d &  c & ~b & ~a);
	assign o_[5] = ~(~d &  c & ~b &  a);
	assign o_[6] = ~(~d &  c &  b & ~a);
	assign o_[7] = ~(~d &  c &  b &  a);
	assign o_[8] = ~( d & ~c & ~b & ~a);
	assign o_[9] = ~( d & ~c & ~b &  a);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
