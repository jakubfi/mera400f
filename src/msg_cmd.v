// -----------------------------------------------------------------------
module cmd_dec(
	input req,
	input [0:3] cmd,
	output cp,
	output r, w, in, pa, ok, pe, en, cpd, cpr, cpf, cps
);

	wire [0:10] bus /* synthesis keep */;
	always @ (*) begin
		case ({req, cmd})
			{ `MSG_REQ, `CMD_R }   : bus = 11'b10000000000;
			{ `MSG_REQ, `CMD_W }   : bus = 11'b01000000000;
			{ `MSG_REQ, `CMD_IN }  : bus = 11'b00100000000;
			{ `MSG_REQ, `CMD_PA }  : bus = 11'b00010000000;
			{ `MSG_RESP, `CMD_OK } : bus = 11'b00001000000;
			{ `MSG_RESP, `CMD_PE } : bus = 11'b00000100000;
			{ `MSG_RESP, `CMD_EN } : bus = 11'b00000010000;
			{ `MSG_REQ, `CMD_CPD } : bus = 11'b00000001000;
			{ `MSG_REQ, `CMD_CPR } : bus = 11'b00000000100;
			{ `MSG_REQ, `CMD_CPF } : bus = 11'b00000000010;
			{ `MSG_REQ, `CMD_CPS } : bus = 11'b00000000001;
			default: bus = 11'd0;
		endcase
	end

	assign cp = cpd | cpr | cpf | cps;
	assign { r, w, in, pa, ok, pe, en, cpd, cpr, cpf, cps } = bus;

endmodule

// -----------------------------------------------------------------------
module cmdarg_enc(
	input f, s, r, w, ok, pe, cpresp,
	output [0:7] cmdarg
);

	always @ (*) begin
		case ({f, s, r, w, ok, pe, cpresp})
			// I/F requests
			7'b1000000 : cmdarg = { `MSG_REQ,  `CMD_F,  3'b110 };
			7'b0100000 : cmdarg = { `MSG_REQ,  `CMD_S,  3'b111 };
			// I/F responses
			7'b0010100 : cmdarg = { `MSG_RESP, `CMD_OK, 3'b001 };
			7'b0010010 : cmdarg = { `MSG_RESP, `CMD_PE, 3'b000 };
			7'b0001100 : cmdarg = { `MSG_RESP, `CMD_OK, 3'b000 };
			// CP responses
			7'b0000001 : cmdarg = { `MSG_RESP, `CMD_OK, 3'b011 };
			default    : cmdarg = 8'd0;
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
