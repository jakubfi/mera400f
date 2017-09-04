// I-SK unit (system interface)

module isk(
	input [0:`BUS_MAX] cpu0d,
	output [0:`BUS_MAX] cpu0r,
	input [0:`BUS_MAX] cpu1d,
	output [0:`BUS_MAX] cpu1r,
	input [0:`BUS_MAX] memd,
	output [0:`BUS_MAX] memr,
	input [1:4] zg,
	input [1:4] zz,
	output [1:4] zw
);

	always @ (*) begin
		zw[1] = zg[1];
		zw[2] = zg[2] & ~zg[1];
		zw[3] = zg[3] & ~zg[2] & ~zg[1];
		zw[4] = zg[4] & ~zg[3] & ~zg[2] & ~zg[1];
	end

	assign cpu0r = memd | cpu1d;
	assign cpu1r = memd | cpu0d;
	assign memr = cpu0d | cpu1d;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
