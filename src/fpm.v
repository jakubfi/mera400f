/*
	F-PM unit (FPU microoperations)

	document: 12-006370-01-4A
	unit:     F-PM2-2
	pages:    2-17..2-28
*/

module fpm(
	input __clk,
	// sheet 1
	input [8:15] w,
	input l_d_,
	input _0_d,
	input lkb_,
	output d1_,
	output [2:7] d,
	// sheet 2
	input fcb_,
	input scc_,
	input pcb,
	output d_1,
	// sheet 3
	input _0_f_,
	input f2_,
	input strob2_fp,
	input f5_,
	input strob_fp_,
	output g,
	output wdt,
	output wt,
	// sheet 4
	output fic_,
	output fic,
	// sheet 5
	input r03,
	input r02,
	input t16_,
	output c_f,
	output v_f,
	output m_f,
	output z_f,
	output dw,
	// sheet 6
	input [7:9] ir,
	input pufa,
	input f9,
	input nrf,
	output ad,
	output sd$_,
	output mw_,
	output dw_,
	output af,
	output sf,
	output mf_,
	output df_,
	output dw_df,
	output mw_mf,
	output af_sf_,
	output ad_sd,
	// sheet 7
	input f10_,
	input f7_,
	input f6_,
	output fwz,
	output _end,
	output ws_,
	// sheet 8
	input lp_,
	input f8_,
	input f13_,
	output fi3_,
	output di,
	output fi0_,
	output wc_,
	output fi1_,
	output fi2_,
	output d0,
	output d_2,
	// sheet 9
	input w0_,
	input t_1_t_1,
	input fp0_,
	input fab_,
	input faa_,
	input fc0_,
	input _0_t,
	input t0_t1,
	input c0_eq_c1,
	input t1_,
	input t0_,
	input clockta_,
	input t_0_1_,
	input t_2_7_,
	input t_8_15_,
	input t_16_23_,
	input t_24_31_,
	input t_32_39_,
	output t_1,
	output t0_t_1,
	output ok,
	output nz,
	output opsu,
	output ta,
	// sheet 10
	input trb_,
	input i39_,
	input m0_,
	input mb,
	input c39_,
	input f4_,
	input clockm,
	input _0_m,
	input m39_,
	input m15_,
	input m38_,
	input m14_,
	output m_1,
	output ck_,
	// sheet 11
	input m32_,
	input t0_c0,
	output m_40,
	output m_32,
	output sgn_t0_c0,
	output sgn_

);


endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
