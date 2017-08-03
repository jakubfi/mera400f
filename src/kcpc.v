module kcpc(
	input clk,
	input kc_reset,
	input ekc,
	input ekc_fp,
	input ldstate,
	input rescyc,
	input dpr,
	output pr,
	input clm,
	input dprzerw,
	output przerw,
	output kc,
	output pc
);

	parameter KC_TICKS;
	parameter PC_TICKS;

	reg trig_kc;
	always @ (posedge clk, posedge kc_reset) begin
		if (kc_reset) trig_kc <= 1'b0;
		else if (ekc_fp) trig_kc <= 1'b1;
		else if (ldstate) trig_kc <= ekc;
	end
/*
	wire trig_kc;
	ffjk REG_KC(
		.s_(~ekc_fp),
		.j(ekc),
		.c_(~got),
		.k(1'b0),
		.r_(~kc_reset),
		.q(trig_kc)
	);
*/
	univib #(.ticks(KC_TICKS)) VIB_KC(
		.clk(clk),
		.a_(1'b0),
		.b(trig_kc),
		.q(kc)
	);

	univib #(.ticks(PC_TICKS)) VIB_PC(
		.clk(clk),
		.a_(kc),
		.b(1'b1),
		.q(pc)
	);

	wire pr_;
	ffd REG_PR(
		.s_(~rescyc),
		.d(~dpr),
		.c(kc),
		.r_(1'b1),
		.q(pr_)
	);
	assign pr = ~pr_;

	ffd REG_PRZERW(
		.r_(~clm),
		.d(dprzerw),
		.c(kc),
		.s_(1'b1),
		.q(przerw)
	);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
