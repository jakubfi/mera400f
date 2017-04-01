/*
	State register (R0)

	document: 12-006368-01-8A
	unit:     P-R3-2
	pages:    2-63..2-66
*/

module r0 (
	// buses
	input [0:8] w,
	output [0:8] r0,
	// data signals
	input zs, s_1, s0, carry_,
	input vl_, vg_, exy_, exx_,
	// strobe signals
	input strob1,
	input ust_z, ust_v, ust_mc, ust_y, ust_x,
	input cleg_,
	// commands
	input w_zmvc, w_legy, w8_x,
	// async
	input _0_v,
	input zer
);

	// --- R00, Z flag --------------------------------------------------------
	wire c0 = ~(ust_z & strob1);
	always @(posedge zer, posedge w_zmvc, posedge c0) begin
		if (zer) r0[0] <= 0;
		else if (w_zmvc) r0[0] <= w[0];
		else r0[0] <= zs;
	end

	// --- R01, M flag --------------------------------------------------------
	wire c1 = ~(ust_mc & strob1);
	always @(posedge zer, posedge w_zmvc, posedge c1) begin
		if (zer) r0[1] <= 0;
		else if (w_zmvc) r0[1] <= w[1];
		else r0[1] <= s_1;
	end

	// --- R02, V flag --------------------------------------------------------
	wire c2 = ~(ust_v & strob1);
	wire zer2 = _0_v ^ zer;
	always @(posedge zer2, posedge w_zmvc, posedge c2) begin
		if (zer2) r0[2] <= 0;
		else if (w_zmvc) r0[2] <= w[2];
		else if (s0 ^ s_1) r0[2] <= 1;
	end

	// --- R03, C flag --------------------------------------------------------
	// FIX: +W2 instead of +W3 was on C (carry) flag input
	wire c3 = ~(ust_mc & strob1);
	always @(posedge zer, posedge w_zmvc, posedge c3) begin
		if (zer) r0[3] <= 0;
		else if (w_zmvc) r0[3] <= w[3];
		else r0[3] <= ~carry_;
	end

	// --- R04, L flag --------------------------------------------------------
	always @(posedge zer, posedge w_legy, posedge cleg_) begin
		if (zer) r0[4] <= 0;
		else if (w_legy) r0[4] <= w[4];
		else r0[4] <= ~vl_;
	end

	// --- R05, E flag --------------------------------------------------------
	always @(posedge zer, posedge w_legy, posedge cleg_) begin
		if (zer) r0[5] <= 0;
		else if (w_legy) r0[5] <= w[5];
		else r0[5] <= zs;
	end

	// --- R06, G flag --------------------------------------------------------
	always @(posedge zer, posedge w_legy, posedge cleg_) begin
		if (zer) r0[6] <= 0;
		else if (w_legy) r0[6] <= w[6];
		else r0[6] <= ~vg_;
	end

	// --- R07, Y flag --------------------------------------------------------
	wire c7 = ~(ust_y & strob1);
	always @(posedge zer, posedge w_legy, posedge c7) begin
		if (zer) r0[7] <= 0;
		else if (w_legy) r0[7] <= w[7];
		else r0[7] <= ~exy_;
	end

	// --- R08, X flag --------------------------------------------------------
	wire c8 = ~(ust_x & strob1);
	always @(posedge zer, posedge w8_x, posedge c8) begin
		if (zer) r0[8] <= 0;
		else if (w8_x) r0[8] <= w[8];
		else r0[8] <= ~exx_;
	end

endmodule

// --------------------------------------------------------------------
module r0_9_15(
	input [9:15] w,
	input lrp,
	input zer_,
	output reg [9:15] r0_
);

	always @ (posedge lrp, negedge zer_) begin
		if (~zer_) r0_ <= 7'b1111111;
		else r0_ <= ~w;
	end

endmodule


// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
