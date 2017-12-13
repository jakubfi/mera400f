module platform(
	input CLK_EXT,
	output BUZZER_,
	// control panel
	input RXD,
	output TXD,
	output [7:0] DIG,
	output [7:0] SEG,
	// RAM
	output SRAM_CE_, SRAM_OE_, SRAM_WE_, SRAM_UB_, SRAM_LB_,
	output [17:0] SRAM_A,
	inout [15:0] SRAM_D,
	output F_CS_, F_OE_, F_WE_
);

	localparam CLK_EXT_HZ = 50_000_000;

// --- MERA-400f ---------------------------------------------------------

	wire sram_ce, sram_oe, sram_we;
	mera400f #(
		.CLK_EXT_HZ(CLK_EXT_HZ)
	) MERA400F (
		.clk_ext(CLK_EXT),
		.rxd(RXD),
		.txd(TXD),
		.dig(DIG),
		.seg(SEG),
		.ram_ce(sram_ce),
		.ram_oe(sram_oe),
		.ram_we(sram_we),
		.ram_a(SRAM_A),
		.ram_d(SRAM_D)
	);

// --- External devices --------------------------------------------------

	// silence the buzzer
	assign BUZZER_ = 1'b1;

	// disable flash, which uses the same D and A buses as sram
	assign F_CS_ = 1'b1;
	assign F_OE_ = 1'b1;
	assign F_WE_ = 1'b1;

	// always use full 16-bit word
	assign SRAM_LB_ = 1'b0;
	assign SRAM_UB_ = 1'b0;
	assign SRAM_CE_ = ~sram_ce;
	assign SRAM_OE_ = ~sram_oe;
	assign SRAM_WE_ = ~sram_we;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
