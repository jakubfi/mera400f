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

/*

	Memory configuration: OU r, n
	r = rdt_
	n = ad_

     .---------------> logical segment number
     |             .-> logical block number
	rrrr rrrrrrrr rrrr
             .--------> physical segment (last 3 bits for Elwro)
             |    .---> physical module
             |    | .-> 1=memory configuration
	nnnnnnn nnnn nnnn n

*/

	// chip and bytes always enabled
	assign SRAM_CE = 0;
	assign SRAM_UB = 0;
	assign SRAM_LB = 0;
	assign SRAM_WE = ~we;
	assign SRAM_OE = ~oe;
	assign ok_ = ~((ok & (~r_ | ~w_)) | (cok & ~s_));

	// address lines
	assign SRAM_A[17:0] = {map_out[2:7], ~ad_[4:15]};

	// data lines
	assign SRAM_D = we ? ~rdt_ : 16'hzzzz;
	assign ddt_ = ~r_ ? ~rd_data : 16'hffff;

	// --- memory configuration ------------------------------------------------

  wire [0:7] map_log = ~{rdt_[12:15], rdt_[0:3]};
	wire [0:7] map_phy = ~{ad_[11:14], ad_[7:10]};
	wire [0:7] seg_addr = ~{nb_, ad_[0:3]};
	reg [0:7] map_rd_addr;
	reg map_wr = 0;
	reg map_rd = 0;
	/* synthesis ramstyle = "M4K" */
  reg [0:7] map [0:255];
	initial map[0] = 8'd0;
	initial map[1] = 8'd1;
	initial begin
		reg [8:0] i;
		for (i=9'd2 ; i<9'd256 ; i=i+9'd1) begin
			map[i] = 0;
		end
	end

  always @ (posedge clk)
  begin
    if (map_wr) map[map_log] <= map_phy;
		map_rd_addr <= seg_addr;
  end

  wire [0:7] map_out = map_rd ? map[map_rd_addr] : 8'hzz;

	`define CIDLE		0
	`define CCFG		1
	`define COK			2
	reg [1:0] cstate = `CIDLE;
	reg cok = 0;
	always @ (posedge clk) begin
		case (cstate)

			`CIDLE: begin
				if (~s_ && ~ad_[15] && (map_log > 1)) begin
					map_wr <= 1;
					cstate <= `CCFG;
				end
			end

			`CCFG: begin
				map_wr <= 0;
				cok <= 1;
				cstate <= `COK;
			end

			`COK: begin
				if (s_) begin
					cok <= 0;
					cstate <= `CIDLE;
				end
			end

		endcase
	end

	// --- memory access -------------------------------------------------------

	`define IDLE		0
	`define	READ		1
	`define WRITE		2
	`define OK			3
	`define MAP			4
	reg [2:0] state = `IDLE;
	reg we, oe, ok;
	reg [0:15] rd_data;
	always @ (posedge clk) begin
		case (state)

			`IDLE: begin
				if (~r_ | ~w_) begin
					state <= `MAP;
					map_rd <= 1;
				end
			end

			`MAP: begin
				if ((seg_addr > 1) && (map_out == 0)) begin
					state <= `IDLE;
					map_rd <= 0;
				end else if (~r_) begin
					state <= `READ;
					oe <= 1;
				end else if (~w_) begin
					state <= `WRITE;
					we <= 1;
				end
			end
	
			`READ: begin
				rd_data <= SRAM_D;
				ok <= 1;
				state <= `OK;
			end
	
			`WRITE: begin
				map_rd <= 0;
				we <= 0;
				ok <= 1;
				state <= `OK;
			end
	
			`OK: begin
				map_rd <= 0;
				oe <= 0;
				if (r_ & w_) begin
					ok <= 0;
					state <= `IDLE;
				end
			end

		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
