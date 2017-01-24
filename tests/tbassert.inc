`define tbassert(signal, value) \
	if (signal !== value) begin \
		$display("FAILED: got %d, expected %d!", signal, value); \
		$finish; \
	end

// vim: tabstop=2 shiftwidth=2 autoindent syntax=verilog
