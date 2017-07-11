module decoder8(
	input [0:2] i,
	input ena_,
	output [0:7] o_
);

	always @ (*) begin
		case ({ena_, i})
			4'h0: o_ <= ~8'b10000000;
			4'h1: o_ <= ~8'b01000000;
			4'h2: o_ <= ~8'b00100000;
			4'h3: o_ <= ~8'b00010000;
			4'h4: o_ <= ~8'b00001000;
			4'h5: o_ <= ~8'b00000100;
			4'h6: o_ <= ~8'b00000010;
			4'h7: o_ <= ~8'b00000001;
			default: o_ <= ~8'b00000000;
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
