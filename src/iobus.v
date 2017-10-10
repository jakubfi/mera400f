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

module iobus(
	input clk_sys,
	input clk_uart,
	input RXD2,
	output TXD2,

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
	output [0:15] ddt
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
		.rxd(RXD2),
		.send(utx_send),
		.tx_byte(utx_byte),
		.tx_busy(utx_busy),
		.tx_ready(utx_ready),
		.txd(TXD2)
	);

	// --- Transmitter -------------------------------------------------------

	wire txbusy;
	reg txsend;

	msg_tx MSG_TX(
		.clk_sys(clk_sys),
		.uart_data(utx_byte),
		.uart_send(utx_send),
		.uart_busy(utx_busy),
		.send(txsend),
		.busy(txbusy),
		.ok_with_dt(dr),
		.s(rs),
		.f(rf),
		.cl(rcl),
		.ok(rok),
		.pe(rpe),
		.bar({rqb, rpn, rnb}),
		.ad(rad),
		.dt(rdt)
	);

	// --- Receiver ----------------------------------------------------------

	wire rxbusy, rxcmdready;
	reg rxreset;

	wire rxreq;
	wire rxpn;
	wire [0:3] rxnb;
	wire [0:15] rxad;
	wire [0:15] rxdt;
	wire rxr, rxw, rxin, rxpa, rxok, rxpe, rxen;

	msg_rx MSG_RX(
		.clk_sys(clk_sys),
		.uart_data(urx_byte),
		.uart_busy(urx_busy),
		.uart_ready(urx_ready),
		.cmd_ready(rxcmdready),
		.busy(rxbusy),
		.reset(rxreset),
		.req(rxreq),
		.pn(rxpn),
		.nb(rxnb),
		.ad(rxad),
		.dt(rxdt),
		.r(rxr),
		.w(rxw),
		.in(rxin),
		.pa(rxpa),
		.ok(rxok),
		.pe(rxpe),
		.en(rxen)
	);

	// --- Transmachine ------------------------------------------------------

	wire r_req = rs | rf | rcl;
	wire r_resp = rok | rpe;
	wire d_req = rxcmdready & rxreq;
	wire d_resp = rxcmdready & ~rxreq;

	localparam IDLE		= 3'd0;
	localparam R_REQ	= 3'd1;
	localparam D_RESP	= 3'd2;
	localparam D_REQ	= 3'd3;
	localparam R_RESP	= 3'd4;
	localparam D_EN		= 3'd5;
	localparam WAIT		= 3'd6;
	reg [0:2] state = IDLE;

	always @ (posedge clk_sys) begin

		case (state)

			IDLE: begin
				d_ena <= 0;
				rxreset <= 0;
				if (r_req) begin						// internal request
					txsend <= 1;
					if (rcl) state <= D_RESP;	// CL -> no reply
					else state <= R_REQ;			// other int. -> need reply
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

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
