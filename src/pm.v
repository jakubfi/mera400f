/*
	P-M unit (microinstructions)

	document: 12-006368-01-8A
	unit:     P-M3-2
	pages:    2-11..2-28
*/

module pm(
	input __clk,
	// sheet 1
	input start,
	input pon,
	input work,
	input hlt_n,
	input stop,
	input clo,
	input hlt,
	input cycle,
	input irq,
	output _wait,
	output run,
	// sheet 2
	input ekc_1,
	input ekc_i,
	input ekc_2,
	input got,
	input ekc_fp,
	input clm,
	input strob2,
	output sp0,
	output przerw,
	output si1,
	output sp1,
	// sheet 3
	input k2,
	input panel_store,
	input panel_fetch,
	input panel_load,
	input panel_bin,
	input rdt9,
	input rdt11,
	input k1,
	output laduj,
	output k2_bin_store,
	output k2fetch,
	output w_rbc,
	output w_rba,
	output w_rbb,
	// sheet 4
	input p0,
	output ep0,
	output stp0,
	output ek2,
	output ek1,
	// sheet 5
	input j$,
	input bcoc$,
	input zs,
	input p2,
	input ssp$,
	input sc$,
	input md,
	input xi,
	output p,
	output mc_3,
	output mc_0,
	output xi$,
	// sheet 6
	input p4,
	input b0,
	input na,
	input c0,
	input ka2,
	input ka1,
	// sheet 7
	input p3,
	input p1,
	input nef,
	input p5,
	input i2,
	output pp,
	output ep5,
	output ep4,
	output ep3,
	output ep1,
	output ep2,
	output icp1,
	// sheet 8
	input strob1,
	input exl,
	input lipsp,
	input gr,
	input wx,
	input shc,
	// sheet 9
	input read_fp,
	input ir7,
	input inou,
	input rok,
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
	input rlp_fp,
	output rc,
	output rb,
	output ra,
	// sheet 11
	input bod,
	input ir15,
	input ir14,
	input ir13,
	input ir9,
	input ir8,
	output lk,
	// sheet 12
	input rj,
	input uj,
	input lwlwt,
	input sr,
	input lac,
	input lrcb,
	input rpc,
	input rc$,
	input ng$,
	input ls,
	input oc,
	input wa,
	input wm,
	input wz,
	input ww,
	input wr,
	input wp,
	output wls,
	// sheet 13
	input ri,
	input war,
	input wre,
	input i3,
	input s_fp,
	input sar$,
	input lar$,
	input in,
	input bs,
	input zb$,
	output w_r,
	// sheet 14
	input wic,
	input i4,
	input wac,
	input i1,
	output w_ic,
	output w_ac,
	output w_ar,
	// sheet 15
	input wrz,
	input wrs,
	input mb,
	input im,
	input lj,
	input lwrs,
	input jkrb,
	output lrz,
	output w_bar,
	output w_rm,
	// sheet 16
	input we,
	input ib,
	input ir6,
	input cb,
	input i5,
	input rb$,
	input w$,
	input i3_ex_przer,
	output baa,
	output bab,
	output bac,
	output aa,
	output ab,
	// sheet 17
	input at15,
	input srez$,
	input rz,
	input wir,
	input blw_pw,
	output wpb, // WPB - Wskaźnik Prawego Bajtu
	output bwb,
	output bwa,
	output kia,
	output kib,
	output w_ir,
	// sheet 18
	input ki,
	input dt_w,
	input f13,
	input wkb,
	output mwa,
	output mwb,
	output mwc
);

	parameter KC_TICKS;
	parameter PC_TICKS;

	// sheet 1, page 2-11
	//  * ff: START, WAIT, CYCLE

	wire start_reset = hlt_n | stop | clo;
	wire start_clk = pon & work;
	wire startq;
	ffd REG_START(
		.s_(~start),
		.d(1'b1),
		.c(~start_clk),
		.r_(~start_reset),
		.q(startq)
	);

	wire M43_3 = start_reset | si1;
	ffd REG_WAIT(
		.s_(1'b1),
		.d(hlt),
		.c(wx),
		.r_(~M43_3),
		.q(_wait)
	);

	wire __cycle_q;
	ffd REG_CYCLE(
		.s_(~cycle),
		.d(1'b0),
		.c(1'b1),
		.r_(~rescyc),
		.q(__cycle_q)
	);

	assign run = startq & ~_wait;
	wire dpr = run | __cycle_q;
	wire dprzerw = (__cycle_q | startq) & irq & ~p & mc_0;
	wire stpc = dpr | dprzerw;

	// sheet 2, page 2-12
	//  * ff: PR (pobranie rozkazu - instruction fetch)
	//  * ff: PP (przyjęcie przerwania - interrupt receive)
	//  * univib: KC (koniec cyklu - cycle end)
	//  * univib: PC (początek cyklu - cycle start)

	wire ekc = ekc_1 | ekc_i | ekc_2 | p2 | p0stpc;
	wire kc_reset = clo | pc;

	wire trig_kc;
	ffjk REG_KC(
		.s_(~ekc_fp),
		.j(ekc),
		.c_(~got),
		.k(1'b0),
		.r_(~kc_reset),
		.q(trig_kc)
	);

	wire kc;
	univib #(.ticks(KC_TICKS)) VIB_KC(
		.clk(__clk),
		.a_(1'b0),
		.b(trig_kc),
		.q(kc)
	);

	wire pc;
	univib #(.ticks(PC_TICKS)) VIB_PC(
		.clk(__clk),
		.a_(kc),
		.b(1'b1),
		.q(pc)
	);

	wire rescyc = clm | strob2 | si1;

	wire pr_;
	ffd REG_PR(
		.s_(~rescyc),
		.d(~dpr),
		.c(kc),
		.r_(1'b1),
		.q(pr_)
	);
	wire pr = ~pr_;

	assign sp0 = pr_ & ~przerw & pc;

	ffd REG_PRZERW(
		.r_(~clm),
		.d(dprzerw),
		.c(kc),
		.s_(1'b1),
		.q(przerw)
	);

	assign si1 = pc & przerw;
	assign sp1 = ~przerw & pr & pc;
	wire zerstan_ = ~kc & ~clm & ~p0;

	// sheet 3, page 2-13
	//  * ff: FETCH, STORE, LOAD, BIN (bootstrap)

	wire M30_X = strob2 & k2;

	wire bin, load, fetch, store;
	ffd REG_STORE(
		.s_(~panel_store),
		.d(1'b0),
		.c(M30_X),
		.r_(~clm),
		.q(store)
	);
	ffd REG_FETCH(
		.s_(~panel_fetch),
		.d(1'b0),
		.c(M30_X),
		.r_(~clm),
		.q(fetch)
	);
	ffd REG_LOAD(
		.s_(~panel_load),
		.d(1'b0),
		.c(M30_X),
		.r_(~clm),
		.q(load)
	);
	wire bin_d = ~(rdt9 & rdt11 & lg_0);
	wire bin_clk = strob1 & k1;
	ffd REG_BIN(
		.s_(~panel_bin),
		.d(bin_d),
		.c(~bin_clk),
		.r_(~clm),
		.q(bin)
	);

	assign laduj = load;
	wire sfl = store | fetch | load;
	// FIX: +UR was a NAND output on schematic, instead of AND
	wire ur = k2 & (load | fetch);
	wire ar_1 = k2 & ~load;
	wire k2store = k2 & store;
	assign k2_bin_store = k2 & (store | bin);
	assign k2fetch = k2 & fetch;

	wire k1s1 = k1 & strob1;
	assign w_rbc = k1s1 & lg_0;
	assign w_rba = k1s1 & lg_2;
	assign w_rbb = k1s1 & lg_1;

	// sheet 4, page 2-14
	//  * control panel state transitions
	//  * transition to P0 state

	wire psr = p0 | k2store;
	wire p0stpc = p0 & stpc;
	wire p0_k2 = p0 | k2;
	assign ep0 = (k2 | k1) & ~bin;
	assign stp0 = bin | stpc | sfl;
	assign ek2 = (p0 & sfl) | (bin & lg_3 & k1);
	assign ek1 = (p0_k2 & bin) | (k1 & bin & ~lg_3);
	wire lg_plus_1 = (bin & k2) | (k1 & rdt9);

	// sheet 5, page 2-15
	//  * P - wskaźnik przeskoku (branch indicator)
	//  * MC - premodification counter

	wire p_d = (~j$ & bcoc$) | zs;
	wire p_set = (p2 & strob1) | clm;
	wire p_clk = ssp$ & strob1 & w$;
	wire p_reset = strob1 & rok & ~inou & wm;

	wire p_;
	ffd WSK_P(
		.s_(~p_set),
		.d(~p_d),
		.c(~p_clk),
		.r_(~p_reset),
		.q(p_)
	);
	assign p = ~p_;

	wire setwp = strob1 & wx & md;
	wire reswp = p_set | (sc$ & strob2 & p1);
	wire reset_mc = reswp | (~md & p4);

	mc MC(
		.inc(setwp),
		.reset(reset_mc),
		.mc_3(mc_3),
		.mc_0(mc_0)
	);

	assign xi$ = ~p & p1 & strob2 & xi;

	// sheet 6, page 2-16
	//  * WMI - wskaźnik rozkazu dwusłowowego (2-word instruction indicator)
	//  * WPI - wskaźnik premodyfikacji (premodification indicator)
	//  * WBI - wskaźnik B-modyfikacji (B-modification indicator)

	wire wm_q;
	wire wm_d = pr & ~c0 & na;
	ffd REG_WMI(
		.s_(1'b1),
		.d(wm_d),
		.c(strob2),
		.r_(~xi$),
		.q(wm_q)
	);

	wire wb_j = pr & ~b0 & na;
	wire wb_k = (p4 & ~wpp) | p2;
	wire wb;
	ffjk REG_WBI(
		.s_(1'b1),
		.j(wb_j),
		.c_(strob1),
		.k(wb_k),
		.r_(zerstan_),
		.q(wb)
	);

	wire wpp;
	ffjk REG_WPI(
		.s_(~setwp),
		.j(1'b0),
		.c_(strob1),
		.k(p4),
		.r_(~reswp),
		.q(wpp)
	);

	wire p4wp = p4 & wpp;
	// Wskaźnik Premodyfikacji i B-modyfikacji (było: wpb)
	wire wpbmod = wb | wpp;
	wire bla = p4 & ka1ir6 & ~wpp;
	wire nair6 = na & ir6;
	wire ka12x = ~(~(na & c0) & ~ka2 & ~ka1); // does not
	wire ka1ir6 = ka1 & ir6;

	// sheet 7, page 2-17
	//  * main loop state transition signals

	wire M69_1 = ~(nair6 | wpbmod);
	wire M100_8 = ~(p3 & ka1ir6);
	wire M89_10 = ~(wm_q | ka12x);
	wire M89_13 = ~(~p1 | nef);
	wire M100_11 = ~(~p3 & ~p4);

	wire M85_6 = ~(M69_1 & M100_8 & M100_11);
	wire M85_12 = ~(M69_1 & M89_10 & M89_13);
	wire M85_8 = ~(M100_11 & nair6 & ~wpbmod);
	wire M84_6 = ~(nair6 & M89_10 & M89_13 & ~wpbmod);

	assign pp = ~(M85_12 & M85_6 & ~p5);
	assign ep5 = ~(M85_8 & M84_6);

	wire M100_6 = ~(M100_11 & wpbmod);
	wire M101_12 = ~(M89_10 & M89_13 & wpbmod);

	assign ep4 = ~(M100_8 & M100_6 & M101_12);

	assign ep3 = M89_13 & ka12x;
	assign ep1 = M89_13 & wm_q;
	assign ep2 = nef & p1;
	wire p5_p4 = p5 | p4;
	wire load_ac = p5_p4 | p1 | p3 | i2;

	wire M98_6 = wm_q & p2;

	assign icp1 = M98_6 | p1 | ic_1;

	// sheet 8, page 2-18

	wire str1wx = strob1 & wx;
	wire lolk = slg2 | (strob2 & p1 & shc) | (strob1 & wm & inou);

	wire downlk = strob1 & (wrwwgr | ((shc | inou) & wx));
	wire wrwwgr = gr & wrww;

	// sheet 9, page 2-19
	//  * group counter (licznik grupowy)

	assign arp1 = ar_1 | read_fp | i3 | wrwwgr;

	// LG clock
	wire M62_3 = strob1 & (i3 | wrwwgr | lg_plus_1);
	// LG reset
	wire M62_11 = zerstan_ & ~i1;

	// LG preload triggers
	wire slg1 = strob2 & ~gr & p1 & ~exl & ~lipsp; // "common" preload at P1
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

	wire ic_1 = wx & inou;
	wire okinou = inou & rok;

	// sheet 10, page 2-20
	//  * general register selectors

	assign rc = _7_rkod | (p3 & ir13) | (p4 & ir10) | (p0_k2 & rsc) | (rlp_fp & 1'b0) | (w & lgc);
	assign rb = _7_rkod | (p3 & ir14) | (p4 & ir11) | (p0_k2 & rsb) | (rlp_fp & lpb)  | (w & lgb);
	assign ra = _7_rkod | (p3 & ir15) | (p4 & ir12) | (p0_k2 & rsa) | (rlp_fp & lpa)  | (w & lga);

	// sheet 11, page 2-21
	//  * step counter (licznik kroków)

	wire [0:3] lk_in;

	assign lk_in[3] = (shc & ir15) | (gr & (ir9 | ir8)) | (inou & bod);
	assign lk_in[2] = (shc & ir14) | (gr) | okinou;
	assign lk_in[1] = (shc & ir13) | (gr & (~ir9 & ir8));
	assign lk_in[0] = (shc & ir6);

	lk CNT_LK(
		.cd(downlk),
		.i(lk_in),
		.l(lolk),
		.r(~zerstan_),
		.lk(lk)
	);
	
	// sheet 12, page 2-22

	wire ruj = rj | uj;
	wire pac = rj | uj | lwlwt;
	wire lwtsr = lwlwt | sr;
	wire lrcblac = lac | lrcb;
	wire pat = lrcb | sr;
	wire rjcpc = rj | rpc | rc$;
	wire lrcbngls$ = lrcb | ng$ | ls;
	wire M95_10 = ~w$ & ls;
	wire wls_ = ~(M95_10 & wls);
	assign wls = ~(wls_ & ~wa);
	wire M24_8 = ~oc & ~bs & w$;
	wire M36_3 = ~ls & we;
	wire w = ~(~wa & ~M24_8 & ~M36_3 & ~wm & ~wz & ~ww & ~wr & ~wp);
	wire wrww = wr | ww;

	// sheet 13, page 2-23
	//  * W bus to Rx microoperation

	wire warx = (p1 & ~wpp) | (~wpp & p3) | (ri & wa) | (war & ur);
	wire M50_8 = ~((ur & wre) | (lipsp & lg_1 & i3) | (lwtsr & wp) | (wa & rjcpc));
	wire M66_8 = ~((wr & sar$) | (zb$ & we) | (lar$ & w$) | (wm & in & rok));
	assign w_r = ~(M50_8 & ~s_fp & M66_8);
	// FIX: -7->RKOD was a active-high output of a 7451, which has active-low outputs
	wire _7_rkod = (w$ & bs) | (ls & we);

	// sheet 14, page 2-24
	//  * W bus to IC, AC, AR microoperations

	wire M53_8 = (lg_0 & lipsp & i3) | (ljkrb & we) | (wp & ruj) | (ur & wic);
	wire M36_6 = bs | wls;
	wire M52_8 = (M36_6 & we) | (ur & wac) | (wa & lrcbngls$) | (wr & lrcblac);
	wire M68_8 = (~wls & ls & we) | (we & lwrs) | (wp & lrcb);
	wire M23_8 = inou & wr;
	assign w_ic = M53_8 | M23_8 | i4;
	assign w_ac = M52_8 | load_ac;
	assign w_ar = M68_8 | warx | i1 | p5_p4;

	// sheet 15, page 2-25
	//  * W bus to block number (NB) and interrupt mask (RM)

	assign lrz = ur & wrz;
	wire wrsz = wrz ^ wrs;
	assign w_bar = (wrs & ur) | (mb & wr) | (i3 & lipsp & lg_2);
	assign w_rm = (wrs & ur) | (wr & im) | (lg_2 & lipsp & i3);
	wire abx = (psr & wic) | (wa & rj) | (we & ~(~lwrs & ~jkrb)) | (lj & ww);
	wire ljkrb = ~(~lj & ~jkrb); // does not (big time)

	// sheet 16, page 2-26
	//  * A bus control signals

	wire M8_8 = ib | ng$;
	wire M9_6 = (zb$ & ir6) ^ lj;
	wire M9_3 = (zb$ & ~ir6) ^ lj;
	wire M8_6 = cb | oc;
	wire M67_8 = (we & M9_6) | (w$ & M8_8);
	wire M72_8 = (M8_8 & w$) | (M8_6 & w$) | (we & M9_3) | (~na & p3);
	wire M71_8 = (w$ & ls) | (psr & war);
	wire M89_4 = ~wpb & rb$;
	wire M71_6 = (~na & p3) | (w$ & M89_4);
	// FIX: M10_4 was labeled as a NAND gate, instead of NOR
	wire M10_4 = ~ir6 & rc$;
	wire M55_8 = (M10_4 & wa) | (lg_0 & i3_ex_przer);

	assign baa = bla | M67_8;
	assign bab = bla | M67_8 | (ka1 & p3);
	assign bac = bla | M72_8;
	assign aa = M71_6 | i5 | p4wp | M71_8;
	assign ab = M71_6 | M55_8 | abx;

	// sheet 17, page 2-27
	//  * left/right byte selection signals

	// PBI - Wskaźnik Prawego Bajtu (było: pb/pb_/wpb_)
	ffd REG_PB(
		.r_(lrcb),
		.d(at15),
		.c(~str1wx),
		.s_(1'b1),
		.q(wpb)
	);

	assign w_ir = (wir & ur) | pr;

	// KI bus control signals

	assign kia = f13 | (psr & wrs) | i3_ex_przer;
	assign kib = f13 | bin;

	// W bus control signals

	wire bw = blw_pw | (ww & rz);
	assign bwa = bw;
	assign bwb = bw | (cb & wpb & wr);

	wire wirpsr = wir & psr;
	wire mwax = (i3_ex_przer & lg_3) | (wp & pac) | (ri & ww) | (wac & psr);
	wire mwbx = (pat & wp) | (srez$ & ww);
	wire M56_8 = (wrsz & psr) | (i3_ex_przer & lg_2) | (bin & k2) | (ww & ki);
	wire M73_8 = (k2 & load) | (psr & wkb) | (ir6 & wa & rc$);
	assign mwa = wirpsr | mwax | M56_8 | f13 | dt_w;
	assign mwb = wirpsr | mwbx | M56_8 | f13 | we | w$ | p4 | M73_8;
	assign mwc = wirpsr | dt_w | M73_8 | (wa & lrcb);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
