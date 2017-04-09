/*
	AWP (FPU)

	document: 12-006370-01-4A
	unit:     F-PA2-1
	pages:    2-1..2-48
*/

module awp(
	input [0:15] w,
	input r03,
	input r04,
	input pufa,
	input [7:9] ir,
	input nrf,
	input mode_,
	input step_,
	input efp_,
	input got_,
	input ok$,
	input oken,
	output [0:15] zp,	// bus
	output fi0_,			// fixed point overflow
	output fi1_,			// floating point underflow
	output fi2_,			// floating point overflow
	output fi3_,			// div/0
	output rlp_fp_,		// (r1, r2, r3) read/write
	output lpa,				//
	output lpb,				// LP counter outputs (rX select)
	output s_fp_,			// ZP->W
	output ustr0_fp_,	// set flags
	output f13_,			// AWP->W
	output strob_fp_,	// fpu strob
	output sr_fp_,		// memory read
	output read_fp_,	// memory read
	output ekc_fp_		// FPU done
);


endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
