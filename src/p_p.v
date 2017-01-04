/*
	MERA-400 P-P unit (interrupts)

	document:	12-006368-01-8A
	unit:			P-P3-2
	pages:		2-44..2-57
	sheets:		14
*/

module p_p(
	// sheet 1, 2
	input [0:15] w,
	input clm,
	input w_rm,
	input strob1,
	input i4,
	output [0:31] rs,
	// sheet 3
	input pout,
	input zer,
	input b_parz,
	input ck_rz_w,
	input p_p0,
	input zerrz,
	input i1,
	input przerw,
	output [0:15] rz,
	output [0:31] rp,
	// sheet 4
	input rpa,
	input zegar,
	input xi,
	input fi0,
	// sheet 5
	input fi1,
	input fi2,
	input fi3,
	input __int11,
	// sheet 6
	input k1,
	input i2,
	// sheet 7
	// ??
	// sheet 8
	// --
	// sheet 9
	input oprq,
	// sheet 10
	input ir14,
	input wx,
	input sin,
	input ir15,
	// sheet 11
	input rin,
	input zw,
	input rdt15,
	input zgpn,
	input rdt0, // ??
	input rdt14,
	input rdt13,
	input rdt12,
	input rdt11,
	output dok,
	output irq,
	// sheet 12
	output npbd,
	output npbc,
	output npbb,
	output npb1,
	// sheet 13
	output npad,
	output npac,
	output npab,
	output npa1,
	output dad11,
	output dad12,
	output dad13,
	output dad14,
	output dad15

);

	wire [0:8] zi;

	wire clm__ = ~(clm & ~(strob1 & i4));
	wire clrs = w_rm & strob1;
	rm __rm(.w(w[0:9]), .zi(zi), .clm__(clm__), .clrs(clrs), .rs(rs));

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
