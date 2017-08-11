// I-SK unit (system interface)

module isk(
	input dmcl,
	input dcl,
	input off, // not implemented in FPGA
	output rcl,
	output zoff // not implemented in FPGA
);

	assign zoff = 1'b0;

	assign rcl = dcl | dmcl;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
