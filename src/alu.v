/*

0-7: {sd, ~scb_, sb, ~sab_}
8-15: {sd, ~sca_, sb, ~saa_}

			.-> saryt
			| .-> sd, sca, sb, saa (s[3:0])
			| |			.-> sd, scb, sb, sab (s[3:0])
			| |			|
A+B		1	1001	1001	ad, lws, rws, js, lj, ib, trb, krb
A-B		1	0110	0110	sw, co, ng, cb
A|B		0	1110	1110	or, om, ls, is
A|~B	0	1101	1101	bc, oc
A&B		0	1011	1011	nr, nm, ls & ~wls, bn, bs
~A&B	0	0010	0010	ls & wls, bb
A&~B	0	0111	0111	er, em, is, bm
A^B		0	0110	0110	xr, xm, bs
A			1	0000	0000	ri
A			0	1111	1111	zb, (lb, rb) & W&, irb, sr
B			0 1010	1010	(lb, rb) & wz
A-1		1	1111	1111	drb
~A		0 0000	0000	ngl
A+A		1 1100	1100	sl

*/

module alu(
	input p16_,
	input [0:15] a,
	input [0:15] ac,
	input saryt,
	input sd_, sb_,
	input scb_, sab_,
	input sca_, saa_,
	output [0:15] f,
	output j$,
	output carry_,
	output zsum_
);

	wor __NC;

	// sheet 5

	wire [3:0] g, p;
	wire [3:1] c_;
	wire [3:0] j$1;

	// most significant
	alu181 ALU_0_3(
		.a(a[0:3]),
		.b(ac[0:3]),
		.s({sd, ~scb_, sb, ~sab_}),
		.m(~saryt),
		.cn_(c_[3]),
		.f(f[0:3]),
		.eq(j$1[3]),
		.x(p[3]),
		.y(g[3]),
		.cn4_(carry_)
	);
	wire z1_ = ~(f[0] | f[1]);
	wire z2_ = ~(f[2] | f[3]);

	alu181 ALU_4_7(
		.a(a[4:7]),
		.b(ac[4:7]),
		.s({sd, ~scb_, sb, ~sab_}),
		.m(~saryt),
		.cn_(c_[2]),
		.f(f[4:7]),
		.eq(j$1[2]),
		.x(p[2]),
		.y(g[2]),
		.cn4_(__NC)
	);
	wire z3_ = ~(f[4] | f[5]);
	wire z4_ = ~(f[6] | f[7]);
	wire sb = ~sb_;
	wire sd = ~sd_;

	// sheet 6

	assign j$ = &j$1;

	alu181 ALU_8_11(
		.a(a[8:11]),
		.b(ac[8:11]),
		.s({sd, ~sca_, sb, ~saa_}),
		.m(~saryt),
		.cn_(c_[1]),
		.f(f[8:11]),
		.eq(j$1[1]),
		.x(p[1]),
		.y(g[1]),
		.cn4_(__NC)
	);
	wire z5_ = ~(f[8] | f[9]);
	wire z6_ = ~(f[10] | f[11]);
	wire z7_ = ~(f[12] | f[13]);
	wire z8_ = ~(f[14] | f[15]);

	// least significant
	alu181 ALU_12_15(
		.a(a[12:15]),
		.b(ac[12:15]),
		.s({sd, ~sca_, sb, ~saa_}),
		.m(~saryt),
		.cn_(p16_),
		.f(f[12:15]),
		.eq(j$1[0]),
		.x(p[0]),
		.y(g[0]),
		.cn4_(__NC)
	);

	// FIX: M35 and M33 had 'carry in', G and P pins switched between them
	carry182 CARRY(
		.y(g),
		.x(p),
		.cn_(p16_),
		.cnx_(c_[3]),
		.cny_(c_[2]),
		.cnz_(c_[1]),
		.ox(__NC),
		.oy(__NC)
	);

	// on sheet 8

	assign zsum_ = ~(z1_ & z2_ & z3_ & z4_ & z5_ & z6_ & z7_ & z8_);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
