/*
  MERA-400 PUKS-3 unit (power supply: reset circuit and voltage control)

  document: 12-006383-01-9A
  unit:     PUKS-3
  pages:    1-9
*/

module puks(
	input clk,
	input zoff_, // not implemented for FPGA
	input rcl_,
	input dcl_,
	output reg off_, // not implemented for FPGA
	output pout_,
	output pon_,
	output reg clo_,
	output reg clm_
);

	// -POUT: power out, 0.2-2us 
	assign pout_ = 1'b1;

	// -OFF: power lines not ready
	initial off_ = 1;
	reg [4:0] power_ok_cnt = 5'd31;
	always @ (posedge clk) begin
		if (power_ok_cnt > 5'd24) begin
			power_ok_cnt <= power_ok_cnt - 1'b1;
			off_ <= 1;
		end else if (power_ok_cnt != 0) begin
			power_ok_cnt <= power_ok_cnt - 1'b1;
			off_ <= 0;
		end else begin
			off_ <= 1;
		end
	end

	// -PON: power on (0.2-2us strob when power is ready)
	assign pon_ = ~pon;
	wire pon;
	univib #(.ticks(3'd7)) PON(
		.clk(clk),
		.a(1'b0),
		.b(off_),
		.q(pon)
	);

	// -CLO: general reset
	// -CLM: module reset
	// (held for cl_hold cycles after startup so CPU gets clo_/clm_ negedge)
	initial clm_ = 1;
	initial clo_ = 1;
	reg [2:0] cl_hold = 3'd7;
	always @ (posedge clk) begin
		if (cl_hold != 0) begin
			cl_hold <= cl_hold - 1'b1;
			clm_ = 1;
			clo_ = 1;
		end else begin
			clm_ <= off_ & dcl_ & rcl_;
			clo_ <= off_ & dcl_;
		end
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
