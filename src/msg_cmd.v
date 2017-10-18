// -----------------------------------------------------------------------
module cmd_dec(
	input [0:7] cmd,
	output valid,
	output r, w, in, pa, ok, pe, en,
	output cp, cpd, cpr, cpf, cps
);

	wire [0:10] bus;
	always @ (*) begin
		case (cmd)
			{ `MSG_REQ,  `CMD_R,   3'b110 } : bus = 11'b10000000000;
			{ `MSG_REQ,  `CMD_W,   3'b111 } : bus = 11'b01000000000;
			{ `MSG_REQ,  `CMD_IN,  3'b101 } : bus = 11'b00100000000;
			{ `MSG_REQ,  `CMD_PA,  3'b000 } : bus = 11'b00010000000;
			{ `MSG_RESP, `CMD_OK,  3'b000 } : bus = 11'b00001000000;
			{ `MSG_RESP, `CMD_OK,  3'b001 } : bus = 11'b00001000000;
			{ `MSG_RESP, `CMD_PE,  3'b000 } : bus = 11'b00000100000;
			{ `MSG_RESP, `CMD_EN,  3'b000 } : bus = 11'b00000010000;
			{ `MSG_REQ,  `CMD_CPD, 3'b001 } : bus = 11'b00000001000;
			{ `MSG_REQ,  `CMD_CPR, 3'b100 } : bus = 11'b00000000100;
			{ `MSG_REQ,  `CMD_CPF, 3'b100 } : bus = 11'b00000000010;
			{ `MSG_REQ,  `CMD_CPS, 3'b000 } : bus = 11'b00000000001;
			default: bus = 11'd0;
		endcase
	end

	assign cp = cpd | cpr | cpf | cps;
	assign { r, w, in, pa, ok, pe, en, cpd, cpr, cpf, cps } = bus;
	assign valid = (bus != 0);

endmodule

// -----------------------------------------------------------------------
module cmd_enc(
	input f, s, r, w, in, ok, pe, cps,
	output [0:7] cmd
);

	always @ (*) begin
		case ({f, s, r, w, in, ok, pe, cps})
			8'b10000000 : cmd = { `MSG_REQ,  `CMD_F,  3'b110 }; // req: F
			8'b01000000 : cmd = { `MSG_REQ,  `CMD_S,  3'b111 }; // req: S
			8'b00100100 : cmd = { `MSG_RESP, `CMD_OK, 3'b001 }; // rsp: OK for R
			8'b00100010 : cmd = { `MSG_RESP, `CMD_PE, 3'b000 }; // rsp: PE for R
			8'b00010100 : cmd = { `MSG_RESP, `CMD_OK, 3'b000 }; // rsp: OK for W
			8'b00001100 : cmd = { `MSG_RESP, `CMD_OK, 3'b000 }; // rsp: OK for IN
			8'b00000001 : cmd = { `MSG_RESP, `CMD_OK, 3'b011 }; // rsp: OK for CPS
			default     : cmd = 8'd0;
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
