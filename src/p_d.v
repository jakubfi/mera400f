/*
	MERA-400 P-D unit

	document:	12-006368-01-8A
	unit:			P-D2-3
	pages:		2-30..2-43
*/

module p_d(
	input [0:15] w,		// A80, A81, B78, B77, B09, B08, B35, A27, A30, A29, B15, B16, B25, B26, B13, B12
	input strob1,			// B85
	input w_ir,				// B86
	output [0:15] ir,	// A78, A79, B75, B74, A19, A18, A21, A22, B17, A33, A31, A32, B30, B27, B06, B07
	output c0,				// B05

	input si1,				// B79
	output ls,				// A91
	output pj,				// B92
	output bs,				// A93
	output ou,				// B87
	output in,				// A88
	output is,				// A92
	output ri,				// B67
	output pufa,			// A85
	output rb__,			// A15
	output cb,				// B89
	output sc__,			// B90
	output oc__,			// B88
	output ka2,				// A83
	output gr__,			// B47

	output hlt,				// A34
	output mcl,				// B34
	output sin,				// B28
	output gi,				// A28
	output lip,				// A35
	output mb,				// B39
	output im,				// B40
	output ki,				// B38
	output fi,				// B41
	output sp,				// B37
	output rz,				// B42
	output ib,				// B36
	output lpc,				// A09
	output rpc,				// A10
	output shc,				// A57
	output rc__,			// B04
	output ng__,			// B03
	output zb__,			// B20
	output b0,				// A25

	input q,					// B19
	input mc_3,				// B10
	input [0:8] r0,		// B29, B33, B31, A16, B23, B22, B21, B32, A26
	output _0_v,			// A14
	input p,					// A23
	output md,				// B11
	output xi,				// A24
	output nef,				// A20

	input w__,				// A61
	input p4,					// A77
	input we,					// A65
	output amb,				// A75
	output apb,				// B65
	output jkrb,			// A86
	output lwrs__,		// A67
	output saryt,			// B62
	output ap1,				// A76
	output am1,				// A90

	input wz,					// A66
	input wls,				// A70
	output bcdc__,		// A89

	output sd,				// A69
	output scb,				// A82
	output sca,				// A71
	output sb,				// A74
	output sab,				// A73
	output saa,				// A72
	output lrcb__,		// A45
	output aryt,			// A68
	output sbar__,		// B91
	output nrf,				// A12

	input at15,				// A07
	input wx,					// A64
	input wa,					// A63
	output ust_z,			// B49
	output ust_v,			// A08
	output ust_mc,		// B80
	output ust_leg,		// B93
	output sr__,			// B46
	output ust_y,			// A53
	output ust_x,			// A47
	output blr,				// A87

	input wpb,				// A58
	input wr,					// A60
	input pp,					// A62
	input ww,					// B60
	input wzi,				// A59
	output ewa,				// A55
	output ewp,				// A56
	output uj__,			// B18
	output lwt__,			// B94
	output lj,				// B50
	output ewe,				// A54

	input wp,					// A37
	output ekc_1,			// A42
	output ewz,				// A49
	output ew__,			// A50

	output lar__,			// B82
	output ssp__,			// B81
	output ka1,				// A94
	output na,				// A84
	output exl,				// A06
	output p16,				// A36

	input lk,					// A52
	input wm,					// A38
	output ewr,				// A51
	output ewm,				// A48
	output efp,				// A11
	output sar__,			// A05
	output eww,				// A41
	output srez__,		// A17

	output ewx,				// A43
	output axy,				// A46
	output inou__,		// A39
	output ekc_2,			// A40
	output lac__			// B43
);

	// page 2-30 - IR, instruction register

	ir u_ir(.w(w), .strob1(strob1), .w_ir(w_ir), .ir(ir));
	assign c0 = ~|ir[13:15];
	assign ir13_14 = |ir[13:14];

	// page 2-31 - preliminary decoder

	wire si11 = si1 & ir[0];
	wire si12 = si1 & ir[1];
	wire ir01 = ~(~ir[1] & ~ir[0]);
	assign sc__ = ~(~s & ~c);
	wire sc = ~sc__;
	assign oc__ = ~(ka2 & ir[7]);
	wire gr = ~(~l & ~g);
	assign gr__ = ~gr;

	decoder16 dec_01(.en({~si11 ,  ir[1]}), .i(ir[2:5]), .o({lw, tw, ls, ri, rw, pw, rj, is, bb, bm, bs, bc, bn, ou, in, pufa}));
	decoder16 dec_10(.en({ ir[0], ~si12 }), .i(ir[2:5]), .o({aw, ac, sw, cw, _or, om, nr, nm, er, em, xr, xm, cl, lb, rb, cb}));
	decoder16 dec_11(.en({ ir[0],  ir[1]}), .i(ir[2:5]), .o({awt, trb, irb, drb, cwt, lwt, lws, rws, js, ka2, c, s, j, l, g, bn}));

	// page 2-32 - preliminary decoder

	wire [1:7] __a;
	decoder8 dec_a(.en(1), .i(ir[7:9]), .o(__a));
	wire snef = ~(&(~__a[5:7]));

	decoder8 dec_s(.en(s), .i(ir[7:9]), .o({hlt, mcl, sin, gi, lip}));
	wire gmio = ~(~mcl & ~gi & ~inou);
	wire hsm = ~(~hlt & ~sin & ~__bn5);

	wire inou;
	decoder8 dec_bn(.en(b_n), .i(ir[7:9]), .o({mb, im, ki, __bn5, fi, sp, rz, ib}));
	wire fimb = ~fi & ~im & ~mb;

	wire b_1 = &ir[10:12];
	wire [0:3] __null;
	decoder8 dec_c(.en(c), .i({b_1, ir[15], ir[6]}), .o({__null, ngl, srz, rpc, lpc}));
	wire pcrs = ~(~rpc & ~lpc & ~rc__ & ~sx);
	assign shc = c & ir[11];

	wire __other_en = c & b0;
	decoder8 dec_other(.en(__other_en), .i(ir[13:15]), .o({rc__, zb__, sx, ng__, __oth4, sly, slx, sx}));
	wire sl = ~slx & ~__oth4 & ~sly;

	// page 2-33 - ineffective and illegal instrictions

	assign md = __a[5] & b_n;
	assign _0_v = js & ~__a[4] & we;

	wire __b34567 = ~(~ir[10] & ~(ir[11] & ir[12]));
	wire __nef_1 = (inou & q) | (__b34567 & c) | (q & s) | (q & ~snef & b_n);

	wire __nef_2 = (md & mc_3) | (c & ir13_14) | (b_1 & s);

	wire __nef_jcs = ~(js & ~(r0[3] | __a[7]));

	wire __nef_jys = js & ~(r0[7] | ~__a[6]);
	wire __nef_jxs = js & ~(r0[8] | ~__a[5]);
	wire __nef_jvs = js & ~(r0[2] | ~__a[4]);
	wire __nef_jm = __a[5] & ~(r0[1] | ~j);
	wire __nef_j1 = __nef_jys | __nef_jxs | __nef_jvs | __nef_jm;

	wire __nef_jn = ~(~(~__a[6] | ~j) & r0[5]);
	wire __nef_jz = __a[4] & ~(~j | r0[0]);
	wire __jjs_ = ~(~j & ~js);
	wire __nef_jg = __jjs_ & ~(r0[6] | ~__a[3]);
	wire __nef_je = __jjs_ & ~(r0[5] | ~__a[2]);
	wire __nef_jl = __jjs_ & ~(r0[4] | ~__a[1]);
	wire __nef_j2 = __nef_jz | __nef_jg | __nef_je | __nef_jl;

	assign nef = ~(~__nef_1 & ir01 & __nef_2 & __nef_jcs & ~__nef_j1 & __nef_jn & ~p & ~__nef_j2);
	assign xi = ~(~__nef_1 & ~__nef_2 & ir01);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
