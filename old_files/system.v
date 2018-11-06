module system
(
input        	brd_rst,
input			brd_clk,
output  [3:0]	led,
input   [3:0]	switch
);

wire   	[15:0]	addr;
wire		[31:0]	data_toCPU;
wire		[31:0]	data_fromCPU;
wire				we;
wire				sys_reset;

assign sys_reset = ~brd_rst;
assign sys_clock = brd_clk;

memoryIO_282 mem1(
	.data_out	( data_toCPU ),
	.data_in		( data_fromCPU ),
	.address		( addr ),
	.we			( we ),
	.clk			( sys_clock ),
	.io_in		(switch),
	.io_out		(led)
); 

core282 cpu (
    .clock     ( sys_clock ),
    .reset     ( sys_reset ),
    .address   ( addr ),
    .we        ( we ),
    .data_in   ( data_toCPU ),
    .data_out  ( data_fromCPU )
);

endmodule


module core282 ( input clock, input reset, output[15:0] address, output we,
			  input[31:0] data_in, output [31:0] data_out);

reg [15:0] pc;
reg [31:0] ir;
reg [31:0]	ac;
reg		f_ORe;


assign address = f_ORe ? ir[15:0] : pc ;	//address driven by PC for fetch, ...
assign we = f_ORe&(ir[31:28]==4'b0111);	//if execute and STORE opcode
assign data_out = ac;					//the data for STOREs

always@(posedge clock, negedge reset)
 if(reset==0) begin		//RESET operation
	f_ORe <=0;			//first clock out of reset will be fetch
	pc <= 4'h0000;		//start fetching from memory address 0
	end
 else   				//NORMAL operation
  begin
    if(f_ORe == 0) 		//FETCH
	begin
	   ir <= data_in;	//and data_in = mem(pc);
	   pc<=pc+1;
	   f_ORe <= 1;	//next clock will be execute
	end
    else				//EXECUTE
	begin
	   f_ORe <=0;	//next clock will be fetch
	   case(ir[31:28])
			4'b0101:	ac <= data_in;  	//and data_in =  mem(ir[15:0]);
			4'b0001:	ac <= ac + data_in;  	//and data_in =  mem(ir[15:0]);
//			4'b0010:	data_out <= ac;  	// mem(ir[15:0]) <= ac;  SEE ABOVE!
			4'b1000:	pc <= ir[15:0];
			//??	default: 
	   endcase
	end
  end
endmodule