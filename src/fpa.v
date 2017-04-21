/*
	F-PA unit (FPU arithmetic)

	document: 12-006370-01-4A
	unit:     F-PA2-1
	pages:    2-29..2-48
*/

module fpa(
	// sheet 1
	input [0:15] w, // also on sheets 2, 12, 13
	input taa,
	// sheet 2
	input t_1,
	input tab_,
	input clockta_,
	output t_0_1_,
	output t_2_7_,
	// sheet 3
	input m_1,
	input ma,
	input mb,
	input clockm,
	input _0_m,
	output c0_eq_c1,
	output c1_,
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
	output t_8_15_,
	// sheet 6
	input p_16_,
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
	input p_32_,
	// sheet 12
	input clocktb_,
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
	input p_40_,
	output p32_,
	// sheet 16
	input clocktc_,
	input trb_,
	input _0_t,
	output t39_,
	// sheet 17
	input f9_ka_,
	input lkb_,
	// sheet 18
	input z_f,
	input m_f,
	input v_f,
	input c_f,
	output [0:15] zp,
	output t_32_39_,
	output t_16_23_,
	// sheet 19
	input [0:7] d,
	input _0_zp_,
	input zpb_,
	input zpa_,
	output t_24_31_

);

	wor __NC;

	// sheet 1

	// K bus

	wire f9ka = ~f9_ka_;
	wire lkb = ~lkb_;

	wire [0:39] k /* synthesis keep */;

	always @ (*) begin
		case ({lkb, f9ka})
			2'b00: k <= sum[0:39];
			2'b01: k <= m[0:39];
			2'b10: k <= {w[0:15], w[0:15], w[0:7]};
			2'b11: k <= 40'd0;
		endcase
	end

	wire taa_ = ~taa;

	// sheet 2

	// T register

	reg [0:39] t;

	always @ (posedge clockta_, negedge _0_t_) begin
		if (~_0_t_) t[0:15] <= 0;
		else case ({tab_, taa_})
			2'b00: t[0:15] <= t[0:15];
			2'b01: t[0:15] <= {t_1, t[0:14]};
			2'b10: t[0:15] <= {t[1:15], t[16]};
			2'b11: t[0:15] <= k[0:15];
		endcase
	end

	assign t_0_1_ = ~(t[0] | t[1]);
	assign t_2_7_ = ~(t[2] | t[3]) & ~(t[4] | t[5]) & ~(t[6] | t[7]);
	assign t_8_15_ = ~(t[8] | t[9]) & ~(t[10] | t[11]) & ~(t[12] | t[13]) & ~(t[14] | t[15]);

	always @ (posedge clocktb_, negedge _0_t_) begin
		if (~_0_t_) t[16:31] <= 0;
		else case ({trb_, taa_})
			2'b00: t[16:31] <= t[16:31];
			2'b01: t[16:31] <= {t[15], t[16:30]};
			2'b10: t[16:31] <= {t[17:31], t[32]};
			2'b11: t[16:31] <= k[16:31];
		endcase
	end

	always @ (posedge clocktc_, negedge _0_t_) begin
		if (~_0_t_) t[32:39] <= 0;
		else case ({trb_, taa_})
			2'b00: t[32:39] <= t[32:39];
			2'b01: t[32:39] <= {t[31], t[32:38]};
			2'b10: t[32:39] <= {t[33:39], m_1};
			2'b11: t[32:39] <= k[32:39];
		endcase
	end

	// sheet 3

	// M register

	reg [0:39] m;

	wire clockm_ = ~clockm;
	wire ma_ /* synthesis keep */ = ~ma;
	wire mb_ /* synthesis keep */ = ~mb;
	wire _0_m_ = ~_0_m;

	always @ (posedge clockm_, negedge _0_m_) begin
		if (~_0_m_) m[0:39] <= 0;
		else case ({mb_, ma_})
			2'b00: m[0:39] <= m[0:39];
			2'b01: m[0:39] <= {m_1, m[0:38]};
			2'b10: m[0:39] <= {m[1:31], m_32, m[33:39], m_40};
			2'b11: m[0:39] <= t[0:39];
		endcase
	end

	// C register

	wire f2 = ~f2_;
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
	assign c1_ = ~c[1];
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
		.m(0),
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
		.m(0),
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
		.c_(p_16_),
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
		.m(0),
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
		.m(0),
		.c_(p_16_),
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
		.m(0),
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
		.m(0),
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
		.c_(p_32_),
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
		.m(0),
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
		.m(0),
		.c_(p_32_),
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
		.m(0),
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
		.m(0),
		.c_(p_40_),
		.s({fra, frb, frb, fra}),
		.f(sum[36:39]),
		.g(__NC),
		.p(__NC),
		.co_(p36_),
		.eq(__NC)
	);

	// sheet 16

	wire _0_t_ = ~_0_t;
	assign t39_ = ~t[39];

	// sheet 18

	wire zpa = ~zpa_;
	wire zpb = ~zpb_;
	wire _0_zp = ~_0_zp_;

	always @ (*) begin
		if (_0_zp) zp <= 16'd0;
		else case ({zpb, zpa})
			2'b00: zp <= t[0:15];
			2'b01: zp <= t[16:31];
			2'b10: zp <= {t[32:39], d[0:7]};
			2'b11: zp <= {z_f, m_f, v_f, c_f, 12'd0};
		endcase
	end

	assign t_16_23_ = ~(t[16] | t[17]) & ~(t[18] | t[19]) & ~(t[20] | t[21]) & ~(t[22] | t[23]);
	assign t_32_39_ = ~(t[32] | t[33]) & ~(t[34] | t[35]) & ~(t[36] | t[37]) & ~(t[38] | t[39]);

	// sheet 19

	assign t_24_31_ = ~(t[24] | t[25]) & ~(t[26] | t[27]) & ~(t[28] | t[29]) & ~(t[30] | t[31]);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
