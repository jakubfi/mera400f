/*
	Memory (software configurable, Elwro-like)
*/

module mem_elwro_sram(
	input clk,
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
	assign SRAM_A[17:0] = {map_out[2:7], ~ad_[4:15]};
	assign SRAM_D = we ? ~rdt_ : 16'hzzzz;

	// Interface signals
	assign ok_ = ~((ok & (~r_ | ~w_)) | (cok & ~s_));
	assign ddt_ = ~r_ ? ~rd_data : 16'hffff;

	// --- memory configuration ------------------------------------------------

	wire [0:7] map_log = ~{rdt_[12:15], rdt_[0:3]};
	wire [0:7] map_phy = ~{ad_[11:14], ad_[7:10]};
	wire [0:7] seg_addr = ~{nb_, ad_[0:3]};
	reg map_rd = 0;
	wire [0:7] map_out;
	wire cok;

	memcfg MEMCFG(
		.clk(clk),
		.s_(s_),
		.ad15(~ad_[15]),
		.map_rd(map_rd),
		.map_log(map_log),
		.map_phy(map_phy),
		.seg_addr(seg_addr),
		.cok(cok),
		.map_out(map_out)
	);

	// --- memory access -------------------------------------------------------

	localparam S_IDLE	= 2'd0;
	localparam S_OK		= 2'd1;
	localparam S_MAP	= 2'd2;

	reg [1:0] state = S_IDLE;
	reg we, oe, ok;
	reg [0:15] rd_data;

	always @ (posedge clk) begin
		case (state)

			S_IDLE: begin
				if (~r_) begin
					state <= S_MAP;
					map_rd <= 1;
					oe <= 1;
				end else if (~w_) begin
					state <= S_MAP;
					map_rd <= 1;
				end
			end

			S_MAP: begin
				map_rd <= 0;
				if ((seg_addr > 1) && (map_out == 0)) begin
					state <= S_IDLE;
				end else if (~r_) begin
					rd_data <= SRAM_D;
					ok <= 1;
					state <= S_OK;
				end else if (~w_) begin
					state <= S_OK;
					ok <= 1;
					we <= 1;
				end
			end
	
			S_OK: begin
				map_rd <= 0;
				oe <= 0;
				we <= 0;
				if (r_ & w_) begin
					ok <= 0;
					state <= S_IDLE;
				end
			end

		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
