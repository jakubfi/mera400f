// Control Panel input - serial commands interpreter

module cpin(
	input clk_sys,
	input [7:0] rx_byte,
	input rx_busy,
	output reg send_leds,
	output reg [11:0] fnkey,			// function switches
	output reg [3:0] rotary_pos,	// user-set rotary switch position
	output reg [15:0] kl					// data input switches
);

	localparam S_IDLE = 2'd0;
	localparam S_READ = 2'd1;
	localparam S_CLR	= 2'd2;

	initial rotary_pos = 4'd1; // user-set rotary switch position ("r1" initial)
	reg rxb;
	reg [1:0] state = S_IDLE;

	always @ (posedge clk_sys) begin
		case (state)

			S_IDLE: begin
				rxb <= rx_busy;
				if (~rx_busy & rxb) state <= S_READ;
			end

			S_READ: begin
				state <= S_CLR;
				case (rx_byte[7:5])
					3'b000: ; // unused
					3'b001: fnkey[rx_byte[4:1]] <= rx_byte[0];
					3'b010,
					3'b011: kl[5:0] <= rx_byte[5:0];
					3'b100: kl[10:6] <= rx_byte[4:0];
					3'b101: kl[15:11] <= rx_byte[4:0];
					3'b110: send_leds <= 1'b1;
					3'b111: rotary_pos <= rx_byte[3:0];
				endcase
			end

			S_CLR: begin
				state <= S_IDLE;
				send_leds <= 1'b0;
				// reset all monostable switches
				fnkey[`FN_STOPN] <= 1'b0;
				fnkey[`FN_STEP] <= 1'b0;
				fnkey[`FN_FETCH] <= 1'b0;
				fnkey[`FN_STORE] <= 1'b0;
				fnkey[`FN_CYCLE] <= 1'b0;
				fnkey[`FN_LOAD] <= 1'b0;
				fnkey[`FN_BIN] <= 1'b0;
				fnkey[`FN_OPRQ] <= 1'b0;
				fnkey[`FN_CLEAR] <= 1'b0;
			end

		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
