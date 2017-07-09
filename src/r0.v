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
	input zs, s_1, s0, carry,
	input vl, vg, exy, exx,
	// strobe signals
	input strob1,
	input ust_z, ust_v, ust_mc, ust_y, ust_x,
	input cleg,
	// commands
	input w_zmvc, w_legy, w8_x,
	// async
	input _0_v,
	input zer
);

	// --- R00, Z flag --------------------------------------------------------
	wire c0 = ust_z & strob1;
	always @ (posedge zer, posedge w_zmvc, negedge c0) begin
		if (zer) r0[0] <= 0;
		else if (w_zmvc) r0[0] <= w[0];
		else r0[0] <= zs;
	end

	// --- R0[1,3], MC flags --------------------------------------------------
	wire c1 = ust_mc & strob1;
	always @ (posedge zer, posedge w_zmvc, negedge c1) begin
		if (zer) {r0[1], r0[3]} <= 2'd0;
		else if (w_zmvc) {r0[1], r0[3]} <= {w[1], w[3]};
		else {r0[1], r0[3]} <= {s_1, carry};
	end

	// --- R02, V flag --------------------------------------------------------
	wire c2 = ust_v & strob1;
	wire zer2 = _0_v ^ zer;
	always @ (posedge zer2, posedge w_zmvc, negedge c2) begin
		if (zer2) r0[2] <= 0;
		else if (w_zmvc) r0[2] <= w[2];
		else if (s0 ^ s_1) r0[2] <= 1;
	end

	// --- R0[4:6], LEG flags -------------------------------------------------
	always @ (posedge zer, posedge w_legy, negedge cleg) begin
		if (zer) r0[4:6] <= 3'd0;
		else if (w_legy) r0[4:6] <= w[4:6];
		else r0[4:6] <= {vl, zs, vg};
	end

	// --- R07, Y flag --------------------------------------------------------
	wire c7 = ust_y & strob1;
	always @ (posedge zer, posedge w_legy, negedge c7) begin
		if (zer) r0[7] <= 0;
		else if (w_legy) r0[7] <= w[7];
		else r0[7] <= exy;
	end

	// --- R08, X flag --------------------------------------------------------
	wire c8 = ust_x & strob1;
	always @ (posedge zer, posedge w8_x, negedge c8) begin
		if (zer) r0[8] <= 0;
		else if (w8_x) r0[8] <= w[8];
		else r0[8] <= exx;
	end

endmodule

// --------------------------------------------------------------------
module r0_9_15(
	input [9:15] w,
	input lrp,
	input zer,
	output reg [9:15] r0
);

	always @ (posedge lrp, posedge zer) begin
		if (zer) r0 <= 7'd0;
		else r0 <= w;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
