/*
	MERA-400 R0 register

	document:	12-006368-01-8A
	unit:			P-R2-3
	pages:		2-65..2-66
*/

/* synthesis ramstyle = "M4K" */

module r0 (
	// buses
	input [0:15] w,
	output reg [0:8] r0,
	// data signals
	input zs, s_1, s0, carry_,
	input vl_, vg_, exy_, exx_,
	// strobe signals
	input strob1,
	input ust_z, ust_v, ust_mc, ust_y, ust_x,
	input cleg_,
	// commands
	input w_zmvc, w_legy,
	input w8_x,
	// async
	input zero_v,
	input zer
);

	initial begin
		r0 = 9'd0;
	end

	// --- R00, Z flag --------------------------------------------------------
	wire set0, clk0, reset0;

	assign set0 = ~(w[0] & w_zmvc);
	assign clk0 = ~(ust_z & strob1);
	assign reset0 = ~((set0 & w_zmvc) | zer);

	always @ (posedge clk0, negedge set0, negedge reset0) begin
		if (~reset0) r0[0] <= 1'b0;
		else if (~set0) r0[0] <= 1'b1;
		else r0[0] <= zs;
	end

	// --- R01, M flag --------------------------------------------------------
	wire set1, clk1, reset1;

	assign set1 = ~(w[1] & w_zmvc);
	assign clk1 = ~(ust_mc & strob1);
	assign reset1 = ~((set1 & w_zmvc) | zer);

	always @ (posedge clk1, negedge set1, negedge reset1) begin
		if (~reset1) r0[1] <= 1'b0;
		else if (~set1) r0[1] <= 1'b1;
		else r0[1] <= s_1;
	end

	// --- R02, V flag --------------------------------------------------------
	wire j2, clk2, reset2, set2;

	assign j2 = s0 ^ s_1;
	assign clk2 = ust_v & strob1;
	assign reset2 = ~((set2 & w_zmvc) | (zero_v ^ zer));
	assign set2 = ~(w[2] & w_zmvc);

	always @ (negedge clk2, negedge set2, negedge reset2) begin
		if (~reset2) r0[2] <= 1'b0;
		else if (~set2) r0[2] <= 1'b1;
		else r0[2] <= j2;
	end

	// --- R03, C flag --------------------------------------------------------
	wire j3, k3, clk3, reset3, set3;

	assign j3 = ~carry_;
	assign clk3 = ust_mc & strob1;
	assign k3 = carry_;
	assign reset3 = ~((set3 & w_zmvc) | zer);
	assign set3 = ~(w[3] & w_zmvc);

	always @ (negedge clk3, negedge set3, negedge reset3) begin
		if (~reset3) r0[3] <= 1'b0;
		else if (~set3) r0[3] <= 1'b1;
		else case ({j3, k3})
			2'b00: r0[3] <= r0[3];
			2'b01: r0[3] <= 1'b0;
			2'b10: r0[3] <= 1'b1;
			2'b11: r0[3] <= ~r0[3];
		endcase
	end

	// --- R04, L flag --------------------------------------------------------
	wire set4, clk4, reset4;

	assign set4 = ~(zer | (w_legy & reset4));
	assign clk4 = cleg_;
	assign reset4 = ~(w[4] & w_legy);

	// NOTE: negated output
	always @ (posedge clk4, negedge reset4, negedge set4) begin
		if (~reset4) r0[4] <= 1'b1;
		else if (~set4) r0[4] <= 1'b0;
		else r0[4] <= ~vl_;
	end

	// --- R05, E flag --------------------------------------------------------
	wire set5, clk5, reset5;

	assign set5 = ~(w[5] & w_legy);
	assign clk5 = cleg_;
	assign reset5 = ~(zer | (w_legy & set5));

	always @ (posedge clk5, negedge reset5, negedge set5) begin
		if (~reset5) r0[5] <= 1'b0;
		else if (~set5) r0[5] <= 1'b1;
		else r0[5] <= zs;
	end

	// --- R06, G flag --------------------------------------------------------
	wire set6, clk6, reset6;

	assign set6 = ~(zer | (w_legy & reset6));
	assign clk6 = cleg_;
	assign reset6 = ~(w[6] & w_legy);

	// NOTE: negated output
	always @ (posedge clk6, negedge reset6, negedge set6) begin
		if (~reset6) r0[6] <= 1'b1;
		else if (~set6) r0[6] <= 1'b0;
		else r0[6] <= ~vg_;
	end

	// --- R07, Y flag --------------------------------------------------------
	wire set7, clk7, reset7;

	assign set7 = ~(zer | (w_legy & reset7));
	assign clk7 = ~(ust_y & strob1);
	assign reset7 = ~(w[7] & w_legy);

	// NOTE: negated output
	always @ (posedge clk7, negedge reset7, negedge set7) begin
		if (~reset7) r0[7] <= 1'b1;
		else if (~set7) r0[7] <= 1'b0;
		else r0[7] <= ~exy_;
	end

	// --- R08, X flag --------------------------------------------------------
	wire set8, clk8, reset8;

	assign set8 = ~(zer | (w8_x & reset8));
	assign clk8 = ~(ust_x & strob1);
	assign reset8 = ~(w[8] & w8_x);

	// NOTE: negated output
	always @ (posedge clk8, negedge reset8, negedge set8) begin
		if (~reset8) r0[8] <= 1'b1;
		else if (~set8) r0[8] <= 1'b0;
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
		if (~zer_) r0_ <= 7'd0;
		else if (lrp) r0_ <= ~w;
	end

endmodule


// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
