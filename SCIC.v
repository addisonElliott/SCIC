// module SCIC(output [3:0] LEDs, input [3:0] switches, input reset, clock);
module SCIC(/*output [15:0] PC, output [31:0] IR, */output [31:0] AC, output [3:0] LEDs, input [3:0] switches, input reset, clock);
    wire [15:0]	address;
    wire [31:0]	data_toCPU;
    wire [31:0]	data_fromCPU;
    wire we;

    // Note: reset is active HIGH
    memory_controller memory_controller_inst(data_toCPU, LEDs, data_fromCPU, address, switches, we, clock);
    // CPU cpu_inst(data_fromCPU, address, we, data_toCPU, reset, clock);
    CPU cpu_inst(/*PC, IR, */AC, data_fromCPU, address, we, data_toCPU, reset, clock);
endmodule
