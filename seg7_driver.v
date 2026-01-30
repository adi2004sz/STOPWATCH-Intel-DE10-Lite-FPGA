// =============================================================================
// 7-Segment Driver Module
// Converts BCD digits to 7-segment patterns for static displays
// =============================================================================

module seg7_driver (
    input wire [3:0] digit0,       // HEX0 digit (tens of milliseconds)
    input wire [3:0] digit1,       // HEX1 digit (hundreds of milliseconds)
    input wire [3:0] digit2,       // HEX2 digit (ones of seconds)
    input wire [3:0] digit3,       // HEX3 digit (tens of seconds)
    
    output wire [6:0] seg0,        // HEX0 segment output (active-low)
    output wire [6:0] seg1,        // HEX1 segment output (active-low)
    output wire [6:0] seg2,        // HEX2 segment output (active-low)
    output wire [6:0] seg3         // HEX3 segment output (active-low)
);

    // BCD to 7-segment decoder function
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
    
    // Direct output for each display
    assign seg0 = bcd_to_seg7(digit0);
    assign seg1 = bcd_to_seg7(digit1);
    assign seg2 = bcd_to_seg7(digit2);
    assign seg3 = bcd_to_seg7(digit3);

endmodule
