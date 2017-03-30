/*
	Interrupt request and interrupt service register pair
*/

module rzrp(
	input imask,		// interrupt mask
	input irq_,			// async irq source
	input w,				// clocked irq source
	input rz_c_,		// irq clock
	input rz_r_,		// irq clear
	input rp_c,			// interrupt service clock
	input prio_in_,	// interrupt priority chain input
	output rz,			// irq
	output sz,			// irq & mask
	output rp_,			// interrupt service register
	output prio_out	// interrupt priority chain output
);

	ffjk RZ(
		.s_(irq_),
		.j(w),
		.c_(rz_c_),
		.k(~rp_),
		.r_(rz_r_),
		.q(rz)
	);
	assign sz = ~(rz & imask);
	ffd RP(
		.s_(prio_in_),
		.d(sz),
		.c(rp_c),
		.r_(1'b1),
		.q(rp_)
	);
	assign prio_out = rp_ & prio_in_;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
