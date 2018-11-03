module memory_controller(output [31:0] data_out, output [3:0] io_out, input [31:0] data_in, input [15:0] address, input [3:0] io_in, input we, clock);
	wire [31:0] rom_data_out, io_data_out, ram_data_out;
	wire select_ram, select_io, select_rom;
    reg [1:0] data_select;

    // Address Map:
    //      Range       Item    Size (words)    Binary Range
    //      0000-001F   ROM     32              0000 0000 0000 0000 -> 0000 0000 0001 1111
    //      0020-003F   I/O     32              0000 0000 0010 0000 -> 0000 0000 0011 1111
    //      0800-0FFF   RAM     2048            0000 1000 0000 0000 -> 0000 1111 1111 1111
    //      Otherwise return 0s
    // Note: Placed the memory on byte boundaries to make it easy to synthesize the logic for this, but I am not sure if these if statements will synthesize that way
    // @(*) is a combinational block but you are not required to use an assign statement for wires
    always @(*) begin
        if (address <= 16'h001f) begin
            data_select = 2'b00;
        end
        else if (address <= 16'h003F) begin
            data_select = 2'b01;
        end
        else if (address >= 16'h0800 && address <= 16'h0FFF) begin
            data_select = 2'b10;
        end
        else begin
            data_select = 2'b11;
        end
    end

    // Wires for if a particular memory module is selected
    assign select_rom = (data_select == 2'b00);
    assign select_io = (data_select == 2'b01);
    assign select_ram = (data_select == 2'b10);

    ROM rom_inst(rom_data_out, address[5:0], select_rom);
    io_controller_bidirectional io_controller_bidirectional_inst(io_data_out, io_out, data_in, address[5:0], io_in, select_io, we, clock);
    RAM ram_inst(ram_data_out, data_in, address[10:0], we, select_ram, clock);

    // data_out wire is set to be whichever address range we are speaking to
    Mux4to1 #(32) data_mux_inst(data_out, rom_data_out, io_data_out, ram_data_out, 32'd0, data_select);
endmodule

module io_controller_bidirectional(output reg [31:0] data_out, output reg [3:0] io_out, input [31:0] data_in, input [5:0] address, input [3:0] io_in, input chip_select, we, clock);
    // wire [31:0] wire_in [0:31];
    // wire [31:0] wire_out [0:31];

    // wire_out[12][31:0] = 32'h0;

    // if chip_select is set, then return data_out = memory at address location
    // if chip_select is set and we is enabled, then set values at that memory location
	// assign data_out = {32'b0000_0000_0000_0000_0000_0000_0000, io_in};

    // TODO: Need to figure out this module
	always @(negedge clock) begin
        if (chip_select) begin
            if (we) begin
                // TODO: How to do this?
                io_out <= data_in[3:0];
            end
            else begin
                // TODO: How to do this?
                data_out <= 32'h0;            
            end
        end
        else begin
            data_out <= 32'bz;
        end
    end
endmodule