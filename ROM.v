module ROM(output reg [31:0] data_out, input [5:0] address, input chip_select);
    // Memory elements, 32 words (1KiB)
    reg [31:0] memory [0:31];

    // Load in data to ROM from separate file
    initial begin
		$readmemh("program1.mem", memory, 0, 31);
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
