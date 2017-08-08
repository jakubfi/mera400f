module memcfg(
	input clk,
	input s_,
	input ad15,
	input map_rd,
	input [0:7] map_log,
	input [0:7] map_phy,
	input [0:7] seg_addr,
	output reg cok,
	output [0:7] map_out
);

/*
  Memory configuration: "OU r, n": OU=s_, r=rdt_, n=ad_

  page -------- segment           ------- frame module 1
  rrrr rrrrrrrr rrrr              nnnnnnn nnnn  nnnn   n

	NOTE: frame is 3 bits long for Elwro 32K modules
*/

	reg [0:7] map_rd_addr;
	reg map_wr = 0;

	/* synthesis ramstyle = "M4K" */
	reg [0:7] map [0:255];
	initial begin
		reg [8:0] i;
		for (i=0 ; i<9'd256 ; i=i+9'd1) begin
			if (i == 1) map[i] = 1;
			else map[i] = 0;
		end
	end

	always @ (posedge clk) begin
		if (map_wr) map[map_log] <= map_phy;
		map_rd_addr <= seg_addr;
	end

	assign map_out = map_rd ? map[map_rd_addr] : 8'hzz;

	localparam S_CIDLE	= 2'd0;
	localparam S_CCFG	 = 2'd1;
	localparam S_COK		= 2'd2;

	reg [1:0] cstate = S_CIDLE;

	always @ (posedge clk) begin
		case (cstate)

			S_CIDLE: begin
				if (~s_ && ad15 && (map_log > 1)) begin
					map_wr <= 1;
					cstate <= S_CCFG;
				end
			end

			S_CCFG: begin
				map_wr <= 0;
				cok <= 1;
				cstate <= S_COK;
			end

			S_COK: begin
				if (s_) begin
					cok <= 0;
					cstate <= S_CIDLE;
				end
			end

		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
