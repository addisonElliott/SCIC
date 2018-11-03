 module RAM(output reg [31:0] data_out, input [31:0] data_in, input [10:0] address, input we, chip_select, clock);
    reg [31:0] memory [0:2047];

    always @(negedge clock) begin
        if (chip_select) begin
            if (we) begin
                memory[address] <= data_in;
            end
            else begin
                data_out <= memory[address];
            end
        end
        else begin
            data_out = 32'bz;
        end
    end
endmodule