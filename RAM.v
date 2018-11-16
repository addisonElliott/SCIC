 module RAM(output reg [31:0] data_out, input [31:0] data_in, input [4:0] address, input we, chip_select, clock);
    // 2048 x 32 memory
    reg [31:0] memory [0:31];

    assign data_out = memory[address];

    always @(negedge clock) begin
        // Only do stuff when chip_select is HIGH
        if (chip_select) begin
            // If write-enable is HIGH, then write to memory with data_in, otherwise retrieve memory at specified address
            if (we) begin
                memory[address] <= data_in;
            end
            // else begin
            //     data_out <= memory[address];
            // end
        end
        else begin
            // data_out is high impedance state when not selected
            // data_out <= 32'bx;
        end
    end
endmodule
