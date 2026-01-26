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
    wire clk_1Hz;                  // 1 Hz timebase clock
    wire clk_display;              // Display refresh clock (~1 kHz)
    wire key0_debounced;           // Debounced start/pause button
    wire key1_debounced;           // Debounced reset button
    wire counting;                 // FSM output: counting active
    wire reset_timer;              // FSM output: reset timer
    wire [3:0] sec_ones;           // Ones digit of seconds
    wire [3:0] sec_tens;           // Tens digit of seconds
    wire [3:0] min_ones;           // Ones digit of minutes
    wire [3:0] min_tens;           // Tens digit of minutes
    wire [6:0] seg7_data;          // 7-segment output from driver
    wire [3:0] seg7_select;        // Segment select signals
    
    // Instantiate clock divider
    clock_divider u_clock_divider (
        .clk_50MHz(CLOCK_50),
        .rst_n(KEY[1]),            // Use KEY[1] (reset button) as active-low reset
        .clk_1Hz(clk_1Hz),
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
        .clk(clk_1Hz),
        .rst_n(KEY[1]),
        .enable(counting),
        .reset_counter(reset_timer),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens),
        .min_ones(min_ones),
        .min_tens(min_tens)
    );
    
    // Instantiate 7-segment driver
    seg7_driver u_seg7_driver (
        .clk(clk_display),
        .rst_n(KEY[1]),
        .digit0(sec_ones),
        .digit1(sec_tens),
        .digit2(min_ones),
        .digit3(min_tens),
        .seg7_out(seg7_data),
        .digit_select(seg7_select)
    );
    
    // Assign outputs - all displays show same data but selected by digit_select
    assign HEX0 = seg7_select[0] ? seg7_data : 7'b1111111;
    assign HEX1 = seg7_select[1] ? seg7_data : 7'b1111111;
    assign HEX2 = seg7_select[2] ? seg7_data : 7'b1111111;
    assign HEX3 = seg7_select[3] ? seg7_data : 7'b1111111;

endmodule
