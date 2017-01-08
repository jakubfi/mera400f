/*
	MERA-400 P-P unit (interrupts)

	document:	12-006368-01-8A
	unit:			P-P3-2
	pages:		2-44..2-57
	sheets:		14
*/

module p_p(
	input clk,
	// sheet 1, 2
	input [0:15] w,
	input clm,
	input w_rm,
	input strob1,
	input i4,
	output [0:9] rs,
	// sheet 3
	input pout,
	input zer,
	input b_parz,
	input ck_rz_w,
	input b_p0,
	input zerrz,
	input i1,
	input przerw,
	output [0:15] rz,
	// sheet 4
	input rpa,
	input zegar,
	input xi,
	input fi0,
	// sheet 5
	input fi1,
	input fi2,
	input fi3,
	output przerw_z,
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
	// --
	// sheet 13
	output dad11,
	output dad12,
	output dad13,
	output dad14,
	output dad4,
	output dad15

);

	// sheet 1, 2
	// * RM - interrupt mask register

  wire [0:9] __zi = {zi, 1'b1};
	wire clm__ = ~(~clm & ~(strob1 & i4));
	wire clrs = ~(strob1 & w_rm);

	genvar i;
	generate
		for (i=0 ; i<10 ; i=i+1) begin : __rm
			rmx __rm(.w_(~w[i]), .clrs(clrs), .zi(__zi[i]), .clm__(clm__), .rs(rs[i]));
		end
	endgenerate

	// sheet 3..10
	// * RZ, RP - interrupt request and service registers

	// mask drivers when interrupt is serviced
	wire [0:8] zi = {__prio_out[1], __prio_out[2], __prio_out[3], __prio_out[4], __prio_out[11], __prio_out[13], __prio_out[15], __prio_out[21], __prio_out[27]};

	// extra interrupt (not connected)
	wire __int11 = 1'b1;

	// software interrupt drivers
	wire __m89_6 = ~(ir14 & __m104_12);
	wire __m70_3 = ~(ir15 & __m104_12);

	// rz clocks
	wire ck_rzwm = ~(strob1 & ck_rz_w);
	wire ck_rzz = ~(strob1 & i2);

	// rz resets
	wire _0_rzw = ~(~clm & ~zerrz);
	wire _0_rzz = ~(~clm & ~k1);
	wire __m104_12 = wx & sin & strob1;
	wire __m94_3 = ~_0_rzw & ~(__m104_12 & (~ir14 & ~ir15));

	// rp clocks
	wire ez_rpw = i1 & przerw;
	//wire ez_rpz = ez_rpw;

	// buses for the interrupt lines
	wire [0:31] __imask = {1'b1, rs[0:3], {7{rs[4]}}, {2{rs[5]}}, {2{rs[6]}}, {6{rs[7]}}, {6{rs[8]}}, {4{rs[9]}}};
	wire [0:31] __intr = {~pout, ~b_parz, ~b_p0, _rz4, ~rpa, ~zegar, ~xi, ~fi0, ~fi1, ~fi2, ~fi3, __int11, zk[0:15], ~oprq, ~_rz29, __m89_6, __m70_3};
	wire [0:31] __w = {w[0:11], {16{1'b0}}, w[12:15]};
	wire [0:31] __ckrz = {{12{~ck_rzwm}}, {16{~ck_rzz}}, {4{~ck_rzwm}}};
	wire [0:31] __zerrz = {{12{~_0_rzw}}, {16{~_0_rzz}}, {2{~_0_rzw}}, {2{__m94_3}}};
	wire [0:31] __ckrp = {{32{ez_rpw}}};
	wire [0:31] __prio_out;
	wire [0:31] __prio_in = {~zer, __prio_out[0:30]};
	wire [0:31] __rz;
	wire [0:31] __sz;
	wire [0:31] rp;

	assign rz = {__rz[0:11], __rz[28:31]};

	genvar j;
	generate
		for (j=0 ; j<32 ; j=j+1) begin : __rzp
			rzp rzp0(.imask(__imask[j]), .intr_(__intr[j]), .w(__w[j]), .ckrz_(__ckrz[j]), .zerrz_(__zerrz[j]), .ckrp(__ckrp[j]), .prio_in_(__prio_in[j]), .rz(__rz[j]), .sz(__sz[j]), .rp(rp[j]), .prio_out(__prio_out[j]));
		end
	endgenerate

	// sheet 5

	wire srps = ~zi[8];
	assign przerw_z = srps & zi[4];

	// sheet 6

	wire nk_ad = i2 & zw;

	// sheet 11

	// TODO: delay line
	wire rin_dly = rin;
	wire __m12_3 = ~(rin & rin_dly);

	// TODO: delay line?
	wire zw_dly = zw;

	wire __m14_6;
	// TODO: actual timing
	univib __rin(.clk(clk), .a(__m12_3), .b(zw_dly), .q(__m14_6));

	wire __m11_3 = ~(~rdt15 & ~zgpn);
	wire __m12_6 = ~(__m11_3 & ~rdt15);
	wire __m9_5;
	ffd_ __dok(.s_(1), .d(__m12_6), .c(~__m14_6), .r_(~__m12_3), .q(__m9_5));
	assign dok = rin & __m9_5;

	wire _rz29 = __m14_6 & rdt15 & rdt0;
	wire _rz4 = __m14_6 & rdt15 & ~rdt0;

	assign irq = &__sz;

	wire [0:15] zk;
	decoder16 __zk(.en({~__m14_6, ~__m11_3}), .i({rdt14, rdt13, rdt12, rdt11}), .o(zk));

	// sheet 12

	wire npbd = ~(~rp[24] & ~rp[25] & ~rp[26] & ~rp[28] & ~rp[29] & ~rp[30] & ~rp[27] & ~rp[31]);
	wire npbc = ~(~rp[28] & ~rp[29] & ~rp[30] & ~rp[31] & ~rp[23] & ~rp[22] & ~rp[21] & ~rp[20]);
	wire npbb = ~(~rp[22] & ~rp[23] & ~rp[26] & ~rp[30] & ~rp[27] & ~rp[31] & ~rp[19] & ~rp[18]);
	wire npba = ~(~rp[19] & ~rp[21] & ~rp[23] & ~rp[25] & ~rp[29] & ~rp[27] & ~rp[31] & ~rp[17]);

	// sheet 13

	wire npad = ~(~rp[ 8] & ~rp[ 9] & ~rp[10] & ~rp[11] & ~rp[12] & ~rp[13] & ~rp[14] & ~rp[15]);
	wire npac = ~(~rp[ 4] & ~rp[ 5] & ~rp[ 6] & ~rp[ 7] & ~rp[12] & ~rp[13] & ~rp[14] & ~rp[15]);
	wire npab = ~(~rp[ 2] & ~rp[ 3] & ~rp[ 6] & ~rp[ 7] & ~rp[10] & ~rp[11] & ~rp[14] & ~rp[15]);
	wire npaa = ~(~rp[ 1] & ~rp[ 3] & ~rp[ 5] & ~rp[ 7] & ~rp[ 9] & ~rp[11] & ~rp[13] & ~rp[15]);

	assign dad4 = nk_ad;

	wire __m85_11 = npbd ^ npad;
	wire __m85_8  = npbc ^ npac;
	wire __m85_6  = npbb ^ npab;
	wire __m85_3  = npba ^ npaa;
	wire __m99_6 = __m85_11 ^ __m85_8;

	wire __m4_8 = przerw & zw & i4;

	assign dad11 = (__m4_8 & zi[6])    | (nk_ad & __m99_6);
	assign dad12 = (__m4_8 & __m85_11) | (nk_ad & ~__m85_8);
	assign dad13 = (__m4_8 & __m85_8)  | (nk_ad & __m85_6);
	assign dad14 = (__m4_8 & __m99_6)  | (nk_ad & __m85_3);
	assign dad15 = (__m4_8 & __m85_3);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
