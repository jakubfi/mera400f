/*
	document: 12-006368-01-8A
	pages: 2-59, 3-59, 4-59, 5-59
	unit: P-R2-3
	sheets: 2, 3, 4, 5 (of 12)
*/

module regs(
	input Z, M, C, V, fL, E, G, Y, X,
	input RPA, RPB, RPP,
	input [15:0] W,
	output [15:0] L,
	input CZYTRN, PISZRN, CZYTRW, PISZRW,
	input RA, RB
);

// M58, M49
assign L[15:8] = RPA ? {Z, M, V, C, fL, E, G, Y} : 8'bz;
// M38, M26
assign L[7:0] = RPP ? {Z, M, V, C, fL, E, G, Y} : 8'bz;
// M41
assign L[7] = RPB ? X : 1'bz;

\74670 M56(
	.D4(W[3]), .D3(W[2]), .D2(W[1]), .D1(W[0]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRN), .GRN(~CZYTRN),
	.Q4(L[3]), .Q3(L[2]), .Q2(L[1]),.Q1(L[0])
);

\74670 M57(
	.D4(W[3]), .D3(W[2]), .D2(W[1]), .D1(W[0]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRW), .GRN(~CZYTRW),
	.Q4(L[3]), .Q3(L[2]), .Q2(L[1]), .Q1(L[0])
);

\74670 M47(
	.D4(W[4]), .D3(W[5]), .D2(W[6]), .D1(W[7]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRN), .GRN(~CZYTRN),
	.Q4(L[4]), .Q3(L[5]), .Q2(L[6]),.Q1(L[7])
);

\74670 M48(
	.D4(W[4]), .D3(W[5]), .D2(W[6]), .D1(W[7]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRW), .GRN(~CZYTRW),
	.Q4(L[4]), .Q3(L[5]), .Q2(L[6]), .Q1(L[7])
);

\74670 M36(
	.D4(W[8]), .D3(W[9]), .D2(W[10]), .D1(W[11]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRN), .GRN(~CZYTRN),
	.Q4(L[8]), .Q3(L[9]), .Q2(L[10]),.Q1(L[11])
);

\74670 M37(
	.D4(W[8]), .D3(W[9]), .D2(W[10]), .D1(W[11]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRW), .GRN(~CZYTRW),
	.Q4(L[8]), .Q3(L[9]), .Q2(L[10]), .Q1(L[11])
);

\74670 M24(
	.D4(W[12]), .D3(W[13]), .D2(W[14]), .D1(W[15]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRN), .GRN(~CZYTRN),
	.Q4(L[12]), .Q3(L[13]), .Q2(L[14]),.Q1(L[15])
);

\74670 M25(
	.D4(W[12]), .D3(W[13]), .D2(W[14]), .D1(W[15]),
	.RB(RB), .RA(RA),
	.WB(RB), .WA(RA),
	.GWN(~PISZRW), .GRN(~CZYTRW),
	.Q4(L[12]), .Q3(L[13]), .Q2(L[14]), .Q1(L[15])
);

endmodule

// vim: tabstop=4 shiftwidth=4 autoindent noexpandtab
