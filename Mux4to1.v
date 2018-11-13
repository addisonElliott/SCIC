module Mux4to1 
        #(parameter data_width = 1)
        (output reg [data_width-1: 0] y, input [data_width-1: 0] in_0, in_1, in_2, in_3, input [1: 0] s);
    // On change of any input bits or select bits
    always @(in_0, in_1, in_2, in_3, s)
        // Switch select bit and redirect y output
        case (s) 
            2'b00: y <= in_0;
            2'b01: y <= in_1;
            2'b10: y <= in_2;
            2'b11: y <= in_3;
        endcase
endmodule