/*
	AWP FIC register

	document: 12-006370-01-4A
	unit:     F-PM2-2
	pages:    2-20
*/

module fic(
	input cda,
	input cua_,
	input rab_,
	input load_,
	input [0:5] in,
	output reg [0:5] out
);
/*
	always @(posedge rab_, negedge load_, posedge cda, posedge cua_) begin
		if (rab_) out <= 0;
		else if (~load_) out <= in;
		else if (cda) out <= out - 1'b1;
		else out <= out + 1'b1;
	end
*/
	// NOTE: Sensitivities are different for the FPGA implementation.
	//       Idea behind it is to always be front-edge sensitive
	wire clk = ~load_ | cda | ~cua_;
	always @ (posedge clk, posedge rab_) begin
		if (rab_) out <= 0;
		else if (~load_) out <= in;
		else begin
			if (cda) out <= out - 1'd1;
			else out <= out + 1'd1;
		end
	end

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
