/*
	MERA-400 P-A unit (ALU)

	document:	12-006368-01-8A
	unit:			P-A3-2
	pages:		2-70..2-84
	sheets:		15
*/

module p_a(
	// sheet 1
	input [0:15] ir,
	input [0:15] ki,
	input [0:15] rdt,
	input w_dt,
	input mwa, mwb, mwc,
	input bwa, bwb,
	output [0:15] ddt,
	output [0:15] w,
	// sheet 2
	// sheet 3
	// sheet 4
	// sheet 5
	input saryt,
	input sab, scb, sb, sd,
	output s0,
	output carry,
	// sheet 6
	input p16,
	input saa, sca,
	output j__,
	output exx,
	// sheet 7
	input wx,
	input eat0,
	input axy,
	output at15,
	output exy,
	// sheet 8
	input w_ac,
	input strob2,
	input as2,
	input strob1,
	input am1,
	input apb,
	input amb,
	input ap1,
	output s_1,
	output wzi,
	output zs,
	// sheet 9
	input arm4,
	input w_ar,
	input arp1,
	output arz,
	// sheet 10
	input icp1,
	input w_ic,
	input off,
	// sheet 11, 12
	input baa, bab, bac,
	input ab,
	input aa,
	input [0:15] l,
	// sheet 13, 14
	input barnb,
	input [0:15] kl,
	input ic_ad,
	output [0:15] dad,
	input ar_ad,
	output zga

);

	// sheet 1..4

	wire [0:2] __s = {mwa, mwb, mwc};
	assign w[0:7] = bwb ? {8{1'b0}} :
		(__s == {3'b000}) ? ir[0:7] :
		(__s == {3'b001}) ? kl[0:7] :
		(__s == {3'b010}) ? rdt[0:7] :
		(__s == {3'b011}) ? {8{1'b0}} :
		(__s == {3'b100}) ? ki[0:7] :
		(__s == {3'b101}) ? at[0:7] :
		(__s == {3'b110}) ? ac[0:7] :
		a[0:7];
	assign w[8:15] = bwa ? {8{1'b0}} :
		(__s == {3'b000}) ? ir[8:15] :
		(__s == {3'b001}) ? kl[8:15] :
		(__s == {3'b010}) ? rdt[8:15] :
		(__s == {3'b011}) ? ac[0:7] :
		(__s == {3'b100}) ? ki[8:15] :
		(__s == {3'b101}) ? at[8:15] :
		(__s == {3'b110}) ? ac[8:15] :
		a[8:15];

	assign ddt = w & {16{w_dt}};

	// sheet 5

	wire [0:15] f;
	wire [0:3] g, p;
	wire [0:2] c;
	wire [0:3] __j;

	wire carry_;
	assign carry = ~carry_;
	alu181 __alu0(.a(a[0:3]), .b(ac[0:3]), .s({sd, sb, scb, sab}), .m(~saryt), .cn_(c[2]), .f(f[0:3]), .eq(__j[3]), .x(p[3]), .y(g[3]), .cn4_(carry_));
	alu181 __alu1(.a(a[4:7]), .b(ac[4:7]), .s({sd, sb, scb, sab}), .m(~saryt), .cn_(c[1]), .f(f[4:7]), .eq(__j[2]), .x(p[2]), .y(g[2]));
	assign s0 = f[0];

	// sheet 6

	assign j__ = &__j;
	alu181 __alu2(.a(a[8:11]), .b(ac[8:11]), .s({sd, sb, sca, saa}), .m(~saryt), .cn_(c[0]), .f(f[8:11]), .eq(__j[1]), .x(p[1]), .y(g[1]));
	alu181 __alu3(.a(a[12:15]), .b(ac[12:15]), .s({sd, sb, sca, saa}), .m(~saryt), .cn_(~p16), .f(f[12:15]), .eq(__j[0]), .x(p[0]), .y(g[0]));
	carry182 __carry(.y(g), .x(p),  .cn_(~p16), .cnx_(c[0]), .cny_(c[1]), .cnz_(c[2]));
	assign exx = (a[15] & ir[6]) | (a[0] & ~ir[6]);

	// sheet 7

	reg [0:15] at;

	wire __s1 = as2;
	wire __s0 = ~(~wx & ~as2);
	always @ (negedge strob1) begin
		case ({__s1, __s0})
			2'b00 : at <= at;
			2'b01 : at <= {eat0, at[0:14]};
			2'b10 : at <= at; // NOTE: shouldn't happen (by design). In real CPU it would shift "0" on the right side of each quad-bit
			2'b11 : at <= f;
		endcase
	end

	assign at15 = at[15];
	assign exy = (at[15] & axy) | (a[0] & ~axy);

	// sheet 8

	wire __m49_6 = ~((w_ac & strobb) | (w_ac & stroba));
	wire strobb = ~(~as2 | ~strob2);
	wire stroba = ~(as2 | ~strob1);

	reg [0:15] ac;

	always @ (posedge __m49_6) begin
		ac <= w;
	end

	wire __m8_11 = ac[0] ^ a[0];
	wire __m8_3 = ~ac[0] ^ a[0];
	wire __m7_8 = ~((~a[0] & am1) | (__m8_11 & apb) | (__m8_3 & amb) | (a[0] & ap1));

	// WZI

	wire __m65_11 = as2 & strob1;
	assign s_1 = __m7_8 ^ ~carry;
	wire __m42_8 = |f;
	assign zs = ~(~(s_1 | __m42_8));

	reg __wzi;
	always @ (posedge __m65_11) begin
		__wzi <= zs;
	end
	assign wzi = __wzi;

	// sheet 9

	reg [0:15] ar;

	wire __load_ar = (w_ar & strobb) | (w_ar & stroba);
	always @ (posedge __load_ar, posedge arm4, posedge arp1) begin
		if (__load_ar) ar <= w;
		else if (arm4) ar <= ar - 3'd4;
		else ar <= ar + 1'b1;
	end

	assign arz = ~(|ar[0:7]);

	// sheet 10

	reg [0:15] ic;
	wire __ic_cu = ~(icp1 & strob1);
	wire __ic_load = (w_ic & stroba) | (w_ic & strobb);

	always @ (posedge __ic_cu, posedge __ic_load, posedge off) begin
		if (off) ic <= 16'b0;
		else if (__ic_cu) ic <= ic + 1'b1;
		else ic <= w;
	end

	// sheet 11, 12

	wire [0:15] a;
	assign a[0:7] = bac ? 8'b0 :
		{ab, aa} == 2'b00 ? l[8:15] :
		{ab, aa} == 2'b01 ? ic[0:7] :
		{ab, aa} == 2'b10 ? ar[0:7] :
		l[0:7];
	assign a[8:9] = bab ? 2'b0 :
		{ab, aa} == 2'b00 ? ir[8:9] :
		{ab, aa} == 2'b01 ? ic[8:9] :
		{ab, aa} == 2'b10 ? ar[8:9] :
		l[8:9];
	assign a[10:15] = baa ? 6'b0 :
		{ab, aa} == 2'b00 ? ir[10:15] :
		{ab, aa} == 2'b01 ? ic[10:15] :
		{ab, aa} == 2'b10 ? ar[10:15] :
		l[10:15];

	// sheet 13, 14

	assign dad = ar_ad ? ar :
		ic_ad ? ic :
		16'b0;

	assign zga = (barnb == kl[0]) && (kl[1:15] == dad[1:15]);

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
