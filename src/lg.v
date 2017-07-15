module lg(
	input reset_,
	input clk_,
	input gr,
	input slg1, slg2,
	input [7:9] ir,
	output lg_0, lg_1, lg_2, lg_3,
	output lga, lgb, lgc
);

	// @ slg1: na poczatku rozkazu ładuje ir[7:9]
	// @ slg2: dla rozkazów grupowych ładuje numer pierwszego rejestru w grupie

	wire set0 = ~((slg2) | (slg1 & ir[9]));
	wire set1 = ~(slg1 & ir[8]);
	wire set2 = ~((slg2 & (ir[8] & ir[9])) | (slg1 & ir[7]));

	// bit 0
	ffjk __lga(
		.s_(set0),
		.j(1'b1),
		.c_(clk_),
		.k(1'b1),
		.r_(reset_),
		.q(lga)
	);
	// bit 1
	ffjk __lgb(
		.s_(set1),
		.j(lga),
		.c_(clk_),
		.k(lga),
		.r_(reset_),
		.q(lgb)
	);
	// bit 2
	ffjk __lgc(
		.s_(set2),
		.j(lgb & lga & gr),
		.c_(clk_),
		.k(lgb & lga & gr),
		.r_(reset_),
		.q(lgc)
	);

	assign lg_3 = lgb & lga;
	assign lg_2 = lgb & ~lga;
	assign lg_1 = lga & ~lgb;
	assign lg_0 = ~lga & ~lgb;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
