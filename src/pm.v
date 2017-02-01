/*
	MERA-400 P-M unit (microinstructions)

	document:	12-006368-01-8A
	unit:			P-M3-2
	pages:		2-11..2-28
	sheets:		19
*/

module pm(
	input clk,
	// sheet 1
	input start__,
	input pon,
	input work,
	input hlt_n,
	input stop__,
	input clo,
	input hlt,
	input cycle,
	input irq,
	output start,
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
	input rdt11,
	input k1,
	output laduj,
	output k2_bin_store,
	output k2fetch,
	output w_rbc__,
	output w_rba__,
	output w_rbb__,
	// sheet 4
	input p0,
	input rdt9,
	output ep0,
	output stp0,
	output ek2,
	output ek1,
	// sheet 5
	input js,
	input bcoc__,
	input zs,
	input p2,
	input ssp__,
	input sc__,
	input md,
	input xi,
	output p,
	output mc_3,
	output mc,
	output xi__,
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
	input lipsp__,
	input gr__,
	input wx,
	input shc,
	// sheet 9
	input read_fp,
	input ir7,
	input inou__,
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
	input uj__,
	input lwt__,
	input sr__,
	input lac__,
	input lrcb__,
	input rpc,
	input rc__,
	input ng__,
	input ls,
	input oc__,
	input wa,
	output wm,
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
	input sar__,
	input lar__,
	input in,
	input bs,
	input zb__,
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
	input lwrs__,
	input jkrb__,
	output lrz,
	output w_bar,
	output w_rm,
	// sheet 16
	input we,
	input ib,
	input ir6,
	input cb,
	input i5,
	input rb__,
	input w__,
	input i3_ex_prz,
	output baa,
	output bab,
	output bac,
	output aa,
	output ab,
	// sheet 17
	input at15,
	input srez__,
	input rz,
	input wir,
	input blw_pw,
	output wprb, // WPB - Wskaźnik Prawego Bajtu
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

	// sheet 1, page 2-11
	//  * ff: START, WAIT, CYCLE

	wire __m76 = ~hlt_n & ~stop__ & ~clo;
	wire __m44 = ~(pon & work);
	ffd __start(.s_(~start__), .r_(__m76), .d(1), .q(start), .c(__m44));

	wire __m43 = __m44 & ~si1;
	ffd __wait(.s_(1), .r_(__m43), .d(hlt), .q(_wait), .c(wx));

	wire __cycle_q;
	ffd __cycle(.s_(~cycle), .r_(~rescyc), .d(0), .q(__cycle_q), .c(1));

	assign run = start & ~_wait;
	wire dpr = ~run & ~__cycle_q;
	wire dprzerw = ~(~__cycle_q & ~start) & irq & ~p & ~mc;
	wire stpc = ~(~dpr & ~dprzerw);

	// sheet 2, page 2-12
	//  * ff: PR (pobranie rozkazu - instruction fetch)
	//  * ff: PP (przyjęcie przerwania - interrupt receive)
	//  * univib: KC (koniec cyklu - cycle end)
	//  * univib: PC (początek cyklu - cycle start)

	wire __m27 = ~(~ekc_1 & ~ekc_i & ~ekc_2 & ~p2 & ~p0stpc);
	wire __m43_11 = ~clo & ~__pc_q;
	wire __m13_11;
	ffjk __m13(.s_(~ekc_fp), .r_(__m43_11), .c_(~got), .j(__m27), .k(0), .q(__m13_11));
	wire __kc_q, __pc_q;
	// TODO: actual timings
	univib __kc(.clk(clk), .a(0), .b(__m13_11), .q(__kc_q));

	// TODO: actual timings
	univib __pc(.clk(clk), .a(__kc_q), .b(1), .q(__pc_q));

	wire rescyc = ~(~clm & ~strob2 & ~si1);
	wire pr;
	ffd __pr(.s_(~rescyc), .r_(1), .d(~dpr), .q(pr), .c(__kc_q));
	assign sp0 = ~pr & przerw & ~__kc_q;
	ffd __przerw(.s_(1), .r_(1), .d(~dprzerw), .q(przerw), .c(__kc_q));
	assign si1 = ~(__kc_q & ~przerw);
	assign sp1 = przerw & ~pr & __kc_q;
	wire zerstan = ~(~__pc_q & ~clm & ~p0);

	// sheet 3, page 2-13
	//  * ff: FETCH, STORE, LOAD, BIN (bootstrap)

	wire __m30 = strob2 & k2;
	wire __m14_12 = ~(rdt9 & rdt11 & lg_0);
	wire __m47_8 = ~(strob1 & k1);

	wire bin, load, fetch, store;

	ffd __store(.s_(~panel_store), .d(0), .c(__m30), .r_(~clm), .q(store));
	ffd __fetch(.s_(~panel_fetch), .d(0), .c(__m30), .r_(~clm), .q(fetch));
	ffd __load(.s_(~panel_load), .d(0), .c(__m30), .r_(~clm), .q(load));
	ffd __bin(.s_(~panel_bin), .d(__m14_12), .c(__m47_8), .r_(~clm), .q(bin));

	assign laduj = load;
	wire sfl = ~(~store & ~load & ~fetch);
	wire ur = ~(k2 & ~(~store & ~bin));
	// TODO: no sign on schematic
	wire ar_1 = ~(k2 & ~load);
	wire k2store = k2 & store;
	assign k2_bin_store = k2 & ~(~store & ~bin);
	assign k2fetch = k2 & fetch;

	assign w_rbc__ = k1s1 & lg_0;
	assign w_rba__ = k1s1 & lg_2;
	assign w_rbb__ = k1s1 & lg_1;
	// TODO: no sign on schematic
	wire k1s1 = strob1 & k1;

	// sheet 4, page 2-14
	//  * control panel state transitions
	//  * transition to P0 state

	// TODO: no sign on schematic
	wire psr = ~(~k2store & ~p0);
	wire p0stpc = stpc & p0;
	// TODO: no sign on schematic
	wire p0_k2 = ~(~k2 & ~p0);
	assign ep0 = ~(~k2 & ~k1) & ~bin;
	assign stp0 = ~(~bin & ~stpc & ~sfl);
	assign ek2 = ~(~(p0 & sfl) & ~(bin & lg_3 & k1));
	assign ek1 = ~(~(p0_k2 & bin) & ~(k1 & bin & ~lg_3));
	// TODO: no sign on schematic
	wire lg_plus_1 = ~((bin & k2) | (k1 & rdt9));
	// TODO: no sign on schematic, not connected anywhere
	wire zero_lg = ~rdt9 & k1s1 & rok;

	// sheet 5, page 2-15
	//  * P - wskaźnik przeskoku (branch indicator)
	//  * MC - premodification counter

	wire __m31 = ~((~js & bcoc__) | (zs));
	wire __m43_8 = ~(p2 & strob1) & ~clm;
	wire __m46 = ~(ssp__ & strob1 & w__);
	wire __m45 = ~(strob1 & rok & ~inou & wm);
	wire p_;
	ffd __p(.s_(__m43_8), .d(__m31), .c(__m46), .r_(__m45), .q(p_));
	assign p = ~p_;

	wire setwp = strob1 & wx & md;

	reg [1:0] __mc;
	always @ (posedge setwp, posedge __m77) begin
		if (__m77) __mc <= 2'd0;
		else __mc <= __mc + 1'b1;
	end

	assign mc_3 = &__mc;
	assign mc = ~|__mc;

	wire __m77 = ~(~reswp & ~(~md & p4));

	wire reswp = ~(__m43_8 & ~(sc__ & strob2 & p1));
	assign xi__ = ~p & p1 & strob2 & xi;

	// sheet 6, page 2-16
	//  * WPI - wskaźnik premodyfikacji (premodification indicator)
	//  * WBI - wskaźnik B-modyfikacji (B-modification indicator)

	wire __m86 = pr & ~c0 & na;
	ffd __wm(.s_(1), .d(__m86), .c(strob2), .r_(~xi), .q(wm));

	wire __m88 = pr & ~b0 & na;
	wire wb;
	ffjk __wb(.s_(1), .j(__m88), .c_(strob1), .k(p4), .r_(~zerstan), .q(wb));
	wire wpp;
	ffjk __wp(.s_(~setwp), .j(0), .c_(strob1), .k(p4), .r_(~reswp), .q(wpp));
	wire p4wp = p4 & wp;
	wire wpb = ~(~wb & ~wp);
	wire bla = ~(p4 & ka1ir6 & ~wp);
	wire nair6 = na & ir6;
	wire ka12x = ~(~(na & c0) & ~ka2 & ~ka1);
	wire ka1ir6 = ka1 & ir6;

	// sheet 7, page 2-17
	//  * main loop state transition signals

	wire __m69_1 = ~(~nair6 | wpb);
	wire __m100_8 = ~(p3 & ka1ir6);
	wire __m89_10 = ~(wm | ka12x);
	wire __m89_13 = ~(~p1 | nef);
	wire __m100_11 = ~(~p3 & ~p4);

	wire __m85_6 = ~(__m69_1 & __m100_8 & __m100_11);
	wire __m85_12 = ~(__m69_1 & __m89_10 & __m89_13);
	wire __m85_8 = ~(__m100_11 & ~nair6 & ~wpb);
	wire __m84_6 = ~(~nair6 & __m89_10 & __m89_13 & ~wpb);

	assign pp = ~(__m85_12 & __m85_6 & ~p5);
	assign ep5 = ~(__m85_8 & __m84_6);

	wire __m100_6 = ~(__m100_11 & wpb);
	wire __m101_12 = ~(__m89_10 & __m89_13 & wpb);

	assign ep4 = ~(__m100_8 & __m100_6 & __m101_12);

	assign ep3 = __m89_13 & ka12x;
	assign ep1 = __m89_13 & wm;
	assign ep2 = nef & p1;
	wire p5_p4 = ~(~p5 & ~p4);
	wire lac = ~p5_p4 & ~p1 & ~p3 & ~i2;

	wire __m98_6 = ~(wm & p2);

	assign icp1 = ~(__m98_6 & ~p1 & ~ic_1);

	// sheet 8, page 2-18

	wire str1wx = strob1 & wx;
	wire slg1 = p1 & ~exl & strob2 & ~(lipsp__ | gr__);
	wire slg2 = strob1 & gr__ & wx;
	wire lolk = ~(~slg2 & ~(p1 & strob2 & shc) & ~(wm & strob1 & inou));

	wire __m98_11 = ~(~shc & ~inou);
	wire __m97_8 = ~(__m98_11 & wx);
	wire __m97_3 = ~(__m97_8 & ~wrwwgr);
	wire downlk = ~(strob1 & __m97_3);
	wire wrwwgr = gr__ & wrww;

	wire gr = gr__;

	// sheet 9, page 2-19
	//  * group counter (licznik grupowy)

	// TODO: no sign on schematic
	assign arp1 = ~(ar_1 & ~read_fp & ~i3 & ~wrwwgr);

	wire lga, lgb, lgc;

	wire __m62_3 = ~(~wrwwgr & ~i3 & lg_plus_1) & strob1;
	wire __m62_11 = ~zerstan & ~i1;
	wire __m78_8 = ~((slg2) | (slg1 & ir9) );
	wire __m94_6 = ~(slg1 & ir8);
	wire __m78_6 = ~((slg2 & (ir8 & ir9)) | (slg1 & ir7));
	wire __m80_12 = lgb & lga & gr;

	ffjk __lga(.s_(__m78_8), .j(1), .c_(__m62_3), .k(1), .r_(__m62_11), .q(lga));
	ffjk __lgb(.s_(__m94_6), .j(lga), .c_(__m62_3), .k(lga), .r_(__m62_11), .q(lgb));
	ffjk __lgc(.s_(__m78_6), .j(__m80_12), .c_(__m62_3), .k(__m80_12), .r_(__m62_11), .q(lgc));

	assign lg_3 = lgb & lga;
	wire lg_2 = lgb & ~lga;
	wire lg_1 = lga & ~lgb;
	assign lg_0 = ~lga & ~lgb;

	wire ic_1 = wx & inou;
	wire inou = inou__;
	wire okinou = inou & rok;

	// sheet 10, page 2-20
	//  * general register selectors

	//rc = (rsc & p0_k2) | (ir10 & p4) | (ir13 & p3) | (_7_rkod) | (0 & rlp_fp) | (lgc & w);
	//rb = (ir14 & p3) | (ir11 & p4) | (rsb & p0_k2) | (_7_rkod) | (rlp_fp & lpb) | (lgb & w);
	//ra = (_7_rkod) | (ir15 & p3) | (p4 & ir12) | (p0_k2 & rsa) | (w & lga) | (rlp_fp & lpa);

	assign rc = (lgc & w) | (_7_rkod) | (p3 & ir13) | (p4 & ir10) | (rsc & p0_k2);
	assign rb = (lgb & w) | (_7_rkod) | (p3 & ir14) | (p4 & ir11) | (rsb & p0_k2) | (rlp_fp & lpb);
	assign ra = (lga & w) | (_7_rkod) | (p3 & ir15) | (p4 & ir12) | (rsa & p0_k2) | (rlp_fp & lpa);

	// sheet 11, page 2-21
	//  * step counter (licznik kroków)

	wire lk0, lk1, lk2, lk3;

	wire __m64_8 = (ir9 & gr) | (ir8 & gr) | (inou & bod) | (ir15 & shc);
	wire __m65_6 = ~((shc & ir14) | gr);
	wire __m94_8 = ~(__m65_6 & ~okinou);
	wire __m49_8 = (shc & ir13) | (gr & (~ir9 & ir8));
	wire __m85_11 = shc & ir6;

	counter4 __lk(
		.cd(~downlk),
		.i({__m64_8, __m94_8, __m49_8, __m85_11}),
		.l(lolk),
		.r(zerstan),
		.o({lk0, lk1, lk2, lk3})
	);
	
	assign lk = ~(~(lk0 | lk1) & ~(lk2 | lk3));

	// sheet 12, page 2-22

	wire ruj = ~(~rj & ~uj__);
	wire pac = (~uj__ & ~rj & ~lwt__);
	wire lwtsr = ~(~lac__ & ~lrcb__);
	wire lrcblac = ~(~lac__ & ~lrcb__);
	wire pat = ~lrcb__ & ~sr__;
	wire rjcpc = ~(~rj & ~rpc & ~rc__);
	wire lrcbngls__ = ~(~lrcb__ & ~ng__ & ~ls);

	//wire __m95_10 = ~(~wa | ~ls);
	reg __wls;
	assign wls = __wls;
	wire __wls_1 = wa & ls;
	always @ (__wls_1) begin
		if (__wls_1) __wls <= 1'b1;
		else __wls <= 1'b0;
	end

	wire __m24_8 = ~(~oc__ & ~bs & w__);
	wire __m36_3 = ~(~ls & we);
	wire w = ~(~wa & __m24_8 & __m36_3 & ~wm & ~wz & ~ww & ~wr & ~wp);
	wire wrww = ~(~wr & ~ww);

	// sheet 13, page 2-23
	//  * W bus to Rx microoperation

	wire warx = (p1 & ~wpp) | (~wpp & p3) | (ri & wa) | (war & ur);
	wire __m50 = (ur & wre) | (lipsp__ & lg_1 & i3) | (lwtsr & wp) | (wa & rjcpc);
	wire __m66 = (wr & sar__) | (zb__ & we) | (lar__ & w__) | (wm & in & rok);
	assign w_r = ~(~__m50 & ~s_fp & ~__m66);
	wire _7_rkod = (w__ & bs) | (ls & we);

	// sheet 14, page 2-24
	//  * W bus to IC, AC, AR microoperations

	wire __m53 = (lg_0 & lipsp__ & i3) | (ljkrb & we) | (wp & ruj) | (ur & wic);
	wire __m36 = ~(~bs & ~wls);
	wire __m52 = (__m36 & we) | (ur & wac) | (wa & lrcbngls__) | (wr & lrcblac);
	wire __m68 = (~wls & ls & we) | (we & lwrs__) | (wp & lrcb__);
	wire __m23 = inou & wr;
	assign w_ic = ~(~__m53 & ~__m23 & ~i4);
	assign w_ac = ~(~__m52 & ~lac);
	assign w_ar = ~(~__m68 & ~warx & ~i1 & ~p5_p4);

	// sheet 15, page 2-25
	//  * W bus to block number (NB) and interrupt mask (RM)

	assign lrz = ur & wrz;
	wire wrsz = wrz & wrs;
	assign w_bar = (wrs & ur) | (mb & wr) | (i3 & lipsp__ & lg_2);
	assign w_rm = (wrs & ur) | (wr & im) | (lg_2 & lipsp__ & i3);
	wire abx = ~((psr & wic) | (wa & rj) | (we & lwrs__) | (lj & ww));
	wire ljkrb = ~(~lj & ~jkrb__);

	// sheet 16, page 2-26
	//  * A bus control signals

	wire __m8_8 = ~(~ib & ~ng__);
	wire __m9_6 = lj ^ ~(~zb__ & ~ir6);
	wire __m9_3 = lj ^ ~(~zb__ & ir6);
	wire __m8_6 = ~(~cb & ~oc__);
	wire __m67 = ~((we & __m9_6) | (w__ & __m8_8));
	wire __m72 = ~((__m8_8 & w__) | (__m8_6 & w__) | (we & __m9_3) | (~na & p3));
	wire __m71_8 = ~((w__ & ls) | (psr & war));
	wire __m89_4 = ~(pb | ~rb__);
	wire __m71_6 = ~((na & p3) | (w__ & __m89_4));
	wire __m10_4 = ~(ir6 & ~rc);
	wire __m55_8 = ~((__m10_4 & wa) | (lg_0 & i3_ex_prz));

	assign baa = ~(__m67 & bla);
	assign bab = ~(__m67 & bla & ~(ka1 & p3));
	assign bac = ~(bla & __m72);
	assign aa = ~i5 & ~p4wp & __m71_8 & __m71_6;
	assign ab = __m71_6 & __m55_8 & abx;

	// sheet 17, page 2-27
	//  * W bus control signals
	//  * KI bus control signals
	//  * left/right byte selection signals

	wire __m10 = ~(~cb & pb);

	wire pb_;
	wire pb = ~pb_;
	ffd __pb(.s_(lrcb__), .d(at15), .c(~str1wx), .r_(1), .q(pb_));
	assign wprb = pb;
	wire mwax = (i3_ex_prz & lg_3) | (wp & ~pac) | (ri & ww) | (wac & psr);
	wire mwbx = (~pat & wp) | (srez__ & ww);
	wire __m23_3 = ~(ww & rz);
	assign bwb = ~(~(__m10 & wr) & ~blw_pw & __m23_3);
	assign bwa = ~(__m23_3 & ~blw_pw);
	assign kia = ~(~(psr & wrs) & i3_ex_prz & f13);
	assign kib = ~(~(wir & ur) & ~bin);
	assign w_ir = ~(~(wir & ur) & ~pr);
	wire wirpsr = psr & wir;

	// sheet 18, page 2-28
	//  * W bus control signals

	wire __m56 = ~((wrsz & psr) | (i3_ex_prz & lg_2) | (bin & k2) | (ww & ki));
	wire __m73 = ~((k2 & load) | (psr & wkb) | (ir6 & wa & rc));
	assign mwa = __m56 & ~mwax & ~dt_w & ~wirpsr & f13;
	assign mwb = __m56 & ~f13 & ~wirpsr & ~mwbx & ~we & ~w__ & ~p4 & __m73;
	assign mwc = ~wirpsr & ~dt_w & __m73 & ~(wa & lrcb__);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
