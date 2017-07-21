module strobgen(
	input __clk,
	input ss11, ss12, ss13, ss14, ss15,
	input ok, zw, oken,
	input mode, step,
	input strob_fp,
	output reg got,
	output strob1,
	output strob1b,
	output strob2,
	output strob2b
);

	parameter STROB1_1_TICKS;
	parameter STROB1_2_TICKS;
	parameter STROB1_3_TICKS;
	parameter STROB1_4_TICKS;
	parameter STROB1_5_TICKS;
	parameter GOT_TICKS;
	parameter STROB2_TICKS;

	localparam S_GOT	= 6'd0;
	localparam S_ST1	= 6'd1;
	localparam S_ST1B	= 6'd2;
	localparam S_ST12	= 6'd3;
	localparam S_ST12B= 6'd4;
	localparam S_ST2	= 6'd5;
	localparam S_ST2B	= 6'd6;

	wire if_got_holdoff = zw & oken;
	wire e_s12 = ss11 | (ss12 & ok);
	wire e_s1 = (ss13 & ok) | ss14 | ss15;

	// TODO: this needs to be cleaned up after strob signals loose their "clock" powers
	//assign got = state == S_GOT;
	assign strob1 = (state == S_ST1) | (state == S_ST12);
	assign strob1b = (state == S_ST1B) | (state == S_ST12B);
	assign strob2 = state == S_ST2;
	assign strob2b = state == S_ST2B;

	// TODO: strob_fp
	// TODO: step

	reg [0:2] state;
	always @ (posedge __clk) begin
		case (state)
			// GOT
			S_GOT: begin
				got <= 0;
				if (e_s12) begin
					state <= S_ST12;
				end else if (e_s1) begin
					state <= S_ST1;
				end
				end

			// STROB1 (lonely) front edge
			S_ST1: begin
				state <= S_ST1B;
				end

			// STROB1 (lonely) back edge
			S_ST1B: begin
				if (~if_got_holdoff) begin
					state <= S_GOT;
					got <= 1;
				end
				end

			// STROB1 (with STROB2) front edge
			S_ST12: begin
				state <= S_ST12B;
				end

			// STROB1 (with STROB2) back edge
			S_ST12B: begin
				state <= S_ST2;
				end

			// STROB2 front edge
			S_ST2: begin
				state <= S_ST2B;
				end

			// STROB2 back edge
			S_ST2B: begin
				if (~if_got_holdoff) begin
					state <= S_GOT;
					got <= 1;
				end
				end
		endcase
	end

/*
	wire strob1_st2;
	wire strob1_only;
	univib #(.ticks(STROB1_1_TICKS)) VIB_STROB1_1(
		.clk(__clk),
		.a_(got),
		.b(ss11 | (ss12 & ok)),
		.q(strob1_st2)
	);
	univib #(.ticks(STROB1_3_TICKS)) VIB_STROB1_3(
		.clk(__clk),
		.a_(got),
		.b((ss13 & ok) | ss14 | ss15),
		.q(strob1_only)
	);

	wire strob1_any = strob1_st2 | strob1_only;

	// sheet 4, page 2-4
	// * got, strob2, step register

	wire sgot = ss11 | ss12; // 1 = stan ze strob1/2, 0 = stan tylko ze strob1
	wire if_holdoff = got_trig & zw & oken;
	wire step_trig = ~sgot & strob_step; // poczekaj na STEP z przejściem ze STROB1 do GOT (w stanie ze strob1 only)
	wire got_trig = if_holdoff | step_trig | strob1_only | strob2;

	univib #(.ticks(GOT_TICKS)) VIB_GOT(
		.clk(__clk),
		.a_(got_trig),
		.b(1'b1),
		.q(got)
	);

	// NOTE: strob2 needs to be triggered with 1-cycle delay
	// to set it apart from strob1 falling edge. This is needed
	// for cycles where one action is taken on strob1 falling
	// edge, and another on the strob2 rising edge.
	reg strob2_trig = 1;
	always @ (posedge __clk) begin
		strob2_trig <= (strob_step & sgot) | strob1_st2;
		// poczekaj na STEP z przejściem ze STROB1 do STROB2 (w stanie ze strob1 i strob2)
	end

	univib #(.ticks(STROB2_TICKS)) VIB_STROB2(
		.clk(__clk),
		.a_(strob2_trig),
		.b(1'b1),
		.q(strob2)
	);

	* step jest uzbrajany jeśli MODE=1 i wystąpił STROB1
	* STEP zabrania przejścia do stanu STROB2 jeśli ss11 | ss12 (czyli jeśli jesteśmy w strob1 po którym jest strob2, to będziemy trzymać strob1)
	* STEP zabrania przejścia do stanu GOT jeśli ~(ss11 | ss12) (czyli jeśli jesteśmy w strob1 bez strob2, to będziemy trzymać strob1)
	* wciśnięcie STEP zeruje przerzutnik i CPU wykonuje krok (odpala się przejście do następnego stanu)
	* MODE=0 resetuje przerzutnik i trzyma go w takim stanie (czyli step nie działa przy MODE=0)
	* podsumowując: jeśli MODE=1, to podtrzymujemy bieżący stan STROB1 dopóki użytkownik nie wciśnie STOP

	wire step_set = mode & strob1_any;
	wire strob_step;
	ffd REG_STEP(
		.s_(~step_set),
		.d(1'b0),
		.c(~step),
		.r_(mode),
		.q(strob_step)
	);

	assign strob1 = strob1_any | strob_fp | strob_step;
*/


endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
