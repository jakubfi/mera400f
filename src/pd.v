/*
	MERA-400 P-D unit (instruction decoder)

	document:	12-006368-01-8A
	unit:			P-D2-3
	pages:		2-30..2-43
	sheets:		14
*/

module pd(
	// sheet 1
	input [0:15] w,		// A80, A81, B78, B77, B09, B08, B35, A27, A30, A29, B15, B16, B25, B26, B13, B12 - W bus
	input strob1,			// B85
	input w_ir,				// B86 - W->IR: send bus W to instruction register IR
	output [0:15] ir,	// A78, A79, B75, B74, A19, A18, A21, A22, B17, A33, A31, A32, B30, B27, B06, B07 - IR register
	output c0,				// B05 - C=0 (opcode field C is 0 - instruction argument is stored in the next word)
	// sheet 2
	input si1_,				// B79
	output ls_,				// A91 - LS
	output rj_,				// B92 - RJ
	output bs_,				// A93 - BS
	output ou_,				// B87 - OU
	output in_,				// A88 - IN
	output is_,				// A92 - IS
	output ri_,				// B67 - RI
	output pufa,			// A85 - any of the wide or floating point arithmetic instructions
	output rb$_,			// A15 - RB*: RB instruction
	output cb_,				// B89 - CB
	output sc$,				// B90 - SC*: S|C opcode group
	output oc$_,			// B88 - OC*: BRC, BLC
	output ka2_,			// A83 - KA2 opcode group
	output gr$_,			// B47 - GR*: G|L opcode group
	// sheet 3
	output hlt,				// A34 - HLT
	output mcl_,			// B34 - MCL
	output sin_,			// B28 - SIU, SIL, SIT, CIT
	output gi_,				// A28 - GIU, GIL
	output lip_,			// A35 - LIP
	output mb_,				// B39 - MB
	output im_,				// B40 - IM
	output ki_,				// B38 - KI
	output fi_,				// B41 - FI
	output sp_,				// B37 - SP
	output rz_,				// B42 - RZ
	output ib_,				// B36 - IB
	output lpc,				// A09 - LPC
	output rpc,				// A10 - RPC
	output shc_,			// A57 - SHC
	output rc$_,			// B04 - RC*: RIC, RKY
	output ng$_,			// B03 - NG*: NGA, NGL
	output zb$_,			// B20
	output b0_,				// A25 - B=0 (opcode field B is 0 - no B-modification)
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
	output jkrb_,			// A86
	output lwrs$_,		// A67
	output saryt,			// B62 - SARYT: ALU operation mode (0 - logic, 1 - arythmetic)
	output ap1,				// A76 - AP1: register A plus 1 (for IRB)
	output am1,				// A90 - AM1: register A minus 1 (for DRB)
	// sheet 6
	input wz_,				// A66 - state WZ
	input wls,				// A70
	output bcoc$,			// A89
	// sheet 7
	output sd_,				// A69 - ALU function select
	output scb_,			// A82 - ALU function select
	output sca_,			// A71 - ALU function select
	output sb_,				// A74 - ALU function select
	output sab_,			// A73 - ALU function select
	output saa_,			// A72 - ALU function select
	output lrcb$_,		// A45
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
	output sr$_,			// B46
	output ust_y,			// A53
	output ust_x,			// A47
	output blr_,			// A87
	// sheet 9
	input wpb_,				// A58
	input wr_,				// A60
	input pp_,				// A62
	input ww_,				// B60
	input wzi,				// A59
	output ewa,				// A55 - Enter WA
	output ewp,				// A56 - Enter WP
	output uj$_,			// B18
	output lwt$_,			// B94
	output lj_,				// B50
	output ewe,				// A54 - Enter WE
	// sheet 10
	input wp_,				// A37
	output ekc_1_,		// A42
	output ewz,				// A49 - Enter WZ
	output ew$,				// A50 - Enter W&
	// sheet 11
	output lar$,			// B82
	output ssp$,			// B81
	output ka1_,			// A94
	output na_,				// A84 - Normalny Argument
	output exl_,			// A06
	output p16_,			// A36
	// sheet 12
	input lk,					// A52
	input wm_,				// A38
	output ewr,				// A51 - Enter WR
	output ewm,				// A48 - Enter WM
	output efp_,			// A11
	output sar$,			// A05
	output eww,				// A41 - Enter WW
	output srez$,			// A17
	// sheet 13
	output ewx,				// A43 - Enter WX
	output axy,				// A46
	output inou$_,		// A39 - INOU* - IN or OU instruction
	output ekc_2_,		// A40 - EKC*2 - Enter cycle end (Koniec Cyklu)
	output lac$_			// B43
);

	parameter INOU_USER_ILLEGAL = 1'b1;

	wor __NC; // unconnected signals here, to suppress warnings

	// sheet 1, page 2-30
	// * IR - instruction register

	ir REG_IR(
		.d(w),
		.c(strob1 & w_ir),
		.q(ir)
	);

	assign c0 = ~(~ir[13] & ~ir[14] & ~ir[15]);
	wire ir13_14 = ~(~ir[13] & ~ir[14]);

	// sheet 2, page 2-31
	// * decoder for 2-arg instructions with normal argument (opcodes 020-036 and 040-057)
	// * decoder for KA1 instruction group (opcodes 060-067)

	wire si11_ = si1_ & ir[0];
	wire si12_ = si1_ & ir[1];
	wire ir01 = ~(~ir[1] & ~ir[0]);

	wire lw_, tw_, rw_, pw_, bb_, bm_, bc_, bn_, pufa_;
	decoder16 DEC01(
		.en1_(si11_),
		.en2_(~ir[1]),
		.d(ir[2]), .c(ir[3]), .b(ir[4]), .a(ir[5]),
		.o_({lw_, tw_, ls_, ri_, rw_, pw_, rj_, is_, bb_, bm_, bs_, bc_, bn_, ou_, in_, pufa_})
	);
	assign pufa = ~pufa_;

	wire aw_, ac_, sw_, cw_, or_, om_, nr_, nm_, er_, em_, xr_, xm_, cl_, lb_, rb_;
	decoder16 DEC10(
		.en1_(~ir[0]),
		.en2_(si12_),
		.d(ir[2]), .c(ir[3]), .b(ir[4]), .a(ir[5]),
		.o_({aw_, ac_, sw_, cw_, or_, om_, nr_, nm_, er_, em_, xr_, xm_, cl_, lb_, rb_, cb_})
	);
	assign rb$_ = rb_;

	wire awt_, trb_, irb_, drb_, cwt_, lwt_, lws_, rws_, js_, c_, s_, j_, l_, g_, b_n_;
	decoder16 DEC11(
		.en1_(~ir[0]),
		.en2_(~ir[1]),
		.d(ir[2]), .c(ir[3]), .b(ir[4]), .a(ir[5]),
		.o_({awt_, trb_, irb_, drb_, cwt_, lwt_, lws_, rws_, js_, ka2_, c_, s_, j_, l_, g_, b_n_})
	);
	assign sc$ = ~(s_ & c_);
	wire sc_ = ~sc$;
	assign oc$_ = ~(ka2 & ~ir[7]);
	wire oc_ = oc$_;
	wire ka2 = ~ka2_;
	wire gr = ~(l_ & g_);
	assign gr$_ = ~gr;

	// sheet 3, page 2-32
	// * opcode field A register number decoder
	// * S opcode group decoder
	// * B/N opcode group decoder
	// * C opcode group decoder

	wire [1:7] a_eq_;
	decoder_bcd DEC_A_EQ(
		.a(ir[9]),
		.b(ir[8]),
		.c(ir[7]),
		.d(1'b0),
		.o_({__NC, a_eq_, __NC, __NC})
	);
	wire snef = ~(a_eq_[5] & a_eq_[6] & a_eq_[7]);

	wire hlt_;
	decoder_bcd DEC_S(
		.a(ir[9]),
		.b(ir[8]),
		.c(ir[7]),
		.d(s_),
		.o_({hlt_, mcl_, sin_, gi_, lip_, __NC, __NC, __NC, __NC, __NC})
	);
	assign hlt = ~hlt_;
	wire gmio_ = ~(mcl_ & gi_ & inou_);
	wire hsm = ~(hlt_ & sin_ & __bn5_);

	wire __bn5_;
	decoder_bcd DEC_BN(
		.a(ir[9]),
		.b(ir[8]),
		.c(ir[7]),
		.d(b_n_),
		.o_({mb_, im_, ki_, fi_, sp_, __bn5_, rz_, ib_, __NC, __NC})
	);
	wire fimb_ = fi_ & im_ & mb_;

	wire b_1 = ~ir[10] & ~ir[11] & ir[12];

	wire ngl_, srz_, lpc_, rpc_;
	decoder_bcd DEC_D(
		.a(ir[6]),
		.b(ir[15]),
		.c(b_1),
		.d(c_),
		.o_({__NC, __NC, __NC, __NC, ngl_, srz_, rpc_, lpc_, __NC, __NC})
	);
	assign lpc = ~lpc_;
	assign rpc = ~rpc_;
	wire pcrs = ~(rpc_ & lpc_ & rc$_ & sx_);
	wire c = ~c_;

	assign shc_ = ~(c & ir[11]);

	wire sx_, __oth4_, sly_, slx_, srxy_;
	wire M85_3 = ~(c & ~b0_);
	decoder_bcd DEC_OTHER(
		.a(ir[15]),
		.b(ir[14]),
		.c(ir[13]),
		.d(M85_3),
		.o_({rc$_, zb$_, sx_, ng$_, __oth4_, sly_, slx_, srxy_, __NC, __NC})
	);
	wire ng_ = ng$_;
	wire zb_ = zb$_;
	wire sl_ = slx_ & __oth4_ & sly_;
	wire sly = ~sly_;
	wire slx = ~slx_;
	wire sx = ~sx_;
	assign b0_ = ~(~ir[10] & ~ir[11] & ~ir[12]);

	// sheet 4, page 2-33
	// * ineffective instructions
	// * illegal instructions

	assign md = ~a_eq_[5] & ~b_n_;
	assign _0_v = ~js_ & ~a_eq_[4] & we;

	wire M85_11 = ~(~ir[10] & ~(ir[11] & ir[12]));
	// jumper a on 1-3 : IN/OU illegal for user
	// jupmer a on 2-3 : IN/OU legal for user
	wire M27_8 = ~((INOU_USER_ILLEGAL & inou & q) | (M85_11 & c) | (q & ~s_) | (q & ~snef & ~b_n_));
	wire M40_8 = ~((md & mc_3) | (c & ir13_14 & b_1) | (snef & ~s_));

	wire M28_6 = ~(~(r0[3] | a_eq_[7]) & ~js_); // nef JCS

	wire M2_4 = ~(r0[7] | a_eq_[6]); // nef JYS
	wire M2_1 = ~(r0[8] | a_eq_[5]); // nef JXS
	wire M2_13 = ~(r0[2] | a_eq_[4]); // nef JVS
	wire M2_10 = ~(r0[1] | j_); // nef JM
	wire M16_8 = ~((M2_4 & ~js_) | (M2_1 & ~js_) | (M2_13 & ~js_) | (~a_eq_[5] & M2_10)); // nef J1

	wire M28_11 = ~(~(a_eq_[6] | j_) & r0[5]); // nef JN
	wire M1_4 = ~(j_ | r0[0]); // nef JZ
	wire M28_3 = ~(j_ & js_);
	wire M15_8 = ~(
		(~a_eq_[4] & M1_4) |
		(M28_3 & ~(r0[6] | a_eq_[3])) | // nef JG
		(M28_3 & ~(r0[5] | a_eq_[2])) | // nef JE
		(M28_3 & ~(r0[4] | a_eq_[1])) // nef JL
	);

	assign nef = ~(M27_8 & ir01 & M40_8 & M28_6 & M16_8 & M28_11 & p_ & M15_8);
	assign xi = ~(M27_8 & M40_8 & ir01);

	// sheet 5, page 2-34

	wire cns = ~(~ccb & ng_ & sw_);
	wire amb_ = ~((uka & p4) | (cns & w$));
	assign amb = ~amb_;
	wire a_ = aw_ & ac_ & awt_;
	wire M90_12 = ~(a_ & trb_ & ib_);
	assign lwrs$_ = lws_ & rws_;
	wire lwrs_ = lwrs$_;
	wire M49_6 = ~(lwrs_ & lj_ & js_ & krb_);
	wire apb_ = ~((~uka & p4) | (M90_12 & w$) | (M49_6 & we));
	assign apb = ~apb_;
	wire ans = ~(sw_ & ng_ & a_);
	assign jkrb_ = ~(~(js_ & krb_));
	wire M90_8 = ~(sl_ & ri_ & krb_);
	assign saryt = (we & M49_6) | (p4) | (w$ & M90_8) | ((cns ^ M90_12) & w$);
	wire riirb = ~(ri_ & irb_);
	wire ap1_ = ~(riirb & w$);
	assign ap1 = ~ap1_;
	wire krb = ~(irb_ & drb_);
	wire krb_ = ~krb;
	assign am1 = ~drb_ & w$;
	wire w$ = ~w$_;
	wire p4 = ~p4_;
	wire we = ~we_;

	// sheet 6, page 2-35
	// * control signals

	// FIX: -WZ on <A66> was labeled as +WZ
	wire wz = ~wz_;
	wire M84_8 = riirb ^ nglbb;
	wire M67_8 = ~(bm_ & is_ & er_ & xr_);
	wire sds_ = ~((wz & ~(xm_ & em_)) | (M67_8 & w$) | (w$ & M84_8) | (we & wlsbs));
	wire ssb_ = ~(w$ & ~(ngl_ & oc_ & bc_));
	wire nglbb = ~(bb_ & ngl_);
	assign bcoc$ = ~(oc_ & bc_);
	wire wls_ = ~wls;
	wire wlsbs = ~(wls_ & bs_);
	wire ssca_ = ~((M84_8 & w$) | (w$ & ~(bs_ & bn_ & nr_)) | (wz & ~(emnm_ & lrcb_)) | (we & ls));
	wire ls = ~ls_;
	wire emnm_ = em_ & nm_;
	wire ssab_ = ~(~rb_ & w$ & wpb);
	wire ssaa_ = ~((~(rb_ | wpb) & w$) | (w$ & ~lb_));

	// sheet 7, page 2-36
	// * ALU control signals

	wire M93_12 = ~(sl_ & ls_ & orxr_);
	wire M50_8 = ~((M93_12 & w$) | (w$ & nglbb) | (wlsbs & we) | (wz & nm_ & ~(mis_ & lrcb_)));

	assign sd_ = ~(sds_ & amb_);
	assign scb_ = ~(apb_ & ssca_ & ssab_);
	assign sca_ = ~(ssca_ & apb_ & ssaa_);
	assign sb_ = ~(apb_ & ssb_ & sl_ & ap1_);
	assign sab_ = ~(ssab_ & amb_ & M50_8 & ap1_);
	assign saa_ = ~(ap1_ & M50_8 & amb_ & ssaa_);
	wire orxr_ = or_ & xr_;
	wire lrcb_ = lbcb_ & rb_;
	assign lrcb$_ = lrcb_;
	wire mis_ = m_ & is_;
	wire lbcb_ = lb_ & cb_;
	assign aryt = ~(cw_ & cwt_);
	wire c$_ = cw_ & cwt_ & cl_;
	wire ccb = ~(c$_ & cb_);
	assign sbar$ = ~(lrcb_ & mis_ & ~(gr & ir[7]) & bm_ & pw_ & tw_);
	assign nrf = ir[7] & ka2 & ir[6];
	wire fppn = pufa ^ nrf;

	// sheet 8, page 2-37
	// * R0 flags control signals

	wire nor$ = ~(ngl_ & er_ & nr_ & orxr_);
	assign ust_z = (nor$ & w$) | (w$ & ans) | (m & wz);
	wire m_ = xm_ & om_ & emnm_;
	wire m = ~m_;
	assign ust_v = (ans ^ (ir[6] & ~sl_)) & w$;
	assign ust_mc = ans & w$;
	assign ust_leg = ccb & w$;
	wire M59_8 = ~((ir[6] & r0[8]) | (~ir[6] & r0[7]));
	assign eat0 = ~(srxy_ | M59_8) ^ ~(shc_ | at15_);
	wire sr = ~(srxy_ & srz_ & shc_);
	assign sr$_ = ~sr;
	wire sr_ = ~sr;
	assign ust_y = (w$ & ~sl_) | (sr & shc_ & wx);
	wire wx = ~wx_;
	assign ust_x = ~wa_ & sx;
	wire wa = ~wa_;
	assign blr_ = ~(w$ & ~oc_ & ~ir[6]);

	// sheet 9, page 2-38
	// * execution phase control signals

	wire M77_8 = ~(ngl_ & ri_ & rj_);
	assign ewa = (pcrs & ~pp_) | (M77_8 & ~pp_) | (we & (wls_ & ls)) | (wpb_ & ~lbcb_ & wr);
	wire wr = ~wr_;
	wire prawy_ = ~(~lbcb_ & wpb);
	wire pp = ~pp_;
	wire wpb = ~wpb_;
	wire lrcb = ~lrcb_;
	assign ewp = (lrcb & wx) | (wx & sr & lk_) | (~rj_ & wa) | (~pp_ & ~(uj$_ & lwt$_));
	assign uj$_ = ~(~j_ & a_eq_[7]);
	assign lwt$_ = lwt_ & lw_;
	wire lj = ~(a_eq_[7] | j_);
	assign lj_ = ~lj;
	wire wzi_ = ~wzi;
	assign ewe = (lj & ww) | (ls & wa) | (~pp_ & ~(llb_ & zb_ & js_)) | (~wzi & krb & w$);
	wire ww = ~ww_;

	// sheet 10, page 2-39
	// * execution phase control signals
	// * instruction cycle end signal

	wire M59_6 = ~(rbib | (wzi_ & ~(krb_ & is_)));
	assign ekc_1_ = ~((lac_ & wr & (grlk_ & lrcb_)) | (lrcb_ & wp) | (llb_ & we) | (M59_6 & w$));
	wire wp = ~wp_;
	assign ewz = (w$ & wzi_ & ~is_) | (wr & m) | (pp & lrcbsr);
	wire lrcbsr = ~(lrcb_ & sr_);
	wire ri = ~ri_;
	wire M88_6 = ~(is_ & rb_ & bmib & prawy_);
	assign ew$ = (wr & M88_6) | (we & wlsbs) | (~ri_ & ww) | (~(ng_ & lbcb_) & wa) | (pp & sew$);

	// sheet 11, page 2-40
	// * control signals

	assign lar$ = ~(lb_ & ri_ & ~ans & trb_ & ls_ & sl_ & ~nor$ & krb_);
	wire M92_12 = (bc_ & bn_ & bb_) & trb_ & oc_;
	assign ssp$ = ~(is_ & bmib & M92_12 & bs_);
	wire sew$ = ~(M92_12 & krb_ & ~nor$ & sl_ & sw_ & a_ & c$_);
	wire llb_ = bs_ & ls_ & lwrs_;
	assign ka1_ = ~(si11_ & si12_ & ~ir[2]) & js_;
	wire uka = ~(ka1_ | ~ir[6]); // Ujemny Krótki Argument
	assign na_ = ~(ka1_ & ka2_ & sc_ & ir01);
	assign exl_ = ~(~ir[6] & ka2 & ir[7]);
	wire M63_3 = ~(~ng_ & ir[6]);
	assign p16_ = ~((M63_3 & w$ & cns) | (riirb & w$) | (~ib_ & w$) | (slx & r0[8]) | M31_6);
	wire M31_6 = (~(ac_ & M63_3) & w$ & r0[3]) | (r0[7] & sly) | (uka & p4) | (lj & we);

	// sheet 12, page 2-41
	// * execution phase control signals

	wire M60_8 = (~lk & inou);
	wire M76_3 = ~l_ ^ M60_8;
	assign ewr = (wp & lrcb) | (lk & wr & ~l_) | (~lws_ & we) | (M76_3 & wx) | M20_9 | M20_10;
	wire M20_9 = M60_8 & ~wm_;
	wire M20_10 = ~(fimb_ & lac_ & tw_) & pp;
	assign ewm = gmio_ & pp;
	assign efp_ = ~(fppn & pp);
	wire lk_ = ~lk;
	wire wm = ~wm_;
	assign sar$ = ~(l_ & lws_ & tw_);
	wire M75_6 = ~((pw_ & rw_) & lj_ & rz_ & ki_);
	assign eww = (we & ~rws_) | (pp & M75_6) | (ri & wa) | (lk & ww & ~g_) | M33_8_9_10;
	wire M33_8_9_10 = (wx & ~g_) | (~mis_ & wz) | (rbib & w$);
	assign srez$ = rbib ^ ~mis_;

	// sheet 13, page 2-42
	// * execution phase control signal
	// * instruction cycle end signal

	assign ewx = (lrcbsr & wz) | (pp & (gr ^ hsm)) | ((inou & lk) & wm) | (lk & ~(inou_ & sr_) & wx);
	assign axy = ~(sr_ & ~(ir[6] & rbib));
	wire grlk_ = ~(gr & lk);
	wire inou = ~(in_ & ou_);
	wire inou_ = ~inou;
	assign inou$_ = inou_;
	assign ekc_2_ = ~((wx & hsm) | (wm & inou_) | ((grlk_ & lj_) & ri_ & ww) | (pcrs & wa));
	wire rbib = ~(rb_ & ib_);
	wire bmib = ib_ & bm_;
	wire lac_ = bmib & mis_;
	assign lac$_ = lac_;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
