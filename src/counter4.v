module counter4(
	input cd,
	input [0:3] i,
	output reg [0:3] o,
	input r,
	input l_
);

	always @ (posedge cd, negedge l_, posedge r) begin
		if (r) o <= 4'd0;
		else if (~l_) o <= i;
		else o <= o - 1'b1;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
