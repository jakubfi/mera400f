/*
	P-X unit (state control)

	document: 12-006368-01-8A
	unit:     P-X3-2
	pages:    2-1..2-10
*/

module px(
	input __clk, // clock for "univibrators"
	// sheet 1
	input clo,	// A62 - general clear (reset)

	input ek1,	// A32 - Enter state K1
	input ek2,	// A29 - Enter state K2
	input ep0,	// A09 - Enter state P0
	input sp0,	// A79 - Set state P0
	input ep1,	// A12 - Enter state P1
	input sp1,	// A11 - Set state P1
	input ep2,	// A21 - Enter state P2
	input ep3,	// A18 - Enter state P3
	input ep4,	// A19 - Enter state P4
	input ep5,	// A20 - Enter state P5
	input ewp,	// A34 - Enter state WP
	input ewa,	// A30 - Enter state WA
	input ewe,	// B40 - Enter state WE
	input ewr,	// A41 - Enter state WR
	input ew$,	// A36 - Enter state W&
	input ewz,	// A37 - Enter state WZ
	input ewx,	// B50 - Enter state WX
	input ewm,	// B49 - Enter state WM
	input eww,	// A46 - Enter state WW
	input si1,	// B52 - Set state I1
	output ekc_i,	// A76 - EKC*I - Enter state KC (Koniec Cyklu)

	output reg k1,	// A23 - state K1
	output reg k2,	// A27 - state K2
	output reg p0,	// A14 - state P0
	output reg p1,	// A15 - state P1
	output reg p2,	// A16 - state P2
	output reg p3,	// A17 - state P3
	output reg p4,	// A26 - state P5
	output reg p5,	// B22 - state P5
	output reg wp,	// B21 - state WP
	output reg wa,	// A25 - state WA
	output reg wz,	// A42 - state WZ
	output reg w$,	// B43 - state W&
	output reg wr,	// B42 - state WR
	output reg we,	// B45 - state WE
	output reg ww,	// A44 - state WW
	output reg wm,	// A45 - state WM
	output reg wx,	// A71 - state WX
	output reg i1,	// B59 - state I1
	output reg i2,	// A58 - state I2
	output reg i3,	// B60 - state I3
	output reg i4,	// A51 - state I4
	output reg i5,	// B61 - state I5

	input stp0,	// B48
	// sheet 3
	input laduj,				// A38
	output as2_sum_at,	// A13
	// sheet 4
	input strob_fp,
	input mode,		// B54
	input step,		// A48
	output got,		// A83
	output strob2,	// A49
	output strob1,	// A22 A90
	// sheet 5
	input przerw_z,	// A61
	input przerw,	// A24
	input lip,			// B77
	input sp,			// A67
	input lg_0,			// B67
	input pp,			// A64
	input lg_3,			// A68 - LG=3 (Licznik Grupowy)
	output arm4,		// B79
	output blw_pw,	// B85
	output zer_sp,	// A73
	output lipsp,	// A66
	// sheet 6
	input sbar$,		// A53
	input q,				// A55 - Q system flag
	input in,			// A03 - instruction IN
	input ou,			// B19 - instruction OU
	input k2fetch,	// B41
	input read_fp,	// A39
	output pn_nb,		// B94 - PN->NB
	output bp_nb,		// B93 - BP->NB
	output bar_nb,	// A75 - BAR->NB
	output barnb,		// A72
	output q_nb,		// A74 - Q->NB
	output df_,			// B92
	output w_dt,		// A81 - W->DT
	output dr_,			// A87
	output dt_w,		// A65 - DT->W
	output ar_ad,	// B63 - AR->AD
	output ds_,			// A88 - DS: "Send" Driver // NOTE: missing on original schematic
	// sheet 7
	input mcl,			// A43 - instruction MCL
	input gi,			// A47
	input ir6,			// B58
	input fi,			// A10
	input arz,			// B56
	input k2_bin_store,	// A31
	input lrz,			// B78
	output ic_ad,	// B87
	output dmcl,		// B88
	output ddt15,	// A92
	output ddt0,		// B89
	output din_,		// A91
	output dad15_i,// B81
	output dad10,	// B82
	output dad9,		// A86
	output dw_,			// A93
	output i3_ex_przer,	// A52
	output ck_rz_w,	// B91
	output zerrz,		// B85
	// sheet 8
	input sr_fp,		// B53
	input zw,			// A85 - module allowed to use the system bus (CPU) (ZezWolenie 1)
	input srez$,		// B76
	input wzi,			// A60
	input is,			// A84
	input ren_,			// B74
	input rok_,			// A89
	input efp,			// B09
	input exl,			// A78 - instruction EXL
	output zg,			// B44 - request to use the system bus (ZGłoszenie)
	output ok$,			// A80 - OK*
	output oken,		// B17
	// sheet 9
	input stop_n,		// B55
	input zga,			// B57
	input rpe_,			// A82
	input stop,		// B51
	input ir9,			// B06
	input pufa,			// B08 - any of the wide or floating point instructions
	input ir7,			// A06
	input ir8,			// A04
	output hlt_n,	// A94
	output bod,			// A77
	output b_parz,	// A56
	output b_p0,		// B84
	output awaria,	// B90
	output dad15_ir9,// B07
	output dad12,	// A08
	output dad13,	// A07
	output dad14		// A05
);

	parameter AWP_PRESENT;
	parameter STOP_ON_NOMEM;
	parameter LOW_MEM_WRITE_DENY;

	parameter STROB1_1_TICKS;
	parameter STROB1_2_TICKS;
	parameter STROB1_3_TICKS;
	parameter STROB1_4_TICKS;
	parameter STROB1_5_TICKS;
	parameter GOT_TICKS;
	parameter STROB2_TICKS;
	parameter ALARM_DLY_TICKS;
	parameter ALARM_TICKS;

	// sheet 1, page 2-1
	// * state registers

	always @ (posedge got, posedge clo) begin
		if (clo) begin
			{k1, wp, k2, wa, we, wr, w$, wz, p2, p5, p4, p3} <= 'b0;
			{i2, i3, i4, i5, wx, wm, ww} <= 'b0;
		end else begin
			{k1, wp, k2, wa, we, wr, w$, wz, p2, p5, p4, p3} <= {ek1, ewp, ek2, ewa, ewe, ewr, ew$, ewz, ep2, ep5, ep4, ep3};
			{i2, i3, i4, i5, wx, wm, ww} <= {ei2, ei3, ei4, ei5, ewx, ewm, eww};
		end
	end

	ffd REG_P1(
		.s_(~sp1),
		.d(ep1),
		.c(got),
		.r_(~clo),
		.q(p1)
	);

	ffd REG_P0(
		.s_(~clo & ~sp0),
		.d(ep0),
		.c(got),
		.r_(1'b1),
		.q(p0)
	);

	ffd REG_I1(
		.s_(~si1),
		.d(ei1),
		.c(got),
		.r_(~clo),
		.q(i1)
	);

	// sheet 3, page 2-3
	// * strob signals

	wire stp0$ = p0 & stp0;
	assign as2_sum_at = wz | p4 | we | w$;
	wire M19_6 = w$ | we | p4 | (k2 & laduj);
	wire M18_8 = p1 | k1 | k2 | i1 | i3;
	wire M20_8 = p5 | wr | ww | wm | i2 | i4 | i5;
	wire M16_8 = wz | stp0$ | p3 | wa;
	wire M15_8 = p2 | wp | wx;

  strobgen #(
    .STROB1_1_TICKS(STROB1_1_TICKS),
    .STROB1_2_TICKS(STROB1_2_TICKS),
    .STROB1_3_TICKS(STROB1_3_TICKS),
    .STROB1_4_TICKS(STROB1_4_TICKS),
    .STROB1_5_TICKS(STROB1_5_TICKS),
    .GOT_TICKS(GOT_TICKS),
    .STROB2_TICKS(STROB2_TICKS)
  ) STROBGEN(
    .__clk(__clk),
    .ok(ok),
    .zw(zw),
		.oken(oken),
    .mode(mode),
    .step(step),
    .strob_fp(strob_fp),
    .ss11(M19_6),
    .ss12(M18_8),
    .ss13(M20_8),
    .ss14(M16_8),
		.ss15(M15_8),
    .strob1(strob1),
    .strob2(strob2),
    .got(got)
  );

	wire gotst1 = ~got & ~strob1;

	// sheet 5, page 2-5
	// interrupt phase control signals

	assign arm4 = strob2 & i1 & lip;
	assign blw_pw = ~przerw_z & lg_3 & i3 & przerw;
	wire ei5 = i4 | (lip & i1);
	wire exrprzerw = przerw | exr;
	wire ei2 = i1 & przerw_z;
	wire ei4 = i3 & lg_0;
	wire i3lips = i3 & lipsp;
	assign ekc_i = (lg_3 & i3lips) | (i5 & ~lip);
	assign zer_sp = ~lip & i5;
	assign lipsp = lip | sp;
	wire ei1 = (exr | lip) & pp;
	wire ei3 = (~przerw_z & przerw & i1) | (i1 & exr) | (sp & pp) | (i2) | M25;
	wire M25 = (i5 & lip) | (~lipsp & ~lg_0 & i3) | (i3 & lipsp & ~lg_3);

	// sheet 6, page 2-6

	wire M28_8 = wr | p1 | p5 | wm | k2fbs | ww | read_fp;
	wire M30_8 = i3 | read_fp | wm | p5 | ww | k2fbs | (wr & ~inou);

	assign pn_nb = ~(barnb & ~wm) & zwzg;
	assign bp_nb = (barnb & ~wm) & zwzg;
	assign bar_nb = barnb & zwzg;
	assign barnb = (i3 & sp) | (ww & sbar$) | (sbar$ & wr) | (q & M28_8);
	assign q_nb = zwzg & ~i2;
	wire inou = in | ou;
	wire M40_8 = i2 | (in & wm) | k1;
	assign df_ = ~(M40_8 & zwzg);
	wire M49_3 = (ou & wm) ^ w;
	assign w_dt = M49_3 & zwzg;
	assign dr_ = ~(r & zwzg);
	wire r = k2fetch | p5 | i4 | i1 | i3lips | wr | p1 | read_fp;
	assign dt_w = M40_8 | r;
	assign ar_ad = M30_8 & zwzg;
	assign ds_ = ~(~(~ou | ~wm) & zwzg);

	// sheet 7, page 2-7
	// * system bus drivers

	assign ic_ad = zwzg & (k1 | p1 | (inou & wr));
	assign dmcl = zwzg & mcl & wm;
	wire wmgi = wm & gi;
	assign ddt15 = zwzg & wmgi;
	assign ddt0 = zwzg & (wmgi & ir6);
	assign din_ = ~(zwzg & wmgi);
	assign dad15_i = zwzg & (i5 | i1);
	assign dad10 = zwzg & (i1 | (i4 & exr) | i5);
	assign dad9 = zwzg & (i1 | i4 | i5);
	wire M40_12 = arz | ~q | exrprzerw;
	// A-C : 0-256 write deny
	// B-A : no write deny
	wire ABC_A = M40_12 | ~LOW_MEM_WRITE_DENY;
	wire M59_3 = w & ABC_A;
	assign dw_ = ~(zwzg & M59_3);
	wire w = i5 | i3_ex_przer | ww | k2_bin_store;
	assign i3_ex_przer = i3 & exrprzerw;
	wire rw = r ^ w;
	// FIX: -K2FBS was labeled +K2FBS
	wire k2fbs = k2_bin_store | k2fetch;
	assign ck_rz_w = ~(~(wr & fi) & ~lrz & ~blw_pw);

	wire __ck_rz_w_dly;
	dly #(.ticks(2'd2)) DLY_ZERZ( // 2 ticks @50MHz = 40ns (~25ns orig.)
		.clk(__clk),
		.i(ck_rz_w),
		.o(__ck_rz_w_dly)
	);
	wire __ck_rz_w_dly_ = ~__ck_rz_w_dly;

	assign zerrz = __ck_rz_w_dly_ & ck_rz_w & ~blw_pw;

	// sheet 8, page 2-8

	wire M12_6 = wm | i2 | wr | ww;
	wire M12_8 = i1 | i3 | i4 | i5;
	wire M17_8 = k2fbs | p1 | p5 | k1;
	wire M16_6 = M12_6 | read_fp | M12_8 | M17_8;

	wire zgi_set = ~sr_fp & ~si1 & ~sp1;
	wire zgi;
	ffjk REG_ZGI(
		.s_(zgi_set),
		.j(M16_6),
		.c_(~gotst1),
		.k(zgi),
		.r_(~clo),
		.q(zgi)
	);

	wire zwzg = zgi & zw;
	assign zg = zgi | M47_15 | (zw & oken);

	wire M46_8 = ~clo & ~(strob2 & w$ & wzi & is);
	wire M47_15;
	ffjk JK47(
		.s_(1'b1),
		.j(srez$ & wr),
		.c_(~ok$),
		.k(M47_15),
		.r_(M46_8),
		.q(M47_15)
	);
	wire ad_ad = zw & zgi & (i4 & M37_15);
	wire alarm = ~ok$ & zwzg;

	// P-X / K-L, M-N : more than one interface unit (-ROK prolonged ~10ns)
	// P-X / K-N, N-M : one interface unit
	// unused: SINGLE_INTERFACE 1'b1

	wire M57_6 = ren_ & talarm_ & rok_;
	ffjk REG_OK$(
		.s_(1'b1),
		.j(zwzg),
		.c_(M57_6),
		.k(1'b1),
		.r_(zgi),
		.q(ok$)
	);
	wire ok = ok$;
	assign oken = ~(ren_ & rok_);

	// E-F: no AWP
	wire EF = ~efp | AWP_PRESENT;
	wire M65_6 = ~EF;
	wire M37_15;
	ffjk JK37(
		.s_(1'b1),
		.j(M65_6),
		.c_(~got),
		.k(i5),
		.r_(~clo),
		.q(M37_15)
	);
	wire exr = ~(~M37_15 & EF & ~exl);

	// sheet 9, page 2-9

	wire hltn_reset = zwzg & rw;
	wire hltn_d = stop_n & zga & hltn_reset;
	wire hltn_set = awaria_set & STOP_ON_NOMEM;

	ffd REG_HLTN(
		// S-R : stop on segfault in mem block 0
		.s_(~hltn_set),
		.d(hltn_d),
		.c(strob1),
		.r_(hltn_reset),
		.q(hlt_n)
	);

	assign bod = ~(rpe_ & ren_);

	assign b_parz = strob1 & ~rpe_ & r;
	assign b_p0 = rw & talarm;

	wire awaria_set = (b_parz | b_p0) & ~bar_nb;
	ffd REG_AWARIA(
		.s_(~awaria_set),
		.d(1'b0),
		.c(~clo),
		.r_(~stop),
		.q(awaria)
	);

	wire alarm_dly;
	dly #(.ticks(ALARM_DLY_TICKS)) DLY_ALARM(
		.clk(__clk),
		.i(alarm),
		.o(alarm_dly)
	);

	wire talarm;
	univib #(.ticks(ALARM_TICKS)) VIB_ALARM(
		.clk(__clk),
		.a_(1'b0),
		.b(alarm_dly),
		.q(talarm)
	);
	wire talarm_ = ~talarm;

	assign dad15_ir9 = ad_ad & ir9;
	assign dad12 = ad_ad & pufa;
	assign dad13 = ad_ad & ir7;
	assign dad14 = ad_ad & ir8;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
