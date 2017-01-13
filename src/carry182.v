module carry182(
	input [3:0] y, x,
	input cn_,
	output ox, oy,
	output cnx_, cny_, cnz_
);

	assign cnx_ = ~(                                y[0] & (x[0] | ~cn_));
	assign cny_ = ~(                y[1] & (x[1] | (y[0] & (x[0] | ~cn_))));
	assign cnz_ = ~(y[2] & (x[2] | (y[1] & (x[1] | (y[0] & (x[0] | ~cn_))))));

	assign oy = y[3] & (x[3] | y[2]) & (x[3] | x[2] | y[1]) & (x[3] | x[2] | x[1] | y[0]);
	assign ox = |x;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
