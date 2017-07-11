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
	input [0:15] bus_ki,
	input [0:15] rdt_,
	input w_dt_,
	input mwa,
	input mwb,
	input mwc,
	input bwa,
	input bwb,
	output [0:15] ddt_,
	output [0:15] w,
	// sheet 2
	// sheet 3
	// sheet 4
	// sheet 5
	input saryt,
	input sab,
	input scb,
	input sb,
	input sd,
	output s0,
	output carry_,
	// sheet 6
	input p16_,
	input saa,
	input sca,
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
	input arm4,
	input w_ar,
	input arp1,
	output arz,
	// sheet 10
	input icp1,
	input w_ic,
	input off_,
	// sheet 11, 12
	input baa,
	input bab,
	input bac,
	input ab,
	input aa,
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
		.mwc(mwc),
		.mwb(mwb),
		.mwa(mwa),
		.bwa(bwa),
		.bwb(bwb),
		.ir(ir),
		.kl(kl),
		.rdt_(rdt_),
		.ki(bus_ki),
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
		.sd(sd),
		.sb(sb),
		.scb(scb),
		.sab(sab),
		.sca(sca),
		.saa(saa),
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

	wire as2_ = ~as2;
	wire strob2 = ~strob2_;
	wire strobb = as2 & strob2;
	wire stroba = ~as2 & strob1;

	wire ac_clk = w_ac & (stroba | strobb);

	wire [0:15] ac;
	ac REG_AC(
		.c(~ac_clk),
		.w(w),
		.ac(ac)
	);

	wire M8_11 = ac[0] ^ a[0];
	wire M8_3 = ~ac[0] ^ a[0];
	wire M7_8 = ~((~a[0] & am1) | (M8_11 & apb) | (M8_3 & amb) | (a[0] & ap1));
	assign s_1 = M7_8 ^ carry_;
	assign zs = ~(s_1 | zsum_);

	// WZI

	wire wzi_clk = as2 & strob1;

	wire wzi_;
	ffd REG_WZI(
		.s_(1'b1),
		.d(zs),
		.c(~wzi_clk),
		.r_(1'b1),
		.q(wzi_)
	);
	assign wzi = wzi_;

	// sheet 9

	wire ar_load = w_ar & (stroba | strobb);
	wire ar_plus1 = arp1 & stroba;

	wire [0:15] ar;
	ar REG_AR(
		.l(ar_load),
		.p1(ar_plus1),
		.m4(arm4),
		.w(w),
		.ar(ar)
	);

	assign arz = |ar[0:7];

	// sheet 10

	wire ic_plus1 = icp1 & strob1;
	wire ic_load = w_ic & (stroba | strobb);

	wire [0:15] ic;
	ic REG_IC(
		.cu(ic_plus1),
		.l(ic_load),
		.r(~off_),
		.w(w),
		.ic(ic)
	);

	// sheet 11, 12

	wire [0:15] a;
	bus_a BUS_A(
		.bac(bac),
		.bab(bab),
		.baa(baa),
		.aa(aa),
		.ab(ab),
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
