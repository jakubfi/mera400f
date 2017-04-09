/*
	F-PS unit (FPU control)

	document: 12-006370-01-4A
	unit:     F-PS2-1
	pages:    2-1..2-16
*/

module fps(
	// sheet 1
	input mode_,
	input step_,
	output strob_fp_,
	output strob2_fp,
	// sheet 2
	input oken,
	input zw1,
	input di,
	input efp_,
	input puf,
	input got_,
	output sr_fp_,
	output ekc_fp_,
	output _0_f_,
	// sheet 3
	input g,
	input wdt,
	input af_sf_,
	input mw_,
	output _0_t,
	output lkb_,
	output _0_d_,
	output clocktc_,
	output clocktb_,
	output clockta_,
	output t_c_,
	output fcb,
	// sheet 4
	input mf_,
	input fp16_,
	output t_1_t_1,
	output tab_,
	output trb_,
	output taa,
	output cp_,
	// sheet 5
	input sd$_,
	input ck_,
	input sf,
	input p32_,
	input m14_,
	input t0_eq_c0,
	input m38_,
	input t0_c0,
	input ws_,
	input df_,
	input af,
	input ad,
	output frb_,
	output p_16_,
	output p_32_,
	output mw_p16_,
	output p_40_,
	output fab_,
	output faa_,
	output fra_,
	// sheet 6
	input fic_,
	input fic,
	input ad_sd,
	input ta,
	input sgn_t0_t0,
	// sheet 7
	input opsu,
	input dw_,
	input wc_,
	input wt,
	input dw,
	// sheet 8
	input ss,
	output f5_,
	output f6_,
	output f2_,
	output f4_,
	// sheet 9
	input ok$,
	input ff_,
	output read_fp_,
	// sheet 10
	input sgn_,
	input fwz,
	input nrf,
	// sheet 11
	input nz,
	input t0_t_1,
	input ok,
	output f13,
	output f13_,
	// sheet 12
	output f10_,
	output f9,
	output f8_,
	output f7_,
	output f9_ka_,
	// sheet 13
	input dw_df,
	input mw_mf,
	output scc_,
	output pc8,
	output _0_d,
	output _0_m,
	output mb,
	output ma,
	output clockm,
	// sheet 14
	output rlp_fp_,
	output lpa,
	// sheet 15
	output zpa_,
	output zpb_,
	output _z_zp_,
	output s_fp_,
	output ustr0_fp,
	output lp_,
	output lpb
);


endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
