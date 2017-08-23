module ld(
	input clk_sys,
	input lkb,
	input _0_d,
	input l_d,
	input [0:7] sum_c,
	input sum_c_2,
	input sum_c_1,
	input [8:15] w,
	output reg [-2:7] d
);

	wire [0:9] l;

	always @ (*) begin
		case (lkb)
			0: l <= {sum_c_2, sum_c_1, sum_c[0:7]};
			1: l <= {w[8], w[8], w[8:15]};
		endcase
	end

	always @ (posedge clk_sys, posedge _0_d) begin
		if (_0_d) d <= 10'd0;
		else if (l_d) d <= l;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
