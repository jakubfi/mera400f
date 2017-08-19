module fp_strobgen(
	input clk_sys,
	input start,
	input di,
	input dp8, dp2, dp6, dp5,
	input mode,
	input step,
	input oken,
	input f1,
	input zw,
	output strob1, strob2, __got, got_fp, sr_fp
);

	wire strob1_st2, strob1_only;
	univib #(.ticks(2'd3)) VIB_STROB1_ST2(
		.clk(clk_sys),
		.a_(sr),
		.b(dp8 | dp2),
		.q(strob1_st2)
	);
	univib #(.ticks(2'd3)) VIB_STROB1_ST1(
		.clk(clk_sys),
		.a_(sr),
		.b(dp6 | dp5),
		.q(strob1_only)
	);

	wire step_reset = mode & (strob1_st2 | ~strob1_only);

	wire strob_step;
	ffd REG_STEP(
		.s_(~step_reset),
		.d(1'b0),
		.c(~step),
		.r_(mode),
		.q(strob_step)
	);

	assign strob1 = strob1_only | strob1_st2 | strob_step;

	wire has_strob2 = dp8 | dp2;
	wire strob2_trig = strob1_st2 | (has_strob2 & strob_step);

	univib #(.ticks(2'd3)) VIB_STROB2(
		.clk(clk_sys),
		.a_(strob2_trig),
		.b(1'b1),
		.q(strob2)
	);

	wire stgot = strob1_only | strob2 | (~has_strob2 & strob_step) | (oken & f1 & zw);

	univib #(.ticks(2'd3)) VIB_GOT(
		.clk(clk_sys),
		.a_(stgot),
		.b(1'b1),
		.q(__got)
	);

	assign got_fp = ~di & __got;
	wire sr = start | got_fp;
	assign sr_fp = sr & f1;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
