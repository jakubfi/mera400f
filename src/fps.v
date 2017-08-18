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
	input efp, // Enter FP - start AWP job
	input puf,
	input got,
	output sr_fp, // initiate interface access from AWP
	output ekc_fp, // AWP has done its job
	output _0_f,
	// sheet 3
	input g,
	input wdt,
	input af_sf,
	input mw,
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
	input mf,
	input fp16_,
	output t_1_t_1,
	output tab,
	output trb,
	output taa,
	output cp,
	// sheet 5
	input sd,
	input ck,
	input sf,
	input p32_,
	input m14,
	input t0_eq_c0,
	input m38,
	input t0_c0,
	input ws,
	input df,
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
	input wc,
	input wt,
	input dw,
	// sheet 8
	input ss,
	output f5,
	output f6,
	output f2,
	output f4,
	// sheet 9
	input ok$,
	input ff,
	output read_fp, // memory read
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
	output f10,
	output f9,
	output f8,
	output f7,
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
	output rlp_fp, // read/write r[123] registers according to LP counter
	output lpa, // LP lsb
	output lpb, // LP msb
	// sheet 15
	output zpa,
	output zpb,
	output _0_zp,
	output s_fp,
	output ustr0_fp,
	output lp
);

	// --- Start AWP work ---------------------------------------------------
	// sync: @ldstate: start <= efp

	wire start_trig;
	ffjk REG_START(
		.s_(1'b1),
		.j(efp),
		.c_(~got),
		.k(1'b1),
		.r_(~_0_f),
		.q(start_trig)
	);

	wire start;
	univib #(.ticks(2'd3)) VIB_START(
		.clk(__clk),
		.a_(got),
		.b(start_trig),
		.q(start)
	);

	// --- Internal AWP strobs (strob_fp to CPU also) -----------------------

	wire dp8 = f4 | f8 | f3 | (ok$ & f1) | f9 | f13;
	wire dp2 = f6 | f5 | f12;
	wire dp6 = f2 | f10;
	wire dp5 = f11 | f7;

	wire strob1, strob2, __got, got_fp;
	fp_strobgen FP_STROBGEN(
		.clk_sys(__clk),
		.start(start),
		.di(di),
		.dp8(dp8),
		.dp2(dp2),
		.dp6(dp6),
		.dp5(dp5),
		.mode(mode),
		.step(step),
		.oken(oken),
		.f1(f1),
		.zw(zw),
		.strob1(strob1),
		.strob2(strob2),
		.__got(__got),
		.got_fp(got_fp),
		.sr_fp(sr_fp)
	);

	assign strob_fp = strob1;
	assign strob2_fp = strob2;

	// --- End AWP work -----------------------------------------------------

	wire dkc = ~df13 & f13;
	wire d_ekc = dkc | di;
	wire ekc_fp_trig;
	ffd REG_KC(
		.s_(1'b1),
		.d(d_ekc),
		.c(__got),
		.r_(puf),
		.q(ekc_fp_trig)
	);

	univib #(.ticks(2'd3)) VIB_KC(
		.clk(__clk),
		.a_(1'b0),
		.b(ekc_fp_trig),
		.q(ekc_fp)
	);

	// --- State registers --------------------------------------------------

	assign _0_f = ekc_fp | ~puf;

	reg f11, f12;

	assign read_fp = f1;
	assign rlp_fp = f13 | f3;
	assign fcb = f12 | f11;
	assign lkb = f3 | f1;

	always @ (posedge got_fp, posedge _0_f) begin
		if (_0_f) begin
			{f2, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13} <= 4'd0;
		end else begin
			{f2, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13} <= {ef2, ef4, ef5, ef6, ef7, ef8, ef9, ef10, ef11, ef12, ef13};
		end
	end

	wire f1_s = start & ~nrf;
	wire f3_s = start & nrf;

	wire f3;
	ffd REG_F3(
		.s_(~f3_s),
		.d(ef3),
		.c(got_fp),
		.r_(~_0_f),
		.q(f3)
	);

	wire f1;
	ffd REG_F1(
		.s_(~f1_s),
		.d(ef1),
		.c(got_fp),
		.r_(~_0_f),
		.q(f1)
	);

	// ----------------------------------------------------------------------
	// ----------------------------------------------------------------------
	// ----------------------------------------------------------------------

	// sheet 3

	wire lp3lkb = lp3 & lkb;

	assign _0_t = start | (strob2 & ((g & wdt & f5) | (wc & f4) | (mw & f4) | (f4 & mf)));
	assign l_d = strob1 & ((f5 & ~af_sf) | lp3lkb | ((wdt | wc) & ~ws & f7) | fcb);

	wire M9_3 = lp3lkb | f7_f12;
	wire M19_6 = ((mw | lp1) & lkb) | (f7 & ta_alpha) | f7_f12 | f6;
	wire M19_8 = f7_f12 | (sgn & f7) | (lp2 & lkb & ~mw);

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

	// sheet 4

	wire M30_3 = ~(af_sf & ~wdt);
	wire M30_8 = f9 & dw;
	wire dwsgnf7 = dw & sgn & f7;

	wire M53_3 = f8 & (mw | mf | wdt);

	wire f7_f12 = f9 | f12 | f11 | (~dw & f7) | (M30_3 & f8);
	assign t_1_t_1 = f8 | f12 | f11 | M30_8;
	assign tab = M30_8 | f11 | M53_3;
	assign trb = M53_3 | f11;
	assign taa = (dw_df & f8) | f12;
	assign cp = strob1 & f8 & af_sf & ~wdt;
	wire dw_p16 = ~(~dwsgnf7 & fp16_ & ~mw_p16); // does not

	// sheet 5

	wire M54_8 = wdt | ck;
	wire M76_8 = ~ws & sf;
	wire M76_3 = df & fic;
	wire M76_6 = mf & ~ws;

	wire M67_8 = f7 & ~sgn & dw;
	wire M77_6 = (M54_8 & M76_8) | (~fic & df);
	wire M65_6 = (mw & ~m14) | (dw & t0_c0);
	wire M78_8 = (~m38 & M76_6) | (ad) | (df & fic & t0_c0) | (~ws & af);

	wire M52_3 = M65_6 & f6;

	wire M80_6 = ~(p32_ & ~dwsgnf7 & ~sd); // does not
	wire M77_8 = (t0_eq_c0 & M76_3) | (M76_6 & m38);

	assign frb = ~(~mw_p16 & ~sd & ~M77_8 & ~M76_8); // does not
	assign p_16 = dw_p16 & ~M67_8 & ~M52_3;
	assign p_32 = M80_6 & ~ad;
	wire mw_p16 = ~M65_6 & f6;
	assign p_40 = sd | ws | M77_6 | M77_8;
	assign fab = dwsgnf7 | frb;
	assign fra = M52_3 | M78_8;
	assign faa = M67_8 | M52_3 | fra;

	// sheet 7

	wire df13 = (~lp3 & ss) | (ff & lp);
	wire f9dw = dw & f9;
	wire f4mwdw = f4 & dw_mw;
	wire ta_alpha = ta & sgn_t0_c0;
	wire f5_f8 = f5 | f8;
	wire dw_mw = mw | dw;

	wire f1f2_sel = (~dw & lp2) | (lp & ff);
	wire ef1 = f1 & f1f2_sel;
	wire ef2 = f1 & ~f1f2_sel;
	wire ef3 = (f2 & ~(mw & fwz)) | (f3 & df13);
	wire ef4 = f3 & (~lp | (lp3 & dw_mw));
	wire ef5 = f4 & ~fwz & ~wt & ~wc & ~nrf & ff;
	wire ef6 = opsu & ((dw & fic & f8) | (f8 & mw) | (f4mwdw & ~fwz));
	wire ef7 = (ws & f10) | (sgn_t0_c0 & ta & f9dw) | (f4 & wc) | (f9 & sgn) | (f5_f8 & opsu & (mf | (df & fic))) | (f5_f8 & af_sf & ~fic & ~wt) | (f3 & lp3 & ad_sd);
	wire M22_11 = (f5 & ff) | (f4 & dw_mw) | f8;
	wire ef8 = (~opsu & ~fwz & M22_11 & fic) | (dw_mw & fic & f6) | (fic & f7);
	wire ef9 = f8 & ~fic & dw_df;
	wire ef10 = f11 | (f12 & ok) | (~sgn & df & f9) | (nrf & f4 & ~fwz) | (ff & f7 & ~fic) | (~fic & ~opsu & (f8 & mf));
	wire ef11 = f10 & t0_t_1;
	wire ef12 = (f12 | f10) & nz;
	wire M52_8 = f6 | (~opsu & f8);
	wire M24_6 = f10 | f4 | (mw & f2);
	wire ef13 = (M24_6 & fwz) | (ss & f7) | (~ws & ok & f10) | (df13 & f13) | (M52_8 & mw & ~fic) | (~sgn & f9dw & ~ta_alpha) | (wt & (f5 | f4));

	// sheet 13

	assign scc = (mf & f5) | f7 | f11;
	assign pc8 = (~mf & f5) | f11;
	assign _0_d = strob2 & ((f5 & wdt) | (wc & f4));
	assign _0_m = (strob2 & f9) | start;
	assign mb = f11 | (af_sf & f8) | (mw_mf & f8);
	assign ma = (dw_df & f8) | f12;

	wire M27_12 = (mw_mf & f4) | fcb | f8;
	assign clockm = M27_12 & strob1;
	// WORKAROUND: for M/T registers
	assign opm = M27_12;

	// sheet 14

	wire M3_8 = mw & strob1 & f2;

	wire lpb_s = (start & mw) | (~fwz & M3_8);
	wire lpa_s = (start | f2) & ~mw;

	wire M44_8 = (M3_8 & fwz) | f7 | (f4 & ~dw) | (fwz & f4);

	wire lp_clk = strob1 & ((lp & f8 & dw) | f1 | f3 | f13);

	wire lp1, lp2, lp3;
	lp LP(
		.lp_clk(lp_clk),
		.lpb_s(lpb_s),
		.lpa_s(lpa_s),
		.M44_8(M44_8),
		.out({lpb, lpa}),
		.lp(lp),
		.lp1(lp1),
		.lp2(lp2),
		.lp3(lp3)
	);

	assign zpa = f13 & ~lpa;
	assign zpb = f13 & (~lpb ^ lpa);
	assign _0_zp = f13 & fwz & lp;
	assign s_fp = f13 & lp;
	assign ustr0_fp = f13 & ~lp;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
