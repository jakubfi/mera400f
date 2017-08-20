/*
	F-PA unit (FPU arithmetic)

	document: 12-006370-01-4A
	unit:     F-PA2-1
	pages:    2-29..2-48
*/

module fpa(
	input opta, optb, optc, opm,
	input strob_fp,
	input strobb_fp,
	// sheet 1
	input [0:15] w,
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
	output c0,
	output t1,
	output t0_eq_c0,
	output t0_neq_c0,
	output t0_neq_t1,
	output m0,
	output t0,
	// sheet 4
	input fab,
	input faa,
	output fp0_,
	// sheet 5
	// sheet 6
	input p_16,
	output m14,
	output m15,
	// sheet 7
	// (nothing)
	// sheet 8
	output fp16_,
	// sheet 9
	output t16,
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
	input m_40,
	input cp,
	input t_c,
	output m32,
	output m38,
	output m39,
	output c39,
	// sheet 15
	input fra,
	input frb,
	input p_40,
	output p32_,
	// sheet 16
	input trb,
	input _0_t,
	output t39,
	// sheet 17
	input f9,
	input lkb,
	// sheet 18
	input z_f,
	input m_f,
	input v_f,
	input c_f,
	output [0:15] zp,
	// sheet 19
	input [-2:7] d,
	input _0_zp,
	input zpb,
	input zpa
);

	// --- K bus ------------------------------------------------------------

	wire [0:39] k /* synthesis keep */;

	always @ (*) begin
		case ({lkb, f9})
			2'b00: k <= sum[0:39];
			2'b01: k <= m[0:39];
			2'b10: k <= {w[0:15], w[0:15], w[0:7]};
			2'b11: k <= 40'd0;
		endcase
	end

	// --- T register -------------------------------------------------------

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

	assign t0 = t[0];
	assign t1 = t[1];
	assign t16 = t[16];
	assign t39 = t[39];

	assign t0_eq_c0 = t[0] == c[0];
	assign t0_neq_c0 = c[0] != t[0];
	assign t0_neq_t1 = t[0] != t[1];

	assign t_0_1 = |t[0:1];
	assign t_2_7 = |t[2:7];
	assign t_8_15 = |t[8:15];
	assign t_16_23 = |t[16:23];
	assign t_24_31 = |t[24:31];
	assign t_32_39 = |t[32:39];

	// --- M register -------------------------------------------------------

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

	assign m0 = m[0];
	assign m14 = m[14];
	assign m15 = m[15];
	assign m32 = m[32];
	assign m38 = m[38];
	assign m39 = m[39];

	// --- C register -------------------------------------------------------

	reg [0:39] c;

	// NOTE: T->C and CP sensitivities have changed (ops are front-edge sensitive now)
	// NOTE: F2 as 7495's prallel load enable signal was dropped for the FPGA implementation
	wire cclk = t_c | cp;
	always @ (posedge cclk) begin
		if (t_c) c <= t;
		else if (cp) c <= {c[0], c[0:38]};
	end

	assign c0_eq_c1 = c[0] == c[1];
	assign c0 = c[0];
	assign c39 = c[39];

	// --- Mantissa ALU -----------------------------------------------------

	wire [0:39] sum;

	fpalu FPALU(
		.t(t),
		.c(c),
		.faa(faa),
		.fab(fab),
		.fra(fra),
		.frb(frb),
		.p_16(p_16),
		.p_32(p_32),
		.p_40(p_40),
		.fp0_(fp0_), // carry out above bit 0
		.fp16_(fp16_), // carry out above bit 16
		.p32_(p32_), // carry out above bit 32
		.sum(sum)
	);

	// --- ZP bus -----------------------------------------------------------

	always @ (*) begin
		if (_0_zp) zp <= 16'd0;
		else case ({zpb, zpa})
			2'b00: zp <= t[0:15];
			2'b01: zp <= t[16:31];
			2'b10: zp <= {t[32:39], d[0:7]};
			2'b11: zp <= {z_f, m_f, v_f, c_f, 12'd0};
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
