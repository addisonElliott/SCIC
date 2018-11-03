`timescale 1 ns / 1 ps

module system_tb();
    wire [3:0] LEDs;

    reg reset, clock;
    reg [3:0] switches;

    // UUT = Unit Under Test
    system UUT(LEDs, switches, reset, clock);

    initial begin
        reset <= 1'b1;
        clock <= 1'b0;
        switches <= 4'b0000;

        $dumpfile("system.vcd");
        $dumpvars(0, system_tb);

        forever begin
            // 5ns = 1/2 * period for 100MHz clock
            #5 clock <= ~clock;
        end
    end

    initial begin
        #7 reset <= 1'b0;
        #100 $finish();
    end
endmodule
