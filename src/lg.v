module lg(
	input clk_sys,
	input reset,
	input cu,
	input gr,
	input slg1, slg2,
	input [7:9] ir,
	output lg_0, lg_1, lg_2, lg_3,
	output lga, lgb, lgc
);

	// @ slg1: na poczatku rozkazu ładuje ir[7:9]
	// @ slg2: dla rozkazów grupowych ładuje numer pierwszego rejestru w grupie

	reg [0:2] lg;
	//wire clk = slg1 | slg2 | clk_;
	always @ (posedge clk_sys, posedge reset) begin
		if (reset) lg <= 3'd0;
		else case ({slg1, slg2, cu})
			3'b100: lg <= ir[7:9];
			3'b010: lg <= {(ir[8] & ir[9]), 2'b01};
			3'b001: lg <= {gr, 2'b11} & (lg + 1'b1);
			default: lg <= lg;
		endcase
	end
/*
	wire seta = (slg2) | (slg1 & ir[9]);
	wire setb = slg1 & ir[8];
	wire setc = (slg2 & (ir[8] & ir[9])) | (slg1 & ir[7]);

	wire [0:2] lg;

	// bit 2 - LSB
	ffjk __lga(
		.s_(~seta),
		.j(1'b1),
		.c_(clk_),
		.k(1'b1),
		.r_(~reset),
		.q(lg[2])
	);
	// bit 1
	ffjk __lgb(
		.s_(~setb),
		.j(lg[2]),
		.c_(clk_),
		.k(lg[2]),
		.r_(~reset),
		.q(lg[1])
	);
	// bit 0 - MSB
	ffjk __lgc(
		.s_(~setc),
		.j(lg_3 & gr),
		.c_(clk_),
		.k(lg_3 & gr),
		.r_(~reset),
		.q(lg[0])
	);
*/
	assign lga = lg[2];
	assign lgb = lg[1];
	assign lgc = lg[0];
	assign lg_3 = lg[1:2] == 3;
	assign lg_2 = lg[1:2] == 2;
	assign lg_1 = lg[1:2] == 1;
	assign lg_0 = lg[1:2] == 0;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
