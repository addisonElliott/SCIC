module SCIC(output [3:0] LEDs, input [3:0] switches, input reset, clock);
    wire [15:0]	address;
    wire [31:0]	data_toCPU;
    wire [31:0]	data_fromCPU;
    wire we;

    // TODO: Temporarily remove memory controller to see if it causes problems
    assign LEDs = 4'b0000;
    assign data_toCPU = 32'h0000_000f;

    // Note: reset is active HIGH
    // memory_controller memory_controller_inst(data_toCPU, LEDs, data_fromCPU, address, switches, we, clock);
    CPU cpu_inst(data_fromCPU, address, we, data_toCPU, reset, clock);
endmodule
