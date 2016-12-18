/*
	MERA-400 P-X unit (state control)

	document:	12-006368-01-8A
	unit:			P-X3-2
	pages:		2-1..2-10
	sheets:		10
*/

module p_x(
	input __clk, // clock for "univibrators"
	// sheet 1
	input ek1,	// A32 - Enter state K1
	input ewp,	// A34 - Enter state WP
	input ek2,	// A29 - Enter state K2
	input ewa,	// A30 - Enter state WA
	input clo,	// A62 - general clear (reset)
	input ewe,	// B40 - Enter state WE
	input ewr,	// A41 - Enter state WR
	input ew__,	// A36 - Enter state W&
	input ewz,	// A37 - Enter state WZ
	output reg k1,	// A23 - state K1
	output reg wp,	// B21 - state WP
	output reg k2,	// A27 - state K2
	output reg wa,	// A25 - state WA
	output reg wz,	// A42 - state WZ
	output reg w__,	// B43 - state W&
	output reg wr,	// B42 - state WR
	output reg we,	// B45 - state WE
	input sp1,	// A11 - Set state P1
	input ep1,	// A12 - Enter state P1
	input sp0,	// A79 - Set state P0
	input ep0,	// A09 - Enter state P0
	input stp0,	// B48
	input ep2,	// A21 - Enter state P2
	input ep5,	// A20 - Enter state P5
	input ep4,	// A19 - Enter state P4
	input ep3,	// A18 - Enter state P3
	output reg p1,	// A15 - state P1
	output reg p0,	// A14 - state P0
	output reg p2,	// A16 - state P2
	output reg p5,	// B22 - state P5
	output reg p4,	// A26 - state P5
	output reg p3,	// A17 - state P3
	// sheet 2
	input si1,	// B52 - Set state I1
	input ewx,	// B50 - Enter state WX
	input ewm,	// B49 - Enter state WM
	input eww,	// A46 - Enter state WW
	output reg i5,	// B61 - state I5
	output reg i4,	// A51 - state I4
	output reg i3,	// B60 - state I3
	output reg i2,	// A58 - state I2
	output reg i1,	// B59 - state I1
	output reg ww,	// A44 - state WW
	output reg wm,	// A45 - state WM
	output reg wx,	// A71 - state WX
	// sheet 3
	input laduj,				// A38
	output as2_sum_at,	// A13
	// sheet 4
	input strob_fp,	// A28
	input mode,			// B54
	input step,			// A48
	output got,			// A83
	output strob2,	// A49
	output strob1,	// A22 A90
	// sheet 5
	input przerw_z,	// A61
	input przerw,		// A24
	input lip,			// B77
	input sp,				// A67
	input lg_0,			// B67
	input pp,				// A64
	input lg_3,			// A68 - LG=3 (Licznik Grupowy)
	output arm4,		// B79
	output blw_pw,	// B85
	output ekc_1,		// A76 - EKC*1 - Enter state KC (Koniec Cyklu)
	output zer_sp,	// A73
	output lipsp,		// A66
	// sheet 6
	input sbar__,		// A53
	input q,				// A55 - Q system flag
	input in,				// A03 - instruction IN
	input ou,				// B19 - instruction OU
	input k2fetch,	// B41
	output red_fp,		// A39
	output pn_nb,		// B94 - PN->NB
	output bp_nb,		// B93 - BP->NB
	output bar_nb,	// A75 - BAR->NB
	output barnb,		// A72
	output q_nb,		// A74 - Q->NB
	output df,			// B92
	output w_dt,		// A81 - W->DT
	output dr,			// A87
	output dt_w,		// A65 - DT->W
	output ar_ad,		// B63 - AR->AD
	output ds,			// A88 - DS: "Send" Driver // NOTE: missing on original schematic
	// sheet 7
	input mcl,			// A43 - instruction MCL
	input gi,				// A47
	input ir6,			// B58
	input fi,				// A10
	input arz,			// B56
	input k2_bin_store,	// A31
	input lrz,			// B78
	output ic_ad,		// B87
	output dmcl,		// B88
	output ddt15,		// A92
	output ddt0,		// B89
	output din,			// A91
	output dad15_i,	// B81
	output dad10,		// B82
	output dad9,		// A86
	output dw,			// A93
	output i3_ex_przer,	// A52
	output ck_rz_w,	// B91
	output zerz,		// B85
	// sheet 8
	input sr_fp,		// B53
	input zw1,			// A85 - module 1 allowed to use the system bus (CPU) (ZezWolenie 1)
	input srez__,		// B76
	input wzi,			// A60
	input is,				// A84
	input ren,			// B74
	input rok,			// A89
	input efp,			// B09
	input exl,			// A78 - instruction EXL
	output zg,			// B44 - request to use the system bus (ZGłoszenie)
	output ok__,		// A80 - OK*
	// sheet 9
	input stop_n,		// B55
	input zga,			// B57
	input rpe,			// A82
	input stop,			// B51
	input ir9,			// B06
	input pufa,			// B08 - any of the wide or floating point instructions
	input ir7,			// A06
	input ir8,			// A04
	output hlt_n,		// A94
	output bod,			// A77
	output b_parz,	// A56
	output b_p0,		// B84
	output awaria,	// B90
	output zz1,			// A51 - module 1 in this rack is present (CPU)
	output dad15_ir9,	// B07
	output dad12,		// A08
	output dad13,		// A07
	output dad14		// A05
);

	// sheet 1, page 2-1
	// * state registers

	always @ (posedge got, posedge clo) begin
		if (clo) {k1, wp, k2, wa, we, wr, w__, wz, p2, p5, p4, p3} <= 'b0;
		else {k1, wp, k2, wa, we, wr, w__, wz, p2, p5, p4, p3}
				<= {ek1, ewp, ek2, ewa, ewe, ewr, ew__, ewz, ep2, ep5, ep4, ep3};
	end

	always @ (posedge got, posedge sp1) begin
		if (sp1) p1 <= 1'b1;
		else p1 <= ep1;
	end

	wire __sp0 = ~(~clo & ~sp0);

	always @ (posedge got, posedge __sp0) begin
		if (__sp0) p0 <= 1'b1;
		else p0 <= ep0;
	end

	// sheet 2, page 2-2
	// * state registers

	wire ei4;

	always @ (posedge got, posedge clo) begin
		if (clo) {i2, i3, i4, i5, wx, wm} <= 'b0;
		else {i2, i3, i4, i5, wx, wm} <= {ei2, ei3, ei4, ei5, ewx, ewm};
	end

	initial i1 = 0;
	always @ (posedge got, posedge clo, posedge si1) begin
		if (clo) i1 <= 'b0;
		else if (si1) i1 <= 'b1;
		else i1 <= ei1;
	end

	// sheet 3, page 2-3
	// * state transition delays

	wire stp0__;

	assign as2_sum_at = ~(~wz & ~p4 & ~we & ~w__);
	wire __m19_6 = ~(~w__ & ~we & ~p4 & ~(k2 & laduj));
	wire __m18 = ~(~p1 & ~k1 & ~k2 & ~i1 & ~i3);
	wire __m20 = ~(~p5 & ~wr & ~ww & ~wm & ~i2 & ~i4 & ~i5);
	wire __m16 = ~(~wz & ~stp0__ & ~p3 & ~wa);
	wire __m15 = ~(~p2 & ~wp & ~wx);

	wire sgot = ~(__m19_6 & __m18);

	// 74123 multivibrators configuration:
	// propagation delay: ~30ns
	// pulse length @ 12pF, 5..10kohm: 80..130 ns
	// pulse length @ 22pF, 5..10kohm: 110..190 ns

	// TODO: actual delays
	wire __q1, __q2, __q3, __q4, __q5;
	univib uni1(.clk(__clk), .a(got), .b(__m19_6), .q(__q1)); // 12pF
	univib uni2(.clk(__clk), .a(got), .b(__m18 & ok__), .q(__q2)); // 22pF
	univib uni3(.clk(__clk), .a(got), .b(__m20 & ok__), .q(__q3)); // 12pF
	univib uni4(.clk(__clk), .a(got), .b(__m16), .q(__q4)); // 12pF
	univib uni5(.clk(__clk), .a(got), .b(__m15), .q(__q5)); // 12pF

	wire st56 = __q1 & __q2;
	wire st812 = __q3 & __q4 & __q5;
	wire sts = ~(~st56 & st812);

	// sheet 4, page 2-4
	// * strobs

	wire zw, oken;

	wire __m53_6 = ~(sgot & __tstep);
	// NOTE: 33pF cap to ground
	wire __got = ~((~(zw & oken & __got) & __m53_6) & ~st812 & ~strob2);
	univib uni_got(.clk(__clk), .a(__got), .b(1), .q(got__));
	wire __m53_11 = ~(~(__tstep & ~sgot) & ~st56);
	univib uni_strob2(.clk(__clk), .a(__m53_11), .b(1), .q(strob2));
	wire gotst1 = ~(~got__ & ~strob1);

	reg __tstep; // M21_6
	wire __tstep_s = ~mode & sts;
	wire step_ = ~step;
	always @ (posedge __tstep_s, posedge step_, posedge mode) begin
		if (mode) __tstep <= 1'b0;
		else if (__tstep_s) __tstep <= 1'b1;
		else __tstep <= 1'b0;
	end

	assign strob1 = ~(~strob_fp & ~st56 & ~st812 & ~__tstep);

	// sheet 5, page 2-5
	// interrupt phase control signals

	wire exr;

	assign arm4 = strob2 & i2 & lip;
	assign blw_pw = ~przerw_z & lg_3 & i3 & przerw;
	wire ei5 = ~(i4 & ~(lip & i1));
	wire exrprzerw = ~(~przerw & ~exr);
	wire ei2 = i1 & przerw_z;
	wire i3lips = ~lipsp__ & i3;
	assign ekc_1 = (lg_3 & i3lips) | (i5 & ~lip);
	assign zer_sp = ~lip & i5;
	assign lipsp__ = ~(~lip & ~sp);
	wire ei1 = ~(~exr & ~lip) & pp;
	wire ei3 = (~przerw_z & przerw & i1) | (i1 & exr) | (sp & pp) | (i2) | __m25;
	wire __m25 = (i5 & lip) | (~lipsp__ & ~lg_0 & i3) | (i3 & lipsp__ & ~lg_3);

	// sheet 6, page 2-6

	wire zwzg, read_fp;
	assign red_fp = read_fp;

	wire __m28 = ~(~wr & ~p1 & ~p5 & ~wm & ~k2fbs & ~ww & ~red_fp);
	wire __m30 = ~(~red_fp & ~wm & ~p5 & ~ww & ~k2fbs & ~(wr & ~inou));

	assign pn_nb = ~(barnb & ~wm) & zwzg;
	assign bp_nb = (barnb & ~wm) & zwzg;
	assign bar_nb = barnb & zwzg;
	assign barnb = (is & sp) | (ww & sbar__) | (sbar__ & wr) | (q & ~__m28);
	assign q_nb = zwzg & ~i2;
	wire inou = ~(~in & ~ou);
	wire __m40 = ~(~i2 & (~in & ~wm) & ~k1);
	assign df = __m40 & zwzg;
	wire __m49 = ~(~ou & ~wm) ^ w;
	assign w_dt = __m49 & zwzg;
	assign dr = r & zwzg;
	wire r = ~(k2fetch & ~p5 & ~i4 & ~i1 & ~i3lips & ~wr & ~p1 & ~red_fp);
	assign dt_w = __m40 & r;
	assign ar_ad = __m30 & zwzg;
	assign ds = ~(ou & ~wm) & zwzg; // NOTE: missing on original schematic

	// sheet 7, page 2-7
	// * system bus drivers

	assign ic_ad = zwzg & ~(~k1 & ~p1 & ~(~inou & wr));
	assign dmcl = zwzg & ~(~mcl | ~wm);
	assign ddt15 = zwzg & ~(~wm | ~gi);
	assign ddt0 = zwzg & (~(~wm | ~gi) & ir[6]);
	assign din = zwzg & ~(~wm | ~gi);
	assign dad15 = zwzg & ~(~i5 & ~i1);
	assign dad10 = zwzg & ~(~i1 & ~(i4 & exr) & ~i5);
	assign dad9 = zwzg & ~(~i1 & ~i4 & ~i5);
	// jumper ABC set to AB
	// NOTE: unused: wire __c = ~(~arz & q & ~exrprzerw);
	assign dw =  zwzg & w;
	wire w = ~(~i5 & i3_ex_przer & ~ww & ~k2_bin_store);
	assign i3_ex_przer = ~(exrprzerw & i3);
	wire rw = r ^ w;
	wire k2fbs = k2_bin_store & k2fetch;
	assign ck_rz_n = ~(~(wr & fi) & ~lrz & ~blw_pw);
	// TODO: ~25ns delay
	wire __ck_rz_n_dly = ~ck_rz_n;
	assign zerz = ~(__ck_rz_n_dly & ck_rz_n & ~blw_pw);

	// sheet 8, page 2-8
/*
	wire zwzg = 
	assign zw1 = 
	assign zgi =
	assign zg = 
	wire zw = ~zw1;
	wire ad_ad = 
	wire alarm = 
	assign ok = 
	assign oken = ~(~ren & ~rok);
	wire exr = 
*/
endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
