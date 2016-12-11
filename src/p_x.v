/*
	MERA-400 P-X unit (state control)

	document:	12-006368-01-8A
	unit:			P-X3-2
	pages:		2-1..2-10
*/

module p_x(
	input ek1,	// A32
	input ewp,	// A34
	input ek2,	// A29
	input ewa,	// A30
	input clo,	// A62
	input ewe,	// B40
	input ewr,	// A41
	input ew__,	// A36
	input ewz,	// A37
	output k1,	// A23
	output wp,	// B21
	output k2,	// A27
	output wa,	// A25
	output wz,	// A42
	output w__,	// B43
	output wr,	// B42
	output we,	// B45
	input sp1,	// A11
	input ep1,	// A12
	input spo,	// A79
	input epo,	// A09
	input stpo,	// B48
	input ep2,	// A21
	input ep5,	// A20
	input ep4,	// A19
	input ep3,	// A18
	output p1,	// A15
	output p0,	// A14
	output p2,	// A16
	output p5,	// B22
	output p4,	// A26
	output p3,	// A17

	input si1,	// B52
	input ewx,	// B50
	input ewm,	// B49
	input eww,	// A46
	output i5,	// B61
	output i4,	// A51
	output i3,	// B60
	output i2,	// A58
	output i1,	// B59
	output ww,	// A44
	output wm,	// A45
	output wx,	// A71

	input laduj,				// A38
	output as2_sum_at,	// A13

	input strob_fp,	// A28
	input mode,			// B54
	input step,			// A48
	output got,			// A83
	output strob2,	// A49
	output strob1,	// A22 A90

	input przerw_z,	// A61
	input przerw,		// A24
	input lip,			// B77
	input sp,				// A67
	input lg_0,			// B67
	input pp,				// A64
	input lg_3,			// A68
	output arm4,		// B79
	output blw_pw,	// B85
	output ekc_1,		// A76
	output zer_sp,	// A73
	output lipsp,		// A66

	input sbar__,		// A53
	input q,				// A55
	input in,				// A03
	input ou,				// B19
	input k2fetch,	// B41
	input red_fp,		// A39
	output pn_nb,		// B94
	output bp_nb,		// B93
	output bar_nb,	// A75
	output barnb,		// A72
	output q_nb,		// A74
	output df,			// B92
	output w_dt,		// A81
	output dr,			// A87
	output dt_w,		// A65
	output ar_ad,		// B63

	input mcl,			// A43
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

	input sr_fp,		// B53
	input zw1,			// A85
	input srez__,		// B76
	input wzi,			// A60
	input is,				// A84
	input ren,			// B74
	input rok,			// A89
	input efp,			// B09
	input exl,			// A78
	output zgi,			// C69
	output zg,			// B44
	output ok__,		// A80

	input stop_n,		// B55
	input zga,			// B57
	input rpe,			// A82
	input stop,			// B51
	input ir9,			// B06
	input pufa,			// B08
	input ir7,			// A06
	input ir8,			// A04
	output hlt_n,		// A94
	output bod,			// A77
	output b_parz,	// A56
	output b_p0,		// B84
	output awaria,	// B90
	output zz1,			// A51
	output dad15_ir9,	// B07
	output dad12,		// A08
	output dad13,		// A07
	output dad14		// A05

);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
