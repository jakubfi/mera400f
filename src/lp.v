module lp(
	input lp_clk,
	input lpb_s,
	input lpa_s,
	input lpab_r,
	output [0:1] out,
	output lp, lp1, lp2, lp3
);

/*
	preload:
		@lpb_s (10):
			@start * mw
			@f2 * mw*~fwz
		@lpa_s (01):
			@start * ~mw
			@f2 * ~mw
		@lpab_r (00):
			@f2 * fwz * mw
			@f4 * (~dw|fwz)
			@f7
	lp+1:
		@f13, @strob1b
		@f3, @strob1b
		@f1, @strob1b
		@f8, @strob1b lp*dw
*/

	wire lpb_r = lpa_s | lpab_r;
	wire lpa_r = lpb_s | lpab_r;

	wire lpa, lpb;

/*
	always @ (posedge clk_sys) begin
		if (lp_clk) out <= out + 2'b1;
		else if (lpa_s) out <= 2'b01;
		else if (lpb_s) out <= 2'b10;
		else if (M44_8) out <= 2'b00;
	end
*/

	ffjk REG_LPB(
		.s_(~lpb_s),
		.j(lpa),
		.c_(lp_clk),
		.k(lpa),
		.r_(~lpb_r),
		.q(lpb)
	);

	ffjk REG_LPA(
		.s_(~lpa_s),
		.j(1'b1),
		.c_(lp_clk),
		.k(1'b1),
		.r_(~lpa_r),
		.q(lpa)
	);

	assign out = {lpb, lpa};
	assign lp = (out != 0);
	assign lp1 = (out == 1);
	assign lp2 = (out == 2);
	assign lp3 = (out == 3);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
