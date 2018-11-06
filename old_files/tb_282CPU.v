// NOTE: OLD CODE FOR REFERENCE, NOT USED

//Stimulus for testing 
module tb;
  reg CLK,RST;  //inputs for circuit
  reg [3:0] switch;
  wire [3:0] led;    //output from circuit
  


  reg [7:0]              clk_count = 'd0;
// ======================================
// Counter of system clock ticks        
// ======================================
always @ ( posedge CLK )
    clk_count <= clk_count + 1'd1;

  system u_system (RST, CLK, led, switch);  // instantiate circuit
  initial
     begin
         RST = 1;
         CLK = 0;
          switch = 4'b0101;
      #3 CLK = 1;
      #3 CLK = 0;
      #4 RST = 0;
      repeat (128)
      #5 CLK = ~CLK;
     end
  initial
	  begin
      #250    switch = 4'b1101;
      #250    switch = 4'b0100;
     end
  initial #250 $finish; 	  
endmodule

