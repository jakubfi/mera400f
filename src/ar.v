/*
	Address register (AR)

	document: 12-006368-01-8A
	unit:     P-A3-2
	pages:    2-77
*/

module ar(
	input p1,
	input m4,
	input l,
	input [0:15] w,
	output reg [0:15] ar
);

	// NOTE: Sensitivities are different for the FPGA implementation.
	//       Idea behind it is to always be front-edge sensitive
	wire clk = l | m4 | p1;
	always @ (posedge clk) begin
		if (l) ar <= w;
		else begin
			if (m4) ar <= ar - 3'd4;
			else ar <= ar + 1'b1;
		end
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
