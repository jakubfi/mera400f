module a_bus(
	input bac_, bab_, baa_,
	input aa_, ab_,
	input [0:15] l,
	input [0:15] ic,
	input [0:15] ar,
	input [0:15] ir,
	output [0:15] a
);

	always @ (*) begin
		if (~bac_) a[0:7] = 8'd0;
		else case ({ab_, aa_})
			2'b11 : a[0:7] = l[8:15];
			2'b10 : a[0:7] = ic[0:7];
			2'b01 : a[0:7] = ar[0:7];
			2'b00 : a[0:7] = l[0:7];
		endcase

		if (~bab_) a[8:9] = 2'd0;
		else case ({ab_, aa_})
			2'b11 : a[8:9] = ir[8:9];
			2'b10 : a[8:9] = ic[8:9];
			2'b01 : a[8:9] = ar[8:9];
			2'b00 : a[8:9] = l[8:9];
		endcase

		if (~baa_) a[10:15] = 6'd0;
		else case ({ab_, aa_})
			2'b11 : a[10:15] = ir[10:15];
			2'b10 : a[10:15] = ic[10:15];
			2'b01 : a[10:15] = ar[10:15];
			2'b00 : a[10:15] = l[10:15];
		endcase
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
