`timescale 1ns/100ps

module regs_tb();

	reg [0:15] w;
	reg strob1, w_ir;
	reg q;
	wire [0:15] ir;
	wire ou, in;
	wire inou__;
	wire hlt;

	p_d U1(.q(q), .w(w), .ir(ir), .strob1(strob1), .w_ir(w_ir), .ou(ou), .in(in), .inou__(inou__), .mcl(hlt));

	initial begin
		$display("    w\tstrob\tw->ir\tir\tou\tin");
		$display("--------------------------------------------------------------");
		$monitor("%x\t%d\t%d\t%x\t%d\t%d", w, strob1, w_ir, ir, ou, in);
		w = 0;
		strob1 = 0;
		w_ir = 0;

		#1 w = 'b111_011_0_001_000_000;
		#1 w_ir = 1; strob1 = 1; #1 strob1 = 0; w_ir = 0;
		$display(hlt);

		#1 w = 'b011_101_0_001_010_001; // ou
		#1 w_ir = 1; strob1 = 1; #1 strob1 = 0; w_ir = 0;

		#1 w = 'b011_110_0_001_010_010; // in
		#1 w_ir = 1; strob1 = 1; #1 strob1 = 0; w_ir = 0;

/*
		#1 piszrn = 0;
		#1 w = 33; ra = 0; rb = 1; piszrn = 1; czytrn = 0;
		#1 piszrn = 0;
		#1 w = 44; ra = 1; rb = 1; piszrn = 1; czytrn = 0;
		#1 piszrn = 0;

		#1 ra = 1; rb = 0; piszrn = 0; czytrn = 1;
		#1 czytrn = 0;
		#1 ra = 0; rb = 1; piszrn = 0; czytrn = 1;
		#1 czytrn = 0;
		#1 ra = 1; rb = 1; piszrn = 0; czytrn = 1;
		#1 czytrn = 0;
*/
		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
