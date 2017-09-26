// Minimal 8N1 TX/RX UART driver

// -----------------------------------------------------------------------
module uart(
	input clk,
	input send,
	input [7:0] tx_byte,
	output [7:0] rx_byte,
	output tx_busy,
	output rx_busy,
	output txd,
	input rxd
);

	parameter baud;
	parameter clk_speed;

	uart_tx #(.clk_speed(clk_speed), .baud(baud)) tx(.clk(clk), .d(tx_byte), .busy(tx_busy), .txd(txd), .send(send));
	uart_rx #(.clk_speed(clk_speed), .baud(baud)) rx(.clk(clk), .d(rx_byte), .busy(rx_busy), .rxd(rxd));

endmodule

// -----------------------------------------------------------------------
module uart_tx(
	input clk,
	input [7:0] d,
	input send,
	output busy,
	output txd
);

	parameter baud;
	parameter clk_speed;
	localparam prescale = clk_speed/baud;
	localparam width = $clog2(prescale+1);
	localparam [width-1:0] period = prescale[width-1:0];

	reg [10:0] txbuf = 11'b1;
	reg [3:0] state = 0;
	reg [width-1:0] divcnt;

	always @ (posedge clk) begin
		if (state == 0) begin // idle state
			if (send) begin // send trigger
				state <= 1;
				divcnt <= period;
				txbuf <= {1'b1, 1'b1, d, 1'b0}; // load data
			end
		end else begin // transmission
			if (divcnt > 0) begin // waiting for the next serial clk tick
				divcnt <= divcnt - 1'b1;
			end else begin // next serial clk tick
				divcnt <= period; // preload serial clock timer
				txbuf <= txbuf >> 1; // push the bit
				if (state < 10) begin
					state <= state + 1'b1;
				end else begin
					state <= 0;
				end
			end
		end
	end

	assign busy = |state | send;
	assign txd = txbuf[0];

endmodule

// -----------------------------------------------------------------------
module uart_rx(
	input clk,
	output [7:0] d,
	output busy,
	input rxd
);

	parameter baud;
	parameter clk_speed;
	localparam prescale = clk_speed/baud;
	localparam width = $clog2(prescale+1);
	localparam [width-1:0] period = prescale[width-1:0];

	reg [9:0] rxbuf;
	reg [3:0] state = 0;
	reg [width-1:0] divcnt;

	always @ (posedge clk) begin
		if (state == 0) begin // idle state
			if (~rxd) begin // receive trigger
				state <= 1;
				divcnt <= (period >> 1) - 1'b1;
			end
		end else begin // receiving data
			if (divcnt > 0) begin // waiting for the next serial clk tick
				divcnt <= divcnt - 1'b1;
			end else begin // next serial clk tick
				divcnt <= period - 1'b1; // preload serial clock timer
				if (state < 10) begin
					state <= state + 1'b1; // advance to the next state
					rxbuf <= {rxd, rxbuf[9:1]}; // push the bit
				end else begin // transmission is done
					state <= 0;
				end
			end
		end
	end

	assign busy = |state | ~rxd;
	assign d = rxbuf[9:2];

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
