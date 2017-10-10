module msg_tx(
	input clk_sys,

	output [0:7] uart_data,
	output uart_send,
	input uart_busy,

	input send,
	output busy,

	input ok_with_dt,
	input f, s, cl,
	input ok, pe,
	input [0:5] bar,
	input [0:15] ad,
	input [0:15] dt
);

	// --- Argument presence enc. --------------------------------------------

	wire [0:2] arg;
	args_enc ARGS_ENC(
		.cmd(cmd),
		.req(req),
		.ok_with_dt(ok_with_dt),
		.arg(arg)
	);

	// --- Command enc. ------------------------------------------------------

	wire req;
	wire [0:3] cmd;
	cmd_enc CMD_ENC(
		.f(f),
		.s(s),
		.cl(cl),
		.ok(ok),
		.pe(pe),
		.req(req),
		.cmd(cmd)
	);

	// --- Transmission ------------------------------------------------------

	localparam IDLE	= 3'd0;
	localparam BAR	= 3'd1;
	localparam ADH	= 3'd2;
	localparam ADL	= 3'd3;
	localparam DTH	= 3'd4;
	localparam DTL	= 3'd5;
	localparam WAIT	= 3'd6;

	reg [0:2] state = IDLE;

	always @ (posedge clk_sys) begin
		uart_send <= 0;

		case (state)

			IDLE: begin
				if (send) begin
					uart_data <= { req, cmd, arg };
					uart_send <= 1;
					if (arg[0]) state <= BAR;
					else if (arg[1]) state <= ADH;
					else if (arg[2]) state <= DTH;
					else state <= WAIT;
				end
			end

			BAR: begin
				if (!uart_busy) begin
					uart_data <= { 2'b00, bar };
					uart_send <= 1;
					if (arg[1]) state <= ADH;
					else if (arg[2]) state <= DTH;
					else state <= WAIT;
				end
			end

			ADH: begin
				if (!uart_busy) begin
					uart_data <= ad[0:7];
					uart_send <= 1;
					state <= ADL;
				end
			end

			ADL: begin
				if (!uart_busy) begin
					uart_data <= ad[8:15];
					uart_send <= 1;
					if (arg[2]) state <= DTH;
					else state <= WAIT;
				end
			end

			DTH: begin
				if (!uart_busy) begin
					uart_data <= dt[0:7];
					uart_send <= 1;
					state <= DTL;
				end
			end

			DTL: begin
				if (!uart_busy) begin
					uart_data <= dt[8:15];
					uart_send <= 1;
					state <= WAIT;
				end
			end

			WAIT: begin
				if (!uart_busy) begin
					state <= IDLE;
				end
			end

		endcase
	end

	assign busy = (state != IDLE) | send;

endmodule

// -----------------------------------------------------------------------
module args_enc(
	input [0:3] cmd,
	input req,
	input ok_with_dt,
	output [0:2] arg
);

	wire [0:2] a;

	always @ (*) begin
		case (cmd)
			`CMD_W : a = 3'b111;
			`CMD_R : a = 3'b110;
			`CMD_S : a = 3'b111;
			`CMD_F : a = 3'b110;
			`CMD_IN: a = 3'b101;
			default: a = 3'b000;
		endcase
	end

	wire okdt = (cmd == `CMD_OK) && ok_with_dt;
	assign arg = req ? a : {2'd0, okdt};

endmodule

// -----------------------------------------------------------------------
module cmd_enc(
	input f, s, cl, ok, pe,
	output req,
	output [0:3] cmd
);

	wire [0:4] rcmd;

	always @ (*) begin
		case ({f, s, cl, ok, pe})
			5'b10000: rcmd = { `MSG_REQ, `CMD_F };
			5'b01000: rcmd = { `MSG_REQ, `CMD_S };
			5'b00100: rcmd = { `MSG_REQ, `CMD_CL };
			5'b00010: rcmd = { `MSG_RESP, `CMD_OK };
			5'b00001: rcmd = { `MSG_RESP, `CMD_PE };
			default: rcmd = 5'b00000;
		endcase
	end

	assign req = rcmd[0];
	assign cmd = rcmd[1:4];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
