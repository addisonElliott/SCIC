module half_adder_1bit(output S, Cout, input x, y, Cin);
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