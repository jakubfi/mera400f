module alu(
	input [0:15] a, ac,
	output [0:15] f,
	input saryt,
	input p16_,
	output carry_,
	output j$,
	output zero_,
	input sd_, sb_,
	input scb_, sab_,
	input sca_, saa_
);

	wor __NC;

	// sheet 5

	wire [0:3] g, p;
	wire [1:3] c_;
	wire [0:3] j$1;

	// most significant
	alu181 ALU0(
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

	alu181 ALU1(
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

	alu181 ALU2(
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
	alu181 ALU3(
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
	carry182 __carry(
		.y(g),
		.x(p),
		.cn_(p16_),
		.cnx_(c_[1]),
		.cny_(c_[2]),
		.cnz_(c_[3]),
		.ox(__NC),
		.oy(__NC)
	);

	// on sheet 8

	assign zero_ = ~(z1_ & z2_ & z3_ & z4_ & z5_ & z6_ & z7_ & z8_);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
