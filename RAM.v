 module RAM(output [31:0] data_out, input [31:0] data_in, input [4:0] address, input we, chip_select, clock);
    // 32 x 32 memory
    reg [31:0] memory [31:0];

    // Data out is memory address if selected, otherwise unknown
    assign data_out = chip_select ? memory[address] : 32'bx;

    always @(posedge clock) begin
        // Only do stuff when chip_select is HIGH
        if (chip_select) begin
            // If write-enable is HIGH, then write to memory with data_in, otherwise retrieve memory at specified address
            if (we) begin
                memory[address] <= data_in;
            end
        end
    end
endmodule
