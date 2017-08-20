// AWP (coprocessor, 32-bit fixed point and 48-bit floating point arithmetic)

module awp(
	input clk_sys,
	input [0:15] w,
	input r02,
	input r03,
	input pufa,
	input [7:9] ir,
	input nrf,
	input mode,
	input step,
	input efp,
	input got,
	input ldstate,
	input ok$,
	input oken,
	input zw,
	output [0:15] zp,	// bus
	output fi0,			// fixed point overflow
	output fi1,			// floating point underflow
	output fi2,			// floating point overflow
	output fi3,			// div/0
	output rlp_fp,		// (r1, r2, r3) read/write
	output lpa,				//
	output lpb,				// LP counter outputs (rX select)
	output s_fp,			// ZP->W
	output ustr0_fp,	// set flags
	output f13,				// AWP->W
	output strob_fp,	// fpu strob front edge
	output strobb_fp,	// fpu strob back edge
	output sr_fp,			// memory read
	output read_fp,		// memory read
	output ekc_fp			// FPU done
);

	parameter FP_FI0_TICKS = 2'd3;

// -----------------------------------------------------------------------
// --- F-PS --------------------------------------------------------------
// -----------------------------------------------------------------------

wire strob2_fp, strob2b_fp, _0_f, _0_t, lkb, l_d, clocktc, clocktb, clockta, t_c, fcb, t_1_t_1, tab, trb, taa, cp, frb, p_16, p_32, p_40, fab, faa, fra, f5, f6, f2, f4, f10, f9, f8, f7, scc, pc8, _0_d, _0_m, mb, ma, clockm, zpa, zpb, _0_zp, lp;
wire opta, optb, optc, opm;

fps FPS(
	.clk_sys(clk_sys),
	.opm(opm),
	.opta(opta),
	.optb(optb),
	.optc(optc),
	.mode(mode),
	.step(step),
	.strob_fp(strob_fp),
	.strobb_fp(strobb_fp),
	.strob2_fp(strob2_fp),
	.strob2b_fp(strob2b_fp),
	.oken(oken),
	.zw(zw),
	.di(di),
	.efp(efp),
	.puf(puf),
	.got(got),
	.ldstate(ldstate),
	.sr_fp(sr_fp),
	.ekc_fp(ekc_fp),
	._0_f(_0_f),
	.g(g),
	.wdt(wdt),
	.af_sf(af_sf),
	.mw(mw),
	._0_t(_0_t),
	.lkb(lkb),
	.l_d(l_d),
	.clocktc(clocktc),
	.clocktb(clocktb),
	.clockta(clockta),
	.t_c(t_c),
	.fcb(fcb),
	.mf(mf),
	.fp16_(fp16_),
	.t_1_t_1(t_1_t_1),
	.tab(tab),
	.trb(trb),
	.taa(taa),
	.cp(cp),
	.sd(sd),
	.ck(ck),
	.sf(sf),
	.p32_(p32_),
	.m14(m14),
	.t0_eq_c0(t0_eq_c0),
	.m38(m38),
	.t0_neq_c0(t0_neq_c0),
	.ws(ws),
	.df(df),
	.af(af),
	.ad(ad),
	.frb(frb),
	.p_16(p_16),
	.p_32(p_32),
	.p_40(p_40),
	.fab(fab),
	.faa(faa),
	.fra(fra),
	.fic(fic),
	.ad_sd(ad_sd),
	.ta(ta),
	.sgn_t0_c0(sgn_t0_c0),
	.opsu(opsu),
	.wc(wc),
	.wt(wt),
	.dw(dw),
	.ss(ss),
	.f5(f5),
	.f6(f6),
	.f2(f2),
	.f4(f4),
	.ok$(ok$),
	.ff(ff),
	.read_fp(read_fp),
	.sgn(sgn),
	.fwz(fwz),
	.nrf(nrf),
	.nz(nz),
	.t0_neq_t_1(t0_neq_t_1),
	.ok(ok),
	.f13(f13),
	.f10(f10),
	.f9(f9),
	.f8(f8),
	.f7(f7),
	.dw_df(dw_df),
	.mw_mf(mw_mf),
	.scc(scc),
	.pc8(pc8),
	._0_d(_0_d),
	._0_m(_0_m),
	.mb(mb),
	.ma(ma),
	.clockm(clockm),
	.rlp_fp(rlp_fp),
	.lpa(lpa),
	.zpa(zpa),
	.zpb(zpb),
	._0_zp(_0_zp),
	.s_fp(s_fp),
	.ustr0_fp(ustr0_fp),
	.lp(lp),
	.lpb(lpb)
);

// -----------------------------------------------------------------------
// --- F-PM --------------------------------------------------------------
// -----------------------------------------------------------------------

wire [-2:7] d;
wire g, wdt, wt, fic, c_f, v_f, m_f, z_f, dw, ad, sd, mw, af, sf, mf, df, dw_df, mw_mf, af_sf, ad_sd, ff, ss, puf, fwz, ws, di, wc, t_1, t0_neq_t_1, ok, nz, opsu, ta, m_1, ck, m_40, m_32, sgn_t0_c0, sgn;

fpm #(
	.FP_FI0_TICKS(FP_FI0_TICKS)
) FPM(
	.opta(opta),
	.opm(opm),
	.clk_sys(clk_sys),
	.w(w[8:15]),
	.l_d(l_d),
	._0_d(_0_d),
	.lkb(lkb),
	.d(d),
	.fcb(fcb),
	.scc(scc),
	.pc8(pc8),
	._0_f(_0_f),
	.f2(f2),
	.f5(f5),
	.strob_fp(strob_fp),
	.strobb_fp(strobb_fp),
	.strob2_fp(strob2_fp),
	.strob2b_fp(strob2b_fp),
	.g(g),
	.wdt(wdt),
	.wt(wt),
	.fic(fic),
	.r03(r03),
	.r02(r02),
	.t16(t16),
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
	.sd(sd),
	.mw(mw),
	.af(af),
	.sf(sf),
	.mf(mf),
	.df(df),
	.dw_df(dw_df),
	.mw_mf(mw_mf),
	.af_sf(af_sf),
	.ad_sd(ad_sd),
	.ff(ff),
	.ss(ss),
	.puf(puf),
	.f10(f10),
	.f7(f7),
	.f6(f6),
	.fwz(fwz),
	.ws(ws),
	.lp(lp),
	.f8(f8),
	.f13(f13),
	.di(di),
	.wc(wc),
	.fi0(fi0),
	.fi1(fi1),
	.fi2(fi2),
	.fi3(fi3),
	.w0_(~w[0]),
	.t_1_t_1(t_1_t_1),
	.fp0_(fp0_),
	.fab(fab),
	.faa(faa),
	.c0(c0),
	._0_t(_0_t),
	.t0_neq_t1(t0_neq_t1),
	.c0_eq_c1(c0_eq_c1),
	.t1(t1),
	.t0(t0),
	.clockta(clockta),
	.t_0_1(t_0_1),
	.t_2_7(t_2_7),
	.t_8_15(t_8_15),
	.t_16_23(t_16_23),
	.t_24_31(t_24_31),
	.t_32_39(t_32_39),
	.t_1(t_1),
	.t0_neq_t_1(t0_neq_t_1),
	.ok(ok),
	.nz(nz),
	.opsu(opsu),
	.ta(ta),
	.trb(trb),
	.t39(t39),
	.m0(m0),
	.mb(mb),
	.c39(c39),
	.f4(f4),
	.clockm(clockm),
	._0_m(_0_m),
	.m39(m39),
	.m15(m15),
	.m38(m38),
	.m14(m14),
	.m_1(m_1),
	.ck(ck),
	.m32(m32),
	.t0_neq_c0(t0_neq_c0),
	.m_40(m_40),
	.m_32(m_32),
	.sgn_t0_c0(sgn_t0_c0),
	.sgn(sgn)
);

// -----------------------------------------------------------------------
// --- F-PA --------------------------------------------------------------
// -----------------------------------------------------------------------

wire t_0_1, t_2_7, c0_eq_c1, c0, t1, t0_eq_c0, t0_neq_c0, t0_neq_t1, m0, t0, fp0_, t_8_15, m14, m15, fp16_, t16, m32, m38, m39, c39, p32_, t39, t_32_39, t_16_23, t_24_31;

fpa FPA(
	.opta(opta),
	.optb(optb),
	.optc(optc),
	.opm(opm),
	.strob_fp(strob_fp),
	.strobb_fp(strobb_fp),
	.w(w),
	.taa(taa),
	.t_1(t_1),
	.tab(tab),
	.clockta(clockta),
	.clocktb(clocktb),
	.clocktc(clocktc),
	.t_0_1(t_0_1),
	.t_2_7(t_2_7),
	.t_8_15(t_8_15),
	.t_32_39(t_32_39),
	.t_16_23(t_16_23),
	.t_24_31(t_24_31),
	.m_1(m_1),
	.ma(ma),
	.mb(mb),
	.clockm(clockm),
	._0_m(_0_m),
	.c0_eq_c1(c0_eq_c1),
	.c0(c0),
	.t1(t1),
	.t0_eq_c0(t0_eq_c0),
	.t0_neq_c0(t0_neq_c0),
	.t0_neq_t1(t0_neq_t1),
	.m0(m0),
	.t0(t0),
	.fab(fab),
	.faa(faa),
	.fp0_(fp0_),
	.p_16(p_16),
	.m14(m14),
	.m15(m15),
	.fp16_(fp16_),
	.t16(t16),
	.m_32(m_32),
	.p_32(p_32),
	.m_40(m_40),
	.cp(cp),
	.t_c(t_c),
	.m32(m32),
	.m38(m38),
	.m39(m39),
	.c39(c39),
	.fra(fra),
	.frb(frb),
	.p_40(p_40),
	.p32_(p32_),
	.trb(trb),
	._0_t(_0_t),
	.t39(t39),
	.f9(f9),
	.lkb(lkb),
	.z_f(z_f),
	.m_f(m_f),
	.v_f(v_f),
	.c_f(c_f),
	.zp(zp),
	.d(d),
	._0_zp(_0_zp),
	.zpb(zpb),
	.zpa(zpa)
);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
