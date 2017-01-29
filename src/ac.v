module ac(
	input c,
	input [0:15] w,
	output reg [0:15] ac
);

	always @ (posedge c) begin
		ac <= w;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
