`timescale 1ns/100ps
`include "tbassert.inc"

module test();

	reg si1_, p_;
	reg [0:8] r0;
	reg [0:15] w;
	reg strob1, w_ir;
	wire [0:15] ir;
	wire xi, nef, b0_;
	wire lwt$_, md;
	wire pufa, ka1_, ka2_, aryt;

	pd U1(
		.si1_(si1_), .p_(p_), .q(q), .r0(r0),
		.w(w), .ir(ir),
		.strob1(strob1), .w_ir(w_ir),
		.nef(nef), .xi(xi), .b0_(b0_),
		.pufa(pufa), .ka1_(ka1_), .ka2_(ka2_), .aryt(aryt),
		.lwt$_(lwt$_), .md(md)
	);

	initial begin
		#1 r0 = 9'b0;
		#1 p_ = 1'b1; si1_ = 1'b1;
		#1 strob1 = 1; w_ir = 1;
		#1 w = 16'b000_000_0_000_000_000; // illegal
		#1 `tbassert(ir, 16'b0)
		#1 `tbassert(xi, 1'b1)
		#1 `tbassert(nef, 1'b1)
		#1 w = 16'b010_000_0_000_000_000; // LW
		#1 `tbassert(ir, 16'b010_000_0_000_000_000)
		#1 `tbassert(xi, 1'b0)
		#1 `tbassert(nef, 1'b0)
		#1 `tbassert(lwt$_, 1'b0)
		#1 w = 16'b011_111_0_111_100_000; // DF
		#1 `tbassert(lwt$_, 1'b1)
		#1 `tbassert(pufa, 1'b1)
		#1 `tbassert(ka2_, 1'b1)
		#1 `tbassert(b0_, 1'b1)
		#1 w = 16'b111_001_0_100_000_000; // EXL
		#1 `tbassert(pufa, 1'b0)
		#1 `tbassert(ka2_, 1'b0)
		#1 `tbassert(b0_, 1'b0)
		#1 w = 16'b111_111_0_101_010_000; // MD
		#1 `tbassert(pufa, 1'b0)
		#1 `tbassert(ka2_, 1'b1)
		#1 `tbassert(b0_, 1'b1)
		#1 `tbassert(md, 1'b1)
		#1 w = 16'b110_100_0_000_000_000; // CWT
		#1 `tbassert(ka2_, 1'b1)
		#1 `tbassert(ka1_, 1'b0)
		#1 `tbassert(aryt, 1'b1)

		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
