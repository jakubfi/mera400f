/*
	CPU

	document: 12-006368-01-8A
	pages:    2-1..2-84
*/

module cpu(
	// from power supply (?)
	input off_,
	input pon_,
	input pout_,
	input clm_, clo_,

	// from control panel
	input [0:15] kl,
	input panel_store_, panel_fetch_, panel_load_, panel_bin_,
	input oprq_, stop$_, start$_, work, mode, step_, stop_n, cycle_,
	input wre, rsa, rsb, rsc,
	input wic, wac, war, wir, wrs, wrz, wkb,
	input zegar_,
	// to control panel
	output p0_,
	output [0:15] w,
	output hlt_n_,
	output p_,
	output run,
	output wait_,
	output irq,
	output q,
	output mc_,
	output awaria_,

	// system bus
											input rpa_,
	output dmcl_,
	// -OFF
	output dw_,
	output dr_,
	output ds_,
	output df_,
	output din_,				input rin_,
	output dok_,				input rok_,
											input ren_,
											input rpe_,
	output dqb_,
	output dpn_,				input rpn_,
	output [0:3] dnb_,
	output [0:15] dad_,
	output [0:15] ddt_,	input [0:15] rdt_,
	output zg,
											input zw,
	output zz_,

	input __clk
);

	// --- CPU FEATURES-----------------------------------------------------

	parameter CPU_NUMBER;
	parameter AWP_PRESENT = 1'b1;
	parameter INOU_USER_ILLEGAL = 1'b1;
	parameter STOP_ON_NOMEM = 1'b1;
	parameter LOW_MEM_WRITE_DENY = 1'b0;

	// --- CPU CORE TIMINGS ------------------------------------------------

	parameter STROB1_1_TICKS = 3'd5; // 80-130ns
	parameter STROB1_2_TICKS = 3'd6; // 110-190ns
	parameter STROB1_3_TICKS = 3'd5; // 80-130ns
	parameter STROB1_4_TICKS = 3'd5; // 80-130ns
	parameter STROB1_5_TICKS = 3'd5; // 80-130ns
	parameter GOT_TICKS = 3'd5; // 80-130ns
	parameter STROB2_TICKS = 3'd6; // 110-190ns
	parameter KC_TICKS = 3'd7; // 100-200ns
	parameter PC_TICKS = 3'd6; // 90-150ns

	// --- BUS TIMINGS -----------------------------------------------------

	parameter ALARM_DLY_TICKS = 8'd250; // 2.5-5us in DTR, >=5us from notes on HSO schematic, ~10us in hw(?)
	parameter ALARM_TICKS = 2'd3; // 60ns
	parameter DOK_DLY_TICKS = 4'd15; // 300ns
	parameter DOK_TICKS = 3'd7; // 153ns


	// -DDT open-collector composition
	assign ddt_[0] = pa_ddt_[0] & px_ddt0_;
	assign ddt_[1:14] = pa_ddt_[1:14];
	assign ddt_[15] = pa_ddt_[15] & px_ddt15_;

	// -DAD open-collector composition
	assign dad_[0:3] = pa_dad_[0:3];
	assign dad_[4] = pa_dad_[4] & pp_dad4_;
	assign dad_[5:8] = pa_dad_[5:8];
	assign dad_[9] = pa_dad_[9] & px_dad9_;
	assign dad_[10] = pa_dad_[10] & px_dad10_;
	assign dad_[11] = pa_dad_[11] & pp_dad11_;
	assign dad_[12] = pa_dad_[12] & px_dad12_ & pp_dad12_;
	assign dad_[13] = pa_dad_[13] & px_dad13_ & pp_dad13_;
	assign dad_[14] = pa_dad_[14] & px_dad14_ & pp_dad14_;
	assign dad_[15] = pa_dad_[15] & px_dad15_ir9_ & px_dad15_i_ & pp_dad15_;

// -----------------------------------------------------------------------
// --- P-X ---------------------------------------------------------------
// -----------------------------------------------------------------------

wire k1_, wp_, k2_, wa_, wz_, w$_, wr_, we_, p1_, p2_, p5_, p4_, p3_, i5_, i4_, i3_, i2_, i1_, ww_, wm_, wx_, as2, got_, strob2_, strob1_, strob1, arm4, blw_pw, ekc_i_, zer_sp_, lipsp$_, pn_nb, bp_nb, bar_nb_, barnb, q_nb, w_dt_, dt_w_, ar_ad_, ic_ad_, px_ddt15_, px_ddt0_, px_dad15_i_, px_dad10_, px_dad9_, i3_ex_przer_, ck_rz_w, zerz_, ok$, oken, bod, b_parz_, b_p0_, px_dad15_ir9_, px_dad12_, px_dad13_, px_dad14_;

px #(
	.AWP_PRESENT(AWP_PRESENT),
	.STOP_ON_NOMEM(STOP_ON_NOMEM),
	.LOW_MEM_WRITE_DENY(LOW_MEM_WRITE_DENY),
	.STROB1_1_TICKS(STROB1_1_TICKS),
	.STROB1_2_TICKS(STROB1_2_TICKS),
	.STROB1_3_TICKS(STROB1_3_TICKS),
	.STROB1_4_TICKS(STROB1_4_TICKS),
	.STROB1_5_TICKS(STROB1_5_TICKS),
	.GOT_TICKS(GOT_TICKS),
	.STROB2_TICKS(STROB2_TICKS),
	.ALARM_DLY_TICKS(ALARM_DLY_TICKS),
	.ALARM_TICKS(ALARM_TICKS)
) PX(
	.__clk(__clk),
	.ek1(ek1),
	.ewp(ewp),
	.ek2(ek2),
	.ewa(ewa),
	.clo_(clo_),
	.ewe(ewe),
	.ewr(ewr),
	.ew$(ew$),
	.ewz(ewz),
	.k1_(k1_),
	.wp_(wp_),
	.k2_(k2_),
	.wa_(wa_),
	.wz_(wz_),
	.w$_(w$_),
	.wr_(wr_),
	.we_(we_),
	.sp1_(sp1_),
	.ep1(ep1),
	.sp0_(sp0_),
	.ep0(ep0),
	.stp0(stp0),
	.ep2(ep2),
	.ep5(ep5),
	.ep4(ep4),
	.ep3(ep3),
	.p1_(p1_),
	.p0_(p0_),
	.p2_(p2_),
	.p5_(p5_),
	.p4_(p4_),
	.p3_(p3_),
	.si1(si1),
	.ewx(ewx),
	.ewm(ewm),
	.eww(eww),
	.i5_(i5_),
	.i4_(i4_),
	.i3_(i3_),
	.i2_(i2_),
	.i1_(i1_),
	.ww_(ww_),
	.wm_(wm_),
	.wx_(wx_),
	.laduj(laduj),
	.as2_sum_at(as2),
	.strob_fp_(strob_fp_),
	.mode(mode),
	.step_(step_),
	.got_(got_),
	.strob2_(strob2_),
	.strob1_(strob1_),
	.strob1(strob1),
	.przerw_z(przerw_z),
	.przerw_(przerw_),
	.lip_(lip_),
	.sp_(sp_),
	.lg_0(lg_0),
	.pp_(pp_),
	.lg_3(lg_3),
	.arm4(arm4),
	.blw_pw(blw_pw),
	.ekc_i_(ekc_i_),
	.zer_sp_(zer_sp_),
	.lipsp$_(lipsp$_),
	.sbar$(sbar$),
	.q(q),
	.in_(in_),
	.ou_(ou_),
	.k2fetch_(k2fetch_),
	.red_fp_(read_fp_),
	.pn_nb(pn_nb),
	.bp_nb(bp_nb),
	.bar_nb_(bar_nb_),
	.barnb(barnb),
	.q_nb(q_nb),
	.df_(df_),
	.w_dt_(w_dt_),
	.dr_(dr_),
	.dt_w_(dt_w_),
	.ar_ad_(ar_ad_),
	.ds_(ds_),
	.mcl_(mcl_),
	.gi_(gi_),
	.ir6(ir[6]),
	.fi_(fi_),
	.arz(arz),
	.k2_bin_store_(k2_bin_store_),
	.lrz_(lrz_),
	.ic_ad_(ic_ad_),
	.dmcl_(dmcl_),
	.ddt15_(px_ddt15_),
	.ddt0_(px_ddt0_),
	.din_(din_),
	.dad15_i_(px_dad15_i_),
	.dad10_(px_dad10_),
	.dad9_(px_dad9_),
	.dw_(dw_),
	.i3_ex_przer_(i3_ex_przer_),
	.ck_rz_w(ck_rz_w),
	.zerz_(zerz_),
	.sr_fp_(sr_fp_),
	.zw1_(~zw),
	.srez$(srez$),
	.wzi(wzi),
	.is_(is_),
	.ren_(ren_),
	.rok_(rok_),
	.efp_(efp_),
	.exl_(exl_),
	.zg(zg),
	.ok$(ok$),
	.oken(oken),
	.stop_n(stop_n),
	.zga(zga),
	.rpe_(rpe_),
	.stop_(stop$_),
	.ir9(ir[9]),
	.pufa(pufa),
	.ir7(ir[7]),
	.ir8(ir[8]),
	.hlt_n_(hlt_n_),
	.bod(bod),
	.b_parz_(b_parz_),
	.b_p0_(b_p0_),
	.awaria_(awaria_),
	.zz1_(zz_),
	.dad15_ir9_(px_dad15_ir9_),
	.dad12_(px_dad12_),
	.dad13_(px_dad13_),
	.dad14_(px_dad14_)
);

// -----------------------------------------------------------------------
// --- P-M ---------------------------------------------------------------
// -----------------------------------------------------------------------

wire sp0_, przerw_, si1, sp1_, laduj, k2_bin_store_, k2fetch_, w_rbc$_, w_rba$_, w_rbb$_, ep0, stp0, ek2, ek1, mc_3, xi$_, pp_, ep5, ep4, ep3, ep1, ep2, icp1, arp1, lg_3, lg_0, rc_, rb_, ra_, lk, wls, w_r_, w_ic, w_ac, w_ar, lrz_, w_bar, w_rm, baa, bab, bac, aa, ab, wpb_, bwb, bwa, kia, kib, w_ir, mwa, mwb, mwc;

pm #(
	.KC_TICKS(KC_TICKS),
	.PC_TICKS(PC_TICKS)
)PM(
	.__clk(__clk),
	.start$_(start$_),
	.pon_(pon_),
	.work(work),
	.hlt_n_(hlt_n_),
	.stop$_(stop$_),
	.clo_(clo_),
	.hlt(hlt),
	.cycle_(cycle_),
	.irq(irq),
	.wait_(wait_),
	.run(run),
	.ekc_1_(ekc_1_),
	.ekc_i_(ekc_i_),
	.ekc_2_(ekc_2_),
	.got_(got_),
	.ekc_fp_(ekc_fp_),
	.clm_(clm_),
	.strob2_(strob2_),
	.sp0_(sp0_),
	.przerw_(przerw_),
	.si1(si1),
	.sp1_(sp1_),
	.k2_(k2_),
	.panel_store_(panel_store_),
	.panel_fetch_(panel_fetch_),
	.panel_load_(panel_load_),
	.panel_bin_(panel_bin_),
	.rdt11_(rdt_[11]),
	.k1_(k1_),
	.laduj(laduj),
	.k2_bin_store_(k2_bin_store_),
	.k2fetch_(k2fetch_),
	.w_rbc$_(w_rbc$_),
	.w_rba$_(w_rba$_),
	.w_rbb$_(w_rbb$_),
	.p0_(p0_),
	.rdt9_(rdt_[9]),
	.ep0(ep0),
	.stp0(stp0),
	.ek2(ek2),
	.ek1(ek1),
	.j$(j$),
	.bcoc$(bcoc$),
	.zs(zs),
	.p2_(p2_),
	.ssp$(ssp$),
	.sc$(sc$),
	.md(md),
	.xi(xi),
	.p_(p_),
	.mc_3(mc_3),
	.mc_(mc_),
	.xi$_(xi$_),
	.p4_(p4_),
	.b0_(b0_),
	.na_(na_),
	.c0(c0),
	.ka2_(ka2_),
	.ka1_(ka1_),
	.p3_(p3_),
	.p1_(p1_),
	.nef(nef),
	.p5_(p5_),
	.i2_(i2_),
	.pp_(pp_),
	.ep5(ep5),
	.ep4(ep4),
	.ep3(ep3),
	.ep1(ep1),
	.ep2(ep2),
	.icp1(icp1),
	.strob1_(strob1_),
	.exl_(exl_),
	.lipsp$_(lipsp$_),
	.gr$_(gr$_),
	.wx_(wx_),
	.shc_(shc_),
	.read_fp_(read_fp_),
	.ir7(ir[7]),
	.inou$_(inou$_),
	.rok_(rok_),
	.arp1(arp1),
	.lg_3(lg_3),
	.lg_0(lg_0),
	.rsc(rsc),
	.ir10(ir[10]),
	.lpb(lpb),
	.ir11(ir[11]),
	.rsb(rsb),
	.ir12(ir[12]),
	.rsa(rsa),
	.lpa(lpa),
	.rlp_fp_(rlp_fp_),
	.rc_(rc_),
	.rb_(rb_),
	.ra_(ra_),
	.bod(bod),
	.ir15(ir[15]),
	.ir14(ir[14]),
	.ir13(ir[13]),
	.ir9(ir[9]),
	.ir8(ir[8]),
	.lk(lk),
	.rj_(rj_),
	.uj$_(uj$_),
	.lwt$_(lwt$_),
	.sr$_(sr$_),
	.lac$_(lac$_),
	.lrcb$_(lrcb$_),
	.rpc(rpc),
	.rc$_(rc$_),
	.ng$_(ng$_),
	.ls_(ls_),
	.oc$_(oc$_),
	.wa_(wa_),
	.wm_(wm_),
	.wz_(wz_),
	.ww_(ww_),
	.wr_(wr_),
	.wp_(wp_),
	.wls(wls),
	.ri_(ri_),
	.war(war),
	.wre(wre),
	.i3_(i3_),
	.s_fp_(s_fp_),
	.sar$(sar$),
	.lar$(lar$),
	.in_(in_),
	.bs_(bs_),
	.zb$_(zb$_),
	.w_r_(w_r_),
	.wic(wic),
	.i4_(i4_),
	.wac(wac),
	.i1_(i1_),
	.w_ic(w_ic),
	.w_ac(w_ac),
	.w_ar(w_ar),
	.wrz(wrz),
	.wrs(wrs),
	.mb_(mb_),
	.im_(im_),
	.lj_(lj_),
	.lwrs$_(lwrs$_),
	.jkrb$_(jkrb_),
	.lrz_(lrz_),
	.w_bar(w_bar),
	.w_rm(w_rm),
	.we_(we_),
	.ib_(ib_),
	.ir6(ir[6]),
	.cb_(cb_),
	.i5_(i5_),
	.rb$_(rb$_),
	.w$_(w$_),
	.i3_ex_prz_(i3_ex_przer_),
	.baa(baa),
	.bab(bab),
	.bac(bac),
	.aa(aa),
	.ab(ab),
	.at15_(at15_),
	.srez$(srez$),
	.rz_(rz_),
	.wir(wir),
	.blw_pw(blw_pw),
	.wpb_(wpb_),
	.bwb(bwb),
	.bwa(bwa),
	.kia(kia),
	.kib(kib),
	.w_ir(w_ir),
	.ki_(ki_),
	.dt_w_(dt_w_),
	.f13_(f13_),
	.wkb(wkb),
	.mwa(mwa),
	.mwb(mwb),
	.mwc(mwc)
);

// -----------------------------------------------------------------------
// --- P-D ---------------------------------------------------------------
// -----------------------------------------------------------------------

wire [0:15] ir;
wire c0, ls_, rj_, bs_, ou_, in_, is_, ri_, pufa, rb$_, cb_, sc$, oc$_, ka2_, gr$_, hlt, mcl_, sin_, gi_, lip_, mb_, im_, ki_, fi_, sp_, rz_, ib_, lpc, rpc, shc_, rc$_, ng$_, zb$_, b0_, _0_v, md, xi, nef, amb, apb, jkrb_, lwrs$_, saryt, ap1, am1, bcoc$, sd, scb, sca, sb, sab, saa, lrcb$_, aryt, sbar$, nrf, ust_z, ust_v, ust_mc, ust_leg, eat0, sr$_, ust_y, ust_x, blr_, ewa, ewp, uj$_, lwt$_, lj_, ewe, ekc_1_, ewz, ew$, lar$, ssp$, ka1_, na_, exl_, p16_, ewr, ewm, efp_, sar$, eww, srez$, ewx, axy, inou$_, ekc_2_, lac$_;

pd #(
	.INOU_USER_ILLEGAL(INOU_USER_ILLEGAL)
) PD(
	.w(w),
	.strob1(strob1),
	.w_ir(w_ir),
	.ir(ir),
	.c0(c0),
	.si1(si1),
	.ls_(ls_),
	.rj_(rj_),
	.bs_(bs_),
	.ou_(ou_),
	.in_(in_),
	.is_(is_),
	.ri_(ri_),
	.pufa(pufa),
	.rb$_(rb$_),
	.cb_(cb_),
	.sc$(sc$),
	.oc$_(oc$_),
	.ka2_(ka2_),
	.gr$_(gr$_),
	.hlt(hlt),
	.mcl_(mcl_),
	.sin_(sin_),
	.gi_(gi_),
	.lip_(lip_),
	.mb_(mb_),
	.im_(im_),
	.ki_(ki_),
	.fi_(fi_),
	.sp_(sp_),
	.rz_(rz_),
	.ib_(ib_),
	.lpc(lpc),
	.rpc(rpc),
	.shc_(shc_),
	.rc$_(rc$_),
	.ng$_(ng$_),
	.zb$_(zb$_),
	.b0_(b0_),
	.q(q),
	.mc_3(mc_3),
	.r0(r0),
	._0_v(_0_v),
	.p_(p_),
	.md(md),
	.xi(xi),
	.nef(nef),
	.w$_(w$_),
	.p4_(p4_),
	.we_(we_),
	.amb(amb),
	.apb(apb),
	.jkrb_(jkrb_),
	.lwrs$_(lwrs$_),
	.saryt(saryt),
	.ap1(ap1),
	.am1(am1),
	.wz_(wz_),
	.wls(wls),
	.bcoc$(bcoc$),
	.sd(sd),
	.scb(scb),
	.sca(sca),
	.sb(sb),
	.sab(sab),
	.saa(saa),
	.lrcb$_(lrcb$_),
	.aryt(aryt),
	.sbar$(sbar$),
	.nrf(nrf),
	.at15_(at15_),
	.wx_(wx_),
	.wa_(wa_),
	.ust_z(ust_z),
	.ust_v(ust_v),
	.ust_mc(ust_mc),
	.ust_leg(ust_leg),
	.eat0(eat0),
	.sr$_(sr$_),
	.ust_y(ust_y),
	.ust_x(ust_x),
	.blr_(blr_),
	.wpb_(wpb_),
	.wr_(wr_),
	.pp_(pp_),
	.ww_(ww_),
	.wzi(wzi),
	.ewa(ewa),
	.ewp(ewp),
	.uj$_(uj$_),
	.lwt$_(lwt$_),
	.lj_(lj_),
	.ewe(ewe),
	.wp_(wp_),
	.ekc_1_(ekc_1_),
	.ewz(ewz),
	.ew$(ew$),
	.lar$(lar$),
	.ssp$(ssp$),
	.ka1_(ka1_),
	.na_(na_),
	.exl_(exl_),
	.p16_(p16_),
	.lk(lk),
	.wm_(wm_),
	.ewr(ewr),
	.ewm(ewm),
	.efp_(efp_),
	.sar$(sar$),
	.eww(eww),
	.srez$(srez$),
	.ewx(ewx),
	.axy(axy),
	.inou$_(inou$_),
	.ekc_2_(ekc_2_),
	.lac$_(lac$_)
);

// -----------------------------------------------------------------------
// --- P-R ---------------------------------------------------------------
// -----------------------------------------------------------------------

wire [0:15] l;
wire zgpn, zer_;
wire [0:8] r0;
wire [0:15] ki;

pr #(
	.CPU_NUMBER(CPU_NUMBER),
	.AWP_PRESENT(AWP_PRESENT)
) PR(
	.blr_(blr_),
	.lpc(lpc),
	.wa_(wa_),
	.rpc(rpc),
	.ra_(ra_),
	.rb_(rb_),
	.as2(as2),
	.rc_(rc_),
	.w_r_(w_r_),
	.strob1_(strob1_),
	.strob2_(strob2_),
	.w(w),
	.l(l),
	.bar_nb_(bar_nb_),
	.w_rbb_(w_rbb$_),
	.w_rbc_(w_rbc$_),
	.w_rba_(w_rba$_),
	.dnb_(dnb_),
	.rpn_(rpn_),
	.bp_nb(bp_nb),
	.pn_nb(pn_nb),
	.q_nb(q_nb),
	.w_bar(w_bar),
	.zer_sp_(zer_sp_),
	.clm_(clm_),
	.ustr0_fp_(ustr0_fp_),
	.ust_leg(ust_leg),
	.aryt(aryt),
	.zs(zs),
	.carry_(carry_),
	.s_1(s_1),
	.zgpn(zgpn),
	.dpn_(dpn_),
	.dqb_(dqb_),
	.q(q),
	.zer_(zer_),
	.ust_z(ust_z),
	.ust_mc(ust_mc),
	.s0(s0),
	.ust_v(ust_v),
	._0_v(_0_v),
	.r0(r0),
	.exy_(exy_),
	.ust_y(ust_y),
	.exx_(exx_),
	.ust_x(ust_x),
	.kia(kia),
	.kib(kib),
	.rz(rz),
	.zp(zp),
	.rs(rs),
	.ki(ki)
);

// -----------------------------------------------------------------------
// --- P-P ---------------------------------------------------------------
// -----------------------------------------------------------------------

wire [0:9] rs;
wire [0:15] rz;
wire przerw_z, pp_dad11_, pp_dad12_, pp_dad13_, pp_dad14_, pp_dad4_, pp_dad15_;

pp #(
	.DOK_DLY_TICKS(DOK_DLY_TICKS),
	.DOK_TICKS(DOK_TICKS)
) PP(
	.__clk(__clk),
	.w(w),
	.clm_(clm_),
	.w_rm(w_rm),
	.strob1_(strob1_),
	.i4_(i4_),
	.rs(rs),
	.pout_(pout_),
	.zer_(zer_),
	.b_parz_(b_parz_),
	.ck_rz_w(ck_rz_w),
	.b_p0_(b_p0_),
	.zerrz_(zerz_),
	.i1_(i1_),
	.przerw_(przerw_),
	.rz(rz),
	.rpa_(rpa_),
	.zegar_(zegar_),
	.xi_(xi$_),
	.fi0_(fi0_),
	.fi1_(fi1_),
	.fi2_(fi2_),
	.fi3_(fi3_),
	.przerw_z(przerw_z),
	.k1_(k1_),
	.i2_(i2_),
	.oprq_(oprq_),
	.ir14(ir[14]),
	.wx_(wx_),
	.sin_(sin_),
	.ir15(ir[15]),
	.rin_(rin_),
	.zw(zw),
	.rdt15_(rdt_[15]),
	.zgpn_(zgpn),
	.rdt0_(rdt_[0]),
	.rdt14_(rdt_[14]),
	.rdt13_(rdt_[13]),
	.rdt12_(rdt_[12]),
	.rdt11_(rdt_[11]),
	.dok_(dok_),
	.irq(irq),
	.dad11_(pp_dad11_),
	.dad12_(pp_dad12_),
	.dad13_(pp_dad13_),
	.dad14_(pp_dad14_),
	.dad4_(pp_dad4_),
	.dad15_(pp_dad15_)
);

// -----------------------------------------------------------------------
// --- P-A ---------------------------------------------------------------
// -----------------------------------------------------------------------

wire s0, carry_, j$, exx_, at15_, exy_, s_1, wzi, zs, arz;
wire zga;
wire [0:15] pa_ddt_;
wire [0:15] pa_dad_;

pa PA(
	.ir(ir),
	.ki(ki),
	.rdt_(rdt_),
	.w_dt_(w_dt_),
	.mwa(mwa),
	.mwb(mwb),
	.mwc(mwc),
	.bwa(bwa),
	.bwb(bwb),
	.ddt_(pa_ddt_),
	.w(w),
	.saryt(saryt),
	.sab(sab),
	.scb(scb),
	.sb(sb),
	.sd(sd),
	.s0(s0),
	.carry_(carry_),
	.p16_(p16_),
	.saa(saa),
	.sca(sca),
	.j$(j$),
	.exx_(exx_),
	.wx_(wx_),
	.eat0(eat0),
	.axy(axy),
	.at15_(at15_),
	.exy_(exy_),
	.w_ac(w_ac),
	.strob2_(strob2_),
	.as2(as2),
	.strob1_(strob1_),
	.am1(am1),
	.apb(apb),
	.amb(amb),
	.ap1(ap1),
	.strob1(strob1),
	.s_1(s_1),
	.wzi(wzi),
	.zs(zs),
	.arm4(arm4),
	.w_ar(w_ar),
	.arp1(arp1),
	.arz(arz),
	.icp1(icp1),
	.w_ic(w_ic),
	.off_(off_),
	.baa(baa),
	.bab(bab),
	.bac(bac),
	.ab(ab),
	.aa(aa),
	.l(l),
	.barnb(barnb),
	.kl(kl),
	.ic_ad_(ic_ad_),
	.dad_(pa_dad_),
	.ar_ad_(ar_ad_),
	.zga(zga)
);

// -----------------------------------------------------------------------
// --- AWP ---------------------------------------------------------------
// -----------------------------------------------------------------------

wire fi0_, fi1_, fi2_, fi3_;
wire read_fp_, strob_fp_, sr_fp_, ekc_fp_, rlp_fp_, ustr0_fp_, s_fp_;
wire f13_, lpa, lpb;
wire [0:15] zp;

generate
	if (~AWP_PRESENT) begin
		assign {fi0_, fi1_, fi2_, fi3_} = 4'b1111;
		assign {read_fp_, strob_fp_, sr_fp_, ekc_fp_, rlp_fp_, ustr0_fp_, s_fp_} = 7'b1111111;
		assign {f13_, lpa, lpb} = 3'b100;
		assign zp = 16'h0000;
	end else begin
		awp AWP(
			.__clk(__clk),
			.w(w),
			.r02(r0[2]),
			.r03(r0[3]),
			.pufa(pufa),
			.ir(ir[7:9]),
			.nrf(nrf),
			.mode(mode),
			.step_(step_),
			.efp_(efp_),
			.got_(got_),
			.ok$(ok$),
			.oken(oken),
			.zw1(zw),
			.zp(zp),
			.fi0_(fi0_),
			.fi1_(fi1_),
			.fi2_(fi2_),
			.fi3_(fi3_),
			.rlp_fp_(rlp_fp_),
			.lpa(lpa),
			.lpb(lpb),
			.s_fp_(s_fp_),
			.ustr0_fp_(ustr0_fp_),
			.f13_(f13_),
			.strob_fp_(strob_fp_),
			.sr_fp_(sr_fp_),
			.read_fp_(read_fp_),
			.ekc_fp_(ekc_fp_)
		);
	end
endgenerate

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
