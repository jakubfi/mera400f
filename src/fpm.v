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
	output [1:7] d,
	// sheet 2
	input fcb_,
	input scc_,
	input pc8,
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
	output ff_,
	output ss,
	output puf,
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
	input f13,
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
	input t39_,
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

	parameter FP_FI0_TICKS;

	// sheet 1

	wire lkb = ~lkb_;
	wire [2:1] D_SWM;
	wire [0:7] D_SW;
	always @ (*) begin
		case (lkb)
			0: {D_SWM, D_SW} <= {sum_c_2, sum_c_1, sum_c};
			1: {D_SWM, D_SW} <= {w[8], w[8], w[8:15]};
		endcase
	end

	reg [0:7] D;
	reg D_1, D_2;
	wire _0_d_ = ~_0_d;
	always @ (posedge l_d_, negedge _0_d_) begin
		if (~_0_d_) {D_2, D_1, D} <= 10'd0;
		else {D_2, D_1, D} <= {D_SWM, D_SW};
	end

	wire d_2_ = ~D_2;
	assign d_2 = D_2;
	wire d_1_ = ~D_1;
	assign d_1 = D_1;
	assign d0 = D[0];
	wire d0_ = ~D[0];
	assign d = D[1:7];

	// sheet 2

	reg [0:7] DL;
	always @ (posedge f2strob) begin
		DL <= D;
	end

	wire [0:7] DSUM;

	always @ (*) begin
		case ({~fcb_, ~scc_})
			2'b00: DSUM <= ~DL;
			2'b01: DSUM <= DL;
			2'b10: DSUM <= 8'hff;
			2'b11: DSUM <= 8'h00;
		endcase
	end

	wire [0:7] sum_c;
	wire M29_14;
	always @ (*) begin
		{M29_14, sum_c} <= DSUM + D + pc8;
	end

	wire M9_3 = fcb_ ^ scc_;
	wire M3_6 = ~((DL[0] & M9_3) | (~DL[0] & scc_));
	wire M27_8 = M3_6 ^ d_1_;
	wire sum_c_2 = ~((M29_14 & M3_6) | (M29_14 & d_1_) | (M3_6 & d_1_));
	wire sum_c_1 = M29_14 ^ M27_8;

	// sheet 3

	wire M68_11 = sum_c_ge_40 & sum_c_1_;
	wire M57_8 = ~(f5_af_sf & strob_fp);
	wire M35_6 = ~(f2 & t_ & strob_fp & af_sf);

	ffd REG_G(
		.s_(1),
		.d(sum_c_ge_40),
		.c(M57_8),
		.r_(_0_f_),
		.q(g)
	);

	ffd REG_WDT(
		.s_(1),
		.d(sum_c_1),
		.c(M57_8),
		.r_(_0_f_),
		.q(wdt)
	);

	wire wt_ = ~wt;
	ffd REG_WT(
		.s_(M35_6),
		.d(M68_11),
		.c(M57_8),
		.r_(_0_f_),
		.q(wt)
	);

	wire cda = ~(~wdt & strob_fp & f8);
	wire cua_ = ~(wdt & f8 & strob_fp);
	wire f8_n_wdt = ~wdt & f8;
	wire cd$_ = ~(f8 & strob_fp);
	wire rab_ = ~(~(g & strob2_fp & ~f5_) & _0_f_);

	wire f5_af_sf = af_sf & ~f5_;
	wire f2 = ~f2_;
	wire f2strob = f2 & strob_fp;
	wire strob_fp = ~strob_fp_;

	// sheet 4

	wire M57_3 = ~(mf & f4);
	wire M43_8 = ~(df & f4);
	wire M46_11 = ~(sum_c[7] & f5_af_sf);
	wire M46_8 = ~(f5_af_sf & sum_c[6]);
	wire M46_6 = ~(f5_af_sf & sum_c[5]);
	wire M46_3 = ~(f5_af_sf & sum_c[4]);
	wire M43_3 = ~(f5_af_sf & sum_c[3]);
	wire M57_6 = ~(mw & f4);
	wire M43_6 = ~(f5_af_sf & sum_c[2]);
	wire M57_11 = ~(f4 & dw);

	wire M54_8 = ~(M46_11 & M57_11 & M57_3);
	wire M69_8 = ~(M57_3 & M46_8);
	wire M59_3 = ~(M57_3 & M46_6);
	wire M59_6 = ~(M43_8 & M46_3);
	wire M54_6 = ~(M57_11 & M43_3 & M57_6);
	wire M58_12 = ~(M57_3 & M43_6 & M43_8);

	wire M55_6 = ~((f4 & strob_fp) | (f5_af_sf & strob_fp));

	wire [0:5] FIC;
	fic CNT_FIC(
		.cda(cda),
		.cua_(cua_),
		.rab_(rab_),
		.load_(M55_6),
		.in({M58_12, M54_6, M59_6, M59_3, M69_8, M54_8}),
		.out(FIC)
	);

	wire M71_6 = ~(FIC[5] | FIC[4]);
	wire M71_1 = ~(FIC[3] | FIC[2]);
	wire M75_1 = ~(FIC[1] | FIC[0]);

	assign fic_ = M71_1 & M71_6 & M75_1;
	assign fic = ~fic_;

	// sheet 5

	assign c_f = (df_ & ff & m_1) | (r03 & mwdw) | (ad_sd & ci);
	assign v_f = (r02) | (t0_t1 & mwadsd);
	assign m_f = ~((t_1_ & dw_) | (t16_ & dw));
	wire M77_11 = t_24_31_ & t_16_23_;
	assign z_f = (M77_11 & dw) | (mwadsd & t_) | (ff & fwz);
	assign dw = ~dw_;

	wire sum_c_1_ = ~sum_c_1;

	wire M44_6 = ~(sum_c_1_ & sum_c[4] & sum_c[2]);
	wire M44_12 = ~(sum_c[2] & sum_c_1_ & sum_c[3]);
	wire M27_3 = sum_c_1_ ^ sum_c[1];
	wire M27_11 = sum_c_1_ ^ sum_c[0];

	wire M44_8 = ~(~(sum_c[7] | sum_c[6]) & ~(sum_c[5] | sum_c[2]) & sum_c_1);
	wire M17_3 = ~(~(sum_c[2] | sum_c[4]) & sum_c_1);
	wire M17_11 = ~(~(sum_c[2] | sum_c[3]) & sum_c_1);

	wire sum_c_ge_40 = ~(M44_6 & M44_12 & M27_3 & M27_11 & M44_8 & M17_3 & M17_11);

	// sheet 6
	// instruction decoder

	wire ad_, af_, sf_;
	assign ad = ~ad_;
	assign af = ~af_;
	assign sf = ~sf_;
	wire df = ~df_;
	decoder_bcd ID(
		.a(ir[9]),
		.b(ir[8]),
		.c(ir[7]),
		.d(~pufa),
		.o_({ad_, sd$_, mw_, dw_, af_, sf_, mf_, df_, __NC, __NC})
	);

	wire f9df = df & f9;
	assign dw_df = ~(df_ & dw_);
	assign mw_mf = ~(mf_ & mw_);
	assign af_sf_ = sf_ & af_;
	wire mwdw = ~(dw_ & mw_);
	assign ad_sd = ~(sd$_ & ad_);
	wire mwadsd = ~(mw_ & sd$_ & ad_);

	wire nrf_ = ~nrf;
	wire ff = ~ff_;
	assign ff_ = ~(nrf | ir[7]);
	assign ss = ~(ir[7] | ~pufa);
	assign puf = ~(~pufa & nrf_);

	// sheet 7

	wire af_sf = ~af_sf_;

	wire M63_8 = (mw_mf & f2) | (~f10_) | (af_sf_ & f4) | (f4 & wt);
	wire M68_8 = M63_8 & strob_fp;
	wire M49_8 = ~(strob_fp & ~f7_ & ad_sd);
	wire M72_8 = ~f10_ & strob_fp;
	wire M47_6 = ok & df_ & m_1 & ~_end;

	ffd REG_FWZ(
		.s_(1),
		.d(t_),
		.c(M68_8),
		.r_(_0_f_),
		.q(fwz)
	);

	wire ci;
	ffd REG_CI(
		.s_(1),
		.d(~fp0_),
		.c(M49_8),
		.r_(_0_f_),
		.q(ci)
	);

	ffd REG_END(
		.s_(1),
		.d(ws),
		.c(~f7_),
		.r_(_0_f_),
		.q(_end)
	);

	wire ws;
	assign ws_ = ~ws;
	ffd REG_WS(
		.s_(1),
		.d(M47_6),
		.c(M72_8),
		.r_(_0_f_),
		.q(ws)
	);

	wire f6_f7 = ~(f7_ & f6_);

	// sheet 8

	wire M64_8 = (nrf_ & nz & f4) | (f2 & (dw_df & ~t)) | (nz & f2);
	assign fi3_ = ~(strob_fp & M64_8);
	wire M49_12 = ~(idi & ~f6_ & strob2_fp);
	wire M49_6 = ~(strob_fp & lp_ & f8);
	wire M35_8 = ~(f4 & af_sf & wt_ & t_);

	ffd REG_DI(
		.s_(fi3_),
		.d(beta),
		.c(M49_12),
		.r_(_0_f_),
		.q(di)
	);

	wire idi;
	ffd REG_IDI(
		.s_(1),
		.d(dw),
		.c(f4),
		.r_(M49_6),
		.q(idi)
	);

	wire wc;
	assign wc_ = ~wc;
	ffd REG_WC(
		.s_(M35_8),
		.d(1),
		.c(1),
		.r_(_0_f_),
		.q(wc)
	);

	wire M20_13;
	univib #(.ticks(FP_FI0_TICKS)) VIB_FI0(
		.clk(__clk),
		.a_(~M49_12),
		.b(1),
		.q(M20_13)
	);

	assign fi0_ = ~(di & M20_13);

	wire t_ = ~t;
	wire f8 = ~f8_;
	wire M69_3 = ff & f13;
	assign fi1_ = ~(M69_3 & d_2 & ~(d0 & d_1));
	assign fi2_ = ~(M69_3 & ~(d_1_ & d0_) & d_2_);

	// sheet 9

	wire M3_8 = ~((fab_ & fc0_) | (faa_ & ~fc0_));
	wire M53_6 = M3_8 ^ t_1;
	wire M53_8 = fp0_ ^ M53_6;
	wire M40_8 = ~((w0_ & lkb) | (sgn_ & f9df) | (t_1_t_1 & t_1_) | (f6_f7 & M53_8));
	wire M52_8 = ~((mw_mf & mfwp) | (t0_t1 & dw_df));
	wire M67_3 = ~(t1_ & t0_);
	wire M12_8 = t_32_39_ & t_24_31_ & t_16_23_ & t_8_15_;
	wire M25_6 = ~(t_8_15_ & t_2_7_ & t_0_1_ & t_1_);
	wire M24_8 = ~(t_1_ & t_0_1_ & t_2_7_ & t_8_15_ & t_16_23_ & t_24_31_ & t_32_39_ & m_1_);
	wire M25_8 = ~(M12_8 & dw_df & M67_3 & t_2_7_);
	wire M66_8 = ~(c0_eq_c1 & dw & M25_6);

	wire t_1_ = ~t_1;
	ffd REG_T_1(
		.s_(1),
		.d(M40_8),
		.c(clockta_),
		.r_(~_0_t),
		.q(t_1)
	);

	assign t0_t_1 = t_1_ ^ t0_;
	wire M53_3 = t_1 ^ t0_;
	assign ok = M53_3 & t0_t1 & t & ff;
	assign nz = ~t0_t1 & M53_3 & ff & t;
	assign opsu = ~(M52_8 & M25_8 & M66_8);
	assign ta = M25_6;
	wire t = M24_8;

	// sheet 10

	wire M22_8 = (~trb_ & ~t39_) | (~m0_ & ~mb) | (t_1 & f4) | (af & ~c39_ & f8_n_wdt) | (sf & f8_n_wdt & M9_6);

	wire m_1_ = ~m_1;
	ffd REG_M_1(
			.s_(1),
			.d(M22_8),
			.c(~clockm),
			.r_(~_0_m),
			.q(m_1)
	);

	wire M70_11 = ~(f4 & sf);
	wire M77_6 = c39_ & ck;
	wire M9_6 = ck ^ c39_;

	wire ck;
	assign ck_ = ~ck;
	ffd REG_CK(
		.s_(M70_11),
		.d(M77_6),
		.c(~clockm),
		.r_(~_0_m),
		.q(ck)
	);

	wire f4 = ~f4_;

	wire M13_6 = ~((m39_ & mf) | (m15_ & mw));
	wire M13_8 = ~((m38_ & mf) | (m14_ & mw));
	wire M52_6 = ~((M13_6 & ~pm) | (M13_8 & mfwp));

	wire pm;
	ffd REG_PM(
		.s_(1),
		.d(M52_6),
		.c(~clockm),
		.r_(~_0_m),
		.q(pm)
	);

	wire mfwp = M13_6 ^ ~pm;
	wire mf = ~mf_;
	wire mw = ~mw_;

	// sheet 11

	wire d$;
	ffd REG_D$(
		.s_(~f6_f7),
		.d(0),
		.c(cd$_),
		.r_(_0_f_),
		.q(d$)
	);

	wire M38_8 = d$ ^ M39_8;
	wire M38_6 = ~d$ ^ M39_8;
	assign m_40 = M38_8 & f8 & df;
	assign m_32 = ~((M38_6 & dw) | (dw_ & m32_));
	assign sgn_t0_c0 = t0_c0 ^ sgn;

	wire sgn;
	assign sgn_ = ~sgn;
	ffd REG_SGN(
		.s_(1),
		.d(t0_c0),
		.c(f4),
		.r_(_0_f_),
		.q(sgn)
	);

	wire M39_8 = ~((sgn_ & t_) | (~t0_c0 & t));
	wire M38_11 = M38_8 ^ sgn;
	wire M6_12 = ~(sgn & t_ & lp_);
	wire beta = M38_11 & M6_12;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
