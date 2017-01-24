`timescale 1ns/100ps

module test();

	function [4:0] fn;
		input m;
		input [3:0] s;
		input c;
		input [4:0] a;
		input [4:0] b;
		begin
			case ({m, s})
			'b10000 : fn = ~a;
			'b10001 : fn = ~(a | b);
			'b10010 : fn = ~a & b;
			'b10011 : fn = 0;
			'b10100 : fn = ~(a & b);
			'b10101 : fn = ~b;
			'b10110 : fn = a ^ b;
			'b10111 : fn = a & ~b;
			'b11000 : fn = ~a | b;
			'b11001 : fn = ~(a ^ b);
			'b11010 : fn = b;
			'b11011 : fn = a & b;
			'b11100 : fn = 'b1111;
			'b11101 : fn = a | ~b;
			'b11110 : fn = a | b;
			'b11111 : fn = a;
			'b00000 : fn = a + c;
			'b00001 : fn = (a | b) + c;
			'b00010 : fn = (a | ~b) + c;
			'b00011 : fn = 'b1111 + c;
			'b00100 : fn = a + (a & ~b) + c;
			'b00101 : fn = (a | b) + (a & ~b) + c;
			'b00110 : fn = a - b - 1 + c;
			'b00111 : fn = (a & ~b) - 1 + c;
			'b01000 : fn = a + (a & b) + c;
			'b01001 : fn = a + b + c;
			'b01010 : fn = (a | ~b) + (a & b) + c;
			'b01011 : fn = (a & b) - 1 + c;
			'b01100 : fn = a + a + c;
			'b01101 : fn = (a | b) + a + c;
			'b01110 : fn = (a | ~b) + a + c;
			'b01111 : fn = a - 1 + c;
			endcase
		end
	endfunction

	reg [1:0] m;
	reg [4:0] s, a, b;
	reg [1:0] cn_;
	wire [4:0] f;
	wire x, y, cn4_, eq;
	reg [4:0] result;

	alu181 u1(.m(m[0]), .s(s[3:0]), .a(a[3:0]), .b(b[3:0]), .cn_(cn_[0]), .f(f[3:0]), .eq(eq), .cn4_(cn4_), .x(x), .y(y));

	initial begin

		for (m=0 ; m<2 ; m=m+1) begin
			for (cn_=0 ; cn_<2 ; cn_=cn_+1) begin
				for (s=0 ; s<16 ; s=s+1) begin
					for (a=0 ; a<16 ; a=a+1) begin
						for (b=0 ; b<16 ; b=b+1) begin
							#1 assign result = fn(m, s, ~cn_, a, b);
							#1 if (f[3:0] != result[3:0]) begin
								$display("FAILED functions test: m=%d, s=%d, a=%d, b=%d, cn_=%d => f=%d (expected: f=%d)", m, s, a, b, cn_, f[3:0], result);
								$finish();
							end
						end
					end
				end
			end
		end

		#1 m=0; s=9;
		for (cn_=0 ; cn_<2 ; cn_=cn_+1) begin
			for (a=0 ; a<16 ; a=a+1) begin
				for (b=0 ; b<16 ; b=b+1) begin
					#1 assign result = fn(m, s, ~cn_, a, b);
					#1 if ((f[3:0] != result[3:0]) || (cn4_ != ~result[4])) begin
						$display("FAILED addition test: m=%d, s=%d, a=%d, b=%d, cn_=%d => cn4_=%d, f=%d (expected: cn4_=%d, f=%d)", m, s, a, b, cn_, cn4_, f[3:0], ~result[4], result[3:0]);
						$finish();
					end
				end
			end
		end

	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
