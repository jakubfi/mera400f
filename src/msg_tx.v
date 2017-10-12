module msg_tx(
	input clk_sys,

	output [0:7] uart_data,
	output uart_send,
	input uart_busy,

	input send,
	output busy,

	input ok_with_a2,
	input ok_with_a3,
	input f, s, cl,
	input ok, pe,
	input cpresp,
	input [0:7] a1,
	input [0:15] a2,
	input [0:15] a3
);

	// --- Argument presence enc. --------------------------------------------

	wire [0:2] arg;
	args_enc ARGS_ENC(
		.cmd(cmd),
		.req(req),
		.ok_with_a3(ok_with_a3),
		.ok_with_a2(ok_with_a2),
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
		.cpresp(cpresp),
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
					uart_data <= a1;
					uart_send <= 1;
					if (arg[1]) state <= ADH;
					else if (arg[2]) state <= DTH;
					else state <= WAIT;
				end
			end

			ADH: begin
				if (!uart_busy) begin
					uart_data <= a2[0:7];
					uart_send <= 1;
					state <= ADL;
				end
			end

			ADL: begin
				if (!uart_busy) begin
					uart_data <= a2[8:15];
					uart_send <= 1;
					if (arg[2]) state <= DTH;
					else state <= WAIT;
				end
			end

			DTH: begin
				if (!uart_busy) begin
					uart_data <= a3[0:7];
					uart_send <= 1;
					state <= DTL;
				end
			end

			DTL: begin
				if (!uart_busy) begin
					uart_data <= a3[8:15];
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
	input ok_with_a2,
	input ok_with_a3,
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
			`CMD_CPD:a = 3'b001;
			`CMD_CPR:a = 3'b100;
			`CMD_CPF:a = 3'b100;
			`CMD_CPS:a = 3'b000;
			default: a = 3'b000;
		endcase
	end

	wire oka2 = (cmd == `CMD_OK) && ok_with_a2;
	wire oka3 = (cmd == `CMD_OK) && ok_with_a3;
	assign arg = req ? a : {1'd0, oka2, oka3};

endmodule

// -----------------------------------------------------------------------
module cmd_enc(
	input f, s, cl, ok, pe, cpresp,
	output req,
	output [0:3] cmd
);

	wire [0:4] rcmd;

	always @ (*) begin
		case ({f, s, cl, ok, pe, cpresp})
			6'b100000: rcmd = { `MSG_REQ, `CMD_F };
			6'b010000: rcmd = { `MSG_REQ, `CMD_S };
			6'b001000: rcmd = { `MSG_REQ, `CMD_CL };
			6'b000100: rcmd = { `MSG_RESP, `CMD_OK };
			6'b000010: rcmd = { `MSG_RESP, `CMD_PE };
			6'b000001: rcmd = { `MSG_RESP, `CMD_OK };
			default: rcmd = 5'd0;
		endcase
	end

	assign req = rcmd[0];
	assign cmd = rcmd[1:4];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
