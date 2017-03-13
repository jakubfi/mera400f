/*
	MERA-400 P-X unit (state control)

	document:	12-006368-01-8A
	unit:			P-X3-2
	pages:		2-1..2-10
	sheets:		10
*/

module px(
	input __clk, // clock for "univibrators"
	// sheet 1
	input ek1,	// A32 - Enter state K1
	input ewp,	// A34 - Enter state WP
	input ek2,	// A29 - Enter state K2
	input ewa,	// A30 - Enter state WA
	input clo_,	// A62 - general clear (reset)
	input ewe,	// B40 - Enter state WE
	input ewr,	// A41 - Enter state WR
	input ew$,	// A36 - Enter state W&
	input ewz,	// A37 - Enter state WZ
	output k1_,	// A23 - state K1
	output wp_,	// B21 - state WP
	output k2_,	// A27 - state K2
	output wa_,	// A25 - state WA
	output wz_,	// A42 - state WZ
	output w$_,	// B43 - state W&
	output wr_,	// B42 - state WR
	output we_,	// B45 - state WE
	input sp1_,	// A11 - Set state P1
	input ep1,	// A12 - Enter state P1
	input sp0_,	// A79 - Set state P0
	input ep0,	// A09 - Enter state P0
	input stp0,	// B48
	input ep2,	// A21 - Enter state P2
	input ep5,	// A20 - Enter state P5
	input ep4,	// A19 - Enter state P4
	input ep3,	// A18 - Enter state P3
	output p1_,	// A15 - state P1
	output p0_,	// A14 - state P0
	output p2_,	// A16 - state P2
	output p5_,	// B22 - state P5
	output p4_,	// A26 - state P5
	output p3_,	// A17 - state P3
	// sheet 2
	input si1_,	// B52 - Set state I1
	input ewx,	// B50 - Enter state WX
	input ewm,	// B49 - Enter state WM
	input eww,	// A46 - Enter state WW
	output i5_,	// B61 - state I5
	output i4_,	// A51 - state I4
	output i3_,	// B60 - state I3
	output i2_,	// A58 - state I2
	output i1_,	// B59 - state I1
	output ww_,	// A44 - state WW
	output wm_,	// A45 - state WM
	output wx_,	// A71 - state WX
	// sheet 3
	input laduj,				// A38
	output as2_sum_at,	// A13
	// sheet 4
	input strob_fp_,// A28
	input mode,		// B54
	input step_,		// A48
	output got_,		// A83
	output strob2_,	// A49
	output strob1_,	// A22 A90
	output strob1,	// A22 A90
	// sheet 5
	input przerw_z,	// A61
	input przerw_,	// A24
	input lip_,			// B77
	input sp_,			// A67
	input lg_0,			// B67
	input pp_,			// A64
	input lg_3,			// A68 - LG=3 (Licznik Grupowy)
	output arm4_,		// B79
	output blw_pw_,	// B85
	output ekc_i_,	// A76 - EKC*I - Enter state KC (Koniec Cyklu)
	output zer_sp_,	// A73
	output lipsp$_,	// A66
	// sheet 6
	input sbar$,		// A53
	input q,				// A55 - Q system flag
	input in_,			// A03 - instruction IN
	input ou_,			// B19 - instruction OU
	input k2fetch_,	// B41
	input red_fp_,	// A39
	output pn_nb,		// B94 - PN->NB
	output bp_nb,		// B93 - BP->NB
	output bar_nb_,	// A75 - BAR->NB
	output barnb,		// A72
	output q_nb,		// A74 - Q->NB
	output df_,			// B92
	output w_dt_,		// A81 - W->DT
	output dr_,			// A87
	output dt_w_,		// A65 - DT->W
	output ar_ad_,	// B63 - AR->AD
	output ds_,			// A88 - DS: "Send" Driver // NOTE: missing on original schematic
	// sheet 7
	input mcl_,			// A43 - instruction MCL
	input gi_,			// A47
	input ir6,			// B58
	input fi_,			// A10
	input arz,			// B56
	input k2_bin_store_,	// A31
	input lrz_,			// B78
	output ic_ad_,	// B87
	output dmcl_,		// B88
	output ddt15_,	// A92
	output ddt0_,		// B89
	output din_,		// A91
	output dad15_i_,// B81
	output dad10_,	// B82
	output dad9_,		// A86
	output dw_,			// A93
	output i3_ex_przer_,	// A52
	output ck_rz_w,	// B91
	output zerz_,		// B85
	// sheet 8
	input sr_fp_,		// B53
	input zw1_,			// A85 - module 1 allowed to use the system bus (CPU) (ZezWolenie 1)
	input srez$,		// B76
	input wzi,			// A60
	input is_,			// A84
	input ren_,			// B74
	input rok_,			// A89
	input efp_,			// B09
	input exl_,			// A78 - instruction EXL
	output zg,			// B44 - request to use the system bus (ZGłoszenie)
	output ok$,			// A80 - OK*
	// sheet 9
	input stop_n,		// B55
	input zga,			// B57
	input rpe_,			// A82
	input stop_,		// B51
	input ir9,			// B06
	input pufa,			// B08 - any of the wide or floating point instructions
	input ir7,			// A06
	input ir8,			// A04
	output hlt_n_,	// A94
	output bod,			// A77
	output b_parz_,	// A56
	output b_p0_,		// B84
	output awaria_,	// B90
	output zz1_,		// A51 - module 1 in this rack is present (CPU)
	output dad15_ir9_,// B07
	output dad12_,	// A08
	output dad13_,	// A07
	output dad14_		// A05
);

	parameter AWP_PRESENT = 1'b1;
	parameter STOP_ON_NOMEM = 1'b1;
	parameter LOW_MEM_WRITE_DENY = 1'b0;

	// sheet 1, page 2-1
	// * state registers

	reg k1, wp, k2, wa, we, wr, w$, wz, p2, p5, p4, p3;
	always @ (posedge got, negedge clo_) begin
		if (~clo_) {k1, wp, k2, wa, we, wr, w$, wz, p2, p5, p4, p3} <= 'b0;
		else {k1, wp, k2, wa, we, wr, w$, wz, p2, p5, p4, p3}
				<= {ek1, ewp, ek2, ewa, ewe, ewr, ew$, ewz, ep2, ep5, ep4, ep3};
	end
	assign {k1_, wp_, k2_, wa_, we_, wr_, w$_, wz_, p2_, p5_, p4_, p3_} = ~{k1, wp, k2, wa, we, wr, w$, wz, p2, p5, p4, p3};

	wire p1;
	ffd REG_P1(
		.s_(sp1_),
		.d(ep1),
		.c(got),
		.r_(clo_),
		.q(p1)
	);
	assign p1_ = ~p1;

	wire p0;
	ffd REG_P0(
		.s_(clo_ & sp0_),
		.d(ep0),
		.c(got),
		.r_(1'b1),
		.q(p0)
	);
	assign p0_ = ~p0;

	wire stp0$_ = ~(p0 & stp0);

	// sheet 2, page 2-2
	// * state registers

	reg i2, i3, i4, i5, wx, wm, ww;
	always @ (posedge got, negedge clo_) begin
		if (~clo_) {i2, i3, i4, i5, wx, wm, ww} <= 'b0;
		else {i2, i3, i4, i5, wx, wm, ww} <= {ei2, ei3, ei4, ei5, ewx, ewm, eww};
	end
	assign {i2_, i3_, i4_, i5_, wx_, wm_, ww_} = ~{i2, i3, i4, i5, wx, wm, ww};

	wire i1;
	ffd REG_I1(
		.s_(si1_),
		.d(ei1),
		.c(got),
		.r_(clo_),
		.q(i1)
	);
	assign i1_ = ~i1;

	// sheet 3, page 2-3
	// * strob signals

	assign as2_sum_at = ~(wz_ & p4_ & we_ & w$_);
	wire M19_6 = ~(w$_ & we_ & p4_ & ~(k2 & laduj));
	wire M18_8 = ~(p1_ & k1_ & k2_ & i1_ & i3_);
	wire M20_8 = ~(p5_ & wr_ & ww_ & wm_ & i2_ & i4_ & i5_);
	wire M16_8 = ~(wz_ & stp0$_ & p3_ & wa_);
	wire M15_8 = ~(p2_ & wp_ & wx_);

	wire sgot = ~(M19_6 | M18_8);

	wire STROB1_1, STROB1_2, STROB1_3, STROB1_4, STROB1_5;
	wire STROB1_1_, STROB1_2_, STROB1_3_, STROB1_4_, STROB1_5_;
	assign {STROB1_1_, STROB1_2_, STROB1_3_, STROB1_4_, STROB1_5_} = ~{STROB1_1, STROB1_2, STROB1_3, STROB1_4, STROB1_5};
	univib #(.ticks(3'd5)) VIB_STROB1_1( // 5 ticks = 100ns @ 50MHz (80-130ns)
		.clk(__clk),
		.a_(got$),
		.b(M19_6),
		.q(STROB1_1)
	);
	univib #(.ticks(3'd6)) VIB_STROB1_2( // 6 ticks = 120ns @ 50MHz (110-190ns)
		.clk(__clk),
		.a_(got$),
		.b(M18_8 & ok),
		.q(STROB1_2)
	);
	univib #(.ticks(3'd5)) VIB_STROB1_3( // 5 ticks = 100ns @ 50MHz (80-130ns)
		.clk(__clk),
		.a_(got$),
		.b(M20_8 & ok),
		.q(STROB1_3)
	);
	univib #(.ticks(3'd5)) VIB_STROB1_4( // 5 ticks = 100ns @ 50MHz (80-130ns)
		.clk(__clk),
		.a_(got$),
		.b(M16_8),
		.q(STROB1_4)
	);
	univib #(.ticks(3'd5)) VIB_STROB1_5( // 5 ticks = 100ns @ 50MHz (80-130ns)
		.clk(__clk),
		.a_(got$),
		.b(M15_8),
		.q(STROB1_5)
	);

	wire st56_ = STROB1_1_ & STROB1_2_;
	wire st812_ = STROB1_3_ & STROB1_4_ & STROB1_5_;
	wire sts = ~(st56_ & st812_);

	// sheet 4, page 2-4
	// * got, strob2, step register

	// NOTE: 33pF cap to ground on M15_6
	wire M15_12 = ~(M15_6 & zw & oken);
	wire M52_6 = M15_12 & M53_6;
	wire M53_6 = ~(sgot & M21_5);
	wire M15_6 = ~(M52_6 & st812_ & strob2_);

	wire got$;
	univib #(.ticks(3'd5)) VIB_GOT( // 5 ticks = 100ns @ 50MHz (80-130ns)
		.clk(__clk),
		.a_(M15_6),
		.b(1'b1),
		.q(got$)
	);
	assign got_ = ~got$;
	wire got = got$;

	wire M53_11 = ~(M21_5 & ~sgot);
	wire M53_8 = ~(M53_11 & st56_);

	wire strob2;
	univib #(.ticks(3'd6)) VIB_STROB2( // 6 ticks = 120ns @ 50MHz (110-190ns)
		.clk(__clk),
		.a_(M53_8),
		.b(1'b1),
		.q(strob2)
	);
	assign strob2_ = ~strob2;

	wire gotst1_ = ~(got_ & strob1_);

	// FIX: +MODE was labeled -MODE
	wire M21_5;
	ffd REG_STEP(
		.s_(~(mode & sts)),
		.d(1'b0),
		.c(step_),
		.r_(mode),
		.q(M21_5)
	);

	// NOTE: Workaround for Error (35000) 
	// https://www.altera.com/support/support-resources/knowledge-base/solutions/rd06192013_268.html
	wire strob1_int_ = st812_ & st56_ & strob_fp_ & ~M21_5;
	assign strob1_ = strob1_int_;
	assign strob1 = ~strob1_;

	// sheet 5, page 2-5
	// interrupt phase control signals

	assign arm4_ = ~(strob2 & i2 & ~lip_);
	assign blw_pw_ = ~(~przerw_z & lg_3 & i3 & ~przerw_);
	// FIX: -I4 was +I4
	wire ei5 = ~(i4_ & ~(~lip_ & i1));
	wire exrprzerw = ~(przerw_ & exr_);
	wire ei2 = i1 & przerw_z;
	wire exr = ~exr_;
	wire ei4 = i3 & lg_0;
	wire i3lips_ = ~(lipsp$ & i3);
	// FIX: -EKC*I was labeled -EKC*1
	assign ekc_i_ = ~((lg_3 & ~i3lips_) | (i5 & lip_));
	assign zer_sp_ = ~(lip_ & i5);
	wire lipsp$ = ~(lip_ & sp_);
	assign lipsp$_ = ~lipsp$;
	wire ei1 = ~(exr_ & lip_) & ~pp_;
	wire sp = ~sp_;
	wire ei3 = (~przerw_z & ~przerw_ & i1) | (i1 & ~exr_) | (sp & ~pp_) | (i2) | M25;
	wire M25 = (i5 & ~lip_) | (lipsp$_ & ~lg_0 & i3) | (i3 & lipsp$ & ~lg_3);

	// sheet 6, page 2-6

	wire read_fp_;
	assign read_fp_ = red_fp_;

	wire M28_8 = ~(wr_ & p1_ & p5_ & wm_ & k2fbs_ & ww_ & red_fp_);
	// FIX: -I3 was missing on input of M30
	wire M30_8 = ~(i3_ & red_fp_ & wm_ & p5_ & ww_ & k2fbs_ & ~(wr & ~inou));

	assign pn_nb = ~(barnb & wm_) & zwzg;
	assign bp_nb = (barnb & wm_) & zwzg;
	assign bar_nb_ = ~(barnb & zwzg);
	assign barnb = (i3 & sp) | (ww & sbar$) | (sbar$ & wr) | (q & M28_8);
	assign q_nb = zwzg & i2_;
	wire inou = ~(in_ & ou_);
	wire M40_8 = ~(i2_ & (in_ | wm_) & k1_);
	assign df_ = ~(M40_8 & zwzg);
	wire M49_3 = ~(ou_ | wm_) ^ w;
	assign w_dt_ = ~(M49_3 & zwzg);
	assign dr_ = ~(r & zwzg);
	// FIX: -K2FETCH was labeled +K2FETCH
	wire r = ~(k2fetch_ & p5_ & i4_ & i1_ & i3lips_ & wr_ & p1_ & red_fp_);
	assign dt_w_ = ~(M40_8 | r);
	assign ar_ad_ = ~(M30_8 & zwzg);
	// FIX: -DS was missing on schematic (together with its driver gate)
	assign ds_ = ~(~(ou_ | wm_) & zwzg);

	// sheet 7, page 2-7
	// * system bus drivers

	assign ic_ad_ = ~(zwzg & ~(k1_ & p1_ & ~(inou & wr)));
	assign dmcl_ = ~(zwzg & ~(mcl_ | wm_));
	wire M44_1 = ~(wm_ | gi_);
	assign ddt15_ = ~(zwzg & M44_1);
	assign ddt0_ = ~(zwzg & (M44_1 & ir6));
	assign din_ = ~(zwzg & M44_1);
	assign dad15_i_ = ~(zwzg & ~(i5_ & i1_));
	assign dad10_ = ~(zwzg & ~(i1_ & ~(i4 & exr) & i5_));
	assign dad9_ = ~(zwzg & ~(i1_ & i4_ & i5_));
	wire M40_12 = ~(~arz & q & ~exrprzerw);
	// A-C : 0-256 write deny
	// B-A : no write deny
	wire ABC_A = M40_12 | ~LOW_MEM_WRITE_DENY;
	wire M59_3 = w & ABC_A;
	assign dw_ = ~(zwzg & M59_3);
	wire w = ~(i5_ & i3_ex_przer_ & ww_ & k2_bin_store_);
	// FIX: -I3/EX+PRZERW/ was labeled +I3/EX+PRZERW/
	assign i3_ex_przer_ = ~(exrprzerw & i3);
	wire rw = r ^ w;
	// FIX: -K2FBS was labeled +K2FBS
	wire k2fbs_ = k2_bin_store_ & k2fetch_;
	assign ck_rz_w = ~(~(wr & ~fi_) & lrz_ & blw_pw_);

	wire __ck_rz_w_dly;
	dly #(.ticks(2'd2)) DLY_ZERZ( // 2 ticks @50MHz = 40ns (~25ns orig.)
		.clk(__clk),
		.i(ck_rz_w),
		.o(__ck_rz_w_dly)
	);
	wire __ck_rz_w_dly_ = ~__ck_rz_w_dly;

	assign zerz_ = ~(__ck_rz_w_dly_ & ck_rz_w & blw_pw_);

	// sheet 8, page 2-8

	wire M64_8 = sr_fp_ & si1_ & sp1_;
	wire M12_6 = wm_ & i2_ & wr_ & ww_;
	wire M12_8 = i1_ & i3_ & i4_ & i5_;
	wire M17_8 = k2fbs_ & p1_ & p5_ & k1_;
	wire M16_6 = ~(M12_6 & read_fp_ & M12_8 & M17_8);

	wire zgi;
	ffjk REG_ZGI(
		.s_(M64_8),
		.j(M16_6),
		.c_(gotst1_),
		.k(zgi),
		.r_(clo_),
		.q(zgi)
	);
	wire zgi_ = ~zgi;

	wire zwzg = ~(zgi_ | zw1_);
	assign zg = ~(zgi_ & ~M47_15 & ~(zw & oken));
	wire zw = ~zw1_;

	wire M46_8 = clo_ & ~(strob2 & w$ & wzi & ~is_);
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
	wire oken = ~(ren_ & rok_);

	// E-F: no AWP
	wire EF = efp_ | ~AWP_PRESENT;
	wire M65_6 = ~EF;
	wire M37_15;
	ffjk JK37(
		.s_(1'b1),
		.j(M65_6),
		.c_(got_),
		.k(i5),
		.r_(clo_),
		.q(M37_15)
	);
	wire exr_ = ~M37_15 & EF & exl_;

	// sheet 9, page 2-9

	wire M59_11 = zwzg & rw;
	wire M64_5 = stop_n & zga & M59_11;

	wire hlt_n;
	ffd REG_HLTN(
		// S-R : stop on segfault in mem block 0
		.s_(M55_11 | ~STOP_ON_NOMEM),
		.d(M64_5),
		.c(strob1),
		.r_(M59_11),
		.q(hlt_n)
	);
	assign hlt_n_ = ~hlt_n;

	assign bod = ~(rpe_ & ren_);

	assign b_parz_ = ~(strob1 & ~rpe_ & r);
	assign b_p0_ = ~(rw & talarm);

	wire M55_11 = ~(~(b_parz_ & b_p0_) & bar_nb_);
	wire awaria;
	ffd REG_AWARIA(
		.s_(M55_11),
		.d(1'b0),
		.c(clo_),
		.r_(stop_),
		.q(awaria)
	);
	assign awaria_ = ~awaria;

	assign zz1_ = 1'b0;

	wire alarm_dly;
	dly #(.ticks(5'd25)) DLY_ALARM( // 250 ticks @ 50MHz = 5us (>=5us orig., ~10us on schematic)
		.clk(__clk),
		.i(alarm),
		.o(alarm_dly)
	);

	wire talarm;
	univib #(.ticks(2'd3)) VIB_ALARM( // 3 ticks @ 50MHz = 60ns (60ns orig.)
		.clk(__clk),
		.a_(1'b0),
		.b(alarm_dly),
		.q(talarm)
	);
	wire talarm_ = ~talarm;

	assign dad15_ir9_ = ~(ad_ad & ir9);
	assign dad12_ = ~(ad_ad & pufa);
	assign dad13_ = ~(ad_ad & ir7);
	assign dad14_ = ~(ad_ad & ir8);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
