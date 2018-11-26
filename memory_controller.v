module memory_controller(output [31:0] data_out, output [3:0] io_out, input [31:0] data_in, input [15:0] address, input [3:0] io_in, input we, clock);
    wire [31:0] rom_data_out, io_data_out, ram_data_out;
    wire select_ram, select_io, select_rom;
    wire [1:0] data_select;

    // Address Map:
    //      Range       Item    Size (words)    Binary Range
    //      0000-001F   ROM     32              0000 0000 0000 0000 -> 0000 0000 0001 1111
    //      0020-003F   I/O     32              0000 0000 0010 0000 -> 0000 0000 0011 1111
    //      0040-005F   RAM     32              0000 0000 0100 0000 -> 0000 0000 0101 1111
    //      Otherwise return 0s
    // Note: Placed the memory on byte boundaries to make it easy to synthesize the logic for this, but I am not sure if these if statements will synthesize that way
    // @(*) is a combinational block but you are not required to use an assign statement for wires
    // data_select is basically an enumeration as such:
    //      0 = ROM
    //      1 = I/O
    //      2 = RAM
    //      3 = Otherwise
    assign data_select = (~(|address[15:7]) ? address[6:5] : 2'b11);

    // Wires for if a particular memory module is selected
    // This is essentially a behavioral description of a demultiplexor
    assign select_rom = (data_select == 2'b00);
    assign select_io = (data_select == 2'b01);
    assign select_ram = (data_select == 2'b10);

    // ROM, I/O & RAM module instantiations
    ROM rom_inst(rom_data_out, address[4:0], select_rom);
    io_controller io_controller_inst(io_data_out, io_out, data_in, address[4:0], io_in, select_io, we, clock);
    RAM ram_inst(ram_data_out, data_in, address[4:0], we, select_ram, clock);

    // data_out wire is set to be whichever address range we are speaking to
    // In the case of an unknown address space being specified, the value returned is all zeros
    Mux4to1 #(32) data_mux_inst(data_out, rom_data_out, io_data_out, ram_data_out, 32'd0, data_select);
endmodule
