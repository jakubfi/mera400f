/*
	MERA-400 system
*/

// external board clock frequency in Hz
`define CLK_EXT_HZ 50_000_000

module mera400f(
	input CLK_EXT,
	output BUZZER,
	// control panel
	input RXD,
	output TXD,
	output [7:0] DIG,
	output [7:0] SEG,
	// RAM
	output SRAM_CE, SRAM_OE, SRAM_WE, SRAM_UB, SRAM_LB,
	output [17:0] SRAM_A,
	inout [15:0] SRAM_D,
	output F_CS, F_OE, F_WE
);

	// FPGA cruft
	assign BUZZER = 1;

// -----------------------------------------------------------------------
// --- CPU ---------------------------------------------------------------
// -----------------------------------------------------------------------

	// output: to system bus - drivers
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
	wire dmcl_;
	// input: from system bus - receivers
	wire rpa_ = 1;
	wire rin_ = 1;
	wire rok_;
	wire ren_ = 1;
	wire rpe_ = 1;
	wire rpn_ = 1;
	wire [0:15] rdt_;
	wire zg;
	wire zw = zg;
	wire zz;

	// output: to control panel
	wire p0_;
	wire [0:15] w;
	wire hlt_n, p_, run, _wait, irq, q, mc_0, awaria;

	cpu #(
		.CPU_NUMBER(1'b0),
		.AWP_PRESENT(1'b1),
		.INOU_USER_ILLEGAL(1'b1),
		.STOP_ON_NOMEM(1'b1),
		.LOW_MEM_WRITE_DENY(1'b0),
		.STROB1_1_TICKS(3'd5),
		.STROB1_2_TICKS(3'd6),
		.STROB1_3_TICKS(3'd5),
		.STROB1_4_TICKS(3'd5),
		.STROB1_5_TICKS(3'd5),
		.GOT_TICKS(3'd5),
		.STROB2_TICKS(3'd6),
		.KC_TICKS(3'd7),
		.PC_TICKS(3'd6),
		.ALARM_DLY_TICKS(8'd250),
		.ALARM_TICKS(2'd3),
		.DOK_DLY_TICKS(4'd15),
		.DOK_TICKS(3'd7)
	) CPU0(
		// FPGA
		.__clk(CLK_EXT),
		// power supply
		.off_(off_),
		.pon_(pon_),
		.pout_(pout_),
		.clm_(clm_),
		.clo_(clo_),
		.dmcl_(dmcl_),
		// control panel
		.kl(kl),
		.panel_store_(panel_store_),
		.panel_fetch_(panel_fetch_),
		.panel_load_(panel_load_),
		.panel_bin_(panel_bin_),
		.oprq_(oprq_),
		.stop$_(stop$_),
		.start$_(start$_),
		.work(work),
		.mode(mode),
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
		.hlt_n(hlt_n),
		.p_(p_),
		.run(run),
		._wait(_wait),
		.irq(irq),
		.q(q),
		.mc_0(mc_0),
		.awaria(awaria),
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
		.zz(zz)
	);

// -----------------------------------------------------------------------
// --- P-K ---------------------------------------------------------------
// -----------------------------------------------------------------------

	wire [0:15] kl;
	wire zegar_;
	wire wre_, rsa, rsb, rsc;
	wire wic, wac, war, wir, wrs, wrz, wkb;
	wire panel_store_, panel_fetch_, panel_load_, panel_bin_;
	wire oprq_, stop$_, start$_, work, mode, step_, stop_n, cycle_;
	wire dcl_;

	pk #(
		.TIMER_CYCLE_MS(8'd10),
		.CLK_EXT_HZ(`CLK_EXT_HZ),
		.UART_BAUD(1_000_000)
	) PK(
		.CLK_EXT(CLK_EXT),
		.RXD(RXD),
		.TXD(TXD),
		.SEG(SEG),
		.DIG(DIG),
		.hlt_n(hlt_n),
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
		.mc_0(mc_0),
		.alarm(awaria),
		._wait(_wait),
		.irq(irq),
		.q(q),
		.run(run),
		.wre_(wre_),
		.rsa(rsa),
		.rsb(rsb),
		.rsc(rsc),
		.wic(wic),
		.wac(wac),
		.war(war),
		.wir(wir),
		.wrs(wrs),
		.wrz(wrz),
		.wkb(wkb)
	);

// -----------------------------------------------------------------------
// --- POWER SUPPLY ------------------------------------------------------
// -----------------------------------------------------------------------

	wire off_, pout_, pon_, clo_, clm_;
	puks PUKS(
		.clk(CLK_EXT),
		.zoff_(zoff_),
		.rcl_(rcl_),
		.dcl_(dcl_),
		.off_(off_),
		.pout_(pout_),
		.pon_(pon_),
		.clo_(clo_),
		.clm_(clm_)
	);

// -----------------------------------------------------------------------
// --- I/F ---------------------------------------------------------------
// -----------------------------------------------------------------------

	wire rcl_, zoff_;
	isk ISK(
		.dmcl_(dmcl_),
		.dcl_(dcl_),
		.off_(off_),
		.rcl_(rcl_),
		.zoff_(zoff_)
	);

// -----------------------------------------------------------------------
// --- MEMORY ------------------------------------------------------------
// -----------------------------------------------------------------------

	// disable flash, which uses the same D and A buses as sram
	assign F_CS = 1'b1;
	assign F_OE = 1'b1;
	assign F_WE = 1'b1;

	mem_elwro_sram MEM(
		.clk(CLK_EXT),
	  .SRAM_CE(SRAM_CE),
		.SRAM_OE(SRAM_OE),
		.SRAM_WE(SRAM_WE),
		.SRAM_UB(SRAM_UB),
		.SRAM_LB(SRAM_LB),
		.SRAM_A(SRAM_A),
	  .SRAM_D(SRAM_D),
		.nb_(dnb_),
		.ad_(dad_),
		.rdt_(ddt_),
		.ddt_(rdt_),
		.w_(dw_),
		.r_(dr_),
		.s_(ds_),
		.ok_(rok_)
	);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
