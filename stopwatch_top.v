// =============================================================================
// Stopwatch Top-level Module
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
    output wire [6:0] HEX3,        // Segment outputs
    
    // LED status outputs
    output wire [9:0] LEDR         // LED status indicators
);

    // Internal signals
    wire en_1000Hz;                // 1000 Hz clock enable pulse
    wire en_display;               // Display/debounce clock enable (~1 kHz)
    wire key0_debounced;           // Debounced start/pause button
    wire reset_sync;               // Synchronized reset signal
    wire counting;                 // FSM output: counting active
    wire paused;                   // FSM output: paused state
    wire reset_timer;              // FSM output: reset timer
    wire [3:0] ms_tens;            // Tens digit of milliseconds
    wire [3:0] ms_hundreds;        // Hundreds digit of milliseconds
    wire [3:0] sec_ones;           // Ones digit of seconds
    wire [3:0] sec_tens;           // Tens digit of seconds
    
    // LED blink generator (2 Hz blink rate)
    reg [24:0] blink_counter;
    reg blink_state;
    wire max_time_reached;
    
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
        .reset_timer(reset_timer),
        .paused(paused)
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
    
    // Blink generator for running indicator (2 Hz = toggle every 12.5M cycles)
    always @(posedge CLOCK_50 or negedge reset_sync) begin
        if (!reset_sync) begin
            blink_counter <= 25'd0;
            blink_state <= 1'b0;
        end else begin
            if (blink_counter >= 25'd12_500_000) begin
                blink_counter <= 25'd0;
                blink_state <= ~blink_state;
            end else begin
                blink_counter <= blink_counter + 1;
            end
        end
    end
    
    // Max time detection (59.99 = sec_tens=5, sec_ones=9, ms_hundreds=9, ms_tens=9)
    assign max_time_reached = (sec_tens == 4'd5) && (sec_ones == 4'd9) && 
                              (ms_hundreds == 4'd9) && (ms_tens == 4'd9);
    
    // LED Status Indicators:
    // LEDR[0]   = Blinks when running (counting)
    // LEDR[1]   = Solid when paused
    // LEDR[9]   = On when max time reached (59.99)
    // LEDR[8:2] = Unused (off)
    assign LEDR[0] = counting & blink_state;    // Blink when running
    assign LEDR[1] = paused;                     // Solid when paused
    assign LEDR[8:2] = 7'b0;                     // Unused LEDs off
    assign LEDR[9] = max_time_reached;           // Max time indicator

endmodule
