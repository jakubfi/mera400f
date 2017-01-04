module rm(
	input [0:9] w,
	input [0:8] zi,
	input clm__,
	input clrs,
	output [0:9] rs
);

	wire [0:9] __zi = {zi, 1'b1};

	genvar i;
	generate
		for (i=0 ; i<10 ; i=i+1) begin : __rm
			rmx rm(.w(w[i]), .clrs(clrs), .zi(__zi[i]), .clm__(clm__), .rs(rs[i]));
		end
	endgenerate

endmodule

// --------------------------------------------------------------------------
module rmx(
	input w, clrs, zi, clm__,
	output reg rs
);

	wire __r = ~zi & clm__;

	always @ (posedge clrs, posedge __r) begin
		if (__r) rs <= 1'b0;
		else if (clrs) rs <= w;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
