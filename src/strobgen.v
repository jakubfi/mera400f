module strobgen(
  input __clk,
  input ss11, ss12, ss13, ss14, ss15,
  input ok, zw, oken,
  input mode, step_,
  input strob_fp_,
  output got, got_,
  output strob1, strob1_,
  output strob2, strob2_
);

  parameter STROB1_1_TICKS;
  parameter STROB1_2_TICKS;
  parameter STROB1_3_TICKS;
  parameter STROB1_4_TICKS;
  parameter STROB1_5_TICKS;
  parameter GOT_TICKS;
  parameter STROB2_TICKS;

  localparam TICK_NONE = 3'd0;
  localparam TICK_GOT = 3'd1;
  localparam TICK_S1S = 3'd2;
  localparam TICK_S1L = 3'd3;
  localparam TICK_S1LB = 3'd4;
  localparam TICK_S2 = 3'd5;

  // sheet 3, page 2-3
  // * strob signals

  wire sgot = ~(ss11 | ss12);

  wire STROB1_1_, STROB1_2_, STROB1_3_, STROB1_4_, STROB1_5_;
  univib #(.ticks(STROB1_1_TICKS)) VIB_STROB1_1(
    .clk(__clk),
    .a_(got$),
    .b(ss11),
    .q_(STROB1_1_)
  );
  univib #(.ticks(STROB1_2_TICKS)) VIB_STROB1_2(
    .clk(__clk),
    .a_(got$),
    .b(ss12 & ok),
    .q_(STROB1_2_)
  );
  univib #(.ticks(STROB1_3_TICKS)) VIB_STROB1_3(
    .clk(__clk),
    .a_(got$),
    .b(ss13 & ok),
    .q_(STROB1_3_)
  );
  univib #(.ticks(STROB1_4_TICKS)) VIB_STROB1_4(
    .clk(__clk),
    .a_(got$),
    .b(ss14),
    .q_(STROB1_4_)
  );
  univib #(.ticks(STROB1_5_TICKS)) VIB_STROB1_5(
    .clk(__clk),
    .a_(got$),
    .b(ss15),
    .q_(STROB1_5_)
  );

  wire st56_ = STROB1_1_ & STROB1_2_;
  wire st812_ = STROB1_3_ & STROB1_4_ & STROB1_5_;
  wire sts = ~(st56_ & st812_);

  // sheet 4, page 2-4
  // * got, strob2, step register

  // NOTE: 33pF cap to ground on M15_6
  wire M15_12 = ~(M15_6 & zw & oken);
  wire M52_6 = M15_12 & M53_6;
  wire M53_6 = ~(sgot & M21_5);
  wire M15_6 = ~(M52_6 & st812_ & strob2_);

  wire got$;
  univib #(.ticks(GOT_TICKS)) VIB_GOT(
    .clk(__clk),
    .a_(M15_6),
    .b(1'b1),
    .q(got$)
  );
  assign got_ = ~got$;
  assign got = got$;

  wire M53_11 = ~(M21_5 & ~sgot);
  wire M53_8 = ~(M53_11 & st56_);

  // NOTE: strob2 needs to be triggered with 1-cycle delay
  // to set it apart from strob1 falling edge. This is needed
  // for cycles where one action is taken on strob1 falling
  // edge, and another on the strob2 rising edge.
  reg strob2_trig = 1;
  always @ (posedge __clk) begin
    strob2_trig <= M53_8;
  end

  univib #(.ticks(STROB2_TICKS)) VIB_STROB2(
    .clk(__clk),
    .a_(strob2_trig),
    .b(1'b1),
    .q(strob2)
  );
  assign strob2_ = ~strob2;

  // FIX: +MODE was labeled -MODE
  wire M21_5;
  ffd REG_STEP(
    .s_(~(mode & sts)),
    .d(1'b0),
    .c(step_),
    .r_(mode),
    .q(M21_5)
  );

  // NOTE: Workaround for Error (35000)
  // https://www.altera.com/support/support-resources/knowledge-base/solutions/rd06192013_268.html
  wire strob1_int_ = st812_ & st56_ & strob_fp_ & ~M21_5;
  assign strob1_ = strob1_int_;
  assign strob1 = ~strob1_;

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
