// OK interface signal driver

module dok(
	input clk_sys,
	input rin,
	input zw,
	input int_ext,
	output dok_trig,
	output dok
);

	parameter DOK_DLY_TICKS;
	parameter DOK_TICKS;

	localparam S_IDLE = 2'd0;
	localparam S_WAIT = 2'd1;
	localparam S_OK		= 2'd2;

	reg [1:0] state;
	reg [2:0] okcnt;

	// TODO: check, simplify, make compatibile with the interface?

	always @ (posedge clk_sys) begin
		case (state)
			S_IDLE: begin
				if (rin) state <= S_WAIT;
			end

			S_WAIT: begin
				if (~zw) begin	
					state <= S_OK;
					okcnt <= DOK_TICKS;
				end;
			end

			S_OK: begin
				okcnt <= okcnt - 1'b1;
				if (okcnt == 0) state <= S_IDLE;
			end

		endcase
	end

	assign dok_trig = (state == S_WAIT);
	assign dok = (state == S_OK) & rin;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
