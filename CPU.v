module CPU(output [31:0] data_out, output[15:0] address, output we, input[31:0] data_in, input reset, clock);
    // Define 16-bit program counter (PC), 32-bit instruction register (IR) and 32-bit ACcumulator (AC)
    reg [15:0] PC;
    reg [31:0] IR;
    reg [31:0] AC;
    
    // 1'b0 = Fetching next instruction
    // 1'b1 = Executing next instruction
    reg	fetch_or_execute;

    // Address is the PC for fetching (to get next instruction), otherwise IR is the address in case we are loading or saving data
    assign address = fetch_or_execute ? IR[15:0] : PC;

    // Enable write line when executing a store command (opcode = 4'b0111)
    assign we = fetch_or_execute & (IR[31:28] == 4'b0111);

    // Wire is only used when write enable (we) is high, when this happens we want to store the AC values
    assign data_out = AC;

    // instantiate full adder
    wire [31:0] adderOut;
    wire [31:0] adderIn1;
    wire [31:0] adderIn2;

    assign adderIn1=data_in;
    assign adderIn2=AC;

    fullAdder_32bit_struct fullAdder(adderIn1, adderIn2, adderOut);

    always @(posedge clock) begin
        // Active HIGH reset
        if (reset) begin
            // On reset, set to fetch initially and start fetching from 0 (PC=0)
            // set AC to 0 by default
            fetch_or_execute <= 0;
            PC <= 16'h0000;
            AC <= 32'd0;
        end
        else begin
            if (!fetch_or_execute) begin
                // Fetch next instruction
                // Load in the instruction to the IR and increment PC for next time
                IR <= data_in;
                PC <= PC + 1;
            end
            else begin
                // Execute instruction
                // 4 MSB of IR are the opcode
                case (IR[31:28])
                    // Add AC <= AC + mem(IR[15:0])
                   4'b0001: begin
                        AC <= adderOut;
//                        AC <= AC + data_in;
                   end

                    // Shift AC <= AC << mem(IR[15:0])
                    4'b0010: begin
                        AC <= AC << data_in;
                    end

                    // Shift AC <= AC >> mem(IR[15:0])
                    4'b0011: begin
                        AC <= AC >> data_in;
                    end

                    // Load AC immediate AC <= IR[15:0]
                    4'b0100: begin
                        AC <= {16'd0, IR[15:0]};
                    end
                    
                    // Load AC <= mem(IR[15:0])
                    4'b0101: begin
                        AC <= data_in;
                    end
                            
                    // AC <= AC | mem(IR[15:0])
                    4'b0110: begin
                        AC <= AC | data_in;
                    end

                    // Store mem(IR[15:0]) <= AC
                    4'b0111: begin
                        // Do nothing, the write enable line (we) will be set high
                        AC <= AC;
                    end

                    // Branch PC <= IR[15: 0]
                    4'b1000: begin 
                        PC <= IR[15:0];
                    end

                    // AC <= AC & mem(IR[15:0])
                    4'b1001: begin
                        AC <= AC & data_in;
                    end

                    // Default is to do nothing
                    default: AC <= AC;
                endcase
            end

            // Toggle the fetch_or_execute on each clock cycle
            // Fetch, Execute, Fetch, Execute, ...
            fetch_or_execute <= ~fetch_or_execute;
        end
    end
endmodule
