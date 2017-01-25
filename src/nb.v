module nb(
	input [12:15] w,
	input cnb_,
	input clm_,
	output reg [0:3] nb
);

	always @ (posedge cnb_, negedge clm_) begin
		if (~clm_) nb <= 4'd0;
		else nb <= w[12:15];
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
