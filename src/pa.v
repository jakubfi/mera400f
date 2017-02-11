/*
	MERA-400 P-A unit (ALU)

	document:	12-006368-01-8A
	unit:			P-A3-2
	pages:		2-70..2-84
	sheets:		15
*/

module pa(
	// sheet 1
	input [0:15] ir,
	input [0:15] ki,
	input [0:15] rdt_,
	input w_dt_,
	input mwa_, mwb_, mwc_,
	input bwa_, bwb_,
	output [0:15] ddt_,
	output [0:15] w,
	// sheet 2
	// sheet 3
	// sheet 4
	// sheet 5
	input saryt,
	input sab_, scb_, sb_, sd_,
	output s0,
	output carry_,
	// sheet 6
	input p16_,
	input saa_, sca_,
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
	input baa_, bab_, bac_,
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

	wire mwa = ~mwa_;
	wire mwb = ~mwb_;
	wire mwc = ~mwc_;
	wire bwb = ~bwb_;
	wire bwa = ~bwa_;
	wire w_dt = ~w_dt_;

	wire [0:2] W_SEL = {mwc, mwb, mwa};

	assign w[0:7] = bwb ? 8'b0 :
		(W_SEL == 3'b000) ? ir[0:7] :
		(W_SEL == 3'b001) ? kl[0:7] :
		(W_SEL == 3'b010) ? ~rdt_[0:7] :
		(W_SEL == 3'b011) ? {8{1'b0}} :
		(W_SEL == 3'b100) ? ki[0:7] :
		(W_SEL == 3'b101) ? at[0:7] :
		(W_SEL == 3'b110) ? ac[0:7] :
		a[0:7];

	assign w[8:15] = bwa ? 8'b0 :
		(W_SEL == 3'b000) ? ir[8:15] :
		(W_SEL == 3'b001) ? kl[8:15] :
		(W_SEL == 3'b010) ? ~rdt_[8:15] :
		(W_SEL == 3'b011) ? ac[0:7] :
		(W_SEL == 3'b100) ? ki[8:15] :
		(W_SEL == 3'b101) ? at[8:15] :
		(W_SEL == 3'b110) ? ac[8:15] :
		a[8:15];

	assign ddt_ = ~(w & {16{w_dt}});

	// sheet 5

	wire [0:15] f;
	wire [0:3] g, p;
	wire [1:3] c_;
	wire [0:3] j$1;

	// most significant
	alu181 ALU0(
		.a(a[0:3]),
		.b(ac[0:3]),
		.s({sd, ~scb_, sb, ~sab_}),
		.m(saryt_),
		.cn_(c_[3]),
		.f(f[0:3]),
		.eq(j$1[3]),
		.x(p[3]),
		.y(g[3]),
		.cn4_(carry_)
	);
	assign s0 = f[0];
	wire z1_ = ~(f[0] | f[1]);
	wire z2_ = ~(f[2] | f[3]);

	alu181 ALU1(
		.a(a[4:7]),
		.b(ac[4:7]),
		.s({sd, ~scb_, sb, ~sab_}),
		.m(~saryt),
		.cn_(c_[2]),
		.f(f[4:7]),
		.eq(j$1[2]),
		.x(p[2]),
		.y(g[2]),
		.cn4_(__NC)
	);
	wire z3_ = ~(f[4] | f[5]);
	wire z4_ = ~(f[6] | f[7]);
	wire saryt_ = ~saryt;
	wire sb = ~sb_;
	wire sd = ~sd_;

	// sheet 6

	assign j$ = &j$1;

	alu181 ALU2(
		.a(a[8:11]),
		.b(ac[8:11]),
		.s({sd, ~sca_, sb, ~saa_}),
		.m(saryt_),
		.cn_(c_[1]),
		.f(f[8:11]),
		.eq(j$1[1]),
		.x(p[1]),
		.y(g[1]),
		.cn4_(__NC)
	);
	wire z5_ = ~(f[8] | f[9]);
	wire z6_ = ~(f[10] | f[11]);
	wire z7_ = ~(f[12] | f[13]);
	wire z8_ = ~(f[14] | f[15]);

	// least significant
	alu181 ALU3(
		.a(a[12:15]),
		.b(ac[12:15]),
		.s({sd, ~sca_, sb, ~saa_}),
		.m(saryt_),
		.cn_(p16_),
		.f(f[12:15]),
		.eq(j$1[0]),
		.x(p[0]),
		.y(g[0]),
		.cn4_(__NC)
	);

	carry182 __carry(
		.y(g),
		.x(p),
		.cn_(p16_),
		.cnx_(c_[1]),
		.cny_(c_[2]),
		.cnz_(c_[3]),
		.ox(__NC),
		.oy(__NC)
	);

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
	wire M42_8 = ~(z1_ & z2_ & z3_ & z4_ & z5_ & z6_ & z7_ & z8_);
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

	wire [0:15] ar;
	ar REG_AR(
		.l_(M51_6),
		.p1(arp1),
		.m4(arm4_),
		.w(w),
		.ar(ar)
	);
	assign arz = ~(&(~ar[0:7]));

	// sheet 10

	wire [0:15] ic;
	ic REG_IC(
		.cu(~(icp1 & strob1)),
		.l_(~((w_ic & stroba) | (w_ic & strobb))),
		.r(~off_),
		.w(w),
		.ic(ic)
	);

	// sheet 11, 12

	wire bac = ~bac_;
	wire ab = ~ab_;
	wire aa = ~aa_;
	wire bab = ~bab_;
	wire baa = ~baa_;

	wire [0:15] a;
	assign a[0:7] = bac ? 8'd0 :
		{ab, aa} == 2'b00 ? l[8:15] :
		{ab, aa} == 2'b01 ? ic[0:7] :
		{ab, aa} == 2'b10 ? ar[0:7] :
		l[0:7];
	assign a[8:9] = bab ? 2'd0 :
		{ab, aa} == 2'b00 ? ir[8:9] :
		{ab, aa} == 2'b01 ? ic[8:9] :
		{ab, aa} == 2'b10 ? ar[8:9] :
		l[8:9];
	assign a[10:15] = baa ? 6'd0 :
		{ab, aa} == 2'b00 ? ir[10:15] :
		{ab, aa} == 2'b01 ? ic[10:15] :
		{ab, aa} == 2'b10 ? ar[10:15] :
		l[10:15];

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
