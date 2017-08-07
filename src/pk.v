/*
	P-K unit (control panel, heavily modified for the FPGA implementation)

	document: 12-006368-01-8A
	unit:     SM-PK11
	pages:    2-103..2-108
*/

`define FN_START	4'd0
`define FN_MODE		4'd1
`define FN_CLOCK	4'd2
`define FN_STOPN	4'd3
`define FN_STEP		4'd4
`define FN_FETCH	4'd5
`define FN_STORE	4'd6
`define FN_CYCLE	4'd7
`define FN_LOAD		4'd8
`define FN_BIN		4'd9
`define FN_OPRQ		4'd10
`define FN_CLEAR	4'd11

module pk(
	// FPGA I/Os
	input clk_sys,
	input clk_uart,
	input RXD,
	output TXD,
	output [7:0] SEG,
	output [7:0] DIG,
	// sheet 1
	input hlt_n,
	input off,
	output work,
	output stop,
	output start,
	output mode,
	output stop_n,
	// sheet 2
	input p0,
	output [0:15] kl,
	output dcl,
	output step,
	output fetch,
	output store,
	output cycle,
	output load,
	output bin,
	output oprq,
	// sheet 3
	output reg zegar,
	// sheet 4
	input [0:15] w,
	input p,
	input mc_0,
	input alarm,
	input _wait,
	input irq,
	input q,
	input run,
	// sheet 5
	output wre,
	output rsa,
	output rsb,
	output rsc,
	output wic,
	output wac,
	output war,
	output wir,
	output wrs,
	output wrz,
	output wkb
);

	parameter CLK_SYS_HZ;
	parameter CLK_UART_HZ;
	parameter TIMER_CYCLE_MS;
	parameter UART_BAUD;

	// --- UART

	wire tx_busy;
	wire rx_busy;
	wire [7:0] rx_byte;
	uart #(
		.baud(UART_BAUD),
		.clk_speed(CLK_UART_HZ))
	UART0(
		.clk(clk_uart),
		.rx_byte(rx_byte),
		.rx_busy(rx_busy),
		.rxd(RXD),
		.send(send),
		.tx_busy(tx_busy),
		.tx_byte(tx_byte),
		.txd(TXD)
	);

	// --- Rotary switch position decoder

	wire [10:0] rotary_bus;
	assign {wre, rsc, rsb, rsa, wic, wac, war, wir, wrs, wrz, wkb} = rotary_bus;
	rot_dec ROT_DEC(
		.in(rotary_pos),
		.out(rotary_bus)
	);

	// --- Control panel input (switches over serial)

	wire send_leds;
	wire [11:0] fnkey;
	wire [3:0] rotary_pos;
	cpin CPIN(
		.clk_sys(clk_sys),
		.rx_byte(rx_byte),
		.rx_busy(rx_busy),
		.send_leds(send_leds),
		.fnkey(fnkey),
		.rotary_pos(rotary_pos),
		.kl(kl)
	);

	// --- Virtual switches assignments

	reg owork;
	always @ (posedge clk_sys) begin
		owork <= fnkey[`FN_START];
	end

	assign work = fnkey[`FN_START];
	assign start = ~owork & work;
	assign stop = owork & ~work;
	assign mode = fnkey[`FN_MODE];

	reg ostop_n;
	always @ (posedge clk_sys, posedge hlt_n) begin
		if (hlt_n) stop_n <= 1'b0;
		else begin
			ostop_n <= fnkey[`FN_STOPN];
			if (~ostop_n & fnkey[`FN_STOPN]) stop_n <= ~stop_n;
		end
	end

	assign dcl = fnkey[`FN_CLEAR];
	assign step = fnkey[`FN_STEP];
	assign fetch = fnkey[`FN_FETCH] & p0;
	assign store = fnkey[`FN_STORE] & p0;
	assign cycle = fnkey[`FN_CYCLE] & p0;
	assign load = fnkey[`FN_LOAD] & p0;
	assign bin = fnkey[`FN_BIN] & p0;
	assign oprq = fnkey[`FN_OPRQ];

	// --- Control panel output (leds over serial)

	wire send;
	wire [7:0] tx_byte;
	cpout CPOUT(
		.clk_sys(clk_sys),
		.trigger(send_leds),
		.w(w),
		.indicators({mode, stop_n, zeg, q, p, ~mc_0, irq, run, _wait, alarm}),
		.rotary_pos(rotary_pos),
		.tx_busy(tx_busy),
		.tx_byte(tx_byte),
		.send(send)
	);

	// --- Timer

	wire zeg = fnkey[`FN_CLOCK];

	timer #(
		.TIMER_CYCLE_MS(TIMER_CYCLE_MS),
		.CLK_SYS_HZ(CLK_SYS_HZ)
	) TIMER(
		.clk_sys(clk_sys),
		.enable(zeg),
		.zegar(zegar)
	);

	// --- 7-segment display

	display DISPLAY(
		.clk_sys(clk_sys),
		.w(w),
		.rotary_bus(rotary_bus),
		.indicators({run, _wait, alarm, irq, mode, stop_n, zeg, q, p, mc_0}),
		.SEG(SEG),
		.DIG(DIG)
	);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
