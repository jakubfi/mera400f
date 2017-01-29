module ar(
	input p1,
	input m4,
	input l_,
	input [0:15] w,
	output reg [0:15] ar
);

	always @ (negedge l_, posedge m4, negedge p1) begin
		if (~l_) ar <= w;
		else if (m4) ar <= ar - 3'd4;
		else ar <= ar + 1'b1;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
