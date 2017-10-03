// Control Panel input - serial commands interpreter

module cpin(
	input clk_sys,
	input [7:0] rx_byte,
	input rx_busy,
	input rx_ready,
	output reg send_leds,
	output reg [11:0] fnkey,			// function switches
	output reg [3:0] rotary_pos,	// user-set rotary switch position
	output reg [15:0] kl					// data input switches
);

	localparam S_READ = 1'd0;
	localparam S_CLR	= 1'd1;

	initial rotary_pos = 4'd1; // user-set rotary switch position ("r1" initial)
	reg rxb;
	reg state = S_READ;

	always @ (posedge clk_sys) begin
		case (state)

			S_READ: begin
				if (rx_ready) begin
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
					state <= S_CLR;
				end
			end

			S_CLR: begin
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
				send_leds <= 1'b0;
				state <= S_READ;
			end

		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
