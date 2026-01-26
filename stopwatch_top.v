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
    output wire [6:0] HEX0,        // Segment outputs
    output wire [6:0] HEX1,        // Segment outputs
    output wire [6:0] HEX2,        // Segment outputs
    output wire [6:0] HEX3         // Segment outputs
);

    // Internal signals
    wire clk_100Hz;                // 100 Hz timebase clock
    wire clk_display;              // Display refresh clock (~1 kHz)
    wire key0_debounced;           // Debounced start/pause button
    wire key1_debounced;           // Debounced reset button
    wire counting;                 // FSM output: counting active
    wire reset_timer;              // FSM output: reset timer
    wire [3:0] cs_ones;            // Ones digit of centiseconds
    wire [3:0] cs_tens;            // Tens digit of centiseconds
    wire [3:0] sec_ones;           // Ones digit of seconds
    wire [3:0] sec_tens;           // Tens digit of seconds
    
    // Instantiate clock divider
    clock_divider u_clock_divider (
        .clk_50MHz(CLOCK_50),
        .rst_n(KEY[1]),            // Use KEY[1] (reset button) as active-low reset
        .clk_100Hz(clk_100Hz),
        .clk_display(clk_display)
    );
    
    // Debounce start/pause button
    button_debounce u_debounce_key0 (
        .clk(clk_display),
        .rst_n(KEY[1]),
        .button_in(KEY[0]),
        .button_out(key0_debounced)
    );
    
    // Debounce reset button
    button_debounce u_debounce_key1 (
        .clk(clk_display),
        .rst_n(KEY[1]),
        .button_in(KEY[1]),
        .button_out(key1_debounced)
    );
    
    // Instantiate stopwatch FSM
    stopwatch_fsm u_fsm (
        .clk(clk_display),
        .rst_n(KEY[1]),
        .start_pause_btn(key0_debounced),
        .reset_btn(key1_debounced),
        .counting(counting),
        .reset_timer(reset_timer)
    );
    
    // Instantiate time counter
    time_counter u_time_counter (
        .clk(clk_100Hz),
        .rst_n(KEY[1]),
        .enable(counting),
        .reset_counter(reset_timer),
        .cs_ones(cs_ones),
        .cs_tens(cs_tens),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens)
    );
    
    // Instantiate 7-segment driver (static displays, no multiplexing)
    seg7_driver u_seg7_driver (
        .digit0(cs_ones),          // HEX0: Centiseconds ones
        .digit1(cs_tens),          // HEX1: Centiseconds tens
        .digit2(sec_ones),         // HEX2: Seconds ones
        .digit3(sec_tens),         // HEX3: Seconds tens
        .seg0(HEX0),
        .seg1(HEX1),
        .seg2(HEX2),
        .seg3(HEX3)
    );

endmodule
