`timescale 1ns/100ps

module regs_tb();

	reg [0:15] w;
	reg strob1, w_ir;
	reg q;
	wire [0:15] ir;
	wire ou, in;
	wire inou__;
	wire hlt;

	p_d U1(.q(q), .w(w), .ir(ir), .strob1(strob1), .w_ir(w_ir), .ou_(ou), .in_(in), .inou$_(inou), .mcl_(hlt));

	initial begin
		$finish;
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent
