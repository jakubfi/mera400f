module lp(
	input lp_clk,
	input lpb_s,
	input lpa_s,
	input M44_8,
	output [0:1] out,
	output lp, lp1, lp2, lp3
);

	wire lpb_r = lpa_s | M44_8;
	wire lpa_r = lpb_s | M44_8;

	wire lpa, lpb;

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
  assign lp = lpb | lpa;
  assign lp1 = lpa & ~lpb;
  assign lp2 = lpb & ~lpa;
  assign lp3 = lpb & lpa;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
