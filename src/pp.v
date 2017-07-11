/*
	P-P unit (interrupts)

	document: 12-006368-01-8A
	unit:     P-P3-2
	pages:    2-44..2-57
*/

module pp(
	input __clk,
	// sheet 1, 2
	input [0:15] w,
	input clm_,
	input w_rm,
	input strob1_,
	input i4_,
	output [0:9] rs,
	// sheet 3
	input pout_,
	input zer_,
	input b_parz_,
	input ck_rz_w,
	input b_p0_,
	input zerrz_,
	input i1_,
	input przerw_,
	output [0:15] bus_rz,
	// sheet 4
	input rpa_,
	input zegar_,
	input xi_,
	input fi0_,
	// sheet 5
	input fi1_,
	input fi2_,
	input fi3_,
	output przerw_z,
	// sheet 6
	input k1_,
	input i2_,
	// sheet 7
	// ??
	// sheet 8
	// --
	// sheet 9
	input oprq_,
	// sheet 10
	input ir14,
	input wx_,
	input sin,
	input ir15,
	// sheet 11
	input rin_,
	input zw,
	input rdt15_,
	input zgpn_,
	input rdt0_,
	input rdt14_,
	input rdt13_,
	input rdt12_,
	input rdt11_,
	output dok_,
	output irq,
	// sheet 12
	// --
	// sheet 13
	output dad11_,
	output dad12_,
	output dad13_,
	output dad14_,
	output dad4_,
	output dad15_

);

	parameter DOK_DLY_TICKS;
	parameter DOK_TICKS;

	wor __NC; // unconnected signals here, to suppress warnings

	// sheet 1, 2
	// * RM - interrupt mask register

	wire clm$ = ~(clm_ & ~(strob1 & i4$));
	wire clrs_ = ~(strob1 & w_rm); // M44_8 = M44_11 = -CLRS5-9
	wire strob1 = ~strob1_;
	wire i4$ = ~i4_;

  wire [0:9] zi_ = {~zi, 1'b1};

	genvar num;
	generate
		for (num=0 ; num<10 ; num=num+1) begin : GEN_REG_RM
			wire rm_reset_ = ~(zi_[num] & clm$);
			ffd REG_RM(
				.s_(1'b1),
				.d(w[num]),
				.c(clrs_),
				.r_(rm_reset_),
				.q(rs[num])
			);
			// NOTE: Ix = RS[x] (Ix's not included due to name collisions)
		end
	endgenerate

	// sheet 3..10
	// * RZ, RP - interrupt request and service registers

	// RZ input: async interrupt signals bus
	wire [0:31] IRQ_ = {
		pout_,		// 0 power out (NMI)
		b_parz_,	// 1 memory parity error
		b_p0_,		// 2 no memory
		rz4_,			// 3 other CPU, high priority
		rpa_,			// 4 interface power out
		zegar_,		// 5 timer
		xi_,			// 6 illegal instruction
		fi0_,			// 7 div overflow (fixed point)
		fi1_,			// 8 floating point underflow
		fi2_,			// 9 floating point overflow
		fi3_,			// 10 div/0 or floating point error
		1'b1,			// 11 unused
		zk_[0:15],// 12-27 channel interrupts
		oprq_,		// 28 operator request
		rz29_,		// 29 other CPU, low priority
		M89_6,		// 30 software interrupt high
		M70_3			// 31 software interrupt low
	};

	// FIX: missing connection from M104.12 to M89.5, M70.2

	// RZ input: software interrupt drivers (sheet 10)
	wire M104_12 = ~wx_ & sin & strob1;
	wire M89_6 = ~(ir14 & M104_12);
	wire M70_3 = ~(ir15 & M104_12);

	// RZ input: W bus, synchronous (software-set) interrupt sources
	wire [0:31] INT_SYNC = {
		w[0:11],		// software-settable interrupts
		{16{1'b0}}, // channel interrupts cannot be set synchronously
		w[12:15]		// software-settable interrupts
	};

	// RZ input: clocks
	wire ck_rzwm = ~(strob1 & ck_rz_w);
	wire ck_rzwm_ = ~ck_rzwm;
	wire ck_rzz_ = ~(~(strob1 & ~i2_));
	wire [0:31] RZ_CLK = {
		{12{ck_rzwm_}},
		{16{ck_rzz_}},
		{4{ck_rzwm_}}
	};

	// RZ input: resets
	wire _0_rzw_ = ~(~(clm_ & zerrz_));
	wire _0_rzz_ = ~(~(clm_ & k1_));
	wire M94_3 = _0_rzw_ & ~(M104_12 & (~ir14 & ~ir15));
	wire [0:31] RZ_RESET = {
		{12{_0_rzw_}},
		{16{_0_rzz_}},
		{2{_0_rzw_}},
		{2{M94_3}}
	};

	// RZ input: interrupt mask bus (right after RZ outputs)
	wire [0:31] IMASK = {
		1'b1,				// 0 (NMI)
		rs[0:3],		// 1-4
		{7{rs[4]}},	// 5-11
		{2{rs[5]}},	// 12-13
		{2{rs[6]}},	// 14-15
		{6{rs[7]}},	// 16-21
		{6{rs[8]}},	// 22-27
		{4{rs[9]}}	// 28-31
	};

	// RP input: clocks
	wire ez_rpz = ~(~i1_ & ~przerw_);
	wire ez_rpw_ = ~ez_rpz;
	wire ez_rpz_ = ~ez_rpz;
	wire [0:31] RP_CLK = {
		{16{ez_rpw_}},
		{16{ez_rpz_}}
	};

	// RP output: interrupt mask drivers (to RM)
	wire [0:8] zi = {
		PRIO_OUT[1],
		PRIO_OUT[2],
		PRIO_OUT[3],
		PRIO_OUT[4],
		PRIO_OUT[11],
		PRIO_OUT[13],
		PRIO_OUT[15],
		PRIO_OUT[21],
		PRIO_OUT[27]
	};

	// RP input/output: interrupt priority chain
	wire [0:31] PRIO_OUT;
	wire [0:31] PRIO_IN = {
		zer_,
		PRIO_OUT[0:30]
	};

	// RZ output: only non-channel interrupts are available to the user
	wire [0:31] __rz;
	assign bus_rz = {
		__rz[0:11],
		__rz[28:31]
	};

	// RZ output: masked
	wire [0:31] sz;

	// RP output
	wire [0:31] rp_;

	genvar j;
	generate
		for (j=0 ; j<32 ; j=j+1) begin : GEN_RZ_RP
			rzrp RZ_RP(
				.imask(IMASK[j]),					// IRQ mask input
				.irq_(IRQ_[j]),						// IRQ (async)
				.w(INT_SYNC[j]),					// synchronous interrupt set
				.rz_c_(RZ_CLK[j]),				// RZ clock
				.rz_r_(RZ_RESET[j]),			// RZ reset
				.rp_c(RP_CLK[j]),					// RP clock
				.prio_in_(PRIO_IN[j]),		// priority chain input
				.rz(__rz[j]),							// RZ content
				.sz(sz[j]),								// RZ & mask
				.rp_(rp_[j]),							// RP content
				.prio_out(PRIO_OUT[j])		// priority chain output
			);
		end
	endgenerate

	assign __NC = rp_[0];
	assign __NC = rp_[16];
	assign __NC = PRIO_OUT[31];
	assign __NC = |__rz[12:27];

	// sheet 3

	wire przerw = ~przerw_;

	// sheet 5

	assign przerw_z = srps & zi[4];

	// sheet 6

	wire nk_ad = ~i2_ & zw;

	// sheet 9

	wire srps = ~zi[8];

	// sheet 11

	wire dok_dly;
	dly #(.ticks(DOK_DLY_TICKS)) DLY_DOK(
		.clk(__clk),
		.i(~rin_),
		.o(dok_dly)
	);
	wire M12_3 = ~dok_dly;

	// TODO: cap + diode?
	wire zw_dly = ~zw;

	wire M14_6;
	univib #(.ticks(DOK_TICKS)) TRIG_DOK(
		.clk(__clk),
		.a_(M12_3),
		.b(zw_dly),
		.q(M14_6)
	);

	wire M11_3 = ~(rdt15_ & zgpn_);
	wire M12_6 = ~(M11_3 & rdt15_);

	wire M9_5;
	ffd REG_DOK(
		.s_(1'b1),
		.d(M12_6),
		.c(~M14_6),
		.r_(~M12_3),
		.q(M9_5)
	);
	assign dok_ = ~(~rin_ & M9_5);

	wire rz29_ = ~(M14_6 & ~rdt15_ & ~rdt0_);
	wire rz4_ = ~(M14_6 & ~rdt15_ & rdt0_);

	assign irq = ~(&sz);

	wire [0:15] zk_;
	decoder16 DEC_ZK(
		.en1_(M11_3),
		.en2_(~M14_6),
		.a(~rdt14_),
		.b(~rdt13_),
		.c(~rdt12_),
		.d(~rdt11_),
		.o_(zk_)
	);

	// sheet 12

	wire npbd = ~(rp_[24] & rp_[25] & rp_[26] & rp_[28] & rp_[29] & rp_[30] & rp_[27] & rp_[31]);
	wire npbc = ~(rp_[28] & rp_[29] & rp_[30] & rp_[31] & rp_[23] & rp_[22] & rp_[21] & rp_[20]);
	wire npbb = ~(rp_[22] & rp_[23] & rp_[26] & rp_[30] & rp_[27] & rp_[31] & rp_[19] & rp_[18]);
	wire npba = ~(rp_[19] & rp_[21] & rp_[23] & rp_[25] & rp_[29] & rp_[27] & rp_[31] & rp_[17]);

	// sheet 13

	wire npad = ~(rp_[ 8] & rp_[ 9] & rp_[10] & rp_[11] & rp_[12] & rp_[13] & rp_[14] & rp_[15]);
	wire npac = ~(rp_[ 4] & rp_[ 5] & rp_[ 6] & rp_[ 7] & rp_[12] & rp_[13] & rp_[14] & rp_[15]);
	wire npab = ~(rp_[ 2] & rp_[ 3] & rp_[ 6] & rp_[ 7] & rp_[10] & rp_[11] & rp_[14] & rp_[15]);
	wire npaa = ~(rp_[ 1] & rp_[ 3] & rp_[ 5] & rp_[ 7] & rp_[ 9] & rp_[11] & rp_[13] & rp_[15]);

	assign dad4_ = ~nk_ad;

	wire M85_11 = npbd ^ npad;
	wire M85_8  = npbc ^ npac;
	wire M85_6  = npbb ^ npab;
	wire M85_3  = npba ^ npaa;
	wire M99_6 = M85_11 ^ M85_8;

	wire M4_8 = przerw & zw & i4$;

	assign dad11_ = ~(M4_8 & zi[6])  & ~(nk_ad & M99_6);
	assign dad12_ = ~(M4_8 & M85_11) & ~(nk_ad & ~M85_8);
	assign dad13_ = ~(M4_8 & M85_8)  & ~(nk_ad & M85_6);
	assign dad14_ = ~(M4_8 & M85_6)  & ~(nk_ad & M85_3);
	assign dad15_ = ~(M4_8 & M85_3);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
