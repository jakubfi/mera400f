`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg [0:15] d;
	reg c;
	wire [0:15] q;
	reg [0:16] v;

	latch16 U1(
		.d(d),
		.c(c),
		.q(q)
	);

	initial begin

		for (v=0 ; v<65536 ; v=v+1) begin
			#1 c = 1'b1; d = v[1:16];
			#1 `tbassert(q, v[1:16])
			#1 c = 1'b0; d = 1'b0;
			#1 `tbassert(q, v[1:16])
		end

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
