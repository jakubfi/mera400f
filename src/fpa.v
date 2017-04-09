/*
	F-PA unit (FPU arithmetic)

	document: 12-006370-01-4A
	unit:     F-PA2-1
	pages:    2-29..2-48
*/

module fpa(
	// sheet 1
	input [0:15] w_, // also on sheets 2, 12, 13
	input taa,
	// sheet 2
	input t_1,
	input tab_,
	input clockta_,
	output t_0_1_,
	output t_2_7_,
	// sheet 3
	input m_1,
	input ma,
	input mb,
	input clockm,
	input _0_m,
	output c0_eq_c1,
	output c1_,
	output fc0_,
	output t1_,
	output t0_eq_c0,
	output t0_c0_,
	output t0_t1,
	output m0_,
	output t0_,
	// sheet 4
	input fab_,
	input faa_,
	output fp0_,
	// sheet 5
	output t_8_15_,
	// sheet 6
	input p_16_,
	output m14_,
	output m16_,
	// sheet 7
	// (nothing)
	// sheet 8
	output fp16_,
	// sheet 9
	output t16_,
	// sheet 10
	// (nothing)
	// sheet 11
	input m_32,
	input p_32_,
	// sheet 12
	input clocktb_,
	// also w[8:11]
	// sheet 13
	// w[12:15]
	// sheet 14
	input f2_,
	input m_40,
	input cp_,
	input _t_c,
	output m32_,
	output m38_,
	output m39_,
	output c39_,
	// sheet 15
	input fra_,
	input frb_,
	input p_40_,
	output p32_,
	// sheet 16
	input clocktc,
	input trb_,
	input _0_t_,
	output t39_,
	// sheet 17
	input f9_ka_,
	input lkb_,
	// sheet 18
	input z_f,
	input m_f,
	input v_f,
	input c_f,
	output zp4,
	output zp5,
	output t_32_39_,
	output t_16_23_,
	output zp6,
	output zp7,
	// sheet 19
	input [0:7] d,
	output [8:15] zp,
	input _0_zp_,
	input zpb_,
	input zpa_,
	output t_24_31_

);


endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
