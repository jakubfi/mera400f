/*
	P-D unit (instruction decoder)

	document: 12-006368-01-8A
	unit:     P-D2-3
	pages:    2-30..2-43
*/

module pd(
	// sheet 1
	input [0:15] w,		// A80, A81, B78, B77, B09, B08, B35, A27, A30, A29, B15, B16, B25, B26, B13, B12 - W bus
	input strob1,			// B85
	input w_ir,				// B86 - W->IR: send bus W to instruction register IR
	output [0:15] ir,	// A78, A79, B75, B74, A19, A18, A21, A22, B17, A33, A31, A32, B30, B27, B06, B07 - IR register
	output c0,				// B05 - C=0 (opcode field C is 0 - instruction argument is stored in the next word)
	// sheet 2
	input si1,				// B79
	output ls,				// A91 - LS
	output rj,				// B92 - RJ
	output bs,				// A93 - BS
	output ou,				// B87 - OU
	output in,				// A88 - IN
	output is,				// A92 - IS
	output ri,				// B67 - RI
	output pufa,			// A85 - any of the wide or floating point arithmetic instructions
	output rb$,			// A15 - RB*: RB instruction
	output cb,				// B89 - CB
	output sc$,				// B90 - SC*: S|C opcode group
	output oc,			// B88 - OC*: BRC, BLC
	output ka2,			// A83 - KA2 opcode group
	output gr,			// B47 - GR*: G|L opcode group
	// sheet 3
	output hlt,				// A34 - HLT
	output mcl,			// B34 - MCL
	output sin,			// B28 - SIU, SIL, SIT, CIT
	output gi,				// A28 - GIU, GIL
	output lip,			// A35 - LIP
	output mb,				// B39 - MB
	output im,				// B40 - IM
	output ki,				// B38 - KI
	output fi,				// B41 - FI
	output sp,				// B37 - SP
	output rz,				// B42 - RZ
	output ib,				// B36 - IB
	output lpc,				// A09 - LPC
	output rpc,				// A10 - RPC
	output shc,			// A57 - SHC
	output rc$,			// B04 - RC*: RIC, RKY
	output ng$,			// B03 - NG*: NGA, NGC
	output zb$,			// B20
	output b0,				// A25 - B=0 (opcode field B is 0 - no B-modification)
	// sheet 4
	input q,					// B19 - Q: system flag
	input mc_3,				// B10 - MC=3: three consecutive pre-modifications
	input [0:8] r0,		// B29, B33, B31, A16, B23, B22, B21, B32, A26 - R0 register flags
	output _0_v,			// A14
	input p_,					// A23 - P flag (branch)
	output md,				// B11 - MD
	output xi,				// A24 - instruction is illegal
	output nef,				// A20 - instruction is ineffective
	// sheet 5
	input w$_,				// A61 - W& state
	input p4_,				// A77 - P4 state
	input we_,				// A65 - WE state
	output amb,				// A75
	output apb,				// B65
	output jkrb,			// A86
	output lwrs,		// A67
	output saryt,			// B62 - SARYT: ALU operation mode (0 - logic, 1 - arythmetic)
	output ap1,				// A76 - AP1: register A plus 1 (for IRB)
	output am1,				// A90 - AM1: register A minus 1 (for DRB)
	// sheet 6
	input wz_,				// A66 - state WZ
	input wls,				// A70
	output bcoc$,			// A89
	// sheet 7
	output sd,				// A69 - ALU function select
	output scb,				// A82 - ALU function select
	output sca,				// A71 - ALU function select
	output sb,				// A74 - ALU function select
	output sab,				// A73 - ALU function select
	output saa,				// A72 - ALU function select
	output lrcb,		// A45
	output aryt,			// A68
	output sbar$,			// B91
	output nrf,				// A12
	// sheet 8
	input at15_,			// A07
	input wx_,				// A64 - state WX
	input wa_,				// A63 - state WA
	output ust_z,			// B49
	output ust_v,			// A08
	output ust_mc,		// B80
	output ust_leg,		// B93
	output eat0,			// A13
	output sr,			// B46
	output ust_y,			// A53
	output ust_x,			// A47
	output blr,			// A87
	// sheet 9
	input wpb_,				// A58
	input wr_,				// A60
	input pp_,				// A62
	input ww_,				// B60
	input wzi,				// A59
	output ewa,				// A55 - Enter WA
	output ewp,				// A56 - Enter WP
	output uj,			// B18
	output lwlwt,			// B94
	output lj,				// B50
	output ewe,				// A54 - Enter WE
	// sheet 10
	input wp_,				// A37
	output ekc_1,		// A42
	output ewz,				// A49 - Enter WZ
	output ew$,				// A50 - Enter W&
	// sheet 11
	output lar$,			// B82
	output ssp$,			// B81
	output ka1,			// A94
	output na,				// A84 - Normalny Argument
	output exl,			// A06
	output p16,			// A36
	// sheet 12
	input lk,					// A52
	input wm_,				// A38
	output ewr,				// A51 - Enter WR
	output ewm,				// A48 - Enter WM
	output efp,			// A11
	output sar$,			// A05
	output eww,				// A41 - Enter WW
	output srez$,			// A17
	// sheet 13
	output ewx,				// A43 - Enter WX
	output axy,				// A46
	output inou,		// A39 - INOU* - IN or OU instruction
	output ekc_2,		// A40 - EKC*2 - Enter cycle end (Koniec Cyklu)
	output lac			// B43
);

	parameter INOU_USER_ILLEGAL;

	wor __NC; // unconnected signals here, to suppress warnings

	// sheet 1, page 2-30
	// * IR - instruction register

	wire ir_clk = strob1 & w_ir;
	ir REG_IR(
		.d(w),
		.c(ir_clk),
		.invalidate(si1),
		.q(ir)
	);

	// NOTE: in original design, -SI1 drives open-collector buffers which
	// short ir[0:1] to ground, causing reset of two most significant bits of IR.
	// This is a way of 'disabling' instruction decoder so it doesn't send -LIP/-SP
	// signals to interrupt control loop when serving 'invalid instruction' caused
	// by LIP/SP instructions executed in user program. Here we just reset two bits in IR.

	assign c0 = (ir[13:15] != 0);
	wire ir13_14 = (ir[13:14] != 0);
	wire ir01 = (ir[0:1] != 0);
	wire b_1 = (ir[10:12] == 1);

	// sheet 2, page 2-31
	// * decoder for 2-arg instructions with normal argument (opcodes 020-036 and 040-057)
	// * decoder for KA1 instruction group (opcodes 060-067)

	wire lw, tw, rw, pw, bb, bm, bc, bn;
	wire aw, ac, sw, cw, _or, om, nr, nm, er, em, xr, xm, cl, lb;
	wire awt, trb, irb, drb, cwt, lwt, lws, rws, js, c, s, j, l, g, b_n;
	idec1 IDEC1(
		.i(ir[0:5]),
		.o({lw, tw, ls, ri, rw, pw, rj, is, bb, bm, bs, bc, bn, ou, in, pufa, aw, ac, sw, cw, _or, om, nr, nm, er, em, xr, xm, cl, lb, rb$, cb, awt, trb, irb, drb, cwt, lwt, lws, rws, js, ka2, c, s, j, l, g, b_n})
	);

	assign sc$ = s | c;
	assign oc = ka2 & ~ir[7];
	assign gr = l | g;

	// sheet 3, page 2-32
	// * opcode field A register number decoder
	// * S opcode group decoder
	// * B/N opcode group decoder
	// * C opcode group decoder

	wire [0:7] a_eq;
	decoder8pos DEC_A_EQ(
		.i(ir[7:9]),
		.ena(1'b1),
		.o({a_eq})
	);
	wire snef = (a_eq[5:7] != 0);

	decoder8pos DEC_S(
		.i(ir[7:9]),
		.ena(s),
		.o({hlt, mcl, sin, gi, lip, __NC, __NC, __NC})
	);
	wire gmio = mcl | gi | inou;
	wire hsm = hlt | sin | __bn5;

	wire __bn5;
	decoder8pos DEC_BN(
		.i(ir[7:9]),
		.ena(b_n),
		.o({mb, im, ki, fi, sp, __bn5, rz, ib})
	);

	wire fimb = fi | im | mb;

	wire ngl, srz;
	decoder8pos DEC_D(
		.i({b_1, ir[15], ir[6]}),
		.ena(c),
		.o({__NC, __NC, __NC, __NC, ngl, srz, rpc, lpc})
	);
	wire pcrs = rpc | lpc | rc$ | sx;

	assign shc = c & ir[11];

	wire sx, __oth4, sly, slx, srxy;
	wire M85_3 = c & b0;
	decoder8pos DEC_OTHER(
		.i(ir[13:15]),
		.ena(M85_3),
		.o({rc$, zb$, sx, ng$, __oth4, sly, slx, srxy})
	);

	wire sl = slx | __oth4 | sly;
	assign b0 = (ir[10:12] == 0);

	// sheet 4, page 2-33
	// * ineffective instructions
	// * illegal instructions

	assign md = a_eq[5] & b_n;
	assign _0_v = js & a_eq[4] & we;

	wire M85_11 = ir[10] | (ir[11] & ir[12]);
	// jumper a on 1-3 : IN/OU illegal for user
	// jupmer a on 2-3 : IN/OU legal for user
	wire M27_8 = (INOU_USER_ILLEGAL & inou & q) | (M85_11 & c) | (q & s) | (q & ~snef & b_n);
	wire M40_8 = (md & mc_3) | (c & ir13_14 & b_1) | (snef & s);

	wire jjs = j | js;

	wire nef_jcs = a_eq[7] & ~r0[3];
	wire nef_jys = a_eq[6] & ~r0[7];
	wire nef_jxs = a_eq[5] & ~r0[8];
	wire nef_jvs = a_eq[4] & ~r0[2];
	wire nef_js = js & (nef_jcs | nef_jys | nef_jxs | nef_jvs);

	wire nef_jg = a_eq[3] & ~r0[6];
	wire nef_je = a_eq[2] & ~r0[5];
	wire nef_jl = a_eq[1] & ~r0[4];
	wire nef_jjs = jjs & (nef_jg | nef_je | nef_jl);

	wire nef_jn = j & a_eq[6] & r0[5];
	wire nef_jm = j & a_eq[5] & ~r0[1];
	wire nef_jz = j & a_eq[4] & ~r0[0];

	assign xi = ~(~M27_8 & ~M40_8 & ir01);
	assign nef = ~(~M27_8 & ir01 & ~M40_8 & p_ & ~nef_js & ~nef_jjs & ~nef_jm & ~nef_jn & ~nef_jz);

	// sheet 5, page 2-34

	wire cns = ccb | ng$ | sw;
	wire a = aw | ac | awt;
	assign lwrs = lws | rws;


	wire ans = sw | ng$ | a;
	assign jkrb = js | krb;
	wire M90_8 = sl | ri | krb;
	assign saryt = (we & M49_6) | (p4) | (w$ & M90_8) | ((cns ^ M90_12) & w$);
	wire riirb = ri | irb;
	assign ap1 = riirb & w$;
	wire krb = irb | drb;
	assign am1 = drb & w$;
	wire w$ = ~w$_;
	wire p4 = ~p4_;
	wire we = ~we_;

	// sheet 6, page 2-35
	// * control signals

	wire nglbb = ngl | bb;
	assign bcoc$ = bc | oc;
	wire wlsbs = wls | bs;
	wire emnm = em | nm;

	// sheet 7, page 2-36
	// * ALU control signals

	wire M90_12 = a | trb | ib;
	wire M49_6 = ~(~lwrs & ~lj & ~js & ~krb);
	assign apb = (~uka & p4) | (M90_12 & w$) | (M49_6 & we);
	assign amb = (uka & p4) | (cns & w$);

	// FIX: -WZ on <A66> was labeled as +WZ
	wire wz = ~wz_;
	wire M84_8 = riirb ^ nglbb;
	wire M67_8 = bm | is | er | xr;
	wire sds = (wz & (xm | em)) | (M67_8 & w$) | (w$ & M84_8) | (we & wlsbs);
	wire ssb = w$ & (ngl | oc | bc);

	assign sd = ~sds & ~amb;
	assign sb = ~apb & ~ssb & ~sl & ~ap1;

	wire M93_12 = sl | ls | orxr;
	wire M50_8 = (M93_12 & w$) | (w$ & nglbb) | (wlsbs & we) | (wz & ~nm & (mis | lrcb));
	wire ssab = rb$ & w$ & wpb;
	wire ssaa = (rb$ & w$ & ~wpb) | (w$ & lb);
	wire ssca = (M84_8 & w$) | (w$ & (bs | bn | nr)) | (wz & (emnm | lrcb)) | (we & ls);

	assign sca = ~ssca & ~apb & ~ssaa;
	assign scb = ~ssca & ~apb & ~ssab;
	assign saa = ~ssaa & ~amb & ~ap1 & ~M50_8;
	assign sab = ~ssab & ~amb & ~ap1 & ~M50_8;

	wire orxr = _or | xr;
	assign lrcb = lbcb | rb$;
	wire mis = m | is;
	wire lbcb = lb | cb;
	assign aryt = cw | cwt;
	wire c$ = cw | cwt | cl;
	wire ccb = c$ | cb;
	assign sbar$ = lrcb | mis | (gr & ir[7]) | bm | pw | tw;
	assign nrf = ir[7] & ka2 & ir[6];
	wire fppn = pufa ^ nrf;

	// sheet 8, page 2-37
	// * R0 flags control signals

	wire nor$ = ngl | er | nr | orxr;
	assign ust_z = (nor$ & w$) | (w$ & ans) | (m & wz);
	wire m = xm | om | emnm;
	assign ust_v = (ans ^ (ir[6] & sl)) & w$;
	assign ust_mc = ans & w$;
	assign ust_leg = ccb & w$;
	wire M59_8 = ~((ir[6] & r0[8]) | (~ir[6] & r0[7]));
	assign eat0 = ~(~srxy | M59_8) ^ ~(~shc | at15_);
	assign sr = srxy | srz | shc;
	assign ust_y = (w$ & sl) | (sr & ~shc & wx);
	wire wx = ~wx_;
	assign ust_x = ~wa_ & sx;
	wire wa = ~wa_;
	assign blr = w$ & oc & ~ir[6];

	// sheet 9, page 2-38
	// * execution phase control signals

	wire M77_8 = ng$ | ri | rj;
	assign ewa = (pcrs & ~pp_) | (M77_8 & ~pp_) | (we & (~wls & ls)) | (wpb_ & lbcb & wr);
	wire wr = ~wr_;
	wire prawy = lbcb & wpb;
	wire pp = ~pp_;
	wire wpb = ~wpb_;
	assign ewp = (lrcb & wx) | (wx & sr & ~lk) | (rj & wa) | (~pp_ & ~(~uj & ~lwlwt));
	assign uj = j & ~a_eq[7];
	assign lwlwt = lwt | lw;
	assign lj = ~(~a_eq[7] | ~j);
	assign ewe = (lj & ww) | (ls & wa) | (~pp_ & ~(~llb & ~zb$ & ~js)) | (~wzi & krb & w$);
	wire ww = ~ww_;

	// sheet 10, page 2-39
	// * execution phase control signals
	// * instruction cycle end signal

	wire M59_6 = ~(rbib | (~wzi & ~(~krb & ~is)));
	assign ekc_1 = (~lac & wr & (~grlk & ~lrcb)) | (~lrcb & wp) | (~llb & we) | (M59_6 & w$);
	wire wp = ~wp_;
	assign ewz = (w$ & ~wzi & is) | (wr & m) | (pp & lrcbsr);
	wire lrcbsr = lrcb | sr;
	wire M88_6 = is | rb$ | bmib | prawy;
	assign ew$ = (wr & M88_6) | (we & wlsbs) | (ri & ww) | (~(~ng$ & ~lbcb) & wa) | (pp & sew$);

	// sheet 11, page 2-40
	// * control signals

	assign lar$ = lb | ri | ans | trb | ls | sl | nor$ | krb;
	wire M92_12 = bc | bn | bb | trb | oc;
	assign ssp$ = is | bmib | M92_12 | bs;
	wire sew$ = M92_12 | krb | nor$ | sl | sw | a | c$;
	wire llb = bs | ls | lwrs;
	assign ka1 = (ir[0] & ir[1] & ~ir[2]) | js;
	wire uka = ka1 & ir[6]; // Ujemny Krótki Argument
	assign na = ~ka1 & ~ka2 & ~sc$ & ir01;
	assign exl = ~ir[6] & ka2 & ir[7];
	wire M63_3 = ~(ng$ & ir[6]);
	assign p16 = (M63_3 & w$ & cns) | (riirb & w$) | (ib & w$) | (slx & r0[8]) | M31_6;
	wire M31_6 = (~(~ac & M63_3) & w$ & r0[3]) | (r0[7] & sly) | (uka & p4) | (lj & we);

	// sheet 12, page 2-41
	// * execution phase control signals

	wire M60_8 = ~lk & inou;
	wire M76_3 = l ^ M60_8;
	assign ewr = (wp & lrcb) | (lk & wr & l) | (lws & we) | (M76_3 & wx) | M20_9 | M20_10;
	wire wm = ~wm_;
	wire M20_9 = M60_8 & wm;
	wire M20_10 = (fimb | lac | tw) & pp;
	assign ewm = gmio & pp;
	assign efp = fppn & pp;
	assign sar$ = l | lws | tw;
	wire M75_6 = pw | rw | lj | rz | ki;
	assign eww = (we & rws) | (pp & M75_6) | (ri & wa) | (lk & ww & g) | M33_8_9_10;
	wire M33_8_9_10 = (wx & g) | (mis & wz) | (rbib & w$);
	assign srez$ = rbib ^ mis;

	// sheet 13, page 2-42
	// * execution phase control signal
	// * instruction cycle end signal

	assign ewx = (lrcbsr & wz) | (pp & (gr ^ hsm)) | ((inou & lk) & wm) | (lk & (inou | sr) & wx);
	assign axy = sr | (ir[6] & rbib);
	wire grlk = gr & lk;
	assign inou = in | ou;
	assign ekc_2 = (wx & hsm) | (wm & ~inou) | (~grlk & ~lj & ~ri & ww) | (pcrs & wa);
	wire rbib = rb$ | ib;
	wire bmib = ib | bm;
	assign lac = bmib | mis;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
