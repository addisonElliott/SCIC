//////////////////////////////////////////////////////////////////////////////////
// File:    		leftShift_32bit_struct
// Description: 	Structural-level description of left shift
//////////////////////////////////////////////////////////////////////////////////
module leftShift_32bit_struct(input1,input2,answer);
	
	// set the size of the adder
	parameter N=32;
	
	// create structure
	input [N-1:0] input1,input2;
	output [N-1:0] answer;
	
	// register to hold values
	reg[N-1:0] r_reg;
		
	// create counter variable
	integer i;
		
	// loop to shift left
	always @(*) 
		for(i=0;i<N;i=i+1) 
			begin: leftShift
		
			// fill in empty spots				
			if (i<input1)
				r_reg[i]<=0;
			
			// move bits
			else
				r_reg[i]<=input2[i-input1];						
		end
	
	assign answer=r_reg;
	
endmodule
	
