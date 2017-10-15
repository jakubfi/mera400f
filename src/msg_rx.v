module msg_rx(
	input clk_sys,

	input [0:7] uart_data,
	input uart_busy,
	input uart_ready,

	output busy,
	output cmd_ready,
	input reset,

	output req,
	output pn,
	output [0:3] nb,
	output [0:15] ad,
	output [0:15] dt,

	output r, w, in, pa,
	output ok, pe, en,
	output cp, cpd, cpr, cpf, cps
);

	// --- Command decoder ---------------------------------------------------

	cmd_dec CMD_DEC(
		.req(req),
		.cmd(cmd),
		.r(r),
		.w(w),
		.in(in),
		.pa(pa),
		.ok(ok),
		.pe(pe),
		.en(en),
		.cp(cp),
		.cpd(cpd),
		.cpr(cpr),
		.cpf(cpf),
		.cps(cps)
	);

	// --- Receiver ----------------------------------------------------------

	localparam IDLE	= 4'd0;
	localparam ARG	= 4'd1;
	localparam BAR	= 4'd2;
	localparam ADH	= 4'd3;
	localparam ADL	= 4'd4;
	localparam DTH	= 4'd5;
	localparam DTL	= 4'd6;

	reg [0:2] state = IDLE;

	reg [0:3] cmd;
	reg [0:2] arg;

	always @ (posedge clk_sys, posedge reset) begin
		if (reset) cmd_ready <= 0;
		else case (state)

			IDLE: begin
				if (uart_ready) begin
					{ req, cmd, arg } <= uart_data;
					cmd_ready <= 1;
					state <= ARG;
				end
			end

			ARG: begin
				if (arg[0]) state <= BAR;
				else if (arg[1]) state <= ADH;
				else if (arg[2]) state <= DTH;
				else state <= IDLE;
			end

			BAR: begin
				if (uart_ready) begin
					{ pn, nb } <= { uart_data[2], uart_data[4:7] };
					if (arg[1]) state <= ADH;
					else if (arg[2]) state <= DTH;
					else state <= IDLE;
				end
			end

			ADH: begin
				if (uart_ready) begin
					ad[0:7] <= uart_data;
					state <= ADL;
				end
			end

			ADL: begin
				if (uart_ready) begin
					ad[8:15] <= uart_data;
					if (arg[2]) state <= DTH;
					else state <= IDLE;
				end
			end

			DTH: begin
				if (uart_ready) begin
					dt[0:7] <= uart_data;
					state <= DTL;
				end
			end

			DTL: begin
				if (uart_ready) begin
					dt[8:15] <= uart_data;
					state <= IDLE;
				end
			end

		endcase
	end

	assign busy = (state != IDLE) | uart_busy | uart_ready;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
