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

  // NOTE: in the original design, -SI1 drives open-collector buffers which
  // short ir[0:1] 7475 outputs to ground, causing reset of the two most significant bits of IR.
  // This is a way of 'disabling' instruction decoder so it doesn't send -LIP/-SP
  // signals to interrupt control loop when serving 'invalid instruction' interrupt caused
  // by LIP/SP instructions executed in user program. Here we just reset two bits in IR.

	always @ (posedge c, posedge invalidate) begin
		if (invalidate) q[0:1] <= 2'd0;
		else q <= d;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
