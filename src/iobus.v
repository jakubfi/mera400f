`define MSG_REQ		1'b1
`define MSG_RESP	1'b0

`define CMD_PA	4'b0000
`define CMD_CL	4'b0001
`define CMD_W		4'b0010
`define CMD_R		4'b0011
`define CMD_S		4'b0100
`define CMD_F		4'b0101
`define CMD_IN	4'b0110
`define CMD_EN	4'b0001
`define CMD_OK	4'b0010
`define CMD_PE	4'b0011
`define CMD_CPD	4'b1000
`define CMD_CPR	4'b1001
`define CMD_CPF	4'b1010
`define CMD_CPS	4'b1011

module iobus(
	input clk_sys,
	input clk_uart,
	input RXD,
	output TXD,

	output zg,
	input zw,

	output dpa,
	input rcl,
	output dw,
	output dr,
	input rs,
	input rf,
	output din,
	input rok,
	output dok,
	output den,
	input rpe,
	output dpe,
	input rqb,
	input rpn,
	output dpn,
	input [0:3] rnb,
	output [0:3] dnb,
	input [0:15] rad,
	output [0:15] dad,
	input [0:15] rdt,
	output [0:15] ddt,

	input [0:15] w,
	input [0:3] rotary_pos,
	input [0:9] indicators,

	output [0:3] rotary_out,
	output rotary_trig,
	output [0:15] keys,
	output keys_trig,
	output [0:3] fn,
	output fn_v,
	output fn_trig
);

	parameter CLK_UART_HZ;
	parameter UART_BAUD;

	// --- UART --------------------------------------------------------------

	wire utx_busy;
	wire urx_busy;
	wire utx_ready;
	wire urx_ready;
	wire utx_send;
	wire [0:7] urx_byte;
	wire [0:7] utx_byte;

	uart #(
		.baud(UART_BAUD),
		.clk_speed(CLK_UART_HZ)
	) UART_IOB(
		.clk(clk_uart),
		.rx_byte(urx_byte),
		.rx_busy(urx_busy),
		.rx_ready(urx_ready),
		.rxd(RXD),
		.send(utx_send),
		.tx_byte(utx_byte),
		.tx_busy(utx_busy),
		.tx_ready(utx_ready),
		.txd(TXD)
	);

	// --- Command endcoder --------------------------------------------------

	reg [0:7] cmd;

	cmd_enc CMD_ENC(
		.f(rf),
		.s(rs),
		.r(dr),
		.w(dw),
		.ok(rok),
		.pe(rpe),
		.cpresp(rxcps),
		.cmd(cmd)
	);

	// --- Transmitter -------------------------------------------------------

	wire txbusy;	// transmitter is sending a message
	reg txsend;		// send message trigger

	// switch arguments for rxcp
	wire [0:15] txa2 = rxcp ? w : rad;
	wire [0:15] txa3 = rxcp ? { indicators, 2'b00, rotary_pos } : rdt;

	msg_tx MSG_TX(
		.clk_sys(clk_sys),
		.uart_data(utx_byte),
		.uart_send(utx_send),
		.uart_busy(utx_busy),
		.send(txsend),
		.busy(txbusy),
		.cmd(cmd),
		.a1({2'd0, rqb, rpn, rnb}),
		.a2(txa2),
		.a3(txa3)
	);

	// --- Receiver ----------------------------------------------------------

	wire rxbusy;			// receiver is receiving a message
	wire rxcmdready;	// received a command (but arguments are ready after rxbusy goes low)
	reg rxreset;			// reset the receiver before accepting next command

	wire [0:7] rxcmd;
	wire [0:7] rxa1;
	wire [0:15] rxa2;
	wire [0:15] rxa3;

	msg_rx MSG_RX(
		.clk_sys(clk_sys),
		.uart_data(urx_byte),
		.uart_busy(urx_busy),
		.uart_ready(urx_ready),
		.cmd_ready(rxcmdready),
		.busy(rxbusy),
		.reset(rxreset),
		.cmd(rxcmd),
		.a1(rxa1),
		.a2(rxa2),
		.a3(rxa3)
	);

	wire rxreq = rxcmd[0];
	wire rxpn = rxa1[2];
	wire [0:3] rxnb = rxa1[4:7];
	wire [0:15] rxad = rxa2;
	wire [0:15] rxdt = rxa3;

	// --- Command decoder ---------------------------------------------------

	wire rxr, rxw, rxin, rxpa, rxok, rxpe, rxen;
	wire rxcp;
	wire rxcpd, rxcpr, rxcpf, rxcps;

	cmd_dec CMD_DEC(
		.cmd(rxcmd),
		.r(rxr),
		.w(rxw),
		.in(rxin),
		.pa(rxpa),
		.ok(rxok),
		.pe(rxpe),
		.en(rxen),
		.cp(rxcp),
		.cpd(rxcpd),
		.cpr(rxcpr),
		.cpf(rxcpf),
		.cps(rxcps)
	);

	// --- Transmachine ------------------------------------------------------

	wire r_req = (rs | rf) & ~rad[15];
	wire r_resp = rok | rpe;
	wire d_req = rxcmdready & rxreq;
	wire d_resp = rxcmdready & ~rxreq;
	wire cp_req = rxcmdready & rxreq & rxcp;

	localparam IDLE		= 4'd0;
	localparam R_REQ	= 4'd1;
	localparam D_REQ	= 4'd2;
	localparam CP_REQ	= 4'd3;
	localparam CP_ARG	= 4'd4;
	localparam D_RESP	= 4'd5;
	localparam R_RESP	= 4'd6;
	localparam D_EN		= 4'd7;
	localparam WAIT		= 4'd8;
	reg [0:3] state = IDLE;

	always @ (posedge clk_sys) begin

		case (state)

			IDLE: begin
				d_ena <= 0;
				keys_trig <= 0;
				fn_trig <= 0;
				rotary_trig <= 0;
				rxreset <= 0;
				if (r_req) begin						// internal request
					txsend <= 1;
					//if (rcl) state <= D_RESP;	// CL -> no reply
					//else state <= R_REQ;			// other int. -> need reply
					state <= R_REQ;
				end else if (cp_req) begin	// CP request
					if (!rxcps) begin					// CP req that doesn't need response but has args
						state <= CP_ARG;
					end else begin						// CP that needs response, but has no args
						zg <= 1;
						state <= CP_REQ;
					end
				end else if (d_req) begin		// external request
					if (rxpa) begin						// PA -> only need to let the interrupt go through
						d_ena <= 1;
						state <= WAIT;
					end else begin						// other external -> need reply
						zg <= 1;
						state <= D_REQ;
					end
				end
			end

			CP_ARG: begin
				if (!rxbusy) begin
					if (rxcpd) keys_trig <= 1;
					else if (rxcpf) fn_trig <= 1;
					else if (rxcpr) rotary_trig <= 1;
					state <= WAIT;
				end
			end

			CP_REQ: begin									// control panel request
				if (zw & !rxbusy) begin
					txsend <= 1;
					state <= WAIT;
				end
			end

			R_REQ: begin											// internal request
				txsend <= 0;
				if (d_resp & ~rxbusy) begin			// wait for the finished external response
					d_ena <= 1;
					state <= D_RESP;
				end else if (!zw & d_req & !rxbusy) begin	// watch for an external request
					state <= D_EN;
				end
			end

			D_RESP: begin					// external response
				txsend <= 0;
				if (!r_req) begin		// wait for the internal request to end
					d_ena <= 0;
					rxreset <= 1;
					state <= IDLE;
				end
			end

			D_REQ: begin					// external request
				if (zw & !rxbusy) begin
					d_ena <= 1;
					state <= R_RESP;
				end
			end

			R_RESP: begin					// internal response
				if (r_resp) begin		// wait for the internal response and start sending it
					txsend <= 1;
					state <= WAIT;
				end
			end

			D_EN: begin
				if (!r_req) begin		// wait for the internal request to end and serve the external request
					zg <= 1;
					state <= D_REQ;
				end
			end

			WAIT: begin						// wait for the outgoing transmission to end
				txsend <= 0;
				if (!txbusy) begin
					zg <= 0;
					state <= IDLE;
					rxreset <= 1;
				end
			end

		endcase
	end

	wire xen = (state == D_EN);

	// --- Bus drivers -------------------------------------------------------

	reg d_ena;

	assign dpn = d_ena ? rxpn :  1'd0;
	assign dnb = d_ena ? rxnb :  4'd0;
	assign dad = d_ena ? rxad : 16'd0;
	assign ddt = d_ena ? rxdt : 16'd0;
	assign dr  = d_ena ? rxr  :  1'd0;
	assign dw  = d_ena ? rxw  :  1'd0;
	assign din = d_ena ? rxin :  1'd0;
	assign dpa = d_ena ? rxpa :  1'd0;
	assign dok = d_ena ? rxok :  1'd0;
	assign den= (d_ena ? rxen :  1'd0) | xen;
	assign dpe = d_ena ? rxpe :  1'd0;

	// --- CP drivers --------------------------------------------------------

	assign keys = rxdt;
	assign rotary_out = rxnb;
	assign fn = rxnb;
	assign fn_v = rxpn;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
