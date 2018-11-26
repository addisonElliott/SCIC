module io_controller(output reg [31:0] data_out, output reg [3:0] io_out, input [31:0] data_in, input [4:0] address, input [3:0] io_in, input chip_select, we, clock);
    always @(posedge clock) begin
        // Only do stuff when this chip is selected
        if (chip_select) begin
            // If write enabled is set, then write to io_out, otherwise read from io_in
            if (we) begin
                // Switch the address value
                case (address)
                    // Write to LEDs
                    4'b0000: begin
                        io_out <= data_in[3:0];
                    end

                    default: io_out <= 4'dx;
                endcase
            end
            else begin
                // Switch the address value
                case (address)
                    // Read from switches
                    4'b0000: begin
                        data_out <= {28'd0, io_in};
                    end

                    default: data_out <= 32'bx;
                endcase
            end
        end
        else begin
            // data_out is high impedance state when not selected
            data_out <= 32'bx;
        end
    end
endmodule
