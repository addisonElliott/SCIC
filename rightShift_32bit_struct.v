//////////////////////////////////////////////////////////////////////////////////
// File:    		rightShift_32bit_struct
// Description: 	Structural-level description of full adder and testbench
//////////////////////////////////////////////////////////////////////////////////
module rightShift_32bit_struct(input1,input2,answer);
	
	// set the size of the adder
	parameter N=32;
	
	// create structure
	input [N-1:0] input1,input2;
	output [N-1:0] answer;
	
	// register to h
	reg[N-1:0] r_reg;
		
	// create counter variable
	integer i;
		
	// iterate copies of full and half adder
	always @(*) 
		for(i=0;i<N;i=i+1) 
			begin: rightShift
			
			// move bits
			if (i<(N-input1))
				r_reg[i]<=input2[i+input1];
			// fill in empty spots		
			else
				r_reg[i]<=0;
		end

	
	assign answer=r_reg;
	
endmodule
	
