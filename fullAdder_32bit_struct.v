//////////////////////////////////////////////////////////////////////////////////
// File:    		fullAdder_32bit_struct
// Description: 	Structural-level description of full adder and testbench
//////////////////////////////////////////////////////////////////////////////////
module fullAdder_32bit_struct(input1,input2,answer);
	// set the size of the adder
	parameter N=32;

	// create structure
	input [N-1:0] input1,input2;
	output [N-1:0] answer;
	wire  carry_out;
	wire [N-1:0] carry;
	
	// create counter variable
	genvar i;
	
	// iterate copies of full and half adder
	generate 
	for(i=0;i<N;i=i+1)
		begin: generate_32_bit_Adder
			// half adder for first bit
			if(i==0) 
				half_adder f(input1[0],input2[0],answer[0],carry[0]);
			
			// full adder for all other bits
			else
				full_adder f(input1[i],input2[i],carry[i-1],answer[i],carry[i]);
				end
  
		assign carry_out = carry[N-1];
	endgenerate

endmodule 

// Verilog code for half adder##########################################################
module half_adder(x,y,s,c);
   
   // create variables
   input x,y;
   output s,c;
   
   // perform addition
   assign s=x^y; // reduction XOR for each bit
   assign c=x&y;
   
endmodule // half adder

// Verilog code for full adder ############################################################
module full_adder(x,y,c_in,s,c_out);
	// create variables
	input x,y,c_in;
	output s,c_out;
	
	// perform addition
	assign s = (x^y) ^ c_in;
	assign c_out = (y&c_in)| (x&y) | (x&c_in);

endmodule // full_adder

/*
// Testbench Verilog code for 16-bit Adder ################################################### 
module tb_16_bit_adder;
	// Inputs
	reg [31:0] input1;
	reg [31:0] input2;
	
	// Outputs
	wire [31:0] answer;

 // Instantiate the Unit Under Test (UUT)
 fullAdder_16bit_struct UUT 
 (
  .input1(input1), 
  .input2(input2), 
  .answer(answer)
 );

 initial begin
  // Initialize Inputs
  input1 = 1000;
  input2 = 5678;
  #100;
  
 end
      
endmodule
*/