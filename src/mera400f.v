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
	wire dw;
	wire dr;
	wire ds;
	wire df;
	wire din;
	wire dok;
	wire dqb;
	wire dpn;
	wire [0:3] dnb;
	wire [0:15] dad;
	wire [0:15] ddt;
	wire dmcl;
	// input: from system bus - receivers
	wire rpa = 0;
	wire rin = 0;
	wire rok;
	wire ren = 0;
	wire rpe = 0;
	wire rpn = 0;
	wire [0:15] rdt;
	wire zg;
	wire zw = zg;
	wire zz;

	// output: to control panel
	wire p0;
	wire [0:15] w;
	wire hlt_n, p, run, _wait, irq, q, mc_0, awaria;

	cpu #(
		.CPU_NUMBER(1'b0),
		.AWP_PRESENT(1'b1),
		.INOU_USER_ILLEGAL(1'b1),
		.STOP_ON_NOMEM(1'b1),
		.LOW_MEM_WRITE_DENY(1'b0),
		.ALARM_DLY_TICKS(8'd250),
		.ALARM_TICKS(8'd3),
		.DOK_DLY_TICKS(4'd15),
		.DOK_TICKS(3'd7)
	) CPU0(
		// FPGA
		.__clk(CLK_EXT),
		// power supply
		.off(off),
		.pon(pon),
		.pout(pout),
		.clm(clm),
		.clo(clo),
		.dmcl(dmcl),
		// control panel
		.kl(kl),
		.panel_store(panel_store),
		.panel_fetch(panel_fetch),
		.panel_load(panel_load),
		.panel_bin(panel_bin),
		.oprq(oprq),
		.stop(stop),
		.start(start),
		.work(work),
		.mode(mode),
		.step(step),
		.stop_n(stop_n),
		.cycle(cycle),
		.wre(wre),
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
		.zegar(zegar),
		.p0(p0),
		.w(w),
		.hlt_n(hlt_n),
		.p(p),
		.run(run),
		._wait(_wait),
		.irq(irq),
		.q(q),
		.mc_0(mc_0),
		.awaria(awaria),
		// system bus
		.rpa(rpa),
		.dw(dw),
		.dr(dr),
		.ds(ds),
		.df(df),
		.din(din),
		.rin(rin),
		.dok(dok),
		.rok(rok),
		.ren(ren),
		.rpe(rpe),
		.dqb(dqb),
		.dpn(dpn),
		.rpn(rpn),
		.dnb(dnb),
		.dad(dad),
		.ddt(ddt),
		.rdt(rdt),
		// ssytem bus reservation
		.zg(zg),
		.zw(zw),
		.zz(zz)
	);

// -----------------------------------------------------------------------
// --- P-K ---------------------------------------------------------------
// -----------------------------------------------------------------------

	wire [0:15] kl;
	wire zegar;
	wire wre, rsa, rsb, rsc;
	wire wic, wac, war, wir, wrs, wrz, wkb;
	wire panel_store, panel_fetch, panel_load, panel_bin;
	wire oprq, stop, start, work, mode, step, stop_n, cycle;
	wire dcl;

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
		.off(off),
		.work(work),
		.stop(stop),
		.start(start),
		.mode(mode),
		.stop_n(stop_n),
		.p0(p0),
		.kl(kl),
		.dcl(dcl),
		.step(step),
		.fetch(panel_fetch),
		.store(panel_store),
		.cycle(cycle),
		.load(panel_load),
		.bin(panel_bin),
		.oprq(oprq),
		.zegar(zegar),
		.w(w),
		.p(p),
		.mc_0(mc_0),
		.alarm(awaria),
		._wait(_wait),
		.irq(irq),
		.q(q),
		.run(run),
		.wre(wre),
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

	wire off, pout, pon, clo, clm;
	puks PUKS(
		.clk(CLK_EXT),
		.zoff(zoff),
		.rcl(rcl),
		.dcl(dcl),
		.off(off),
		.pout(pout),
		.pon(pon),
		.clo(clo),
		.clm(clm)
	);

// -----------------------------------------------------------------------
// --- I/F ---------------------------------------------------------------
// -----------------------------------------------------------------------

	wire rcl, zoff;
	isk ISK(
		.dmcl(dmcl),
		.dcl(dcl),
		.off(off),
		.rcl(rcl),
		.zoff(zoff)
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
		.nb_(~dnb),
		.ad_(~dad),
		.rdt_(~ddt),
		.ddt_(rdt_),
		.w_(~dw),
		.r_(~dr),
		.s_(~ds),
		.ok_(rok_)
	);

	wire rok_;
	assign rok = ~rok_;
	wire [0:15] rdt_;
	assign rdt = ~rdt_;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
