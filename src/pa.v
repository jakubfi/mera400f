/*
	MERA-400 P-A unit (ALU)

	document:	12-006368-01-8A
	unit:			P-A3-2
	pages:		2-70..2-84
	sheets:		15
*/

module pa(
	input __clk,
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

	reg [0:15] W;
	assign w = W;
	always @ (mwc_, mwb_, mwa_, bwb_, bwa_, ir, kl, rdt_, ki, at, ac, a) begin

		if (~bwb_) W[0:7] = 8'd0;
		else case ({mwc_, mwb_, mwa_})
			3'b111 : W[0:7] <= ir[0:7];
			3'b110 : W[0:7] <= kl[0:7];
			3'b101 : W[0:7] <= ~rdt_[0:7];
			3'b100 : W[0:7] <= 8'd0;
			3'b011 : W[0:7] <= ki[0:7];
			3'b010 : W[0:7] <= at[0:7];
			3'b001 : W[0:7] <= ac[0:7];
			3'b000 : W[0:7] <= a[0:7];
		endcase

		if (~bwa_) W[8:15] = 8'd0;
		else case ({mwc_, mwb_, mwa_})
			3'b111 : W[8:15] <= ir[8:15];
			3'b110 : W[8:15] <= kl[8:15];
			3'b101 : W[8:15] <= ~rdt_[8:15];
			3'b100 : W[8:15] <= ac[0:7];
			3'b011 : W[8:15] <= ki[8:15];
			3'b010 : W[8:15] <= at[8:15];
			3'b001 : W[8:15] <= ac[8:15];
			3'b000 : W[8:15] <= a[8:15];
		endcase

	end

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

	reg [0:15] a;
	always @ (ab_, aa_, bac_, bab_, baa_, l, ir, ic, ar) begin

		if (~bac_) a[0:7] <= 8'd0;
		else case ({ab_, aa_})
			2'b11 : a[0:7] <= l[8:15];
			2'b10 : a[0:7] <= ic[0:7];
			2'b01 : a[0:7] <= ar[0:7];
			2'b00 : a[0:7] <= l[0:7];
		endcase

		if (~bab_) a[8:9] <= 2'd0;
		else case ({ab_, aa_})
			2'b11 : a[8:9] <= ir[8:9];
			2'b10 : a[8:9] <= ic[8:9];
			2'b01 : a[8:9] <= ar[8:9];
			2'b00 : a[8:9] <= l[8:9];
		endcase

		if (~baa_) a[10:15] <= 6'd0;
		else case ({ab_, aa_})
			2'b11 : a[10:15] <= ir[10:15];
			2'b10 : a[10:15] <= ic[10:15];
			2'b01 : a[10:15] <= ar[10:15];
			2'b00 : a[10:15] <= l[10:15];
		endcase

	end

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
