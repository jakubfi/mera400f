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

	// --- memory configuration ------------------------------------------------

	wire [0:7] cfg_page = { rdt[12:15], rdt[0:3] };
	wire [0:7] cfg_frame = { ad[11:14], 1'b0, ad[8:10] };
	wire [0:7] page = { nb, ad[0:3] };
	wire [0:7] frame;
	wire cfgok;
	wire pvalid;

	memcfg #(
		.MODULE_ADDR_WIDTH(2),
		.FRAME_ADDR_WIDTH(3)
	) MEMCFG(
		.clk(clk),
		.reset(reset),
		.reset_hold(reset_hold),
		.s(s & ad[15]),
		.cfg_page(cfg_page),
		.cfg_frame(cfg_frame),
		.page(page),
		.frame(frame),
		.cfgok(cfgok),
		.pvalid(pvalid)
	);

	// --- memory access -------------------------------------------------------

	localparam IDLE	= 2'd0;
	localparam MAP	= 2'd1;
	localparam OK1	= 2'd2;
	localparam OK2	= 2'd3;
	reg [0:2] state = IDLE;

	wire rw = r | w;

	always @ (posedge clk) begin
		case (state)
			IDLE:
				if (rw) state <= MAP;
			MAP:
				if (pvalid) state <= OK1;
				else state <= IDLE;
			OK1:
				state <= OK2;
			OK2:
				if (~rw) state <= IDLE;
		endcase
	end

	wire we = w & (state == OK1);
	wire rwok = rw & ((state == OK1) || (state == OK2));

	// Interface signals
	assign ok = rwok | cfgok;
	assign ddt = r ? SRAM_D : 16'h0000;

	// RAM module signals
	assign SRAM_CE = 0;
	assign SRAM_UB = 0;
	assign SRAM_LB = 0;
	assign SRAM_WE = ~we;
	assign SRAM_OE = 0; // controlled by WE
	assign SRAM_A[17:0] = { frame[2:7], ad[4:15] };
	assign SRAM_D = we ? rdt : 16'hzzzz;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
