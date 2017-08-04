module alarm(
	input clk,
	input engage,
	output talarm
);

	parameter ALARM_DLY_TICKS;
	parameter ALARM_TICKS;

	localparam width = $clog2(ALARM_DLY_TICKS+1);

	localparam S_IDLE	= 'd0;
	localparam S_WAIT	= 'd1;
	localparam S_ALARM = 'd2;

	reg [0:width-1] alarm_cnt;
	reg [0:1] state = S_IDLE;

	always @ (posedge clk) begin
		case (state)

			S_IDLE:
				if (engage) begin
					alarm_cnt <= ALARM_DLY_TICKS;
					state <= S_WAIT;
				end

			S_WAIT:
				if (~engage) state <= S_IDLE;
				else if (alarm_cnt == 0) begin
					state <= S_ALARM;
					alarm_cnt <= ALARM_TICKS;
				end else alarm_cnt <= alarm_cnt - 1'b1;

			S_ALARM:
				if (alarm_cnt == 0) state <= S_IDLE;
				else alarm_cnt <= alarm_cnt - 1'b1;

		endcase
	end

	assign talarm = (state == S_ALARM);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
