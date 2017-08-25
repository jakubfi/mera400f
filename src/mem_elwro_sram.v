// Memory (software configurable, Elwro-like)

module mem_elwro_sram(
	input clk,
	input reset,
	output reset_hold,
	output SRAM_CE, SRAM_OE, SRAM_WE, SRAM_UB, SRAM_LB,
	output [17:0] SRAM_A,
	inout [15:0] SRAM_D,
	input [0:3] nb_,
	input [0:15] ad_,
	output [0:15] ddt_,
	input [0:15] rdt_,
	input w_, r_, s_,
	output ok_
);

	// RAM module signals
	assign SRAM_CE = 0;
	assign SRAM_UB = 0;
	assign SRAM_LB = 0;
	assign SRAM_WE = ~we;
	assign SRAM_OE = ~oe;
	assign SRAM_A[17:0] = {frame[2:7], ~ad_[4:15]};
	assign SRAM_D = we ? ~rdt_ : 16'hzzzz;

	// Interface signals
	assign ok_ = ~((ok & (~r_ | ~w_)) | (cok & ~s_));
	assign ddt_ = ~r_ ? ~rd_data : 16'hffff;

	// --- memory configuration ------------------------------------------------

	wire [0:7] cfg_page = ~{rdt_[12:15], rdt_[0:3]};
	wire [0:7] cfg_frame = ~{ad_[11:14], ad_[7:10]};
	wire [0:7] page = ~{nb_, ad_[0:3]};
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
		.s_(s_),
		.ad15(~ad_[15]),
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
	wire mem_access = ~r_ | ~w_;
	wire oe = ~r_;
	wire we = ~w_ & ok;
	wire ok = (state == S_OK) & mem_access;
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
