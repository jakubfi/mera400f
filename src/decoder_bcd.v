/*
	7442 BCD to Decimal Decoder
*/

module decoder_bcd(
	input a, // LSB
	input b,
	input c,
	input d, // MSB
	output [0:9] o_
);

	always @ (*) begin
		case ({d, c, b, a})
			4'h0: o_ <= ~10'b1000000000;
			4'h1: o_ <= ~10'b0100000000;
			4'h2: o_ <= ~10'b0010000000;
			4'h3: o_ <= ~10'b0001000000;
			4'h4: o_ <= ~10'b0000100000;
			4'h5: o_ <= ~10'b0000010000;
			4'h6: o_ <= ~10'b0000001000;
			4'h7: o_ <= ~10'b0000000100;
			4'h8: o_ <= ~10'b0000000010;
			4'h9: o_ <= ~10'b0000000001;
			default: o_ <= ~10'b0000000000;
		endcase
	end

endmodule

module decoder_bcd_pos(
	input a, // LSB
	input b,
	input c,
	input d, // MSB
	output [0:9] o
);

	always @ (*) begin
		case ({d, c, b, a})
			4'h0: o <= 10'b1000000000;
			4'h1: o <= 10'b0100000000;
			4'h2: o <= 10'b0010000000;
			4'h3: o <= 10'b0001000000;
			4'h4: o <= 10'b0000100000;
			4'h5: o <= 10'b0000010000;
			4'h6: o <= 10'b0000001000;
			4'h7: o <= 10'b0000000100;
			4'h8: o <= 10'b0000000010;
			4'h9: o <= 10'b0000000001;
			default: o <= 10'b0000000000;
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
