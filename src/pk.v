/*
	P-K unit (control panel, heavily modified for the FPGA implementation)

	document: 12-006368-01-8A
	unit:     SM-PK11
	pages:    2-103..2-108
*/

`define FN_START	4'b0000
`define FN_MODE		4'b0001
`define FN_CLOCK	4'b0010
`define FN_STOPN	4'b0011
`define FN_STEP		4'b0100
`define FN_FETCH	4'b0101
`define FN_STORE	4'b0110
`define FN_CYCLE	4'b0111
`define FN_LOAD		4'b1000
`define FN_BIN		4'b1001
`define FN_OPRQ		4'b1010
`define FN_CLEAR	4'b1011

`define ROT_BUS_R0 11'b10000000000
`define ROT_BUS_R1 11'b10010000000
`define ROT_BUS_R2 11'b10100000000
`define ROT_BUS_R3 11'b10110000000
`define ROT_BUS_R4 11'b11000000000
`define ROT_BUS_R5 11'b11010000000
`define ROT_BUS_R6 11'b11100000000
`define ROT_BUS_R7 11'b11110000000
`define ROT_BUS_IC 11'b00001000000
`define ROT_BUS_AC 11'b00000100000
`define ROT_BUS_AR 11'b00000010000
`define ROT_BUS_IR 11'b00000001000
`define ROT_BUS_SR 11'b00000000100
`define ROT_BUS_RZ 11'b00000000010
`define ROT_BUS_KB 11'b00000000001

module pk(
	// FPGA I/Os
	input CLK_EXT,
	input RXD,
	output TXD,
	output [7:0] SEG,
	output [7:0] DIG,
	// sheet 1
	input hlt_n_,
	input off_,
	output work,
	output stop$_,
	output start$_,
	output mode,
	output stop_n,
	// sheet 2
	input p0_,
	output [0:15] kl,
	output dcl_,
	output step_,
	output fetch_,
	output store_,
	output cycle_,
	output load_,
	output bin_,
	output oprq_,
	// sheet 3
	output reg zegar_,
	// sheet 4
	input [0:15] w,
	input p_,
	input mc_,
	input alarm_,
	input wait_,
	input irq,
	input q,
	input run,
	// sheet 5
	output wre_,
	output rsa,
	output rsb,
	output rsc,
	output wic,
	output wac,
	output war,
	output wir,
	output wrs,
	output wrz,
	output wkb,
	input ir0 // buzzer?
);

  parameter TIMER_CYCLE_MS;
	parameter CLK_EXT_HZ;
	parameter UART_BAUD;

	// --- FPGA: uart action trigger

	wire action;
	univib #(.ticks(5'd20)) UART_ACTION(
		.clk(CLK_EXT),
		.a_(rx_busy),
		.b(1'b1),
		.q(action)
	);

	// --- FPGA: UART

	wire tx_busy;
	wire rx_busy;
	wire [7:0] rx_byte;
	uart #(
		.baud(UART_BAUD),
		.clk_speed(CLK_EXT_HZ))
	UART0(
		.clk(CLK_EXT),
		.rx_byte(rx_byte),
		.rx_busy(rx_busy),
		.rxd(RXD),
		.send(send),
		.tx_busy(tx_busy),
		.tx_byte(tx_byte),
		.txd(TXD)
	);

	// --- FPGA: serial commands processing

	reg [15:0] keys = 0; // data keys
	reg [11:0] fnkey = 12'b0; // function keys
	reg [10:0] rotary_bus = `ROT_BUS_R1; // rotary switch bus (after final decoding)
	reg [3:0] rotary_pos = 4'b0001; // rotary switch position (as send by the user), r1 initial

	always @ (posedge CLK_EXT) begin
		if (~action) begin
			send_leds = 0;
			// reset all monostable switches
			fnkey[`FN_STOPN] <= 0;
			fnkey[`FN_STEP] <= 0;
			fnkey[`FN_FETCH] <= 0;
			fnkey[`FN_STORE] <= 0;
			fnkey[`FN_CYCLE] <= 0;
			fnkey[`FN_LOAD] <= 0;
			fnkey[`FN_BIN] <= 0;
			fnkey[`FN_OPRQ] <= 0;
			fnkey[`FN_CLEAR] <= 0;
		end else begin
			case (rx_byte[7:5])
			  3'b000 : ; // unused
				3'b001 : fnkey[rx_byte[4:1]] <= rx_byte[0];
				3'b010,
				3'b011 : keys[5:0] <= rx_byte[5:0];
				3'b100 : keys[10:6] <= rx_byte[4:0];
				3'b101 : keys[15:11] <= rx_byte[4:0];
				3'b110 : send_leds <= 1;
				3'b111 : begin
					rotary_pos <= rx_byte[3:0]; // store rotary position for status report
					case (rx_byte[3:0])
						4'b0000 : rotary_bus <= `ROT_BUS_R0;
						4'b0001 : rotary_bus <= `ROT_BUS_R1;
						4'b0010 : rotary_bus <= `ROT_BUS_R2;
						4'b0011 : rotary_bus <= `ROT_BUS_R3;
						4'b0100 : rotary_bus <= `ROT_BUS_R4;
						4'b0101 : rotary_bus <= `ROT_BUS_R5;
						4'b0110 : rotary_bus <= `ROT_BUS_R6;
						4'b0111 : rotary_bus <= `ROT_BUS_R7;
						4'b1000 : rotary_bus <= `ROT_BUS_IC;
						4'b1001 : rotary_bus <= `ROT_BUS_AC;
						4'b1010 : rotary_bus <= `ROT_BUS_AR;
						4'b1011 : rotary_bus <= `ROT_BUS_IR;
						4'b1100 : rotary_bus <= `ROT_BUS_SR;
						4'b1101 : rotary_bus <= `ROT_BUS_RZ;
						4'b1110 : rotary_bus <= `ROT_BUS_KB;
						4'b1111 : rotary_bus <= `ROT_BUS_KB;
					endcase
				end
			endcase
		end
	end

	// --- FPGA: send led status

	`define IDLE 0
	`define SEND 1
	`define WAIT_BUSY 2
	`define WAIT_TRANS 3

	// 4 bytes sent back for the status command
	wire [7:0] data [3:0];
	assign data[0] = w[0:7];
	assign data[1] = w[8:15];
	assign data[2] = {mode, stop_n, zeg, q, ~p_, ~mc_, irq, run};
	assign data[3] = {rotary_pos, 2'd0, ~wait_, ~alarm_};

	wire send_leds;
	reg [1:0] snd_state = 0;
	reg [7:0] tx_byte;
	reg send = 0;
	reg [1:0] b_cnt = 0;
	always @ (posedge CLK_EXT) begin
		case (snd_state)
			`IDLE : begin
				if (send_leds) begin
					if (~tx_busy) snd_state <= `SEND;
				end else begin
					b_cnt <= 0;
					send <= 0;
				end
			end
			`SEND : begin
				tx_byte <= data[b_cnt];
				send <= 1;
				snd_state <= `WAIT_BUSY;
			end
			`WAIT_BUSY : begin
				if (tx_busy) begin
					snd_state <= `WAIT_TRANS;
					send <= 0;
				end
			end
			`WAIT_TRANS : begin
				if (~tx_busy) begin
					if (b_cnt == 3) begin
						snd_state <= 0;
					end else begin
						b_cnt <= b_cnt + 1'b1;
						snd_state <= 1;
					end
				end
			end
		endcase
	end

	// --- FPGA: 7-segment display

	wire [7:0] dots;
	wire [7:0] digs [7:0];
	sevenseg_drv DRV(
		.clk(CLK_EXT),
		.seg(SEG),
		.dig(DIG),
		.digs(digs),
		.dots(dots)
	);

	// sheet 1

	assign work = fnkey[`FN_START];

	wire stop;
	impulse STOP(
		.clk(CLK_EXT),
		.in(~fnkey[`FN_START]),
		.q(stop)
	);
	assign stop$_ = ~stop;

	wire start;
	impulse START(
		.clk(CLK_EXT),
		.in(fnkey[`FN_START]),
		.q(start)
	);
	assign start$_ = ~start;

	assign mode = fnkey[`FN_MODE];
	wire zeg = fnkey[`FN_CLOCK];

	ffd STOPN(
		.s_(1'b1),
		.d(~stop_n),
		.c(fnkey[`FN_STOPN]),
		.r_(hlt_n_),
		.q(stop_n)
	);

	// sheet 2

	assign kl = keys;
	assign dcl_ = ~fnkey[`FN_CLEAR];
	assign step_ = ~fnkey[`FN_STEP];
	assign fetch_ = ~fnkey[`FN_FETCH] | p0_;
	assign store_ = ~fnkey[`FN_STORE] | p0_;
	assign cycle_ = ~fnkey[`FN_CYCLE] | p0_;
	assign load_ = ~fnkey[`FN_LOAD] | p0_;
	assign bin_ = ~fnkey[`FN_BIN] | p0_;
	assign oprq_ = ~fnkey[`FN_OPRQ];

	// sheet 3

	// a: 6-1 : 2 ms = 500 Hz	= 100_000 cycles @ 50MHz
	// a: 6-2 : 4 ms = 250 Hz = 200_000 cycles @ 50MHz
	// a: 6-3 : 8 ms = 125 Hz = 400_000 cycles @ 50MHz
	// a: 6-4 : 10 ms = 100 Hz = 500_000 cycles @ 50MHz
	// a: 6-5 : 20 ms = 50 Hz = 1_000_000 cycles @ 50MHz

	localparam prescale = TIMER_CYCLE_MS * (CLK_EXT_HZ / 1_000);
  localparam width = $clog2(prescale+1);
  localparam [width-1:0] period = prescale[width-1:0] - 1'b1;
	reg [width-1:0] timer_cnt = period;
	always @ (posedge CLK_EXT) begin
		if (timer_cnt == 0) begin
			timer_cnt <= period;
		end else begin
			timer_cnt <= timer_cnt - 1'b1;
		end
	end

	assign zegar_ = |timer_cnt | ~zeg;

	// sheet 4

	hex2seg d0(.hex(w[12:15]), .seg(digs[0]));
	hex2seg d1(.hex(w[8:11]), .seg(digs[1]));
	hex2seg d2(.hex(w[4:7]), .seg(digs[2]));
	hex2seg d3(.hex(w[0:3]), .seg(digs[3]));
	assign digs[7][0] = ~p_;
	assign digs[7][6] = ~mc_;
	assign digs[7][5:1] = 0;
	assign dots = {run, ~wait_, ~alarm_, irq, mode, stop_n, zeg, q};

	// sheet 5

	assign {wre_, rsc, rsb, rsa, wic, wac, war, wir, wrs, wrz, wkb} = rotary_bus;
	none2seg d4(.seg(digs[4]));
	rb2seg d5(.r(rotary_bus), .seg(digs[5]));
	ra2seg d6(.r(rotary_bus), .seg(digs[6]));

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
