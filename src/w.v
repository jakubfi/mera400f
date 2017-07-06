module bus_w(
	input mwc_, mwb_, mwa_,
	input bwa_, bwb_,
	input [0:15] ir,
	input [0:15] kl,
	input [0:15] rdt_,
	input [0:15] ki,
	input [0:15] at,
	input [0:15] ac,
	input [0:15] a,
	output [0:15] w
);

	always @ (*) begin
		case ({bwb_, mwc_, mwb_, mwa_})
			4'b1111 : w[0:7] = ir[0:7];
			4'b1110 : w[0:7] = kl[0:7];
			4'b1101 : w[0:7] = ~rdt_[0:7];
			4'b1100 : w[0:7] = 8'd0;
			4'b1011 : w[0:7] = ki[0:7];
			4'b1010 : w[0:7] = at[0:7];
			4'b1001 : w[0:7] = ac[0:7];
			4'b1000 : w[0:7] = a[0:7];
			default : w[0:7] = 8'd0; // bwb_ = 0
		endcase

		case ({bwa_, mwc_, mwb_, mwa_})
			4'b1111 : w[8:15] = ir[8:15];
			4'b1110 : w[8:15] = kl[8:15];
			4'b1101 : w[8:15] = ~rdt_[8:15];
			4'b1100 : w[8:15] = ac[0:7];
			4'b1011 : w[8:15] = ki[8:15];
			4'b1010 : w[8:15] = at[8:15];
			4'b1001 : w[8:15] = ac[8:15];
			4'b1000 : w[8:15] = a[8:15];
			default : w[8:15] = 8'd0; // bwa_ = 0
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
