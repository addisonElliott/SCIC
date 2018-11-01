module system(output [3:0] LEDs, input [3:0] switch, input reset, clock);
	wire [15:0]	addr;
	wire [31:0]	data_toCPU;
	wire [31:0]	data_fromCPU;
	wire we;

	memoryIO_282 mem1(
		.data_out	( data_toCPU ),
		.data_in		( data_fromCPU ),
		.address		( addr ),
		.we			( we ),
		.clock			( sys_clock ),
		.io_in		(switch),
		.io_out		(LEDs)
	); 

	CPU cpu_inst(data_fromCPU, addr, we, data_toCPU, reset, clock);
endmodule