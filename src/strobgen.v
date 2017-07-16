module strobgen(
	input __clk,
	input ss11, ss12, ss13, ss14, ss15,
	input ok, zw, oken,
	input mode, step,
	input strob_fp,
	output got,
	output strob1,
	output strob2
);

	parameter STROB1_1_TICKS;
	parameter STROB1_2_TICKS;
	parameter STROB1_3_TICKS;
	parameter STROB1_4_TICKS;
	parameter STROB1_5_TICKS;
	parameter GOT_TICKS;
	parameter STROB2_TICKS;

	// sheet 3, page 2-3
	// * strob signals

	wire strob1_st2;
	wire strob1_only;
	univib #(.ticks(STROB1_1_TICKS)) VIB_STROB1_1(
		.clk(__clk),
		.a_(got),
		.b(ss11 | (ss12 & ok)),
		.q(strob1_st2)
	);
	univib #(.ticks(STROB1_3_TICKS)) VIB_STROB1_3(
		.clk(__clk),
		.a_(got),
		.b((ss13 & ok) | ss14 | ss15),
		.q(strob1_only)
	);

	wire strob1_any = strob1_st2 | strob1_only;

	// sheet 4, page 2-4
	// * got, strob2, step register

	wire sgot = ss11 | ss12;
	wire if_holdoff = got_trig & zw & oken;
	wire step_trig = ~sgot & strob_step;
	wire got_trig = if_holdoff | step_trig | strob1_only | strob2;

	univib #(.ticks(GOT_TICKS)) VIB_GOT(
		.clk(__clk),
		.a_(got_trig),
		.b(1'b1),
		.q(got)
	);

	// NOTE: strob2 needs to be triggered with 1-cycle delay
	// to set it apart from strob1 falling edge. This is needed
	// for cycles where one action is taken on strob1 falling
	// edge, and another on the strob2 rising edge.
	reg strob2_trig = 1;
	always @ (posedge __clk) begin
		strob2_trig <= (strob_step & sgot) | strob1_st2;
	end

	univib #(.ticks(STROB2_TICKS)) VIB_STROB2(
		.clk(__clk),
		.a_(strob2_trig),
		.b(1'b1),
		.q(strob2)
	);

	wire step_set = mode & strob1_any;
	wire strob_step;
	ffd REG_STEP(
		.s_(~step_set),
		.d(1'b0),
		.c(~step),
		.r_(mode),
		.q(strob_step)
	);

	assign strob1 = strob1_any | strob_fp | strob_step;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
