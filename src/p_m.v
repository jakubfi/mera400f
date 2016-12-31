/*
	MERA-400 P-M unit (microinstructions)

	document:	12-006368-01-8A
	unit:			P-M3-2
	pages:		2-11..2-28
	sheets:		19
*/

module p_m(
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
	ffd __start(.s(~start__), .r(__m76), .d(1), .q(start), .clk(_m44));

	wire __m43 = __m44 & ~si1;
	ffd __wait(.s(0), .r(__m43), .d(hlt), .q(_wait), .clk(wx));

	wire __cycle_q;
	ffd __cycle(.s(cycle), .r(rescyc), .d(0), .q(__cycle_q), .clk(1));

	assign run = start & ~_wait;
	wire dpr = ~run & ~__cycle_q;
	wire dprzerw = ~(~__cycle_q & ~start) & irq & ~p & ~mc;
	wire stpc = ~(~dpr & ~dprzerw);

	// sheet 2
	//  * ff: PR (pobranie rozkazu - instruction fetch)
	//  * ff: PP (przyjęcie przerwania - interrupt receive)
	//  * univib: KC (koniec cyklu - cycle end)
	//  * univib: PC (początek cyklu - cycle start)

	wire __m27 = ~(~ekc_1 & ~ekc_i & ~ekc_2 & ~p2 & ~p0stpc);
	wire __m43_11 = ~clo & ~__pc_q;
	wire __m13_11;
	ffjk __m13(.s(ekc_fp), .r(__m43_11), .clk(got), .j(~__m27), .k(0), .q(__m13_11));
	wire __kc_q;
	// TODO: actual timings
	univib __kc(.clk(clk), .a(0), .b(__m13_11), .q(__kc_q));

	// TODO: actual timings
	univib __pc(.clk(clk), .a(__kc_q), .b(1), .q(__pc_q));

	wire rescyc = ~clm & ~strob2 & ~si1;

	ffd __pr(.s(~rescyc), .r(0), .d(~dpr), .q(pr), .clk(__kc_q));
	ffd __przerw(.s(0), .r(0), .d(~drzperw), .q(przerw), .clk(__kc_q));

	assign si1 = ~(__kc_q & ~przerw);
	assign sp1 = przerw & ~pr & __kc_q;
	wire zerstan = ~(~__pc_q & ~clm & ~p0);

	// sheet 3, page 2-12
	//  * ff: FETCH, STORE, LOAD, BIN (bootstrap)

	wire lg_1, lg_2;

	wire __m30 = strob2 & k2;

	wire bin, load, fetch, store;

	ffd __store(.s(panel_store), .d(0), .clk(__m30), .r(clm), .q(store));
	ffd __fetch(.s(panel_fetch), .d(0), .clk(__m30), .r(clm), .q(fetch));
	ffd __load(.s(panel_load), .d(0), .clk(__m30), .r(clm), .q(load));
	ffd __bin(.s(panel_bin), .d(), .clk(), .r(clm), .q(bin));

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

	// sheet 4, page 2-13
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
	// TODO: no sign on schematic
	wire zero_lg = ~rdt9 & k1s1 & rok;

	// sheet 5, page 2-14
	//  * P - wskaźnik przeskoku (branch indicator)
	//  * MC - premodification counter

	wire __m31 = ~((~js & bcoc__) | (zs));
	wire __m43_8 = ~(p2 & strob1) & ~clm;
	wire p_;
	ffd __p(.s(~__m43_8), .d(__m31), .clk(__m46), .r(__m45), .q(p_));
	assign p = ~p_;

	wire setwp = strob1 & wx & md;

	reg [1:0] __mc;
	always @ (posedge setwp, posedge __m77) begin
		if (__m77) __mc <= 2'b0;
		else __mc <= __mc + 1'b1;
	end

	assign mc_3 = &__mc;
	assign mc = ~|__mc;

	wire __m77 = ~(~reswd & ~(~md & p4));

	wire reswd = ~(__m43_8 & ~(sc__ & strob2 & p1));
	assign xi__ = ~p & p1 & strob2 & xi;

	// sheet 6, page 2-15
	//  * WPI - wskaźnik premodyfikacji (premodification indicator)
	//  * WBI - wskaźnik B-modyfikacji (B-modification indicator)

	wire __m86 = pr & ~c0 & na;
	ffd __wm(.s(0), .d(__m86), .clk(strob2), .r(xi), .q(wm));

	wire __m88 = pr & ~b0 & na;
	ffjk __wb(.s(0), .j(__m88), .clk(~strob1), .k(p4), .r(zerstan), .q(wb));
	ffjk __wp(.s(setwp), .j(0), .clk(~strob1), .k(p4), .r(reswp), .q());
	wire p4wp = p4 & wp;
	wire wpb = ~(~wb & ~wp);
	wire bla = ~(p4 & ka1ir6 & ~wp);
	wire nair6 = na & ir6;
	wire ka12x = ~(~(na & c0) & ~ka2 & ~ka1);
	wire ka1ir6 = ka1 & ir6;

	// sheet 7, page 2-16
	//  * main loop state transition signals

	wire ic_1;

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

	assign ipc1 = ~(__m98_6 & ~p1 & ~ic_1);

	// sheet 8, page 2-17

	// sheet 9, page 2-18
	//  * group counter (licznik grupowy)

	// sheet 10, page 2-19
	//  * general register selectors

	// sheet 11, page 2-20
	//  * step counter (licznik kroków)

	// sheet 12, page 2-21

	// sheet 13, page 2-22
	//  * W bus to Rx microoperation

	// sheet 14, page 2-23
	//  * W bus to IC, AC, AR microoperations

	// sheet 15, page 2-24
	//  * W bus to block number (NB) and interrupt mask (RM)

	// sheet 16, page 2-25
	//  * A bus control signals

	// sheet 17, page 2-26
	//  * W bus control signals
	//  * KI bus control signals
	//  * left/right byte selection signals

	// sheet 18, page 2-27
	//  * W bus control signals

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
