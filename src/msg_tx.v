module msg_tx(
	input clk_sys,

	output [0:7] uart_data,
	output uart_send,
	input uart_busy,

	input send,
	output busy,

	input [0:7] cmd,
	input [0:7] a1,
	input [0:15] a2,
	input [0:15] a3
);

	wire [0:2] arg = cmd[5:7];

	// --- Transmission ------------------------------------------------------

	localparam IDLE	= 3'd0;
	localparam A1	= 3'd1;
	localparam A2H	= 3'd2;
	localparam A2L	= 3'd3;
	localparam A3H	= 3'd4;
	localparam A3L	= 3'd5;
	localparam WAIT	= 3'd6;

	reg [0:2] state = IDLE;

	always @ (posedge clk_sys) begin
		uart_send <= 0;

		case (state)

			IDLE: begin
				if (send) begin
					uart_data <= cmd;
					uart_send <= 1;
					if (arg[0]) state <= A1;
					else if (arg[1]) state <= A2H;
					else if (arg[2]) state <= A3H;
					else state <= WAIT;
				end
			end

			A1: begin
				if (!uart_busy) begin
					uart_data <= a1;
					uart_send <= 1;
					if (arg[1]) state <= A2H;
					else if (arg[2]) state <= A3H;
					else state <= WAIT;
				end
			end

			A2H: begin
				if (!uart_busy) begin
					uart_data <= a2[0:7];
					uart_send <= 1;
					state <= A2L;
				end
			end

			A2L: begin
				if (!uart_busy) begin
					uart_data <= a2[8:15];
					uart_send <= 1;
					if (arg[2]) state <= A3H;
					else state <= WAIT;
				end
			end

			A3H: begin
				if (!uart_busy) begin
					uart_data <= a3[0:7];
					uart_send <= 1;
					state <= A3L;
				end
			end

			A3L: begin
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

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
