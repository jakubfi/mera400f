/*
	MERA-400 P-R unit

	document:	12-006368-01-8A
	unit:			P-R2-3
	pages:		2-58..2-68
*/

module p_r(
	input blr,				// A50
	input lpc,				// A94
	input wa,					// B94
	input rpc,				// B03
	input ra,					// B48
	input rb,					// B49
	input as2,				// B43
	input rc,					// A49
	input w_r,				// B47
	input strob1,			// B32
	input strob2,			// B42

	input [0:15] w,		// B07, B12, B11, B10, B22, B24, B25, B23, B13, B19, B20, B21, B16, B08, B17, B18
	output wand [0:15] l,	// A04, A03, A28, A27, A09, A10, A26, A25, A07, A08, A16, A17, A06, A05, A18, A19

	input bar_nb,			// B83
	input w_rbb,			// A51
	input w_rbc,			// B46
	input w_rba,			// B50
	output wand [0:3] dnb,	//A86,  A90, A87, B84

	input rpn,				// B85
	input bp_nb,			// B86
	input pn_nb,			// A92
	input q_nb,				// B90
	input w_bar,			// B56
	input zer_fp,			// A89
	input clm,				// B93
	input ustr0_fp,		// A11
	input ust_leg,		// B39
	input aryt,				// B45
	input zs,					// A47
	input carry,			// A48
	input s_1,				// B44
	output zgpn,			// B88
	output dpn,				// B87
	output dqb,				// B89
	output q,					// A53
	output zer,				// A52

	input ust_z,			// B53
	input ust_mc,			// B55
	input s0,					// B92
	input ust_v,			// A93
	input zero_v,			// B91
	output [0:8] r0,	// A44, A46, A43, A42, A41, A45, A40, A39, B09

	input exy,				// A37
	input ust_y,			// B40
	input exx,				// A38
	input ust_x,			// B41

	input kia,				// B81
	input kib,				// A91
	input [0:15] rz,	// B70, B76, B60, B66, A60, A64, A68, A56, B80, A80, A74, A84, A77, B74, A71, B57
										// NOTE: rz[14] is rz30, rz[15] is rz31
	input [0:15] zp,	// B68, B72, B62, B64, A62, B63, A66, A58, B78, A82, A75, A85, A78, A83, A70, A54
	input [0:9] rs,		// B69, B75, B61, B65, A61, A63, A67, A57, B79, A81
	output [0:15] ki	// B71, B77, B59, B67, A59, A65, A69, A55, B82, A79, A73, B73, A76, A88, A72, B58
);

	// page 2-58 - user register control signals

	wire __rabc_ = ~(~ra & ~rb & ~rc);
	wire __rpcwa_ = ~(rpc & wa);

	wire rpp = blr;
	wire rpa = ~blr & ~(__rpcwa_ & __rabc_);
	wire rpb = rpa;
	wire lro = ~(lpc & wa & strob_a);
	wire czytrw = ~blr & rc & __rpcwa_;
	wire wr0 = ~ra & ~rb & ~rc;
	wire czytrn = ~blr & ~rc & __rpcwa_ & __rabc_;
	wire __piszrn = __rabc_ & ~rc & w_r;
	wire piszrn = (strob_a & __piszrn) | (strob_b & __piszrn);
	wire __piszrw = rc & w_r;
	wire piszrw = (strob_a & __piszrw) | (strob_b & __piszrw);

	wire strob_a = ~(~strob1 | ~w_r);
	wire strob_b = ~(~strob2 | ~as2);

	// pages 2-59..2-62 - R1-R7 registers

	wire [0:15] _l;
	assign l = _l;
	regs u_regs(.w(w), .l(_l), .czytrn(czytrn), .piszrn(piszrn), .czytrw(czytrw), .piszrw(piszrw), .ra(ra), .rb(rb));

	// page 2-63 - RB register (binary load register), NB/Q/BS register, R0 register (positions 10-15)

	wire [0:15] rRB;
	wire [0:15] __r0;
	rb u_rb(.w(w[10:15]), .w_rba(w_rba), .w_rbb(w_rbb), .w_rbc(w_rbc), .rb(rRB));
	wire [0:3] nb;
	reg [0:3] __nb;
	always @ (negedge cnb0_3, negedge clm) begin
		if (~clm) __nb = 0;
		else __nb = w[12:15];
	end
	assign nb = __nb;
	assign dnb = ~(nb & {4{bar_nb}});
	r0_9_15 u_r0_9_15(.w(w[9:15]), .lrp(lrp), .zer(zer), .r0(__r0[9:15]));
	assign l[9:15] = ~(~__r0[9:15] & {7{rpb}});

	// page 2-64 - Q and BS flags, R0 control signals

	assign zgpn = rpn ^ 1'b1;
	assign dpn = ~((1'b0 ^ bs) & bp_nb) & ~(1'b0 & pn_nb);
	assign dqb = q_nb & q;
	reg __bs;
	always @ (negedge cnb0_3, negedge clm) begin
		if (~clm) __bs = 1'b0;
		else __bs <= w[11];
	end
	wire bs = __bs;
	wire cnb0_3 = w_bar & strob1;
	reg __q;
	always @ (negedge cnb0_3, negedge zer) begin
		if (~zer) __q = 1'b0;
		else __q <= w[10];
	end
	assign q = __q;
	assign zer = ~(~zer_fp & ~clm);

	wire vg = (~aryt & ~(zs & ~carry)) | (~(zs & s_1));
	wire vl = (~aryt & ~carry) | (aryt & s_1);

	wire __s_ustr0_fp_ = ~(strob_a & ~ustr0_fp);
	wire __s_wr0_a = ~(strob_a & w_r & wr0 & ~q); // TODO: w_r is a guess (no connection on the schematic)
	wire __s_wr0_b = ~(strob_b & ~q & wr0 & w_r); // TODO: w_r is a guess (no connection on the schematic)
	wire __s_wr_b = ~(strob_b & w_r & wr0);
	wire __s_wr_a = ~(strob_a & w_r & wr0); // TODO: w_r is a guess (no connection on the schematic)
	// TODO: q, zer, clm, ...
	wire w_zmvc = ~(__s_ustr0_fp_ & lro & __s_wr0_b & __s_wr0_a);
	wire w_legy = ~(__s_wr0_a & lro & __s_wr0_b);
	wire lrp = lro & __s_wr_a & __s_wr_b;
	wire w8_x = ~(__s_wr_b & lro & __s_wr_a);
	wire cleg = strob_b & ust_leg;

	// pages 2-65..2-66 - R0 register (positions 0-9)
	r0 u_r0(.w(w), .r0(r0), .zs(zs), .s_1(s_1), .s0(s0), .carry(carry), .vl(vl), .vg(vg), .exy(exy), .exx(exx),
	.strob1(strob1), .ust_z(ust_z),
	.ust_v(ust_v), .ust_mc(ust_mc), .ust_y(ust_y), .ust_x(ust_x), .cleg(cleg), .w_zmvc(w_zmvc), .w_legy(w_legy),
	.w8_x(w8_x), .zero_v(zero_v), .zer(zer));
	// assignments below are on pages 2-59..2-62
	assign l[0:3] = ~(~r0[0:3] & {4{rpa}});
	assign l[4:7] = ~(~r0[4:7] & {4{rpa}});
	assign l[8] = ~(~r0[8] & rpb);
	assign l[8:11] = ~(~r0[0:3] & {4{rpp}});
	assign l[12:15] = ~(~r0[4:7] & {4{rpp}});

	// pages 2-67..2-68 - KI bus
	wire [0:1] sel = {kia, kib};
	assign ki =
		(sel == 2'b00) ? rz :
		(sel == 2'b01) ? {rs[0:9], bs, q, nb[0:3]} :
		(sel == 2'b10) ? rb :
		zp;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
