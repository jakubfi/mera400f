/*
	Interrupt request and interrupt service register pair
*/

module rzrp(
	input imask,		// interrupt mask
	input irq,			// async irq source
	input w,				// clocked irq source
	input rz_c,			// irq clock
	input rz_r,			// irq clear
	input rp_c,			// interrupt service clock
	input prio_in,	// interrupt priority chain input
	output rz,			// irq
	output sz,			// irq & mask
	output rp,			// interrupt service register
	output prio_out	// interrupt priority chain output
);

	assign sz = rz & imask;

	// rz_c @ strob1 (opadającym w oryginale, narastającym w fpga)
	// rz_r @ clm k1
	// irq @ async

	always @ (posedge rz_c, posedge rz_r, posedge irq) begin
		if (rz_r) rz <= 1'b0;
		else if (irq) rz <= 1'b1;
		else case ({w, rp})
			2'b00 : rz <= rz;
			2'b01 : rz <= 1'b0;
			2'b10 : rz <= 1'b1;
			2'b11 : rz <= ~rz;
		endcase
	end

	// rp_c @ i1 & przerw (faza z KC)
	// prio_in @ rp_

	always @ (posedge rp_c, posedge prio_in) begin
		if (prio_in) rp <= 1'b0;
		else if (rp_c) rp <= sz;
	end

	assign prio_out = rp | prio_in;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
