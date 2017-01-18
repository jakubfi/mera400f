/*
	MERA-400 P-R unit (registers)

	document:	12-006368-01-8A
	unit:			P-R2-3
	pages:		2-58..2-68
	sheets:		12
*/

module p_r(
	// sheet 1
	input blr,				// A50 - BLokuj Rejestry
	input lpc,				// A94 - LPC instruction
	input wa,					// B94 - state WA
	input rpc,				// B03 - RPC instruction
	input ra,					// B48 - user register address
	input rb,					// B49 - user register address
	input as2,				// B43
	input rc,					// A49
	input w_r,				// B47
	input strob1,			// B32
	input strob2,			// B42
	// sheet 2-5
	input [0:15] w,		// B07, B12, B11, B10, B22, B24, B25, B23, B13, B19, B20, B21, B16, B08, B17, B18 - bus W
	output wand [0:15] l,	// A04, A03, A28, A27, A09, A10, A26, A25, A07, A08, A16, A17, A06, A05, A18, A19 - bus L
	// sheet 6
	input bar_nb,			// B83 - BAR->NB: output BAR register to system bus
	input w_rbb,			// A51 - RB[4:9] clock in
	input w_rbc,			// B46 - RB[0:3] clock in
	input w_rba,			// B50 - RB[10:15] clock in
	output wand [0:3] dnb,	// A86,  A90, A87, B84 - DNB: NB system bus driver
	// sheet 7
	input rpn,				// B85
	input bp_nb,			// B86
	input pn_nb,			// A92
	input q_nb,				// B90
	input w_bar,			// B56 - W->BAR: send W bus to {BAR, Q, BS} registers
	input zer_fp,			// A89
	input clm,				// B93
	input ustr0_fp,		// A11
	input ust_leg,		// B39
	input aryt,				// B45
	input zs,					// A47
	input carry,			// A48
	input s_1,				// B44
	output zgpn,			// B88
	output dpn,				// B87 - PN system bus driver
	output dqb,				// B89 - Q system bus driver
	output q,					// A53 - Q: system flag
	output zer,				// A52
	// sheet 8
	input ust_z,			// B53
	input ust_mc,			// B55
	input s0,					// B92
	input ust_v,			// A93
	input zero_v,			// B91
	output [0:8] r0,	// A44, A46, A43, A42, A41, A45, A40, A39, B09 - CPU flags in R0 register
	// sheet 9
	input exy,				// A37
	input ust_y,			// B40
	input exx,				// A38
	input ust_x,			// B41
	// sheet 10-11
	input kia,				// B81
	input kib,				// A91
	input [0:15] rz,	// B70, B76, B60, B66, A60, A64, A68, A56, B80, A80, A74, A84, A77, B74, A71, B57
										// NOTE: rz[14] is rz30, rz[15] is rz31
	input [0:15] zp,	// B68, B72, B62, B64, A62, B63, A66, A58, B78, A82, A75, A85, A78, A83, A70, A54
	input [0:9] rs,		// B69, B75, B61, B65, A61, A63, A67, A57, B79, A81
	output [0:15] ki	// B71, B77, B59, B67, A59, A65, A69, A55, B82, A79, A73, B73, A76, A88, A72, B58
);

	// sheet 1, page 2-58
	// * user register control signals

	wire __m53_6 = ~(~ra & ~rb & ~rc);
	wire __m60_6 = ~(rpc & wa);

	wire rpp = blr;
	wire rpa = ~blr & ~(__m60_6 & __m53_6);
	wire rpb = rpa;

	wire lr0 = ~(lpc & wa & strob_a);
	wire czytrw = ~blr & rc & __m60_6;
	wire wr0 = ~ra & ~rb & ~rc;
	wire czytrn = ~blr & ~rc & __m60_6 & __m53_6;
	wire __m63_12 = __m53_6 & ~rc & w_r;
	wire piszrn = (strob_a & __m63_12) | (strob_b & __m63_12);
	wire __m64_6 = rc & w_r;
	wire piszrw = (strob_a & __m64_6) | (strob_b & __m64_6);

	wire strob_a = ~(~strob1 | ~w_r);
	wire strob_b = ~(~strob2 | ~as2);

	// sheets 2..5, pages 2-59..2-62
	// * R1-R7 user registers

	wire [0:15] __l_regs;
	regs u_regs(.w(w), .l(__l_regs), .czytrn(czytrn), .piszrn(piszrn), .czytrw(czytrw), .piszrw(piszrw), .ra(ra), .rb(rb));

	// sheet 6, page 2-63
	// * RB register (binary load register)
	// * NB (BAR) register and system bus drivers
	// * R0 register positions 10-15 and system bus drivers

	wire [0:15] rRB;
	rb __rb(.w(w[10:15]), .w_rba_(~w_rba), .w_rbb_(~w_rbb), .w_rbc_(~w_rbc), .rb(rRB));

	wire [0:3] nb;
	nb __nb(.w(w[12:15]), .cnb_(~cnb0_3), .clm_(~clm), .nb(nb));
	assign dnb = nb & {4{bar_nb}};

	wire [0:15] __r0_;
	r0_9_15 u_r0_9_15(.w(w[9:15]), .lrp(lrp), .zer_(~zer), .r0_(__r0_[9:15]));

	wire [9:15] __l_r0 = ~(__r0_[9:15] & {7{rpb}});

	// sheet 7, page 2-64
	// * Q and BS flag registers and system bus drivers
	// * R0 control signals

	assign zgpn = rpn ^ 1'b1;
	assign dpn = ~((1'b0 ^ bs) & bp_nb) & ~(1'b0 & pn_nb); // NOTE: pn_nb not used due to 1cpu configuration?
	assign dqb = q_nb & q;

	wire bs;
	ffd __bs(.c(~cnb0_3), .d(w[11]), .r_(~clm), .s_(1), .q(bs));

	wire cnb0_3 = w_bar & strob1;

	ffd __q(.c(~cnb0_3), .d(w[10]), .r_(~zer), .s_(1), .q(q));

	assign zer = ~(~zer_fp & ~clm);

	wire vg = (~aryt & ~(zs | ~carry)) | (aryt & ~(zs | s_1));
	wire vl = (~aryt & ~carry) | (aryt & s_1);

	wire __m60_3 = ~(strob_a & ~ustr0_fp);
	wire __m62_6 = ~(strob_a & w_r & wr0 & ~q); // TODO: w_r is a guess (no connection on the schematic)
	wire __m62_8 = ~(strob_b & ~q & wr0 & w_r); // TODO: w_r is a guess (no connection on the schematic)
	wire __m61_12 = ~(strob_b & w_r & wr0);
	wire __m61_8 = ~(strob_a & w_r & wr0); // TODO: w_r is a guess (no connection on the schematic)

	wire w_zmvc = ~(__m60_3 & lr0 & __m62_8 & __m62_6);
	wire w_legy = ~(__m62_6 & lr0 & __m62_8);
	wire lrp = lr0 & __m61_8 & __m61_12;
	wire w8_x = ~(__m61_12 & lr0 & __m61_8);
	wire cleg = strob_b & ust_leg;

	// sheets 8..9, pages 2-65..2-66
	// * R0 register positions 0-9: CPU flags: ZMVCLEGYX

	r0 u_r0(.w(w), .r0(r0), .zs(zs), .s_1(s_1), .s0(s0), .carry(carry), .vl(vl), .vg(vg), .exy(exy), .exx(exx),
	.strob1(strob1), .ust_z(ust_z),
	.ust_v(ust_v), .ust_mc(ust_mc), .ust_y(ust_y), .ust_x(ust_x), .cleg(cleg), .w_zmvc(w_zmvc), .w_legy(w_legy),
	.w8_x(w8_x), .zero_v(zero_v), .zer(zer));

	// assignments below are on pages 2-59..2-62
	wire [0:8] __l_flags;
	wire [8:15] __l_flags2;
	assign __l_flags[0:3] = ~(~r0[0:3] & {4{rpa}});
	assign __l_flags[4:7] = ~(~r0[4:7] & {4{rpa}});
	assign __l_flags[8] = ~(~r0[8] & rpb);

	assign __l_flags2[8:11] = ~(~r0[0:3] & {4{rpp}});
	assign __l_flags2[12:15] = ~(~r0[4:7] & {4{rpp}});

	// L bus final open-collector composition
	assign l = __l_regs & {{9{1'b1}}, __l_r0} & {__l_flags, {7{1'b1}}} & {{8{1'b1}}, __l_flags2};

	// sheets 10..11, pages 2-67..2-68
	// * KI bus

	wire [0:1] sel = {kia, kib};
	assign ki =
		(sel == 2'b00) ? rz :
		(sel == 2'b01) ? {rs[0:9], bs, q, nb[0:3]} :
		(sel == 2'b10) ? rRB :
		zp;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
