/*
	P-A unit (ALU)

	document: 12-006368-01-8A
	unit:     P-A3-2
	pages:    2-70..2-84
	sheets:   15
*/

module pa(
	input __clk,
	// sheet 1
	input [0:15] ir,
	input [0:15] bus_ki,
	input [0:15] rdt,
	input w_dt,
	input mwa,
	input mwb,
	input mwc,
	input bwa,
	input bwb,
	output [0:15] ddt,
	output [0:15] w,
	// sheet 2
	// sheet 3
	// sheet 4
	// sheet 5
	input saryt,
	input sab,
	input scb,
	input sb,
	input sd,
	output s0,
	output carry,
	// sheet 6
	input p16,
	input saa,
	input sca,
	output j$,
	output exx,
	// sheet 7
	input wx,
	input eat0,
	input axy,
	output at15,
	output exy,
	// sheet 8
	input w_ac,
	input strob1,
	input strob1b,
	input strob2,
	input strob2b,
	input as2,
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
	input baa,
	input bab,
	input bac,
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

	wor __NC; // unconnected signals here, to suppress warnings

	// sheet 1..4

	bus_w BUS_W(
		.mwc(mwc),
		.mwb(mwb),
		.mwa(mwa),
		.bwa(bwa),
		.bwb(bwb),
		.ir(ir),
		.kl(kl),
		.rdt(rdt),
		.ki(bus_ki),
		.at(at),
		.ac(ac),
		.a(a),
		.w(w)
	);

	assign ddt = w_dt ? w : 16'd0;

	// sheet 5..6

	wire [0:15] f;
	wire zsum;
	alu ALU(
		.p16_(~p16),
		.a(a),
		.ac(ac),
		.saryt(saryt),
		.sd(sd),
		.sb(sb),
		.scb(scb),
		.sab(sab),
		.sca(sca),
		.saa(saa),
		.f(f),
		.j$(j$),
		.carry(carry),
		.zsum(zsum)
	);

	assign s0 = f[0];
	assign exx = (a[15] & ir[6]) | (a[0] & ~ir[6]);

	// sheet 7

	wire [0:15] at;
	at REG_AT(
		.clk(__clk),
		.s0(wx | as2),
		.s1(as2),
		.c(strob1b),
		.sl(eat0),
		.f(f),
		.at(at)
	);

	assign at15 = at[15];
	assign exy = (at[15] & axy) | (a[0] & ~axy);

	// sheet 8

	wire strobb = as2 & strob2b;
	wire stroba = ~as2 & strob1b;

	wire ac_clk = w_ac & (stroba | strobb);

	wire [0:15] ac;
	ac REG_AC(
		.clk(__clk),
		.c(ac_clk),
		.w(w),
		.ac(ac)
	);

	wire M8_11 = ac[0] ^ a[0];
	wire M8_3 = ~ac[0] ^ a[0];
	wire M7_8 = (~a[0] & am1) | (M8_11 & apb) | (M8_3 & amb) | (a[0] & ap1);
	assign s_1 = ~M7_8 ^ ~carry;
	assign zs = ~s_1 & zsum;

	// WZI - wskaźnik zera sumatora

	wire wzi_clk = as2 & strob1b;

	always @ (posedge __clk) begin
		if (wzi_clk) wzi <= zs;
	end
/*
	wire wzi_;
	ffd REG_WZI(
		.s_(1'b1),
		.d(zs),
		.c(~wzi_clk),
		.r_(1'b1),
		.q(wzi_)
	);
	assign wzi = wzi_;
*/
	// sheet 9

	wire ar_load = w_ar & (stroba | strobb);
	wire ar_plus1 = arp1 & stroba;

	wire [0:15] ar;
	ar REG_AR(
		.clk(__clk),
		.l(ar_load),
		.p1(ar_plus1),
		.m4(arm4),
		.w(w),
		.arz(arz),
		.ar(ar)
	);

	// sheet 10

	wire ic_plus1 = icp1 & strob1b;
	wire ic_load = w_ic & (stroba | strobb);

	wire [0:15] ic;
	ic REG_IC(
		.clk(__clk),
		.cu(ic_plus1),
		.l(ic_load),
		.r(off),
		.w(w),
		.ic(ic)
	);

	// sheet 11, 12

	wire [0:15] a;
	bus_a BUS_A(
		.bac(bac),
		.bab(bab),
		.baa(baa),
		.aa(aa),
		.ab(ab),
		.l(l),
		.ir(ir),
		.ar(ar),
		.ic(ic),
		.a(a)
	);

	// sheet 13, 14

	always @ (*) begin
		case ({ar_ad, ic_ad})
			2'b00 : dad = 16'd0;
			2'b01 : dad = ic;
			2'b10 : dad = ar;
			2'b11 : dad = ic | ar; // yeah, whatever
		endcase
	end

	assign zga = (kl[0:15] == {~barnb, dad[1:15]});

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
