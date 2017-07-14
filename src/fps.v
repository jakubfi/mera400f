/*
	F-PS unit (FPU control)

	document: 12-006370-01-4A
	unit:     F-PS2-1
	pages:    2-1..2-16
*/

module fps(
	input __clk,
	// sheet 1
	input mode,
	input step,
	output strob_fp,
	output strob2_fp,
	// sheet 2
	input oken,
	input zw,
	input di,
	input efp,
	input puf,
	input got,
	output sr_fp,
	output ekc_fp,
	output _0_f,
	// sheet 3
	input g,
	input wdt,
	input af_sf,
	input mw_,
	output _0_t,
	output lkb,
	output l_d,
	output clocktc,
	output clocktb,
	output clockta,
	output opta, optb, optc, opm,
	output t_c,
	output fcb,
	// sheet 4
	input mf_,
	input fp16_,
	output t_1_t_1,
	output tab,
	output trb,
	output taa,
	output cp,
	// sheet 5
	input sd$_,
	input ck,
	input sf,
	input p32_,
	input m14,
	input t0_eq_c0,
	input m38,
	input t0_c0,
	input ws,
	input df_,
	input af,
	input ad,
	output frb,
	output p_16,
	output p_32,
	output p_40,
	output fab,
	output faa,
	output fra,
	// sheet 6
	input fic,
	input ad_sd,
	input ta,
	input sgn_t0_c0,
	// sheet 7
	input opsu,
	input dw_,
	input wc,
	input wt,
	input dw,
	// sheet 8
	input ss,
	output f5_,
	output f6_,
	output f2_,
	output f4_,
	// sheet 9
	input ok$,
	input ff_,
	output read_fp,
	// sheet 10
	input sgn,
	input fwz,
	input nrf,
	// sheet 11
	input nz,
	input t0_t_1,
	input ok,
	output f13,
	// sheet 12
	output f10_,
	output f9,
	output f8_,
	output f7_,
	output f9_ka,
	// sheet 13
	input dw_df,
	input mw_mf,
	output scc,
	output pc8,
	output _0_d,
	output _0_m,
	output mb,
	output ma,
	output clockm,
	// sheet 14
	output rlp_fp,
	output lpa,
	// sheet 15
	output zpa,
	output zpb,
	output _0_zp,
	output s_fp,
	output ustr0_fp,
	output lp,
	output lpb
);

	parameter FP_STROB1_1_TICKS;
	parameter FP_STROB1_2_TICKS;
	parameter FP_STROB1_3_TICKS;
	parameter FP_STROB1_4_TICKS;
	parameter FP_STROB2_TICKS;
	parameter FP_KC1_TICKS;
	parameter FP_KC2_TICKS;
	parameter FP_START_TICKS;

	// sheet 1

	wire M74_12, M68_12, M72_12, M72_4;
	univib #(.ticks(FP_STROB1_1_TICKS)) VIB_STROB1_1(
		.clk(__clk),
		.a_(sr),
		.b(dp8),
		.q_(M74_12)
	);
	univib #(.ticks(FP_STROB1_2_TICKS)) VIB_STROB1_2(
		.clk(__clk),
		.a_(sr),
		.b(dp2),
		.q_(M68_12)
	);
	univib #(.ticks(FP_STROB1_3_TICKS)) VIB_STROB1_3(
		.clk(__clk),
		.a_(sr),
		.b(dp6),
		.q_(M72_12)
	);
	univib #(.ticks(FP_STROB1_4_TICKS)) VIB_STROB1_4(
		.clk(__clk),
		.a_(sr),
		.b(dp5),
		.q_(M72_4)
	);

	wire M59_8 = M74_12 & M68_12;
	wire M79_11 = M72_12 & M72_4;
	wire M56_8 = ~(~(M59_8 & M79_11) & mode);

	wire M55_5;
	ffd REG_STEP(
		.s_(M56_8),
		.d(1'b0),
		.c(~step),
		.r_(mode),
		.q(M55_5)
	);

	wire strob1 = ~(M79_11 & ~M55_5 & M59_8);
	assign strob_fp = ~(M79_11 & ~M55_5 & M59_8);

	wire M49_4 = ~(dp8 | dp2);
	wire M54_11 = ~(M49_4 & M55_5);
	wire M54_3 = ~(~M49_4 & M55_5);
	wire M54_6 = ~(M59_8 & M54_3);

	wire strob2;
	univib #(.ticks(FP_STROB2_TICKS)) VIB_STROB2(
		.clk(__clk),
		.a_(M54_6),
		.b(1'b1),
		.q(strob2)
	);

	wire stgot = M54_11 & M79_11 & ~strob2;
	assign strob2_fp = strob2;

	// sheet 2

	wire sr = ~(~start & M57_8);
	assign sr_fp = sr & f1;

	wire M43_6 = ~(oken & f1 & zw);

	wire M71_5;
	univib #(.ticks(FP_KC1_TICKS)) VIB_KC1(
		.clk(__clk),
		.a_(~stgot),
		.b(M43_6),
		.q(M71_5)
	);

	wire M57_6 = ~(dkc_ & ~di);
	wire M57_8 = ~(~di & M71_5);

	wire M55_9;
	ffd REG_KC(
		.s_(1'b1),
		.d(M57_6),
		.c(M71_5),
		.r_(puf),
		.q(M55_9)
	);

	univib #(.ticks(FP_KC2_TICKS)) VIB_KC2(
		.clk(__clk),
		.a_(1'b0),
		.b(M55_9),
		.q(ekc_fp)
	);

	wire got_fp = ~M57_8;

	assign _0_f = ~(~ekc_fp & puf);

	wire M73_15;
	ffjk REG_START(
		.s_(1'b1),
		.j(efp),
		.c_(~got),
		.k(1'b1),
		.r_(~_0_f),
		.q(M73_15)
	);

	wire start;
	univib #(.ticks(FP_START_TICKS)) VIB_START(
		.clk(__clk),
		.a_(got),
		.b(M73_15),
		.q(start)
	);

	// sheet 3

	wire M29_8 = (g & wdt & f5) | (wc & f4) | (~mw_ & f4) | (f4 & mf);
	assign _0_t = ~(~start & ~(strob2 & M29_8));
	wire M30_6 = ~(f3_ & f1_);
	assign lkb = M30_6;
	wire mw = ~mw_;

	wire M56_6 = ~(~wdt & ~wc);
	wire M31_8 = ~(f5 & ~af_sf);
	wire M31_6 = ~(lp3 & M30_6);
	wire M43_8 = ~(M56_6 & ~ws & f7);
	wire M31_11 = ~(sgn & f7);
	wire M19_12 = ~(lp2 & M30_6 & mw_);

	wire M32_8 = ~(M31_8 & M31_6 & M43_8);
	wire M9_3 = ~(M31_6 & ~f7_f12);
	wire M19_8 = ~(~f7_f12 & M31_11 & M19_12);
	wire M19_6 = ~(M20_6 & ~f7_f12 & f6_);
	wire M31_3 = ~(f12_ & f11_);
	assign l_d = (M32_8 & strob1) | (M31_3 & strob1);

	wire M30_11 = ~(mw_ & lp1_);
	wire M20_6 = ~((M30_11 & M30_6) | (f7 & ta_alpha));

	// WORKAROUND: opt[abc] and opm are a workaround for T and M
	// clocks being misaligned causing various problems when
	// values from one register are shifted into the other one.
	assign optc = M9_3;
	assign optb = M19_8;
	assign opta = M19_6;
	assign clocktc = strob1 & M9_3;
	assign clocktb = strob1 & M19_8;
	assign clockta = strob1 & M19_6;
	assign t_c = strob1 & f2;
	assign fcb = M31_3;

	// sheet 4

	wire M30_3 = ~(af_sf & ~wdt);
	wire M30_8 = ~(f9 & dw);
	wire M67_12 = ~(mw_ & mf_ & ~wdt);
	wire dwsgnf7 = sgn & dw & f7;

	wire M20_8 = ~((dw_ & f7) | (M30_3 & f8));
	wire M53_3 = ~(f8 & M67_12);

	wire f7_f12 = ~(f9_ & f12_ & f11_ & M20_8);
	assign t_1_t_1 = ~(f8_ & f12_ & f11_ & M30_8);
	assign tab = ~(M30_8 & f11_ & M53_3);
	assign trb = ~(M53_3 &f11_);
	assign taa = ~(~(dw_df & f8) & f12_);
	assign cp = strob1 & f8 & af_sf & ~wdt;
	wire dw_p16 = ~(~dwsgnf7 & fp16_ & ~mw_p16);
	wire mf = ~mf_;

	// sheet 5

	wire M54_8 = ~(~wdt & ~ck);
	wire M76_8 = ~ws & sf;
	wire M76_3 = ~df_ & fic;
	wire M76_6 = mf & ~ws;

	wire M67_8 = ~(f7 & ~sgn & dw);
	wire M77_6 = ~((M54_8 & M76_8) | (~fic & df));
	wire M65_6 = ~((mw & ~m14) | (dw & t0_c0));
	wire M77_8 = ~((t0_eq_c0 & M76_3) | (M76_6 & m38));
	wire M78_8 = ~((~m38 & M76_6) | (ad) | (df & fic & t0_c0) | (~ws & af));

	wire M52_3 = ~(~M65_6 & f6);
	wire M52_6 = ~(M65_6 & f6);
	wire M66_8 = sd$_ & ~ws & M77_6 & M77_8;
	wire M66_6 = M52_6 & sd$_ & M77_8 & ~M76_8;

	wire M80_6 = ~(p32_ & ~dwsgnf7 & sd$_);

	wire df = ~df_;
	assign frb = ~M66_6;
	assign p_16 = dw_p16 & M67_8 & M52_3;
	assign p_32 = M80_6 & ~ad;
	wire mw_p16 = ~M52_6;
	assign p_40 = ~M66_8;
	assign fab = ~(~dwsgnf7 & M66_6);
	assign faa = ~(M67_8 & M52_3 & ~fra);
	assign fra = ~(M52_3 & M78_8);

	// sheet 6

	wire M36_8 = ~(f5_ & f8_);
	wire M45_6 = M36_8 & af_sf;
	wire M22_6 = ~(df & fic);
	wire M22_8 = ~(mf_ & M22_6);

	wire f4mwdw = f4 & dw_mw;
	wire ta_alpha = ta & sgn_t0_c0;
	wire f9dw = dw & f9;

	wire M35 = (M36_8 & opsu & M22_8) | (M45_6 & ~fic & wt_) | (f3 & lp3 & ad_sd);
	wire ef7 = (ws & f10) | (sgn_t0_c0 & ta & f9dw) | (f4 & wc) | (f9 & sgn) | M35;

	// sheet 7

	wire M33_8 = (dw & fic & f8) | (f8 & mw) | (f4mwdw & ~fwz);
	wire sb1f26 = M33_8 & opsu;
	wire M70_6 = f4 & nrf_ & ff;
	wire sa1f26 = ~fwz & wt_ & ~wc & M70_6;
	wire wt_ = ~wt;
	wire M47_8 = ~((~lp) | (lp3 & dw_mw));
	wire sd1 = ~(M47_8 | f3_);
	wire dw_mw = ~(mw_ & dw_);

	// sheet 8
	// przerzutniki stanów

	reg f5, f6, f2, f4;
	assign {f5_, f6_, f2_, f4_} = ~{f5, f6, f2, f4};
	wire f6a_ = f6_;
	always @ (posedge got_fp, posedge _0_f) begin
		if (_0_f) {f5, f6, f2, f4} <= 4'd0;
		else {f5, f6, f2, f4} <= {sa1f26, sb1f26, sc1, sd1};
	end

	wire dp2 = ~(f6_ & f5_ & f12_);

	wire M46_6 = ~((lp3_ & ss) | (ff & lp));
	wire df13 = ~M46_6;
	wire M36_3 = ~(mw & fwz);
	wire M47_6 = ~((f2 & M36_3) | (f3 & df13));

	wire f3_;
	wire f3 = ~f3_;
	ffd REG_F3(
		.s_(~_0_f),
		.d(M47_6),
		.c(got_fp),
		.r_(~(nrf & start)),
		.q(f3_)
	);

	wire dp6 = ~(f2_ & f10_);
	wire dkc_ = ~(M46_6 & f13);

	// sheet 9

	wire M61_3 = ~(ok$ & f1);
	wire M46_8 = ~((dw_ & lp2) | (lp & ff));

	wire dp8 = ~(f4_ & f8_ & f3_ & M61_3 & f9_ & ~f13);
	wire sc1 = M46_8 & f1;
	assign read_fp = f1;

	wire M61_8 = ~(start & nrf_);
	wire M49_10 = ~(f1_ | M46_8);

	wire f1;
	ffd REG_F1(
		.s_(M61_8),
		.d(M49_10),
		.c(got_fp),
		.r_(~_0_f),
		.q(f1)
	);
	wire f1_ = ~f1;

	wire nrf_ = ~nrf;
	wire ff = ~ff_;

	// sheet 10

	wire M52_8 = ~(f6a_ & ~(opsu_ & f8));
	wire M14 = (M52_8 & mw & ~fic) | (~sgn & f9dw & ~ta_alpha) | (wt & ~(f5_ & f4_));

	wire M24_6 = ~(f10_ & f4_ & ~(mw & f2));
	wire sb1 = (M24_6 & fwz) | (ss & f7) | (~ws & ok & f10) | (df13 & f13) | M14;
	wire k__ = (nrf & f4 & ~fwz) | (ff & f7 & ~fic) | (~fic & ~opsu & (f8 & mf));
	wire opsu_ = ~opsu;

	// sheet 11

	wire M2_6 = nz & M4_6;
	wire M2_8 = f10 & t0_t_1;

	reg F13, f12, f11;
	assign f13 = F13;
	wire f11_ = ~f11;
	wire f12_ = ~f12;
	always @ (posedge got_fp, posedge _0_f) begin
		if (_0_f) {F13, f12, f11} <= 3'd0;
		else {F13, f12, f11} <= {sb1, M2_6, M2_8};
	end

	wire M4_6 = ~(f12_ & f10_);
	wire dp5 = ~(f11_ & f7_);

	// FIX: wrongly placed -SGN moved from F12 to F9 case
	wire sa1f710 = (f11) | (f12 & ok) | (~sgn & df & f9) | k__;

	// sheet 12

	wire M12_8 = ~((f5 & ff) | (f4 & dw_mw));
	wire M22_11 = ~(M12_8 & f8_);
	wire M23_6 = ~(opsu_ & ~fwz & M22_11 & fic);
	wire M24_12 = ~(dw_mw & fic & f6);
	wire M22_3 = ~(fic & f7);
	wire M3_12 = f8 & ~fic & dw_df;
	wire M24_8 = ~(M23_6 & M24_12 & M22_3);

	reg f10, F9, f8, f7;
	assign f10_ = ~f10;
	assign f9 = F9;
	wire f9_ = ~F9;
	assign f8_ = ~f8;
	assign f7_ = ~f7;
	always @ (posedge got_fp, posedge _0_f) begin
		if (_0_f) {f10, F9, f8, f7} <= 4'd0;
		else {f10, F9, f8, f7} <= {sa1f710, M3_12, M24_8, ef7};
	end
	assign f9_ka = f9;

	// sheet 13

	wire M17_11 = ~(mf & f5);
	wire M17_3 = ~(mf_ & f5);
	wire M18_8 = ~((f5 & wdt) | (wc & f4));
	wire M41_3 = ~(strob2 & f9);
	wire M18_6 = ~((af_sf & f8) | (mw_mf & f8));
	wire M28_6 = ~(dw_df & f8);
	wire M28_3 = ~(mw_mf & f4);
	wire M27_12 = ~(M28_3 & ~fcb & f8_);

	assign scc = ~(M17_11 & f7_ & f11_);
	assign pc8 = ~(M17_3 & f11_);
	assign _0_d = ~(M18_8 | ~strob2);
	assign _0_m = ~(M41_3 & ~start);
	assign mb = ~(f11_ & M18_6);
	assign ma = ~(M28_6 & f12_);
	assign clockm = M27_12 & strob1;
	// WORKAROUND: for M/T registers
	assign opm = M27_12;

	// sheet 14

	wire M3_8 = mw & strob1 & f2;
	wire M65_8 = ~((start & mw) | (~fwz & M3_8));
	wire M4_11 = ~(M3_8 & fwz);
	wire M4_8 = ~(f4 & dw_);
	wire M27_8 = ~(lp & f8 & dw);
	wire M40_3 = ~(~start & f2_);
	wire M40_11 = ~(fwz & f4);
	wire M40_6 = ~(M40_3 & mw_);
	wire M23_8 = ~(M27_8 & f1_ & f3_ & ~f13);
	wire M44_8 = M4_11 & f7_ & M4_8 & M40_11;
	wire M51_8 = M44_8 & M40_6;
	wire M51_6 = M65_8 & M44_8;
	wire M16_3 = M23_8 & strob1;

	wire lpb_ = ~lpb;
	ffjk REG_LPB(
		.s_(M65_8),
		.j(lpa),
		.c_(M16_3),
		.k(lpa),
		.r_(M51_8),
		.q(lpb)
	);

	wire lpa_ = ~lpa;
	ffjk REG_LPA(
		.s_(M40_6),
		.j(1'b1),
		.c_(M16_3),
		.k(1'b1),
		.r_(M51_6),
		.q(lpa)
	);

	assign rlp_fp = ~(~f13 & f3_);

	// sheet 15

	wire lp3_ = ~(lpb & lpa);
	wire lp3 = ~lp3_;
	wire lp2 = lpb & lpa_;
	assign zpa = lpa_ & f13;
	assign zpb = M64_11 & f13;
	wire M64_11 = lpb_ ^ lpa;
	assign _0_zp = fwz & lp & f13;
	wire lp1_ = ~(lpa & lpb_);
	assign lp = ~(lpb_ & lpa_);
	assign s_fp = lp & f13;
	assign ustr0_fp = f13 & ~lp;
	assign lpb = ~lpb_;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
