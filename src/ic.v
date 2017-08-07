/*
	Instruction counter (IC register)

	document: 12-006368-01-8A
	unit:     P-A3-2
	pages:    2-79
*/

module ic(
	input clk_sys,
	input cu,
	input l,
	input r,
	input [0:15] w,
	output reg [0:15] ic
);

	// NOTE: Sensitivities are different for the FPGA implementation.
	//       Idea behind it is to always be front-edge sensitive
	//wire clk = cu | l | r;
	always @ (posedge clk_sys, posedge r) begin
		if (r) ic <= 16'd0;
		else if (l) ic <= w;
		else if (cu) ic <= ic + 1'b1;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
