/*
	I-SK unit (system interface)

	document: 12-006368-01-8A
	unit:     I-SK1-1
	pages:    2-85..2.90
*/

module isk(
	input dmcl_,
	input dcl_,
	input off_, // not implemented in FPGA
	output rcl_,
	output zoff_ // not implemented in FPGA
);

	assign zoff_ = 1'b1;

	assign rcl_ = dcl_ & dmcl_;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
