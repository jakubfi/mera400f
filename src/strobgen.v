module strobgen(
	input __clk,
	input ss11, ss12, ss13, ss14, ss15,
	input ok$, zw, oken,
	input mode, step,
	input strob_fp,
	output ldstate,
	output got,
	output strob1,
	output strob1b,
	output strob2,
	output strob2b
);

	localparam S_GOT	= 3'd0;
	localparam S_GOTW	= 3'd1;
	localparam S_ST1	= 3'd2;
	localparam S_ST1W	= 3'd3;
	localparam S_ST1B	= 3'd4;
	localparam S_PGOT	= 3'd5;
	localparam S_ST2	= 3'd6;
	localparam S_ST2B	= 3'd7;

	wire if_busy = zw & oken;
	wire es1 = ss11 | (ss12 & ok$) | (ss13 & ok$) | ss14 | ss15;
	wire has_strob2 = ss11 | ss12;
	wire no_strob2 = ss13 | ss14 | ss15;

	assign got = state == S_GOT;
	assign strob1 = state == S_ST1;
	assign strob1b = state == S_ST1B;
	assign strob2 = state == S_ST2;
	assign strob2b = state == S_ST2B;
	assign ldstate = ~if_busy & ((state == S_PGOT) | ((state == S_ST1B) & no_strob2) | (state == S_ST2B));

	// TODO: strob_fp

	// STEP
	reg lstep;
	always @ (posedge __clk) begin
		lstep <= step;
	end
	wire step_trig = ~mode | (step & ~lstep);

	// STROBS
	reg [0:2] state;
	always @ (posedge __clk) begin
		case (state)
			// GOT
			S_GOT: begin
				if (es1) begin
					state <= S_ST1;
				end else begin
					state <= S_GOTW;
				end
			end

			S_GOTW: begin
				if (es1) begin
					state <= S_ST1;
				end
			end

			// STROB1 front
			S_ST1: begin
				if (step_trig) state <= S_ST1B;
				else state <= S_ST1W;
			end

			// STROB1 front (wait for STEP)
			S_ST1W: begin
				if (step_trig) state <= S_ST1B;
			end

			// STROB1 back
			S_ST1B: begin
				if (has_strob2) begin
					state <= S_ST2;
				end else if (no_strob2 & ~if_busy) begin
					state <= S_GOT;
				end else begin
					state <= S_PGOT;
				end
			end

			// STROB2 front
			S_ST2: begin
				state <= S_ST2B;
			end

			// STROB2 back
			S_ST2B: begin
				if (~if_busy) begin
					state <= S_GOT;
				end else begin
					state <= S_PGOT;
				end
			end

			// STROB2 back (wait for I/F operation to end)
			S_PGOT: begin
				if (~if_busy) begin
					state <= S_GOT;
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
		.b(ss11 | (ss12 & ok$)),
		.q(strob1_st2)
	);
	univib #(.ticks(STROB1_3_TICKS)) VIB_STROB1_3(
		.clk(__clk),
		.a_(got),
		.b((ss13 & ok$) | ss14 | ss15),
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
