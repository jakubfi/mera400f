module mera400f(
	// from power supply (?)
	input off_,
	input pon_,
	input pout_,

	// ??
	input clm_, clo_,

	// from control panel
	input kl,
	input panel_store_, panel_fetch_, panel_load_, panel_bin_,
	input oprq_, stop$_, start$_, work, mode_, step_, stop_n, cycle_,
	input wre, rsa, rsb, rsc,
	input wic, wac, war, wir, wrs, wrz, wkb,
	input zegar_,
	// to control panel
	output p0_,
	output [0:15] w,

	// system bus
											input rpa_,
	// -DCL/-DM-CL			-RCL
	// -OFF
	output dw_,
	output dr_,
	output ds_,
	output df_,
	output din_,				input rin_,
	output dok_,				input rok_,
											input ren_,
											input rpe_,
	output dqb_,
	output dpn_,				input rpn_,
	output [0:3] dnb_,
	output [0:15] dad_,
	output [0:15] ddt_,	input [0:15] rdt_,
	output zg,
											input zw,
	output zz_,

	input [0:30] awp_dummy,

	input CLK_EXT
);

// -----------------------------------------------------------------------
// --- CPU ---------------------------------------------------------------
// -----------------------------------------------------------------------

	cpu #(
		.CPU_NUMBER(1'b0),
		.AWP_PRESENT(1'b1),
		.INOU_USER_ILLEGAL(1'b1),
		.STOP_ON_NOMEM(1'b1),
		.LOW_MEM_WRITE_DENY(1'b0)
	)
	CPU0(
		.off_(off_), .pon_(pon_), .pout_(pout_),
		.clm_(clm_), .clo_(clo_),
		.kl(kl),
		.panel_store_(panel_store_), .panel_fetch_(panel_fetch_), .panel_load_(panel_load_), .panel_bin_(panel_bin_),
		.oprq_(oprq_), .stop$_(stop$_), .start$_(start$_), .work(work), .mode_(mode_), .step_(step_), .stop_n(stop_n), .cycle_(cycle_),
		.wre(wre), .rsa(rsa), .rsb(rsb), .rsc(rsc),
		.wic(wic), .wac(wac), .war(war), .wir(wir), .wrs(wrs), .wrz(wrz), .wkb(wkb),
		.zegar_(zegar_),
		.p0_(p0_),
		.w(w),
		.rpa_(rpa_), .dw_(dw_), .dr_(dr_), .ds_(ds_), .df_(df_), .din_(din_), .rin_(rin_), .dok_(dok_), .rok_(rok_), .ren_(ren_), .rpe_(rpe_), .dqb_(dqb_), .dpn_(dpn_), .rpn_(rpn_),
		.dnb_(dnb_), .dad_(dad_), .ddt_(ddt_), .rdt_(rdt_), .zg(zg), .zw(zw), .zz_(zz_),
		.awp_dummy(awp_dummy),
		.__clk(CLK_EXT)
	);

// -----------------------------------------------------------------------
// --- P-K ---------------------------------------------------------------
// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
// --- I/F ---------------------------------------------------------------
// -----------------------------------------------------------------------


endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
