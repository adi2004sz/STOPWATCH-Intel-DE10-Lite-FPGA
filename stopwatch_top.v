// =============================================================================
// Stopwatch for Intel DE10-Lite FPGA Board
// Top-level module
// =============================================================================

module stopwatch_top (
    // Clock input
    input wire CLOCK_50,           // 50 MHz clock
    
    // Key inputs (active-low)
    input wire [1:0] KEY,          // KEY[0] = Start/Pause, KEY[1] = Reset
    
    // 7-segment display outputs (active-low)
    output wire [6:0] HEX0,        // Ones of seconds
    output wire [6:0] HEX1,        // Tens of seconds  
    output wire [6:0] HEX2,        // Ones of minutes
    output wire [6:0] HEX3         // Tens of minutes
);

    // Internal signals
    wire clk_1Hz;                  // 1 Hz timebase clock
    wire clk_display;              // Display refresh clock (~1 kHz)
    
    // Instantiate clock divider
    clock_divider u_clock_divider (
        .clk_50MHz(CLOCK_50),
        .rst_n(KEY[1]),            // Use KEY[1] (reset button) as active-low reset
        .clk_1Hz(clk_1Hz),
        .clk_display(clk_display)
    );
    
    // For now, turn off all 7-segment displays (active-low, so set to 1)
    assign HEX0 = 7'b1111111;
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;

endmodule
