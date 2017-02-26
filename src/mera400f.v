module mera400f(
	input CLK_EXT,
	input RXD,
	output TXD,
	input K1, K2, K3, K4,
	output [7:0] DIG,
	output [7:0] SEG,
	output [15:0] DEBUG,
	output BUZZER
);

// -----------------------------------------------------------------------
// --- CPU ---------------------------------------------------------------
// -----------------------------------------------------------------------

	assign BUZZER = 1;

	// input: from power supply (?)
	wire off_ = 1; // 09 B71 -- 11 Y32 -- 23 Z52 -- 24 R52 / 22 P21 -- 09 B41
	wire pon_ = 0; // 05 A12 -- 23 Z41 -- 24 R41
	wire pout_ = 1; // 07 A24 -- 23 Z42 -- 24 R42

	// input: ??
	wire clm_ = 1; // 23 Z09 -- 24 R09
	wire clo_ = 1; // 09 W80 -- 23 Z08 -- 24 R08 -- 12 X70

	// output: to system bus - drivers
	// -DCL // 11 Y15 -- 22 P39 -- 23 Z40 -- 24 R40
	// -DM-CL // 04 B88 -- 11 Y16
	wire dw_;
	wire dr_;
	wire ds_;
	wire df_;
	wire din_;
	wire dok_;
	wire dqb_;
	wire dpn_;
	wire [0:3] dnb_;
	wire [0:15] dad_;
	wire [0:15] ddt_;
	// input: from system bus - receivers
	wire rpa_ = 1;
	// -RCL
	// -OFF
	wire rin_ = 1;
	wire rok_ = 1;
	wire ren_ = 1;
	wire rpe_ = 1;
	wire rpn_ = 1;
	wire [0:15] rdt_ = 16'hbeef;
	wire zg;
	wire zw = 0;
	wire zz_ = 0;

	// output: to control panel
	wire p0_;
	wire [0:15] w;
	wire hlt_n_, p_, run, wait_, irq, q, mc_, awaria_;

	cpu #(
		.CPU_NUMBER(1'b0),
		.AWP_PRESENT(1'b0),
		.INOU_USER_ILLEGAL(1'b1),
		.STOP_ON_NOMEM(1'b1),
		.LOW_MEM_WRITE_DENY(1'b0)
	)
	CPU0(
		// FPGA
		.__clk(CLK_EXT),
		.DEBUG(DEBUG),
		// control panel
		.off_(off_),
		.pon_(pon_),
		.pout_(pout_),
		.clm_(clm_),
		.clo_(clo_),
		.kl(kl),
		.panel_store_(panel_store_),
		.panel_fetch_(panel_fetch_),
		.panel_load_(panel_load_),
		.panel_bin_(panel_bin_),
		.oprq_(oprq_),
		.stop$_(stop$_),
		.start$_(start$_),
		.work(work),
		.mode_(mode_),
		.step_(step_),
		.stop_n(stop_n),
		.cycle_(cycle_),
		.wre(wre_),
		.rsa(rsa),
		.rsb(rsb),
		.rsc(rsc),
		.wic(wic),
		.wac(wac),
		.war(war),
		.wir(wir),
		.wrs(wrs),
		.wrz(wrz),
		.wkb(wkb),
		.zegar_(zegar_),
		.p0_(p0_),
		.w(w),
		.hlt_n_(hlt_n_),
		.p_(p_),
		.run(run),
		.wait_(wait_),
		.irq(irq),
		.q(q),
		.mc_(mc_),
		.awaria_(awaria_),
		// system bus
		.rpa_(rpa_),
		.dw_(dw_),
		.dr_(dr_),
		.ds_(ds_),
		.df_(df_),
		.din_(din_),
		.rin_(rin_),
		.dok_(dok_),
		.rok_(rok_),
		.ren_(ren_),
		.rpe_(rpe_),
		.dqb_(dqb_),
		.dpn_(dpn_),
		.rpn_(rpn_),
		.dnb_(dnb_),
		.dad_(dad_),
		.ddt_(ddt_),
		.rdt_(rdt_),
		// ssytem bus reservation
		.zg(zg),
		.zw(zw),
		.zz_(zz_),
	);

// -----------------------------------------------------------------------
// --- P-K ---------------------------------------------------------------
// -----------------------------------------------------------------------

	wire kl;
	wire zegar_;
	wire wre_, rsa, rsb, rsc;
	wire wic, wac, war, wir, wrs, wrz, wkb;
	wire panel_store_, panel_fetch_, panel_load_, panel_bin_;
	wire oprq_, stop$_, start$_, work, mode_, step_, stop_n, cycle_;
	wire dcl_;

	pk #(.TIMER_CYCLE_MS(10)) PK(
		.CLK_EXT(CLK_EXT),
		.RXD(RXD),
		.TXD(TXD),
		.SEG(SEG),
		.DIG(DIG),
		.hlt_n_(hlt_n_),
		.off_(off_),
		.work(work),
		.stop$_(stop$_),
		.start$_(start$_),
		.mode(mode),
		.stop_n(stop_n),
		.p0_(p0_),
		.kl(kl),
		.dcl_(dcl_),
		.step_(step_),
		.fetch_(panel_fetch_),
		.store_(panel_store_),
		.cycle_(cycle_),
		.load_(panel_load_),
		.bin_(panel_bin_),
		.oprq_(oprq_),
		.zegar_(zegar_),
		.w(w),
		.p_(p_),
		.mc_(mc_),
		.alarm_(awaria_),
		.wait_(wait_),
		.irq(irq),
		.q(q),
		.run(run),
		.wre_(wre_),
		.rsa(rsa),
		.rsb(rsb),
		.rscrsc(),
		.wic(wic),
		.wac(wac),
		.war(war),
		.wir(wir),
		.wrs(wrs),
		.wrz(wrz),
		.wkb(wkb),
		.ir0(1'b0)
	);

// -----------------------------------------------------------------------
// --- POWER  SUPPLY -----------------------------------------------------
// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
// --- I/F ---------------------------------------------------------------
// -----------------------------------------------------------------------


endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
