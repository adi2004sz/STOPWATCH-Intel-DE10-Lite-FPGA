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
    wire en_1000Hz;                // 1000 Hz clock enable pulse
    wire en_display;               // Display/debounce clock enable (~1 kHz)
    wire key0_debounced;           // Debounced start/pause button
    wire reset_sync;               // Synchronized reset signal
    wire counting;                 // FSM output: counting active
    wire reset_timer;              // FSM output: reset timer
    wire [3:0] ms_tens;            // Tens digit of milliseconds
    wire [3:0] ms_hundreds;        // Hundreds digit of milliseconds
    wire [3:0] sec_ones;           // Ones digit of seconds
    wire [3:0] sec_tens;           // Tens digit of seconds
    
    // Reset synchronizer - synchronize KEY[1] to avoid metastability
    // No debouncing needed for reset - it's acceptable for reset to be immediate
    reg reset_sync1, reset_sync2;
    always @(posedge CLOCK_50) begin
        reset_sync1 <= KEY[1];
        reset_sync2 <= reset_sync1;
    end
    assign reset_sync = reset_sync2;
    
    // Instantiate clock divider - generates enable pulses, not clock signals
    clock_divider u_clock_divider (
        .clk_50MHz(CLOCK_50),
        .rst_n(reset_sync),
        .en_1000Hz(en_1000Hz),
        .en_display(en_display)
    );
    
    // Debounce start/pause button - uses 50 MHz clock with enable
    button_debounce u_debounce_key0 (
        .clk(CLOCK_50),
        .rst_n(reset_sync),
        .clk_en(en_display),
        .button_in(KEY[0]),
        .button_out(key0_debounced)
    );
    
    // Note: Reset button (KEY[1]) is now synchronized but not debounced
    // This is intentional - reset should be immediate and doesn't need debouncing
    
    // Instantiate stopwatch FSM - uses 50 MHz clock with enable
    stopwatch_fsm u_fsm (
        .clk(CLOCK_50),
        .rst_n(reset_sync),
        .clk_en(en_display),
        .start_pause_btn(key0_debounced),
        .reset_btn(reset_sync),        // Use synchronized reset directly
        .counting(counting),
        .reset_timer(reset_timer)
    );
    
    // Instantiate time counter - uses 50 MHz clock with 1000 Hz enable
    time_counter u_time_counter (
        .clk(CLOCK_50),
        .rst_n(reset_sync),
        .clk_en(en_1000Hz),
        .enable(counting),
        .reset_counter(reset_timer),
        .ms_tens(ms_tens),
        .ms_hundreds(ms_hundreds),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens)
    );
    
    // Instantiate 7-segment driver (static displays, no multiplexing)
    seg7_driver u_seg7_driver (
        .digit0(ms_tens),          // HEX0: Milliseconds tens
        .digit1(ms_hundreds),      // HEX1: Milliseconds hundreds
        .digit2(sec_ones),         // HEX2: Seconds ones
        .digit3(sec_tens),         // HEX3: Seconds tens
        .seg0(HEX0),
        .seg1(HEX1),
        .seg2(HEX2),
        .seg3(HEX3)
    );

endmodule
