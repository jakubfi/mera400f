module r0 (
	// buses
	input [0:15] w,
	output [0:8] r0,
	// data signals
	input zs, s_1, s0, carry_,
	input vl_, vg_, exy_, exx_,
	// strobe signals
	input strob1,
	input ust_z, ust_v, ust_mc, ust_y, ust_x,
	input cleg_,
	// commands
	input w_zmvc, w_legy,
	input w8_x,
	// async
	input zero_v,
	input zer
);

	// --- R00, Z flag --------------------------------------------------------
	wire set0 = ~(w[0] & w_zmvc);
	ffd R00(
		.c(~(ust_z & strob1)),
		.d(zs),
		.r_(~((set0 & w_zmvc) | zer)),
		.s_(set0),
		.q(r0[0])
	);

	// --- R01, M flag --------------------------------------------------------
	wire set1 = ~(w[1] & w_zmvc);
	ffd R01(
		.c(~(ust_mc & strob1)),
		.d(s_1),
		.r_(~((set1 & w_zmvc) | zer)),
		.s_(set1),
		.q(r0[1])
	);

	// --- R02, V flag --------------------------------------------------------
	wire set2 = ~(w[2] & w_zmvc);
	ffjk R02(
		.c_(ust_v & strob1),
		.j(s0 ^ s_1),
		.k(1'b0),
		.r_(~((set2 & w_zmvc) | (zero_v ^ zer))),
		.s_(set2),
		.q(r0[2])
	);

	// --- R03, C flag --------------------------------------------------------
	wire set3 = ~(w[3] & w_zmvc);
	ffjk R03(
		.c_(ust_mc & strob1),
		.j(~carry_),
		.k(carry_),
		.r_(~((set3 & w_zmvc) | zer)),
		.s_(set3),
		.q(r0[3])
	);

	// --- R04, L flag --------------------------------------------------------
	wire reset4 = ~(w[4] & w_legy);
	wire r04;
	ffd R04(
		.c(cleg_),
		.d(vl_),
		.r_(reset4),
		.s_(~(zer | (w_legy & reset4))),
		.q(r04)
	);
	assign r0[4] = ~r04;

	// --- R05, E flag --------------------------------------------------------
	wire set5 = ~(w[5] & w_legy);
	ffd R05(
		.c(cleg_),
		.d(zs),
		.r_(~(zer | (w_legy & set5))),
		.s_(set5),
		.q(r0[5])
	);

	// --- R06, G flag --------------------------------------------------------
	wire reset6 = ~(w[6] & w_legy);
	wire r06;
	ffd R06(
		.c(cleg_),
		.d(vg_),
		.r_(reset6),
		.s_(~(zer | (w_legy & reset6))),
		.q(r06)
	);
	assign r0[6] = ~r06;

	// --- R07, Y flag --------------------------------------------------------
	wire reset7 = ~(w[7] & w_legy);
	wire r07;
	ffd R07(
		.c(~(ust_y & strob1)),
		.d(exy_),
		.r_(reset7),
		.s_(~(zer | (w_legy & reset7))),
		.q(r07)
	);
	assign r0[7] = ~r07;

	// --- R08, X flag --------------------------------------------------------
	wire reset8 = ~(w[8] & w8_x);
	wire r08;
	ffd R08(
		.c(~(ust_x & strob1)),
		.d(exx_),
		.r_(reset8),
		.s_(~(zer | (w8_x & reset8))),
		.q(r08)
	);
	assign r0[8] = ~r08;

endmodule

// --------------------------------------------------------------------
module r0_9_15(
	input [9:15] w,
	input lrp,
	input zer_,
	output reg [9:15] r0_
);

	always @ (posedge lrp, negedge zer_) begin
		if (~zer_) r0_ <= 7'd0;
		else if (lrp) r0_ <= ~w;
	end

endmodule


// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
