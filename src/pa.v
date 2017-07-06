/*
	P-A unit (ALU)

	document: 12-006368-01-8A
	unit:     P-A3-2
	pages:    2-70..2-84
	sheets:   15
*/

module pa(
	// sheet 1
	input [0:15] ir,
	input [0:15] ki,
	input [0:15] rdt_,
	input w_dt_,
	input mwa_,
	input mwb_,
	input mwc_,
	input bwa_,
	input bwb_,
	output [0:15] ddt_,
	output [0:15] w,
	// sheet 2
	// sheet 3
	// sheet 4
	// sheet 5
	input saryt,
	input sab_,
	input scb_,
	input sb_,
	input sd_,
	output s0,
	output carry_,
	// sheet 6
	input p16_,
	input saa_,
	input sca_,
	output j$,
	output exx_,
	// sheet 7
	input wx_,
	input eat0,
	input axy,
	output at15_,
	output exy_,
	// sheet 8
	input w_ac,
	input strob2_,
	input as2,
	input strob1_,
	input am1,
	input apb,
	input amb,
	input ap1,
	input strob1,
	output s_1,
	output wzi,
	output zs,
	// sheet 9
	input arm4_,
	input w_ar,
	input arp1,
	output arz,
	// sheet 10
	input icp1,
	input w_ic,
	input off_,
	// sheet 11, 12
	input baa_,
	input bab_,
	input bac_,
	input ab_,
	input aa_,
	input [0:15] l,
	// sheet 13, 14
	input barnb,
	input [0:15] kl,
	input ic_ad_,
	output [0:15] dad_,
	input ar_ad_,
	output zga

);

  wor __NC; // unconnected signals here, to suppress warnings

	// sheet 1..4

	wire w_dt = ~w_dt_;

	bus_w BUS_W(
		.mwc_(mwc_),
		.mwb_(mwb_),
		.mwa_(mwa_),
		.bwa_(bwa_),
		.bwb_(bwb_),
		.ir(ir),
		.kl(kl),
		.rdt_(rdt_),
		.ki(ki),
		.at(at),
		.ac(ac),
		.a(a),
		.w(w)
	);

	assign ddt_ = ~(w & {16{w_dt}});

	// sheet 5..6

	wire [0:15] f;
	wire zsum_;
	alu ALU(
		.p16_(p16_),
		.a(a),
		.ac(ac),
		.saryt(saryt),
		.sd_(sd_),
		.sb_(sb_),
		.scb_(scb_),
		.sab_(sab_),
		.sca_(sca_),
		.saa_(saa_),
		.f(f),
		.j$(j$),
		.carry_(carry_),
		.zsum_(zsum_)
	);

	assign s0 = f[0];
	assign exx_ = ~((a[15] & ir[6]) | (a[0] & ~ir[6]));

	// sheet 7

	wire [0:15] at;
	at REG_AT(
		.s0(~(wx_ & as2_)),
		.s1(as2),
		.c(~strob1),
		.sl(eat0),
		.f(f),
		.at(at)
	);

	assign at15_ = ~at[15];
	assign exy_ = ~((at[15] & axy) | (a[0] & ~axy));

	// sheet 8

	wire M49_6 = ~((w_ac & strobb) | (w_ac & stroba));
	wire strobb = ~(as2_ | strob2_);
	wire as2_ = ~as2;
	wire stroba = ~(as2 | strob1_);

	wire [0:15] ac;
	ac REG_AC(
		.c(M49_6),
		.w(w),
		.ac(ac)
	);

	wire M8_11 = ac[0] ^ a[0];
	wire M8_3 = ~ac[0] ^ a[0];
	wire M7_8 = ~((~a[0] & am1) | (M8_11 & apb) | (M8_3 & amb) | (a[0] & ap1));

	// WZI

	wire M65_11 = ~(as2 & strob1);
	assign s_1 = M7_8 ^ carry_;
	wire M42_8 = zsum_;
	assign zs = ~(s_1 | M42_8);

	wire wzi_;
	ffd REG_WZI(
		.s_(1'b1),
		.d(zs),
		.c(M65_11),
		.r_(1'b1),
		.q(wzi_)
	);
	assign wzi = wzi_;

	// sheet 9

	wire M51_6 = ~((w_ar & strobb) | (w_ar & stroba));
	wire M79_3 = stroba & arp1;

	wire [0:15] ar;
	ar REG_AR(
		.l_(M51_6),
		.p1(M79_3),
		.m4_(arm4_),
		.w(w),
		.ar(ar)
	);
	assign arz = ~(&(~ar[0:7]));

	// sheet 10

	wire M56_3 = ~(icp1 & strob1);
	wire M51_8 = ~((w_ic & stroba) | (w_ic & strobb));

	wire [0:15] ic;
	ic REG_IC(
		.cu_(M56_3),
		.l_(M51_8),
		.r(~off_),
		.w(w),
		.ic(ic)
	);

	// sheet 11, 12

	wire [0:15] a;
	a_bus A_BUS(
		.bac_(bac_),
		.bab_(bab_),
		.baa_(baa_),
		.aa_(aa_),
		.ab_(ab_),
		.l(l),
		.ir(ir),
		.ar(ar),
		.ic(ic),
		.a(a)
	);

	// sheet 13, 14

	wire ic_ad = ~ic_ad_;
	wire ar_ad = ~ar_ad_;

	wire [0:15] dad1_ = ~({16{ar_ad}} & ar);
	wire [0:15] dad2_ = ~({16{ic_ad}} & ic);
	assign dad_ = dad1_ & dad2_;

	wire zga_ = ~(&(kl[0:7] ^ {barnb, dad_[1:7]}));
	assign zga = ~(zga_ | ~(&(kl[8:15] ^ dad_[8:15])));

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
