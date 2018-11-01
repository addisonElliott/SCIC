module memory_controller(output [31:0] data_out, output [3:0] io_out, input [31:0] data_in, input [15:0] address, input [3:0] io_in, input we, clock);
	wire [31:0] rom_data_out, io_data_out, ram_data_out;
	wire select_ram, select_io, select_rom;
    wire [1:0] data_select;

    // Address Map:
    //      Range       Item    Size (words)
    //      0000-001F   ROM     32
    //      0020-002F   I/O     16
    //      0030-082F   RAM     2048
    //      Otherwise return 0s
    if (address <=16'h001F) begin
        data_select = 2'b00;
    end
    else if (address <=16'h002F) begin
        data_select = 2'b01;
    end
    else if (address <= 16'h082F) begin
        data_select = 2'b10;
    end
    else begin
        data_select = 2'b11;
    end

    // Wires for if a particular memory module is selected
    assign select_rom = (data_select == 2'b00);
    assign select_io = (data_select == 2'b01);
    assign select_ram = (data_select == 2'b10);

    ROM rom_inst(rom_data_out, address);

    // TODO: Need to mess around with these modules and get them created
    bidirectionalIOPort sys_IO(io_data_out, data_in, select_io, we, clk, io_in, io_out);
	memory sys_RAM(select_ram, ~we, address[5:0], data_in, ram_data_out);

    // data_out wire is set to be whichever address range we are speaking to
    Mux4to1 #(32) data_mux_inst(data_out, rom_data_out, io_data_out, ram_data_out, 32'd0, data_select);
endmodule

module io_controller_bidirectional(output [31:0] data_out, output reg [3:0] io_out, input [31:0] data_in, input [31:0] address, input [3:0] io_in, input chip_select, we, clock);
	assign data_out = {32'b0000_0000_0000_0000_0000_0000_0000, io_in};

	always @(negedge clock) begin
   		if (we && chip_select) begin 
            io_out <= data_in[3:0];
        end
    end
endmodule