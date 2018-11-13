module ROM(output reg [31:0] data_out, input [4:0] address, input chip_select);
    // Memory elements, 32 words (1KiB)
    reg [31:0] memory [0:31];

    // Load in data to ROM from separate file
    // This file makes it extremely flexible to add new programs to the CPU by simply referencing a different mem file
    initial begin
        // Uncomment the $readmemh command containing the program you want to load the ROM with
        // There are two separate $readmemh commands, one to use for Icarus simulation and the other is for Cadence
        // simulation. You must uncomment the appropriate one depending on how you are simulating the project.
        // The one containing $PHOME environment variable is to use for Cadence tools

        // Program that adds 16 to accumulator over and over forever
        // $readmemh("programs/simple_counter.mem", memory, 0, 31);
        // $readmemh("$PHOME/verilog.src/SDDC/programs/simple_counter.mem", memory, 0, 31);

        // Program that reads from switches and writes to LEDs repeatedly
        // This program tests the bidirectional I/O controller
        // $readmemh("programs/read_and_write_io.mem", memory, 0, 31);
        // $readmemh("$PHOME/verilog.src/SDDC/programs/read_and_write_io.mem", memory, 0, 31);

        // Program that tests all instructions
        // $readmemh("programs/test_new_ops.mem", memory, 0, 31);
        $readmemh("$PHOME/verilog.src/SDDC/programs/test_new_ops.mem", memory, 0, 31);
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
