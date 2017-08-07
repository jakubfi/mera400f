module dok(
	input clk_sys,
	input rin,
	input zw,
	input int_ext,
	output dok_trig,
	output dok
);

	parameter DOK_DLY_TICKS;
	parameter DOK_TICKS;

	wire rin_dly;
	dly #(.ticks(DOK_DLY_TICKS)) DLY_DOK(
		.clk(clk_sys),
		.i(rin),
		.o(rin_dly)
	);

	univib #(.ticks(DOK_TICKS)) TRIG_DOK(
		.clk(clk_sys),
		.a_(~rin_dly),
		.b(~zw),
		.q(dok_trig)
	);

	wire dok_send;
	ffd REG_DOK(
		.s_(1'b1),
		.d(int_ext),
		.c(~dok_trig),
		.r_(rin_dly),
		.q(dok_send)
	);

	assign dok = rin & dok_send;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
