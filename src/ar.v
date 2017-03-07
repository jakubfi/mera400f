module ar(
	input p1,
	input m4_,
	input l_,
	input [0:15] w,
	output reg [0:15] ar
);

	// NOTE: Sensitivities are different for the FPGA implementation.
	//       Idea behind it is to always be front-edge sensitive
	always @ (negedge l_, negedge m4_, posedge p1) begin
		if (~l_) begin
			ar <= w;
		end else begin
			if (~m4_) ar <= ar - 3'd4;
			else ar <= ar + 1'b1;
		end
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
