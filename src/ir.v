/*
	Instruction register (IR)

	document: 12-006368-01-8A
	unit:     P-D3-2
	pages:    2-30
*/

module ir(
	input [0:15] d,
	input c,
	input invalidate,
	output reg [0:15] q
);

	// NOTE: invalidate_ was originaly done by shorting 7475 outputs to ground
	// through open-collector drivers
	always @ (posedge c, posedge invalidate) begin
		if (invalidate) q[0:1] <= 2'd0;
		else q <= d;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
