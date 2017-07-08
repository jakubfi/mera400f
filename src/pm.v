/*
	P-M unit (microinstructions)

	document: 12-006368-01-8A
	unit:     P-M3-2
	pages:    2-11..2-28
*/

module pm(
	input __clk,
	// sheet 1
	input start$_,
	input pon_,
	input work,
	input hlt_n_,
	input stop$_,
	input clo_,
	input hlt,
	input cycle_,
	input irq,
	output start,
	output wait_,
	output run,
	// sheet 2
	input ekc_1_,
	input ekc_i_,
	input ekc_2_,
	input got_,
	input ekc_fp_,
	input clm_,
	input strob2_,
	output sp0_,
	output przerw_,
	output si1,
	output sp1_,
	// sheet 3
	input k2_,
	input panel_store_,
	input panel_fetch_,
	input panel_load_,
	input panel_bin_,
	input rdt11_,
	input k1_,
	output laduj,
	output k2_bin_store_,
	output k2fetch_,
	output w_rbc$_,
	output w_rba$_,
	output w_rbb$_,
	// sheet 4
	input p0_,
	input rdt9_,
	output ep0,
	output stp0,
	output ek2,
	output ek1,
	// sheet 5
	input j$,
	input bcoc$,
	input zs,
	input p2_,
	input ssp$,
	input sc$,
	input md,
	input xi,
	output p_,
	output mc_3,
	output mc_,
	output xi$_,
	// sheet 6
	input p4_,
	input b0_,
	input na_,
	input c0,
	input ka2_,
	input ka1_,
	// sheet 7
	input p3_,
	input p1_,
	input nef,
	input p5_,
	input i2_,
	output pp_,
	output ep5,
	output ep4,
	output ep3,
	output ep1,
	output ep2,
	output icp1,
	// sheet 8
	input strob1_,
	input exl_,
	input lipsp$_,
	input gr$_,
	input wx_,
	input shc_,
	// sheet 9
	input read_fp_,
	input ir7,
	input inou$_,
	input rok_,
	output arp1,
	output lg_3,
	output lg_0,
	// sheet 10
	input rsc,
	input ir10,
	input lpb,
	input ir11,
	input rsb,
	input ir12,
	input rsa,
	input lpa,
	input rlp_fp_,
	output rc_,
	output rb_,
	output ra_,
	// sheet 11
	input bod,
	input ir15,
	input ir14,
	input ir13,
	input ir9,
	input ir8,
	output lk,
	// sheet 12
	input rj_,
	input uj$_,
	input lwt$_,
	input sr$_,
	input lac$_,
	input lrcb$_,
	input rpc,
	input rc$_,
	input ng$_,
	input ls_,
	input oc$_,
	input wa_,
	input wm_,
	input wz_,
	input ww_,
	input wr_,
	input wp_,
	output wls,
	// sheet 13
	input ri_,
	input war,
	input wre,
	input i3_,
	input s_fp_,
	input sar$,
	input lar$,
	input in_,
	input bs_,
	input zb$_,
	output w_r_,
	// sheet 14
	input wic,
	input i4_,
	input wac,
	input i1_,
	output w_ic,
	output w_ac,
	output w_ar,
	// sheet 15
	input wrz,
	input wrs,
	input mb_,
	input im_,
	input lj_,
	input lwrs$_,
	input jkrb$_,
	output lrz_,
	output w_bar,
	output w_rm,
	// sheet 16
	input we_,
	input ib_,
	input ir6,
	input cb_,
	input i5_,
	input rb$_,
	input w$_,
	input i3_ex_prz_,
	output baa,
	output bab,
	output bac,
	output aa,
	output ab,
	// sheet 17
	input at15_,
	input srez$,
	input rz_,
	input wir,
	input blw_pw,
	output wpb_, // WPB - Wskaźnik Prawego Bajtu
	output bwb,
	output bwa,
	output kia,
	output kib,
	output w_ir,
	// sheet 18
	input ki_,
	input dt_w_,
	input f13_,
	input wkb,
	output mwa,
	output mwb,
	output mwc
);

	parameter KC_TICKS;
	parameter PC_TICKS;

	// sheet 1, page 2-11
	//  * ff: START, WAIT, CYCLE

	wire M76_12 = hlt_n_ & stop$_ & clo_;
	wire M44_3 = ~(~pon_ & work);
	ffd REG_START(
		.s_(start$_),
		.d(1'b1),
		.c(M44_3),
		.r_(M76_12),
		.q(start)
	);

	wire M43_3 = M76_12 & ~si1;
	wire __wait_q;
	ffd REG_WAIT(
		.s_(1'b1),
		.d(hlt),
		.c(wx),
		.r_(M43_3),
		.q(__wait_q)
	);
	assign wait_ = ~__wait_q;

	wire __cycle_q;
	ffd REG_CYCLE(
		.s_(cycle_),
		.d(1'b0),
		.c(1'b1),
		.r_(rescyc_),
		.q(__cycle_q)
	);

	assign run = start & wait_;
	wire dpr_ = ~run & ~__cycle_q;
	wire dprzerw_ = ~(~(~__cycle_q & ~start) & irq & p_ & mc_);
	wire stpc = ~(dpr_ & dprzerw_);

	// sheet 2, page 2-12
	//  * ff: PR (pobranie rozkazu - instruction fetch)
	//  * ff: PP (przyjęcie przerwania - interrupt receive)
	//  * univib: KC (koniec cyklu - cycle end)
	//  * univib: PC (początek cyklu - cycle start)

	wire M27_8 = ~(ekc_1_ & ekc_i_ & ekc_2_ & p2_ & p0stpc_);
	wire M43_11 = clo_ & ~M90_13;

	wire M13_11;
	ffjk __m13(
		.s_(ekc_fp_),
		.j(M27_8),
		.c_(got_),
		.k(1'b0),
		.r_(M43_11),
		.q(M13_11)
	);

	wire M90_5;
	univib #(.ticks(KC_TICKS)) VIB_KC(
		.clk(__clk),
		.a_(1'b0),
		.b(M13_11),
		.q(M90_5)
	);

	wire M90_13;
	univib #(.ticks(PC_TICKS)) VIB_PC(
		.clk(__clk),
		.a_(M90_5),
		.b(1'b1),
		.q(M90_13)
	);

	wire rescyc_ = clm_ & strob2_ & ~si1;

	wire pr_;
	ffd REG_PR(
		.s_(rescyc_),
		.d(dpr_),
		.c(M90_5),
		.r_(1'b1),
		.q(pr_)
	);
	wire pr = ~pr_;

	assign sp0_ = ~(pr_ & przerw_ & M90_13);

	ffd REG_PRZERW(
		.s_(clm_),
		.d(dprzerw_),
		.c(M90_5),
		.r_(1'b1),
		.q(przerw_)
	);

	assign si1 = M90_13 & ~przerw_;
	assign sp1_ = ~(przerw_ & pr & M90_13);
	wire zerstan_ = ~M90_5 & clm_ & p0_;
	wire strob2 = ~strob2_;

	// sheet 3, page 2-13
	//  * ff: FETCH, STORE, LOAD, BIN (bootstrap)

	wire M30_X = strob2 & k2;
	wire M14_12 = ~(rdt9 & ~rdt11_ & lg_0);
	wire M47_8 = ~(strob1 & k1);

	wire bin, load, fetch, store;
	ffd REG_STORE(
		.s_(panel_store_),
		.d(1'b0),
		.c(M30_X),
		.r_(clm_),
		.q(store)
	);
	ffd REG_FETCH(
		.s_(panel_fetch_),
		.d(1'b0),
		.c(M30_X),
		.r_(clm_),
		.q(fetch)
	);
	ffd REG_LOAD(
		.s_(panel_load_),
		.d(1'b0),
		.c(M30_X),
		.r_(clm_),
		.q(load)
	);
	ffd REG_BIN(
		.s_(panel_bin_),
		.d(M14_12),
		.c(M47_8),
		.r_(clm_),
		.q(bin)
	);

	assign laduj = load;
	wire sfl = store | fetch | load;
	wire k2 = ~k2_;
	// FIX: +UR was a NAND output on schematic, instead of AND
	wire ur = k2 & (load | fetch);
	wire ar_1 = ~(k2 & ~load);
	wire k2store_ = ~(k2 & store);
	assign k2_bin_store_ = ~(k2 & ~(~store & ~bin));
	assign k2fetch_ = ~(k2 & fetch);
	wire bin_ = ~bin;

	assign w_rbc$_ = k1s1 & lg_0;
	assign w_rba$_ = k1s1 & lg_2;
	assign w_rbb$_ = k1s1 & lg_1;
	wire k1s1 = ~(~(strob1 & k1));
	wire k1 = ~k1_;

	// sheet 4, page 2-14
	//  * control panel state transitions
	//  * transition to P0 state

	wire psr = ~(k2store_ & p0_);
	wire p0stpc_ = ~(stpc & ~p0_);
	wire p0_k2 = ~(~k2 & p0_);
	assign ep0 = ~(~k2 & k1_) & bin_;
	assign stp0 = ~(bin_ & ~stpc & ~sfl);
	assign ek2 = ~(~(~p0_ & sfl) & ~(bin & lg_3 & k1));
	assign ek1 = ~(~(p0_k2 & bin) & ~(k1 & bin & ~lg_3));
	wire lg_plus_1 = (bin & k2) | (k1 & rdt9);
	// NOTE: not connected anywhere (on every schematic)
	//wire zero_lg = ~(~rdt9 & k1s1 & rok);
	wire rdt9 = ~rdt9_;

	// sheet 5, page 2-15
	//  * P - wskaźnik przeskoku (branch indicator)
	//  * MC - premodification counter

	wire M31_6 = ~((~j$ & bcoc$) | zs);
	wire M43_8 = (p2 & strob1) | ~clm_;
	wire M46_8 = ~(ssp$ & strob1 & w$);
	wire M45_8 = strob1 & rok & inou_ & wm$;

	ffd WSK_P(
		.s_(~M43_8),
		.d(M31_6),
		.c(M46_8),
		.r_(~M45_8),
		.q(p_)
	);

	wire p2 = ~p2_;
	wire setwp = strob1 & wx & md;
	wire reswp = M43_8 | (sc$ & strob2 & p1);
	wire reset_mc = reswp | (~md & p4);

	mc MC(
		.inc(setwp),
		.reset(reset_mc),
		.mc_3(mc_3),
		.mc_0(mc_)
	);

	assign xi$_ = ~(p_ & p1 & strob2 & xi);
	wire xi_ = xi$_;
	wire p1 = ~p1_;

	// sheet 6, page 2-16
	//  * WPI - wskaźnik premodyfikacji (premodification indicator)
	//  * WBI - wskaźnik B-modyfikacji (B-modification indicator)

	wire p4 = ~p4_;

	wire wm_q;
	wire M86_6 = pr & ~c0 & ~na_;
	ffd REG_WM(
		.s_(1'b1),
		.d(M86_6),
		.c(strob2),
		.r_(xi_),
		.q(wm_q)
	);

	wire M86_12 = pr & b0_ & ~na_;
	wire M103_3 = (p4 & wpp_) | p2;
	wire wb;
	ffjk REG_WB(
		.s_(1'b1),
		.j(M86_12),
		.c_(strob1),
		.k(M103_3),
		.r_(zerstan_),
		.q(wb)
	);

	wire wpp;
	ffjk REG_WP(
		.s_(~setwp),
		.j(1'b0),
		.c_(strob1),
		.k(p4),
		.r_(~reswp),
		.q(wpp)
	);
	wire wpp_ = ~wpp;

	wire p4wp_ = ~(p4 & wpp);
	wire wpb = ~(~wb & wpp_);
	wire bla = p4 & ka1ir6 & wpp_;
	// FIX: +NAIR6 was -NAIR6
	wire nair6 = ~na_ & ir6;
	wire ka12x = ~(~(~na_ & c0) & ka2_ & ka1_);
	wire ka1ir6 = ka1 & ir6;
	wire ka1 = ~ka1_;

	// sheet 7, page 2-17
	//  * main loop state transition signals

	wire p3 = ~p3_;
	wire M69_1 = ~(nair6 | wpb);
	wire M100_8 = ~(p3 & ka1ir6);
	wire M89_10 = ~(wm_q | ka12x);
	wire M89_13 = ~(p1_ | nef);
	wire M100_11 = ~(p3_ & p4_);

	wire M85_6 = ~(M69_1 & M100_8 & M100_11);
	wire M85_12 = ~(M69_1 & M89_10 & M89_13);
	wire M85_8 = ~(M100_11 & nair6 & ~wpb);
	wire M84_6 = ~(nair6 & M89_10 & M89_13 & ~wpb);

	assign pp_ = M85_12 & M85_6 & p5_;
	assign ep5 = ~(M85_8 & M84_6);

	wire M100_6 = ~(M100_11 & wpb);
	wire M101_12 = ~(M89_10 & M89_13 & wpb);

	assign ep4 = ~(M100_8 & M100_6 & M101_12);

	assign ep3 = M89_13 & ka12x;
	assign ep1 = M89_13 & wm_q;
	assign ep2 = nef & p1;
	wire p5_p4_ = p5_ & p4_;
	wire lac_ = p5_p4_ & p1_ & p3_ & i2_;

	wire M98_6 = ~(wm_q & p2);

	assign icp1 = ~(M98_6 & p1_ & ic_1_);

	// sheet 8, page 2-18

	wire lipsp = ~lipsp$_;
	wire strob1 = ~strob1_;
	wire str1wx = strob1 & wx;
	wire lolk = slg2 | (strob2 & p1 & shc) | (strob1 & wm & inou);

	wire downlk = strob1 & (wrwwgr | ((~shc_ | ~inou_) & wx));
	wire wrwwgr = gr & wrww;
	wire wx = ~wx_;
	wire gr = ~gr$_;
	wire shc = ~shc_;

	// sheet 9, page 2-19
	//  * group counter (licznik grupowy)

	assign arp1 = ~(ar_1 & read_fp_ & i3_ & ~wrwwgr);

	// LG clock
	wire M62_3 = strob1 & (i3 | wrwwgr | lg_plus_1);
	// LG reset
	wire M62_11 = zerstan_ & i1_;

	// LG preload triggers
	wire slg1 = p1 & exl_ & strob2 & ~(lipsp | gr); // "common" preload at P1
	wire slg2 = strob1 & gr & wx; // preload for register group operations (at WX)

	wire lg_2, lg_1;
	wire lga, lgb, lgc;
	lg LG(
		.clk_(M62_3),
		.reset_(M62_11),
		.gr(gr),
		.slg1(slg1),
		.slg2(slg2),
		.ir({ir7, ir8, ir9}),
		.lg_0(lg_0),
		.lg_1(lg_1),
		.lg_2(lg_2),
		.lg_3(lg_3),
		.lga(lga),
		.lgb(lgb),
		.lgc(lgc)
	);

	wire ic_1_ = ~(wx & inou);
	wire inou_ = inou$_;
	wire inou = ~inou_;
	wire rok = ~rok_;
	wire okinou_ = ~(inou & rok);

	// sheet 10, page 2-20
	//  * general register selectors

	// NOTE: 1'b0 is there on every version of the schematic
	assign rc_ = ~((rsc & p0_k2) | (ir10 & p4) | (ir13 & p3) | (~_7_rkod_) | (1'b0 & ~rlp_fp_) | (lgc & w));
	assign rb_ = ~((ir14 & p3) | (ir11 & p4) | (rsb & p0_k2) | (~_7_rkod_) | (~rlp_fp_ & lpb) | (lgb & w));
	assign ra_ = ~((~_7_rkod_) | (ir15 & p3) | (p4 & ir12) | (p0_k2 & rsa) | (w & lga) | (~rlp_fp_ & lpa));

	// sheet 11, page 2-21
	//  * step counter (licznik kroków)

	wire lk0, lk1, lk2, lk3;

	wire M64_8 = (ir9 & gr) | (ir8 & gr) | (inou & bod) | (ir15 & shc);
	wire M65_6 = ~((shc & ir14) | (gr));
	wire M94_8 = ~(M65_6 & okinou_);
	wire M49_8 = (shc & ir13) | (gr & (~ir9 & ir8));
	wire M85_11 = shc & ir6;

	lk CNT_LK(
		.cd(downlk),
		.i({M85_11, M49_8, M94_8, M64_8}),
		.l_(~lolk),
		.r(~zerstan_),
		.o({lk0, lk1, lk2, lk3})
	);
	
	assign lk = ~(~(lk0 | lk1) & ~(lk2 | lk3));

	// sheet 12, page 2-22

	wire rj = ~rj_;
	wire ruj = ~(rj_ & uj$_);
	wire pac_ = ~(uj$_ & rj_ & lwt$_);
	wire lwtsr = ~(lwt$_ & sr$_);
	wire lrcblac = ~(lac$_ & lrcb_);
	wire lrcb_ = lrcb$_;
	wire pat_ = ~(lrcb_ & sr$_);
	// name conflict: wire rc_ = rc$_;
	wire rjcpc = ~(rj_ & ~rpc & rc$_);
	wire ng_ = ng$_;
	wire lrcbngls$ = ~(lrcb_ & ng_ & ls_);
	wire ls = ~ls_;
	// NOTE: Reset condition was "~-LS" on original schematic and "~(-WE|-LS)" in DTR
	// Both were wrong. Fixed to what was done in hardware: ~(W&|-LS).
	wire M95_10 = ~(w$ | ls_);
	wire wls_ = ~(M95_10 & wls);
	assign wls = ~(wls_ & wa_);
	wire wa = ~wa_;
	wire oc_ = oc$_;
	wire M24_8 = ~(oc_ & bs_ & w$);
	wire M36_3 = ~(ls_ & we);
	wire w = ~(wa_ & M24_8 & M36_3 & wm_ & wz_ & ww_ & wr_ & wp_);
	wire wr = ~wr_;
	wire wrww = ~(wr_ & ww_);

	// sheet 13, page 2-23
	//  * W bus to Rx microoperation

	wire ri = ~ri_;
	wire warx_ = ~((p1 & wpp_) | (wpp_ & p3) | (ri & wa) | (war & ur));
	wire M50_8 = ~((ur & wre) | (lipsp & lg_1 & i3) | (lwtsr & wp) | (wa & rjcpc));
	wire M66_8 = ~((wr & sar$) | (~zb_ & we) | (lar$ & w$) | (wm & ~in_ & rok));
	assign w_r_ = M50_8 & s_fp_ & M66_8;
	// FIX: -7->RKOD was a active-high output of a 7451, which has active-low outputs
	wire _7_rkod_ = ~((w$ & ~bs_) | (ls & we));
	wire wm = ~wm_;
	wire wm$ = ~wm_;
	wire wp = ~wp_;
	wire i3 = ~i3_;
	wire zb_ = zb$_;

	// sheet 14, page 2-24
	//  * W bus to IC, AC, AR microoperations

	wire M53_8 = ~((lg_0 & lipsp & i3) | (ljkrb & we) | (wp & ruj) | (ur & wic));
	wire M36_6 = ~(bs_ & wls_);
	wire M52_8 = ~((M36_6 & we) | (ur & wac) | (wa & lrcbngls$) | (wr & lrcblac));
	wire M68_8 = ~((wls_ & ls & we) | (we & ~lwrs_) | (wp & ~lrcb_));
	wire M23_8 = ~(inou & wr);
	assign w_ic = ~(M53_8 & M23_8 & i4_);
	assign w_ac = ~(M52_8 & lac_);
	assign w_ar = ~(M68_8 & warx_ & i1_ & p5_p4_);
	wire lrcb = ~lrcb_;

	// sheet 15, page 2-25
	//  * W bus to block number (NB) and interrupt mask (RM)

	assign lrz_ = ~(ur & wrz);
	wire wrsz = wrz ^ wrs;
	assign w_bar = (wrs & ur) | (~mb_ & wr) | (i3 & lipsp & lg_2);
	assign w_rm = (wrs & ur) | (wr & ~im_) | (lg_2 & lipsp & i3);
	wire ww = ~ww_;
	wire lwrs_ = lwrs$_;
	wire abx = ~((psr & wic) | (wa & rj) | (we & ~(lwrs_ & jkrb$_)) | (~lj_ & ww));
	wire lj = ~lj_;
	wire ljkrb = ~(lj_ & jkrb$_);

	// sheet 16, page 2-26
	//  * A bus control signals

	wire M8_8 = ~(ib_ & ng_);
	wire M9_6 = ~(~ir6 | zb_) ^ lj;
	wire M9_3 = ~(zb_ | ir6) ^ lj;
	wire M8_6 = ~(cb_ & oc_);
	wire M67_8 = (we & M9_6) | (w$ & M8_8);
	wire M72_8 = (M8_8 & w$) | (M8_6 & w$) | (we & M9_3) | (na_ & p3);
	wire M71_8 = ~((w$ & ls) | (psr & war));
	wire M89_4 = ~(pb | rb$_);
	wire M71_6 = ~((na_ & p3) | (w$ & M89_4));
	// FIX: M10_4 was labeled as a NAND gate, instead of NOR
	wire M10_4 = ~(ir6 | rc$_);
	wire M55_8 = ~((M10_4 & wa) | (lg_0 & i3_ex_prz));

	wire we = ~we_;
	assign baa = bla | M67_8;
	assign bab = bla | M67_8 | (ka1 & p3);
	assign bac = bla | M72_8;
	assign aa = M71_6 & i5_ & p4wp_ & M71_8;
	assign ab = M71_6 & M55_8 & abx;

	wire w$ = ~w$_;
	wire i3_ex_prz = ~i3_ex_prz_;

	// sheet 17, page 2-27
	//  * left/right byte selection signals

	wire pb_;
	ffd REG_PB(
		.s_(lrcb),
		.d(at15_),
		.c(~str1wx),
		.r_(1'b1),
		.q(pb_)
	);
	wire pb = ~pb_;
	assign wpb_ = ~pb;

	assign w_ir = (wir & ur) | pr;

	// KI bus control signals

	assign kia = ~f13_ | (psr & wrs) | i3_ex_prz;
	assign kib = ~f13_ | bin;

	// W bus control signals

	wire bw = blw_pw | (ww & ~rz_);
	assign bwa = bw;
	assign bwb = bw | (~cb_ & pb & wr);

	wire wirpsr = wir & psr;
	wire mwax_ = ~((i3_ex_prz & lg_3) | (wp & pac_) | (ri & ww) | (wac & psr));
	wire mwbx_ = ~((pat_ & wp) | (srez$ & ww));
	wire M56_8 = (wrsz & psr) | (i3_ex_prz & lg_2) | (bin & k2) | (ww & ~ki_);
	wire M73_8 = (k2 & load) | (psr & wkb) | (ir6 & wa & ~rc$_);
	assign mwa = ~wirpsr & mwax_ & ~M56_8 & f13_ & dt_w_;
	assign mwb = ~wirpsr & mwbx_ & ~M56_8 & f13_ & we_ & w$_ & p4_ & ~M73_8;
	assign mwc = ~wirpsr & dt_w_ & ~M73_8 & ~(wa & lrcb);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
