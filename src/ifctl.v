module ifctl(
	input __clk,
	input clo,
	input gotst1,
	input zgi_j,
	input zgi_set,
	input ifhold_j,
	input ifhold_reset,
	input zw,
	input ren,
	input rok,
	output reg ok$,
	output zg,
	output zwzg,
	output talarm
);

	parameter ALARM_DLY_TICKS;
	parameter ALARM_TICKS;

	// Cała obsługa interfejsu potencjalnie też powinna być zrobiona jako automat.
	// Być może powinna znaleźć się (po części?) w strobgen - oczekiwanie na interfejs między
	// GOT a S1 jest niczym innym jak kolejnym stanem.

	wire oken = ren | rok;
	assign zwzg = zgi & zw;
	assign zg = zgi | ifhold | (zw & oken);
	// (zw & oken): trzymamy zg aż nie spadnie ok|en
	// ifhold: trzymamy zajęty interfejs przez cały rozkaz z wymogiem atomowych odwołań do pamięci

	// * wejście do zgi_set zaczyna zgłoszenie
	// * każdy kolejny strob1 kończy zgłoszenie
	// * każdy kolejny got zaczyna następne zgłoszenie
	// * zgi_j mówi w jakich stanach zgłaszanie się odbywa

	reg zgi;
	always @ (posedge __clk, posedge clo) begin
		if (clo) zgi <= 1'b0;
		else if (zgi_set) zgi <= 1'b1;
		else if (gotst1) case (zgi_j)
			1'b0: zgi <= 1'b0;
			1'b1: zgi <= ~zgi;
		endcase
	end

/*
	wire zgi;
	ffjk REG_ZGI(
		.s_(~zgi_set),
		.j(zgi_j),
		.c_(gotst1),
		.k(zgi),
		.r_(~clo),
		.q(zgi)
	);
*/

/*
	wire zgi2_reset = clo | (strob2 & w$ & wzi & is);
	wire zgi2_j = srez$ & wr;

	reg ifhold;
	always @ (posedge ok$, posedge zgi2_reset) begin
		if (zgi2_reset) ifhold <= 0;
		else case (zgi2_j)
			1'b0: ifhold <= 0;
			1'b1: ifhold <= ~ifhold;
		endcase
	end
*/

	// ten rejestr trzyma zgłoszenie na interfejsie dla rozkazów, które robią
	// odczyt+zapis, który powinien być zrobiony w tym samym dostępie do I/F (atomowo)
	// (ifhold wypełnia sygnał ZW pomiędzy stanami WR a WW)
	// Przypadek specjalny:
	// IS dokonuje zapisu do pamięci warunkowo względem wskaźnika zera WZI,
	// więc jeśli w W& przy rozkazie IS podczas STROB2 WZI będzie zapalone, to zdejmujemy zajętość

	wire ifhold;
	ffjk IFHOLD(
		.s_(1'b1),
		.j(ifhold_j),
		.c_(~ok$),
		.k(ifhold),
		.r_(~(ifhold_reset | clo)),
		.q(ifhold)
	);

	// ok$ - koniec pracy z interfejsem (niezależnie od finału: ok/en/alarm)
	// to zasadniczo jest zwzg & ok_clk, ale tak nie działa (póki co)

	wire ok_clk = ren | talarm | rok;
	always @ (posedge __clk, negedge zgi) begin
		if (~zgi) ok$ <= 0;
		else if (ok_clk) ok$ <= zwzg;
	end

	/*
	ffjk REG_OK$(
		.s_(1'b1),
		.j(zwzg),
		.c_(~ok_clk),
		.k(1'b1),
		.r_(zgi),
		.q(ok$)
	);
*/
	// alarm przy braku odpowiedzi z interfejsu

	wire alarm = zwzg & ~ok$;

	wire alarm_dly;
	dly #(.ticks(ALARM_DLY_TICKS)) DLY_ALARM(
		.clk(__clk),
		.i(alarm),
		.o(alarm_dly)
	);

	univib #(.ticks(ALARM_TICKS)) VIB_ALARM(
		.clk(__clk),
		.a_(1'b0),
		.b(alarm_dly),
		.q(talarm)
	);

endmodule
// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
