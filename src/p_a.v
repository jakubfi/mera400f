/*
	MERA-400 P-A unit (ALU)

	document:	12-006368-01-8A
	unit:			P-A3-2
	pages:		2-70..2-84
	sheets:		15
*/

module p_a(
	// sheet 1
	input [0:15] ir,
	input [0:15] ki,
	input [0:15] rdt,
	input w_dt,
	input mwa, mwb, mwc,
	input bwa, bwb,
	output [0:15] ddt,
	output [0:15] w,
	// sheet 2
	// sheet 3
	// sheet 4
	// sheet 5
	input saryt,
	input sab, scb, sb, sd,
	output s0,
	output carry,
	// sheet 6
	input p16,
	input saa, sca,
	output j__,
	// sheet 7
	input wx,
	input eat0,
	input axy,
	output at15,
	output exy,
	// sheet 8
	input w_ac,
	input strob2,
	input as2,
	input strob1,
	input am1,
	input apb,
	input amb,
	input ap1,
	output s_1,
	output wzi,
	output zs,
	// sheet 9
	input arm4,
	input w_ar,
	input arp1,
	output arz,
	// sheet 10
	input icp1,
	input w_ic,
	input off,
	// sheet 11, 12
	input baa, bab, bac,
	input ab,
	input aa,
	input [0:15] l,
	// sheet 13, 14
	input barnb,
	input [0:15] kl,
	input ic_ad,
	output [0:15] dad,
	input ar_ad

);

	// sheet 1
	// sheet 2
	// sheet 3
	// sheet 4
	// sheet 5
	// sheet 6
	// sheet 7
	// sheet 8
	// sheet 9
	// sheet 10
	// sheet 11
	// sheet 12
	// sheet 13
	// sheet 14

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
