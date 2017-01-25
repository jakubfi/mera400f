module regs(
	input [0:15] w,
	input ra, rb,
	input czytrn_, piszrn_,
	input czytrw_, piszrw_,
	output [0:15] l
);

	wire [0:15] ln, lw;

	reg170 rw(.i(w), .ra(ra), .rb(rb), .wa(ra), .wb(rb), .we_(piszrw_), .re_(czytrw_), .o(lw));
	reg170 rn(.i(w), .ra(ra), .rb(rb), .wa(ra), .wb(rb), .we_(piszrn_), .re_(czytrn_), .o(ln));

	assign l = ln & lw;

endmodule

// -------------------------------------------------------------------
module reg170(
	input [0:15] i,
	input ra, rb,
	input wa, wb,
	input we_, re_,
	output [0:15] o
);

	reg [0:15] mem [0:3];

	always @ (wa, wb, we_, i) begin
		if (~we_) begin
			mem[{wa, wb}] <= i;
		end
	end

	assign o = ~re_ ? mem[{ra, rb}] : 16'hffff;

endmodule

/* synthesis ramstyle = "M4K" */

module old_regs (
	output [0:15] l,
	input [0:15] w,
	input ra, rb,
	input piszrn_, czytrn_,
	input piszrw_, czytrw_
);

	reg [0:2] read_add;
	reg [0:15] mem [0:15];

	wire wr = ~(piszrn_ & piszrw_);
	wire rd = ~(czytrn_ & czytrw_);
	wire h = ~(czytrw_ & piszrw_);
	wire [0:2] addr = {h, ra, rb};
	wire strobe = wr | rd;

	always @ (posedge strobe) 
	begin
		if (wr) mem[addr] <= w;
		read_add <= addr;
	end

	assign l = rd ? mem[read_add] : 16'hffff;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
