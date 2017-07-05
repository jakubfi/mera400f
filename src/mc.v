module mc(
	input inc_,
	input reset_,
	output mc_3,
	output mc_0
);

  reg [1:0] __mc;
  always @ (negedge inc_, negedge reset_) begin
    if (~reset_) __mc <= 2'd0;
    else __mc <= __mc + 1'b1;
  end

  assign mc_3 = (__mc == 3);
  assign mc_0 = (__mc == 0);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
