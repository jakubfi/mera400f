/*
	PUKS-3 unit (power supply: reset circuit and voltage control)

	document: 12-006383-01-9A
	unit:     PUKS-3
	pages:    1-9
*/

module puks(
	input clk,
	input zoff, // not implemented for FPGA
	input rcl_,
	input dcl,
	output reg off, // not implemented for FPGA
	output pout,
	output pon,
	output reg clo,
	output reg clm
);

	// -POUT: power out (0.2-2us strob, not implemented)
	assign pout = 1'b0;

	// -OFF: power lines not ready (in real hardware: goes high 0.5-2s after the power is switched on)
	initial off = 1;
	reg [2:0] power_ok_cnt = 3'd7;
	always @ (posedge clk) begin
		if (power_ok_cnt == 0) begin
			off <= 0;
		end else begin
			power_ok_cnt <= power_ok_cnt - 1'b1;
		end
	end

	// -PON: power on (0.2-2us strob when power is ready)
	univib #(.ticks(3'd7)) PON(
		.clk(clk),
		.a_(1'b0),
		.b(~off),
		.q(pon)
	);

	// -CLO: general reset
	// -CLM: module reset
	assign clm = ~(~off & ~dcl & rcl_);
	assign clo = ~(~off & ~dcl);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
