// =============================================================================
// 7-Segment Driver Module
// Multiplexes 4 7-segment displays and converts BCD to segment patterns
// =============================================================================

module seg7_driver (
    input wire clk,                // ~1 kHz display refresh clock
    input wire rst_n,              // Active-low reset
    input wire [3:0] digit0,       // HEX0 digit (ones of seconds)
    input wire [3:0] digit1,       // HEX1 digit (tens of seconds)
    input wire [3:0] digit2,       // HEX2 digit (ones of minutes)
    input wire [3:0] digit3,       // HEX3 digit (tens of minutes)
    
    output reg [6:0] seg7_out,     // 7-segment display output (active-low)
    output reg [3:0] digit_select  // Digit select (active-low)
);

    reg [1:0] mux_counter;
    
    // Multiplexer counter for digit selection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mux_counter <= 2'b00;
        end else begin
            mux_counter <= mux_counter + 1;
        end
    end
    
    // BCD to 7-segment decoder
    function [6:0] bcd_to_seg7;
        input [3:0] bcd;
        begin
            case (bcd)
                4'h0: bcd_to_seg7 = 7'b1000000;  // 0
                4'h1: bcd_to_seg7 = 7'b1111001;  // 1
                4'h2: bcd_to_seg7 = 7'b0100100;  // 2
                4'h3: bcd_to_seg7 = 7'b0110000;  // 3
                4'h4: bcd_to_seg7 = 7'b0011001;  // 4
                4'h5: bcd_to_seg7 = 7'b0010010;  // 5
                4'h6: bcd_to_seg7 = 7'b0000010;  // 6
                4'h7: bcd_to_seg7 = 7'b1111000;  // 7
                4'h8: bcd_to_seg7 = 7'b0000000;  // 8
                4'h9: bcd_to_seg7 = 7'b0010000;  // 9
                default: bcd_to_seg7 = 7'b1111111;  // All off
            endcase
        end
    endfunction
    
    // Multiplexer logic
    always @(*) begin
        digit_select = 4'b1111;  // All off by default
        
        case (mux_counter)
            2'b00: begin
                digit_select = 4'b1110;  // HEX0 selected
                seg7_out = bcd_to_seg7(digit0);
            end
            2'b01: begin
                digit_select = 4'b1101;  // HEX1 selected
                seg7_out = bcd_to_seg7(digit1);
            end
            2'b10: begin
                digit_select = 4'b1011;  // HEX2 selected
                seg7_out = bcd_to_seg7(digit2);
            end
            2'b11: begin
                digit_select = 4'b0111;  // HEX3 selected
                seg7_out = bcd_to_seg7(digit3);
            end
        endcase
    end

endmodule
