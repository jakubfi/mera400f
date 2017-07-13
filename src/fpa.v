/*
	F-PA unit (FPU arithmetic)

	document: 12-006370-01-4A
	unit:     F-PA2-1
	pages:    2-29..2-48
*/

module fpa(
	input opta, optb, optc, opm,
	input strob_fp,
	// sheet 1
	input [0:15] w, // also on sheets 2, 12, 13
	input taa,
	// sheet 2
	input t_1,
	input tab,
	input clockta,
	input clocktb,
	input clocktc,
	output t_0_1,
	output t_2_7,
	output t_8_15,
	output t_16_23,
	output t_24_31,
	output t_32_39,
	// sheet 3
	input m_1,
	input ma,
	input mb,
	input clockm,
	input _0_m,
	output c0_eq_c1,
	output fc0_,
	output t1_,
	output t0_eq_c0,
	output t0_c0,
	output t0_t1,
	output m0_,
	output t0_,
	// sheet 4
	input fab_,
	input faa_,
	output fp0_,
	// sheet 5
	// sheet 6
	input p_16,
	output m14_,
	output m15_,
	// sheet 7
	// (nothing)
	// sheet 8
	output fp16_,
	// sheet 9
	output t16_,
	// sheet 10
	// (nothing)
	// sheet 11
	input m_32,
	input p_32,
	// sheet 12
	// also w[8:11]
	// sheet 13
	// w[12:15]
	// sheet 14
	input f2_,
	input m_40,
	input cp_,
	input t_c_,
	output m32_,
	output m38_,
	output m39_,
	output c39_,
	// sheet 15
	input fra_,
	input frb_,
	input p_40,
	output p32_,
	// sheet 16
	input trb,
	input _0_t,
	output t39_,
	// sheet 17
	input f9_ka,
	input lkb,
	// sheet 18
	input z_f,
	input m_f,
	input v_f,
	input c_f,
	output [0:15] zp,
	// sheet 19
	input [0:7] d,
	input _0_zp,
	input zpb,
	input zpa

);

	wor __NC;

	// sheet 1

	// K bus

	wire [0:39] k /* synthesis keep */;

	always @ (*) begin
		case ({lkb, f9_ka})
			2'b00: k <= sum[0:39];
			2'b01: k <= m[0:39];
			2'b10: k <= {w[0:15], w[0:15], w[0:7]};
			2'b11: k <= 40'd0;
		endcase
	end

	// sheet 2

	// T register

	reg [0:39] t;

	always @ (negedge strob_fp, posedge _0_t) begin
		if (_0_t) t[0:15] <= 0;
		else if (opta) case ({~tab, ~taa})
			2'b00: t[0:15] <= t[0:15];
			2'b01: t[0:15] <= {t_1, t[0:14]};
			2'b10: t[0:15] <= {t[1:15], t[16]};
			2'b11: t[0:15] <= k[0:15];
		endcase
	end

	always @ (negedge strob_fp, posedge _0_t) begin
		if (_0_t) t[16:31] <= 0;
		else if (optb) case ({~trb, ~taa})
			2'b00: t[16:31] <= t[16:31];
			2'b01: t[16:31] <= {t[15], t[16:30]};
			2'b10: t[16:31] <= {t[17:31], t[32]};
			2'b11: t[16:31] <= k[16:31];
		endcase
	end

	always @ (negedge strob_fp, posedge _0_t) begin
		if (_0_t) t[32:39] <= 0;
		else if (optc) case ({~trb, ~taa})
			2'b00: t[32:39] <= t[32:39];
			2'b01: t[32:39] <= {t[31], t[32:38]};
			2'b10: t[32:39] <= {t[33:39], m_1};
			2'b11: t[32:39] <= k[32:39];
		endcase
	end

	// sheet 3

	// M register

	reg [0:39] m;

	// NOTE: unused due to M clock/op split
	// wire clockm_ = ~clockm;
	wire ma_ /* synthesis keep */ = ~ma;
	wire mb_ /* synthesis keep */ = ~mb;
	wire _0_m_ = ~_0_m;

	always @ (negedge strob_fp, negedge _0_m_) begin
		if (~_0_m_) m[0:39] <= 0;
		else if (opm) case ({mb_, ma_})
			2'b00: m[0:39] <= m[0:39];
			2'b01: m[0:39] <= {m_1, m[0:38]};
			2'b10: m[0:39] <= {m[1:31], m_32, m[33:39], m_40};
			2'b11: m[0:39] <= t[0:39];
		endcase
	end

	// C register

	// NOTE: unused in FPGA
	// wire f2 = ~f2_;
	wire t_c = ~t_c_;
	wire cp = ~cp_;

	reg [0:39] c;

	// NOTE: T->C and CP sensitivities have changed (ops are front-edge sensitive now)
	// NOTE: F2 as 7495's prallel load enable signal was dropped for the FPGA implementation
	wire cclk = t_c | cp;
	always @ (posedge cclk) begin
		if (t_c) c <= t;
		else if (cp) c <= {c[0], c[0:38]};
	end

	assign c0_eq_c1 = c[0] ^ ~c[1];
	assign fc0_ = ~c[0];
	assign t1_ = ~t[1];
	assign t0_eq_c0 = fc0_ ^ t[0];
	assign t0_c0 = c[0] ^ t[0];
	assign t0_t1 = t[0] ^ t[1];
	assign m0_ = ~m[0];
	assign t0_ = ~t[0];

	// sheet 4
	// ALU

	wire faa = ~faa_;
	wire fab = ~fab_;

	wire [0:39] sum;
	wire g0a, g1a, g2a, g3a;
	wire p0a, p1a, p2a, p3a;

	alu181 M52(
		.a(t[0:3]),
		.b(c[0:3]),
		.m(1'b0),
		.c_(p4_),
		.s({faa, fab, fab, faa}),
		.f(sum[0:3]),
		.g(g3a),
		.p(p3a),
		.co_(fp0_),
		.eq(__NC)
	);

	alu181 M53(
		.a(t[4:7]),
		.b(c[4:7]),
		.m(1'b0),
		.c_(p8_),
		.s({faa, fab, fab, faa}),
		.f(sum[4:7]),
		.g(g2a),
		.p(p2a),
		.co_(__NC),
		.eq(__NC)
	);

	wire p12_, p8_, p4_;

	carry182 M42(
		.c_(~p_16),
		.g({g3a, g2a, g1a, g0a}),
		.p({p3a, p2a, p1a, p0a}),
		.c1_(p12_),
		.c2_(p8_),
		.c3_(p4_),
		.op(__NC),
		.og(__NC)
	);

	// sheet 6

	alu181 M54(
		.a(t[8:11]),
		.b(c[8:11]),
		.m(1'b0),
		.c_(p12_),
		.s({faa, fab, fab, faa}),
		.f(sum[8:11]),
		.g(g1a),
		.p(p1a),
		.co_(__NC),
		.eq(__NC)
	);

	alu181 M55(
		.a(t[12:15]),
		.b(c[12:15]),
		.m(1'b0),
		.c_(~p_16),
		.s({faa, fab, fab, faa}),
		.f(sum[12:15]),
		.g(g0a),
		.p(p0a),
		.co_(__NC),
		.eq(__NC)
	);

	assign m14_ = ~m[14];
	assign m15_ = ~m[15];

	// sheet 8

	alu181 M56(
		.a(t[16:19]),
		.b(c[16:19]),
		.m(1'b0),
		.c_(p21_),
		.s({fra1, frb, frb, fra1}),
		.f(sum[16:19]),
		.g(g3b),
		.p(p3b),
		.co_(fp16_),
		.eq(__NC)
	);

	alu181 M57(
		.a(t[20:23]),
		.b(c[20:23]),
		.m(1'b0),
		.c_(p24_),
		.s({fra1, frb, frb, fra1}),
		.f(sum[20:23]),
		.g(g2b),
		.p(p2b),
		.co_(__NC),
		.eq(__NC)
	);

	// sheet 9

	assign t16_ = ~t[16];

	// sheet 10

	wire p21_, p24_, p28_;
	wire g3b, g2b, g1b, g0b;
	wire p3b, p2b, p1b, p0b;
	carry182 M47(
		.c_(~p_32),
		.g({g3b, g2b, g1b, g0b}),
		.p({p3b, p2b, p1b, p0b}),
		.c1_(p28_),
		.c2_(p24_),
		.c3_(p21_),
		.op(__NC),
		.og(__NC)
	);

	// sheet 11

	alu181 M58(
		.a(t[24:27]),
		.b(c[24:27]),
		.m(1'b0),
		.c_(p28_),
		.s({fra1, frb, frb, fra1}),
		.f(sum[24:27]),
		.g(g1b),
		.p(p1b),
		.co_(__NC),
		.eq(__NC)
	);

	alu181 M59(
		.a(t[28:31]),
		.b(c[28:31]),
		.m(1'b0),
		.c_(~p_32),
		.s({fra1, frb, frb, fra1}),
		.f(sum[28:31]),
		.g(g0b),
		.p(p0b),
		.co_(__NC),
		.eq(__NC)
	);

	// sheet 14

	assign m32_ = ~m[32];
	assign m38_ = ~m[38];
	assign m39_ = ~m[39];
	assign c39_ = ~c[39];

	// sheet 15

	wire p36_;
	wire fra = ~fra_;
	wire fra1 = ~fra_;
	wire frb = ~frb_;

	alu181 M60(
		.a(t[32:35]),
		.b(c[32:35]),
		.m(1'b0),
		.c_(p36_),
		.s({fra, frb, frb, fra}),
		.f(sum[32:35]),
		.g(__NC),
		.p(__NC),
		.co_(p32_),
		.eq(__NC)
	);

	alu181 M61(
		.a(t[36:39]),
		.b(c[36:39]),
		.m(1'b0),
		.c_(~p_40),
		.s({fra, frb, frb, fra}),
		.f(sum[36:39]),
		.g(__NC),
		.p(__NC),
		.co_(p36_),
		.eq(__NC)
	);

	// sheet 16

	assign t39_ = ~t[39];

	// sheet 18

	always @ (*) begin
		if (_0_zp) zp <= 16'd0;
		else case ({zpb, zpa})
			2'b00: zp <= t[0:15];
			2'b01: zp <= t[16:31];
			2'b10: zp <= {t[32:39], d[0:7]};
			2'b11: zp <= {z_f, m_f, v_f, c_f, 12'd0};
		endcase
	end

	assign t_0_1 = |t[0:1];
	assign t_2_7 = |t[2:7];
	assign t_8_15 = |t[8:15];
	assign t_16_23 = |t[16:23];
	assign t_24_31 = |t[24:31];
	assign t_32_39 = |t[32:39];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
