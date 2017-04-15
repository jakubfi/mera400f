/*
	AWP (FPU)

	document: 12-006370-01-4A
	unit:     F-PA2-1
	pages:    2-1..2-48
*/

module awp(
	input __clk,
	input [0:15] w,
	input r02,
	input r03,
	input pufa,
	input [7:9] ir,
	input nrf,
	input mode,
	input step_,
	input efp_,
	input got_,
	input ok$,
	input oken,
	input zw1,
	output [0:15] zp,	// bus
	output fi0_,			// fixed point overflow
	output fi1_,			// floating point underflow
	output fi2_,			// floating point overflow
	output fi3_,			// div/0
	output rlp_fp_,		// (r1, r2, r3) read/write
	output lpa,				//
	output lpb,				// LP counter outputs (rX select)
	output s_fp_,			// ZP->W
	output ustr0_fp_,	// set flags
	output f13_,			// AWP->W
	output strob_fp_,	// fpu strob
	output sr_fp_,		// memory read
	output read_fp_,	// memory read
	output ekc_fp_		// FPU done
);

	parameter FP_STROB1_1_TICKS = 3'd6;
	parameter FP_STROB1_2_TICKS = 3'd6;
	parameter FP_STROB1_3_TICKS = 3'd6;
	parameter FP_STROB1_4_TICKS = 3'd6;
	parameter FP_STROB2_TICKS = 3'd6;
	parameter FP_KC1_TICKS = 3'd6;
	parameter FP_KC2_TICKS = 3'd6;
	parameter FP_START_TICKS = 3'd6;
	parameter FP_FI0_TICKS = 3'd6;

// -----------------------------------------------------------------------
// --- F-PS --------------------------------------------------------------
// -----------------------------------------------------------------------

wire strob2_fp, _0_f_, _0_t, lkb_, l_d_, clocktc_, clocktb_, clockta_, t_c_, fcb_, t_1_t_1, tab_, trb_, taa, cp_, frb_, p_16_, p_32_, p_40_, fab_, faa_, fra_, f5_, f6_, f2_, f4_, f13, f10_, f9, f8_, f7_, f9_ka_, scc_, pc8, _0_d, _0_m, mb, ma, clockm, zpa_, zpb_, _0_zp_, ustr0_fp, lp_;

fps #(
	.FP_STROB1_1_TICKS(FP_STROB1_1_TICKS),
	.FP_STROB1_2_TICKS(FP_STROB1_2_TICKS),
	.FP_STROB1_3_TICKS(FP_STROB1_3_TICKS),
	.FP_STROB1_4_TICKS(FP_STROB1_4_TICKS),
	.FP_STROB2_TICKS(FP_STROB2_TICKS),
	.FP_KC1_TICKS(FP_KC1_TICKS),
	.FP_KC2_TICKS(FP_KC2_TICKS),
	.FP_START_TICKS(FP_START_TICKS)
) FPS(
	.__clk(__clk),
	.mode(mode),
	.step_(step_),
	.strob_fp_(strob_fp_),
	.strob2_fp(strob2_fp),
	.oken(oken),
	.zw1(zw1),
	.di(di),
	.efp_(efp_),
	.puf(puf),
	.got_(got_),
	.sr_fp_(sr_fp_),
	.ekc_fp_(ekc_fp_),
	._0_f_(_0_f_),
	.g(g),
	.wdt(wdt),
	.af_sf_(af_sf_),
	.mw_(mw_),
	._0_t(_0_t),
	.lkb_(lkb_),
	.l_d_(l_d_),
	.clocktc_(clocktc_),
	.clocktb_(clocktb_),
	.clockta_(clockta_),
	.t_c_(t_c_),
	.fcb_(fcb_),
	.mf_(mf_),
	.fp16_(fp16_),
	.t_1_t_1(t_1_t_1),
	.tab_(tab_),
	.trb_(trb_),
	.taa(taa),
	.cp_(cp_),
	.sd$_(sd$_),
	.ck_(ck_),
	.sf(sf),
	.p32_(p32_),
	.m14_(m14_),
	.t0_eq_c0(t0_eq_c0),
	.m38_(m38_),
	.t0_c0(t0_c0),
	.ws_(ws_),
	.df_(df_),
	.af(af),
	.ad(ad),
	.frb_(frb_),
	.p_16_(p_16_),
	.p_32_(p_32_),
	.p_40_(p_40_),
	.fab_(fab_),
	.faa_(faa_),
	.fra_(fra_),
	.fic_(fic_),
	.fic(fic),
	.ad_sd(ad_sd),
	.ta(ta),
	.sgn_t0_c0(sgn_t0_c0),
	.opsu(opsu),
	.dw_(dw_),
	.wc_(wc_),
	.wt(wt),
	.dw(dw),
	.ss(ss),
	.f5_(f5_),
	.f6_(f6_),
	.f2_(f2_),
	.f4_(f4_),
	.ok$(ok$),
	.ff_(ff_),
	.read_fp_(read_fp_),
	.sgn_(sgn_),
	.fwz(fwz),
	.nrf(nrf),
	.nz(nz),
	.t0_t_1(t0_t_1),
	.ok(ok),
	.f13(f13),
	.f13_(f13_),
	.f10_(f10_),
	.f9(f9),
	.f8_(f8_),
	.f7_(f7_),
	.f9_ka_(f9_ka_),
	.dw_df(dw_df),
	.mw_mf(mw_mf),
	.scc_(scc_),
	.pc8(pc8),
	._0_d(_0_d),
	._0_m(_0_m),
	.mb(mb),
	.ma(ma),
	.clockm(clockm),
	.rlp_fp_(rlp_fp_),
	.lpa(lpa),
	.zpa_(zpa_),
	.zpb_(zpb_),
	._0_zp_(_0_zp_),
	.s_fp_(s_fp_),
	.ustr0_fp(ustr0_fp_),
	.lp_(lp_),
	.lpb(lpb)
);

// -----------------------------------------------------------------------
// --- F-PM --------------------------------------------------------------
// -----------------------------------------------------------------------

wire d, d_1, g, wdt, wt, fic_, fic, c_f, v_f, m_f, z_f, dw, ad, sd$_, mw_, dw_, af, sf, mf_, df_, dw_df, mw_mf, af_sf_, ad_sd, ff_, ss, puf, fwz, _end, ws_, di, wc_, d0, d_2, t_1, t0_t_1, ok, nz, opsu, ta, m_1, ck_, m_40, m_32, sgn_t0_c0, sgn_;

fpm #(
	.FP_FI0_TICKS(FP_FI0_TICKS)
) FPM(
	.__clk(__clk),
	.w(w),
	.l_d_(l_d_),
	._0_d(_0_d),
	.lkb_(lkb_),
	.d(d),
	.fcb_(fcb_),
	.scc_(scc_),
	.pc8(pc8),
	.d_1(d_1),
	._0_f_(_0_f_),
	.f2_(f2_),
	.strob2_fp(strob2_fp),
	.f5_(f5_),
	.strob_fp_(strob_fp_),
	.g(g),
	.wdt(wdt),
	.wt(wt),
	.fic_(fic_),
	.fic(fic),
	.r03(r03),
	.r02(r02),
	.t16_(t16_),
	.c_f(c_f),
	.v_f(v_f),
	.m_f(m_f),
	.z_f(z_f),
	.dw(dw),
	.ir(ir),
	.pufa(pufa),
	.f9(f9),
	.nrf(nrf),
	.ad(ad),
	.sd$_(sd$_),
	.mw_(mw_),
	.dw_(dw_),
	.af(af),
	.sf(sf),
	.mf_(mf_),
	.df_(df_),
	.dw_df(dw_df),
	.mw_mf(mw_mf),
	.af_sf_(af_sf_),
	.ad_sd(ad_sd),
	.ff_(ff_),
	.ss(ss),
	.puf(puf),
	.f10_(f10_),
	.f7_(f7_),
	.f6_(f6_),
	.fwz(fwz),
	._end(_end),
	.ws_(ws_),
	.lp_(lp_),
	.f8_(f8_),
	.f13(f13),
	.fi3_(fi3_),
	.di(di),
	.fi0_(fi0_),
	.wc_(wc_),
	.fi1_(fi1_),
	.fi2_(fi2_),
	.d0(d0),
	.d_2(d_2),
	.w0_(~w[0]),
	.t_1_t_1(t_1_t_1),
	.fp0_(fp0_),
	.fab_(fab_),
	.faa_(faa_),
	.fc0_(fc0_),
	._0_t(_0_t),
	.t0_t1(t0_t1),
	.c0_eq_c1(c0_eq_c1),
	.t1_(t1_),
	.t0_(t0_),
	.clockta_(clockta_),
	.t_0_1_(t_0_1_),
	.t_2_7_(t_2_7_),
	.t_8_15_(t_8_15_),
	.t_16_23_(t_16_23_),
	.t_24_31_(t_24_31_),
	.t_32_39_(t_32_39_),
	.t_1(t_1),
	.t0_t_1(t0_t_1),
	.ok(ok),
	.nz(nz),
	.opsu(opsu),
	.ta(ta),
	.trb_(trb_),
	.t39_(t39_),
	.m0_(m0_),
	.mb(mb),
	.c39_(c39_),
	.f4_(f4_),
	.clockm(clockm),
	._0_m(_0_m),
	.m39_(m39_),
	.m15_(m15_),
	.m38_(m38_),
	.m14_(m14_),
	.m_1(m_1),
	.ck_(ck_),
	.m32_(m32_),
	.t0_c0(t0_c0),
	.m_40(m_40),
	.m_32(m_32),
	.sgn_t0_c0(sgn_t0_c0),
	.sgn_(sgn_)
);

// -----------------------------------------------------------------------
// --- F-PA --------------------------------------------------------------
// -----------------------------------------------------------------------

wire t_0_1_, t_2_7_, c0_eq_c1, c1_, fc0_, t1_, t0_eq_c0, t0_c0, t0_t1, m0_, t0_, fp0_, t_8_15_, m14_, m15_, fp16_, t16_, m32_, m38_, m39_, c39_, p32_, t39_, t_32_39_, t_16_23_, t_24_31_;

fpa FPA(
	.w(w),
	.taa(taa),
	.t_1(t_1),
	.tab_(tab_),
	.clockta_(clockta_),
	.t_0_1_(t_0_1_),
	.t_2_7_(t_2_7_),
	.m_1(m_1),
	.ma(ma),
	.mb(mb),
	.clockm(clockm),
	._0_m(_0_m),
	.c0_eq_c1(c0_eq_c1),
	.c1_(c1_),
	.fc0_(fc0_),
	.t1_(t1_),
	.t0_eq_c0(t0_eq_c0),
	.t0_c0(t0_c0),
	.t0_t1(t0_t1),
	.m0_(m0_),
	.t0_(t0_),
	.fab_(fab_),
	.faa_(faa_),
	.fp0_(fp0_),
	.t_8_15_(t_8_15_),
	.p_16_(p_16_),
	.m14_(m14_),
	.m15_(m15_),
	.fp16_(fp16_),
	.t16_(t16_),
	.m_32(m_32),
	.p_32_(p_32_),
	.clocktb_(clocktb_),
	.f2_(f2_),
	.m_40(m_40),
	.cp_(cp_),
	.t_c_(t_c_),
	.m32_(m32_),
	.m38_(m38_),
	.m39_(m39_),
	.c39_(c39_),
	.fra_(fra_),
	.frb_(frb_),
	.p_40_(p_40_),
	.p32_(p32_),
	.clocktc_(clocktc_),
	.trb_(trb_),
	._0_t(_0_t),
	.t39_(t39_),
	.f9_ka_(f9_ka_),
	.lkb_(lkb_),
	.z_f(z_f),
	.m_f(m_f),
	.v_f(v_f),
	.c_f(c_f),
	.zp(zp),
	.t_32_39_(t_32_39_),
	.t_16_23_(t_16_23_),
	.d(d),
	._0_zp_(_0_zp_),
	.zpb_(zpb_),
	.zpa_(zpa_),
	.t_24_31_(t_24_31_)
);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
