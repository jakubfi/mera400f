module univib
	#(parameter TICKS = 4'd5)
(
	input clk,
	input a, b,
	output reg q
);
	reg [3:0] r = TICKS;

	wire done = ~|r;
	wire trig = ~a & b;

	always @ (posedge trig, posedge done) begin
		if (done) q <= 1'b0;
		else if (trig) q <= 1'b1;
	end

	always @ (posedge clk) begin
		if (q) r <= r - 1'b1;
		else r <= 4'b0101;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
