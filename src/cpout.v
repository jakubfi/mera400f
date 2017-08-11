// Control Panel output - sends CPU status over serial

module cpout (
	input clk_sys,
	input trigger,
	input [0:15] w,
	input [0:9] indicators,
	input [0:3] rotary_pos,
	input tx_busy,
	output [7:0] tx_byte,
	output reg send
);

	localparam IDLE				= 2'd0;
	localparam SEND				= 2'd1;
	localparam WAIT_BUSY	= 2'd2;
	localparam WAIT_TRANS	= 2'd3;

	// 4 bytes sent back for the status command
	wire [7:0] data [3:0];
	assign data[0] = w[0:7];
	assign data[1] = w[8:15];
	assign data[2] = indicators[0:7];
	assign data[3] = {rotary_pos, 2'd0, indicators[8:9]};

	reg [1:0] b_cnt = 2'd0;
	assign tx_byte = data[b_cnt];

	reg [1:0] snd_state = IDLE;
	always @ (posedge clk_sys) begin
		case (snd_state)

			IDLE: begin
				if (trigger & ~tx_busy) begin
					b_cnt <= 2'd0;
					snd_state <= SEND;
				end
			end

			SEND: begin
				send <= 1'b1;
				snd_state <= WAIT_BUSY;
			end

			WAIT_BUSY: begin
				if (tx_busy) begin
					snd_state <= WAIT_TRANS;
					send <= 1'b0;
				end
			end

			WAIT_TRANS: begin
				if (~tx_busy) begin
					if (b_cnt == 2'd3) begin
						snd_state <= IDLE;
					end else begin
						b_cnt <= b_cnt + 1'b1;
						snd_state <= SEND;
					end
				end
			end

		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
