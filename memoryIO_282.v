// NOTE: OLD CODE FOR REFERENCE, NOT USED

/*
File: memoryIO_282.v
Description: 	  ROM and data memory plus a bi-directional IO port
Address Ranges:0000-001f  0800-083f                          00fc
*/
module memoryIO_282(data_out, data_in, address, we, clk, io_in, io_out);
	output  [31:0] data_out;
	input   [31:0] data_in;
	input   [15:0] address;
	input   we, clk;
	input   [3:0]	io_in;
	output  [3:0]	io_out;

	wire[31:0]	rom_data_out,ram_data_out,io_data_out;
	wire		select_ram, select_io, select_rom;
	wire[1:0] DataMuxSelect;

	assign select_rom= (address<=16'h001f);	 //32 words 
	assign select_io  = (address==16'h00fc);   //just one word at fc
	assign select_ram= ( (address>=16'h0800) & (address<=16'h083f) );  //64 words (vs. hc12's 1K to 0bff)

	ReadOnlyMemory sys_ROM(rom_data_out, address[4:0]);
	memory sys_RAM(select_ram,~we,address[5:0],data_in,ram_data_out);
	bidirectionalIOPort sys_IO(io_data_out, data_in, select_io, 
							we, clk, io_in, io_out);

	assign DataMuxSelect = {select_rom,select_ram};
	mux4x1_bh DataBusMux(     // use .name assoc
		io_data_out,ram_data_out,rom_data_out,32'h0000_0000,
		DataMuxSelect,data_out);

endmodule   // end memoryIO_282


module ReadOnlyMemory(output reg [31:0] data_out, input [4:0] address);
always@(address)begin
	case(address) 
		/*32'h0000: #6 data_out=32'h5000_00fc;		//ld fc
		32'h0001: #6 data_out=32'h1000_001d;		//add 1d
		32'h0002: #6 data_out=32'h7000_00fc;		//st fc
		32'h0003: #6 data_out=32'h8000_0000;*/		//br 0
		/*32'h0000: #6 data_out=32'h5000_00fc;		//ld fc
		32'h0001: #6 data_out=32'h1000_001d;		//add 1d
		32'h0002: #6 data_out=32'h7000_0800;		//st 800
		32'h0003: #6 data_out=32'h1000_0800;		//add 800
		32'h0004: #6 data_out=32'h8000_0002;*/		//br 2
/*			Program #2*/
		32'h0000: #6 data_out=32'h5000_0800;	// ld 800
		32'h0001: #6 data_out=32'h5000_082b;	// ld 82b
		32'h0002: #6 data_out=32'h5000_001c;	// ld  1c
		32'h0003: #6 data_out=32'h7000_0800;	// st 800
		32'h0004: #6 data_out=32'h5000_0800;	// ld 800
		32'h0005: #6 data_out=32'h1000_001c;	// add 1c
		32'h0006: #6 data_out=32'h7000_082b;	// st 82b
		32'h0007: #6 data_out=32'h5000_082b;	// ld 82b
		32'h0008: #6 data_out=32'h5000_00fc;	// ld fc
		32'h0009: #6 data_out=32'h1000_001d;	// add 1d
		32'h000a: #6 data_out=32'h7000_00fc;	// st fc
		32'h000b: #6 data_out=32'h8000_0000;	// br 0
//*/
		// some constants:
		32'h001c: #6 data_out=32'hffff_fffe;
		32'h001d: #6 data_out=32'h0000_0004;
		default: #7 data_out=32'h1234abcd;
	endcase
end
endmodule

module bidirectionalIOPort(data_out, data_in, chip_select, write, clk, io_in, io_out);
	output  [31:0] data_out;
	input   [31:0] data_in;
	input   chip_select,write, clk;
	input   [3:0]	 io_in;
	output reg [3:0] io_out;

	assign data_out = {32'b0000_0000_0000_0000_0000_0000_0000,io_in};

	always@(negedge clk) //Writes
   		if(write && chip_select) io_out <=  data_in[3:0];
endmodule


//HDL Example 7-1   >>>>>>>>>EXCEPT CHANGED from 4 bits to 32 
//-----------------------------    
//Read and write operations of memory.
//Memory size is 64 words of 32 bits each. 
 module memory (Enable,ReadWrite,Address,DataIn,DataOut);
    input  Enable,ReadWrite;
    input [31:0] DataIn;
    input [5:0] Address;
    output [31:0] DataOut;
    reg [31:0] DataOut;
    reg [31:0] Mem [0:63];          //64 x 32 memory
    always @ (Enable or ReadWrite)
	if (Enable)
           if (ReadWrite) 
              DataOut = Mem[Address];  //Read
           else
              Mem[Address] = DataIn;   //Write
	else DataOut = 4'bz;        //High impedance state
endmodule

//HDL Example 4-8   >>>>>>>>>EXCEPT CHANGED from ? bits to 32
//-------------------------------------    
//Behavioral description of 4-to-1- line multiplexer
//Describes the function table of  Fig. 4-25(b).
module mux4x1_bh (i0,i1,i2,i3,select,y);
   input[31:0] i0,i1,i2,i3;
   input [1:0] select;
   output [31:0] y;
   reg [31:0] y;
   always @ (i0 or i1 or i2 or i3 or select) 
            case (select)
               2'b00: y = i0;
               2'b01: y = i1;
               2'b10: y = i2;
               2'b11: y = i3;
            endcase
endmodule
