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
	output o_v,				// A14
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

	// page 2-31

	decoder16 dec_01(.en({~ir[0],  ir[1]}), .i(ir[2:5]), .o({lw, tw, ls, ri, rw, pw, rj, is, bb, bm, bs, bc, bn, ou, in, pufa}));
	decoder16 dec_10(.en({ ir[0], ~ir[1]}), .i(ir[2:5]), .o({aw, ac, sw, cw, _or, om, nr, nm, er, em, xr, xm, cl, lb, rb, cb}));
	decoder16 dec_11(.en({ ir[0],  ir[1]}), .i(ir[2:5]), .o({awt, trb, irb, drb, cwt, lwt, lws, rws, js, ka2, c, s, j, l, g, bn}));

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
