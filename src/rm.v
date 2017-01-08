module rmx(
	input w_, clrs, zi, clm__,
	output rs
);

	wire __r_ = ~(~zi & clm__);
	ffd r(.s_(1'b1), .d(~w_), .c(clrs), .r_(__r_), .q(rs));

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
