module msg_rx(
	input clk_sys,

	input [0:7] uart_data,
	input uart_busy,
	input uart_ready,

	output busy,
	output cmd_ready,
	input reset,

	output [0:7] cmd,
	output [0:7] a1,
	output [0:15] a2,
	output [0:15] a3
);

	// --- Receiver ----------------------------------------------------------

	localparam IDLE = 4'd0;
	localparam ARG  = 4'd1;
	localparam A1   = 4'd2;
	localparam A2H  = 4'd3;
	localparam A2L  = 4'd4;
	localparam A3H  = 4'd5;
	localparam A3L  = 4'd6;

	reg [0:2] state = IDLE;

	wire [0:2] arg = cmd[5:7];

	always @ (posedge clk_sys, posedge reset) begin
		if (reset) cmd_ready <= 0;
		else case (state)

			IDLE: begin
				if (uart_ready) begin
					cmd <= uart_data;
					cmd_ready <= 1;
					state <= ARG;
				end
			end

			ARG: begin
				if (arg[0]) state <= A1;
				else if (arg[1]) state <= A2H;
				else if (arg[2]) state <= A3H;
				else state <= IDLE;
			end

			A1: begin
				if (uart_ready) begin
					a1 <= uart_data;
					if (arg[1]) state <= A2H;
					else if (arg[2]) state <= A3H;
					else state <= IDLE;
				end
			end

			A2H: begin
				if (uart_ready) begin
					a2[0:7] <= uart_data;
					state <= A2L;
				end
			end

			A2L: begin
				if (uart_ready) begin
					a2[8:15] <= uart_data;
					if (arg[2]) state <= A3H;
					else state <= IDLE;
				end
			end

			A3H: begin
				if (uart_ready) begin
					a3[0:7] <= uart_data;
					state <= A3L;
				end
			end

			A3L: begin
				if (uart_ready) begin
					a3[8:15] <= uart_data;
					state <= IDLE;
				end
			end

		endcase
	end

	assign busy = (state != IDLE) | uart_busy | uart_ready;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
