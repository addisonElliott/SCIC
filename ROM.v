module ROM(output reg [31:0] data_out, input [31:0] address);
    // Memory elements, 32 words (1KiB)
    reg [31:0] memory [0:31];

    // Load in data to ROM from separate file
    initial begin
		$readmemh("program1.mem", memory, 0, 31);
	end

    // When address changes, set data_out to new value in memory
	always @(address) begin
		data_out <= memory[address[5:0];
	end
endmodule
