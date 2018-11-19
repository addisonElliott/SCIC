module ROM(output reg [31:0] data_out, input [4:0] address, input chip_select);
    // When address changes, set data_out to new value in memory
    always @(chip_select or address) begin
        // Memory values listed below are in hexadecimal
        // Instruction format for CPU is as follows:
        //      31----28------------16-15----------------0
        //       Opcode    Unused            Operand
        //
        // Opcodes:
        //      1     Add to AC
        //      2     Shift AC Left
        //      3     Shift AC Right
        //      4     Load immediate to AC
        //      5     Load AC
        //      6     Bitwise OR of AC
        //      7     Store
        //      8     Branch
        //      9     Bitwise AND of AC
        //
        case (address)
            // Program that tests all instructions
            // ------------------------------------------------------------
            // Test the store to ROM and add to AC
            5'h00: data_out <= 32'h4000_000f;   // LI 000f
            5'h01: data_out <= 32'h7000_005f;   // ST 005f
            5'h02: data_out <= 32'h4000_0001;   // LI 0001
            5'h03: data_out <= 32'h1000_005f;   // ADD 005f
            // Result (AC) should be 10

            // Test the shift left (SL)
            5'h04: data_out <= 32'h4000_0001;   // LI 0001
            5'h05: data_out <= 32'h7000_005f;   // ST 005f
            5'h06: data_out <= 32'h4000_ffff;   // LI ffff
            5'h07: data_out <= 32'h2000_005f;   // SL 005f
            // Result (AC) should be 1fffe

            // Test the shift right (SR)
            5'h08: data_out <= 32'h4000_0001;   // LI 0001
            5'h09: data_out <= 32'h7000_005f;   // ST 005f
            5'h0A: data_out <= 32'h4000_ffff;   // LI ffff
            5'h0B: data_out <= 32'h3000_005f;   // SR 005f
            // Result (AC) should be 7fff

            // Test the bitwise OR
            5'h0C: data_out <= 32'h4000_f0f0;   // LI f0f0
            5'h0D: data_out <= 32'h7000_005f;   // ST 005f
            5'h0E: data_out <= 32'h4000_0000;   // LI 0000
            5'h0F: data_out <= 32'h6000_005f;   // OR 005f
            // Result (AC) should be f0f0

            // Test the bitwise AND
            5'h10: data_out <= 32'h4000_0f0f;   // LI 0f0f
            5'h11: data_out <= 32'h7000_005f;   // ST 005f
            5'h12: data_out <= 32'h4000_00f0;   // LI 00f0
            5'h13: data_out <= 32'h9000_005f;   // AND 005f
            // Result (AC) should be 00000
            
            5'h14: data_out <= 32'h5000_0017;   // LD 0017
            5'h15: data_out <= 32'h5000_005f;   // LD 005f
            5'h16: data_out <= 32'h8000_0000;   // BR 0

            // Constants
            5'h17: data_out <= 32'h0000_002A;
            // ------------------------------------------------------------

            // Program that reads from switches and writes to LEDs repeatedly
            // ------------------------------------------------------------
            // 5'h00: data_out <= 32'h5000_0020    // LD 20
            // 5'h01: data_out <= 32'h7000_0020    // ST 20
            // 5'h02: data_out <= 32'h8000_0000    // BR 0
            // ------------------------------------------------------------

            // Program that adds 16 to accumulator over and over forever
            // ------------------------------------------------------------
            // 5'h00: data_out <= 32'h4000_0010 // LI 10
            // 5'h01: data_out <= 32'h7000_005F // ST 005F
            // 5'h02: data_out <= 32'h1000_005F // ADD 005F
            // 5'h03: data_out <= 32'h8000_0003 // BR 3
            // ------------------------------------------------------------

            default: data_out <= 32'h0000_0000; // NOP
        endcase
    end
endmodule
