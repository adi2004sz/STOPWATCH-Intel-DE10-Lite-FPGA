// =============================================================================
// Time Counter Module
// Counts seconds and milliseconds, stores individual digits for display
// =============================================================================

module time_counter (
    input wire clk,                // 1000 Hz clock input
    input wire rst_n,              // Active-low reset
    input wire enable,             // Count enable (from FSM)
    input wire reset_counter,      // Synchronous reset
    
    output reg [3:0] ms_tens,      // Tens digit of milliseconds (0-9)
    output reg [3:0] ms_hundreds,  // Hundreds digit of milliseconds (0-9)
    output reg [3:0] sec_ones,     // Ones digit of seconds (0-9)
    output reg [3:0] sec_tens      // Tens digit of seconds (0-5)
);

    reg [15:0] total_milliseconds;
    wire [15:0] total_seconds;
    
    assign total_seconds = total_milliseconds / 1000;
    
    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            total_milliseconds <= 16'd0;
        end else if (reset_counter) begin
            total_milliseconds <= 16'd0;
        end else if (enable) begin
            // Increment milliseconds, max at 59:999 (59999 milliseconds)
            if (total_milliseconds < 16'd59999) begin
                total_milliseconds <= total_milliseconds + 1;
            end
        end
    end
    
    // Decode milliseconds into tens and hundreds
    always @(*) begin
        ms_tens = ((total_milliseconds % 1000) % 100) / 10;
        ms_hundreds = (total_milliseconds % 1000) / 100;
    end
    
    // Decode seconds into ones and tens
    always @(*) begin
        sec_ones = total_seconds % 10;
        sec_tens = total_seconds / 10;
    end

endmodule
