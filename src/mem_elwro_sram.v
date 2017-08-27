// Memory (software configurable, Elwro-like)

module mem_elwro_sram(
	input clk,
	input reset,
	output reset_hold,
	output SRAM_CE, SRAM_OE, SRAM_WE, SRAM_UB, SRAM_LB,
	output [17:0] SRAM_A,
	inout [15:0] SRAM_D,
	input [0:3] nb,
	input [0:15] ad,
	output [0:15] ddt,
	input [0:15] rdt,
	input w, r, s,
	output ok
);

	// RAM module signals
	assign SRAM_CE = 0;
	assign SRAM_UB = 0;
	assign SRAM_LB = 0;
	assign SRAM_WE = ~we;
	assign SRAM_OE = ~oe;
	assign SRAM_A[17:0] = {frame[2:7], ad[4:15]};
	assign SRAM_D = we ? rdt : 16'hzzzz;

	// Interface signals
	assign ok = rwok | (cok & s);
	assign ddt = r ? rd_data : 16'h0000;

	// --- memory configuration ------------------------------------------------

	wire [0:7] cfg_page = {rdt[12:15], rdt[0:3]};
	wire [0:7] cfg_frame = {ad[11:14], ad[7:10]};
	wire [0:7] page = {nb, ad[0:3]};
	wire [0:7] frame;
	wire cok;
	wire pvalid;

	memcfg #(
		.MODULE_ADDR_WIDTH(2),
		.FRAME_ADDR_WIDTH(3)
	) MEMCFG(
		.clk(clk),
		.reset(reset),
		.reset_hold(reset_hold),
		.s(s),
		.ad15(ad[15]),
		.rd(mem_access),
		.cfg_page(cfg_page),
		.cfg_frame(cfg_frame),
		.page(page),
		.cok(cok),
		.frame(frame),
		.pvalid(pvalid)
	);

	// --- memory access -------------------------------------------------------

	localparam S_IDLE	= 2'd0;
	localparam S_OK		= 2'd1;
	localparam S_MAP	= 2'd2;

	reg [1:0] state = S_IDLE;
	wire mem_access = r | w;
	wire oe = r;
	wire we = w & ok;
	wire rwok = (state == S_OK) & mem_access;
	wire [0:15] rd_data = SRAM_D;

	always @ (posedge clk) begin
		case (state)
			S_IDLE:
				if (mem_access) state <= S_MAP;
			S_MAP:
				if (pvalid) state <= S_OK;
				else state <= S_IDLE;
			S_OK:
				if (~mem_access) state <= S_IDLE;
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
