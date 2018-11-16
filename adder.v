module half_adder_1bit(output S, Cout, input x, y);
    xor G1(S, x, y);
    and G2(Cout, x, y);
endmodule

module full_adder_1bit(output S, Cout, input x, y, Cin);
    wire p, r, s;

    // Two XOR for computing Sum bit
    xor G1(p, x, y);
    xor G2(S, Cin, p);

    // Two AND for computing intermediate r,s, uses p from XOR
    and	G3(r, Cin, p);
    and	G4(s, x, y);

    // Compute Cout by ORing both AND results
    or G5(Cout, r, s);
endmodule

module ripple_carry_adder
        #(parameter data_width = 2)
        (output [data_width-1: 0] out, output Cout, input [data_width-1: 0] x, y, input Cin);
    // Size is 1 + size of result because last element contains carry out of MSB
    wire [data_width:0] carry;

    assign Cout = carry[data_width];
    assign carry[0] = Cin;

    // Generate 32, 1-bit ALUs
    genvar i;
    generate
    for (i = 0; i < data_width; i = i + 1) begin: M1
        full_adder_1bit FA_inst(out[i], carry[i + 1], x[i], y[i], carry[i]);
    end
    endgenerate
endmodule

