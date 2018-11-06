module ROM(output reg [31:0] data_out, input [4:0] address, input chip_select);
    // Memory elements, 32 words (1KiB)
    reg [31:0] memory [0:31];

    // Load in data to ROM from separate file
    // This file makes it extremely flexible to add new programs to the CPU by simply referencing a different mem file
    initial begin
        // Program that adds 16 to accumulator over and over forever
		$readmemh("programs/simple_counter.mem", memory, 0, 31);

        // TODO Not sure what this program does
		// $readmemh("programs/program1.mem", memory, 0, 31);
	end

    // When address changes, set data_out to new value in memory
	always @(chip_select or address) begin
        if (chip_select) begin
    		data_out <= memory[address];
        end
        else begin
            data_out <= 32'bz;
        end
	end
endmodule
