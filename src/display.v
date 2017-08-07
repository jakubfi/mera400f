module display(
	input clk_sys,
	input [0:15] w,
	input [10:0] rotary_bus,
	input [9:0] indicators,
	output [7:0] SEG,
	output [7:0] DIG
);

	wire [6:0] digs [7:0];

	hex2seg d0(.hex(w[12:15]), .seg(digs[0]));
	hex2seg d1(.hex(w[8:11]), .seg(digs[1]));
	hex2seg d2(.hex(w[4:7]), .seg(digs[2]));
	hex2seg d3(.hex(w[0:3]), .seg(digs[3]));
	none2seg d4(.seg(digs[4]));
	rb2seg d5(.r(rotary_bus), .seg(digs[5]));
	ra2seg d6(.r(rotary_bus), .seg(digs[6]));

	assign digs[7][0] = indicators[1];
	assign digs[7][6] = ~indicators[0];
	assign digs[7][5:1] = 0;

	sevenseg_drv DRV(
		.clk(clk_sys),
		.seg(SEG),
		.dig(DIG),
		.digs(digs),
		.dots(indicators[9:2])
	);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
