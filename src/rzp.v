module rzp(
	input imask,		// interrupt mask
	input intr_,		// async irq source
	input w,				// clocked irq source
	input ckrz_,		// irq clock
	input zerrz_,		// irq clear
	input ckrp,			// interrupt service clock
	input prio_in_,	// interrupt priority chain input
	output rz,			// irq
	output sz,			// irq & mask
	output rp,			// interrupt service register
	output prio_out	// interrupt priority chain output
);

	ffjk_ __rz(.c_(ckrz_), .j(w), .k(rp), .r_(zerrz_), .s_(intr_), .q(rz));

	assign sz = ~(rz & imask);

	ffd_ __rp(.s_(prio_in_), .d(sz), .c(ckrp), .r_(1'b1), .q(rp));

	assign prio_out = ~rp & prio_in_;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
