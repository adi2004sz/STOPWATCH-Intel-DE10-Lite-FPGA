// =============================================================================
// Time Counter Module
// Counts minutes and seconds, stores individual digits for display
// =============================================================================

module time_counter (
    input wire clk,                // 1 Hz clock input
    input wire rst_n,              // Active-low reset
    input wire enable,             // Count enable (from FSM)
    input wire reset_counter,      // Synchronous reset
    
    output reg [3:0] sec_ones,     // Ones digit of seconds (0-9)
    output reg [3:0] sec_tens,     // Tens digit of seconds (0-5)
    output reg [3:0] min_ones,     // Ones digit of minutes (0-9)
    output reg [3:0] min_tens      // Tens digit of minutes (0-9)
);

    reg [15:0] total_seconds;
    wire [15:0] total_minutes;
    
    assign total_minutes = total_seconds / 60;
    
    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            total_seconds <= 16'd0;
        end else if (reset_counter) begin
            total_seconds <= 16'd0;
        end else if (enable) begin
            // Increment seconds, max at 59:59 (3599 seconds)
            if (total_seconds < 16'd3599) begin
                total_seconds <= total_seconds + 1;
            end
        end
    end
    
    // Decode seconds into ones and tens
    always @(*) begin
        sec_ones = (total_seconds % 60) % 10;
        sec_tens = (total_seconds % 60) / 10;
    end
    
    // Decode minutes into ones and tens
    always @(*) begin
        min_ones = total_minutes % 10;
        min_tens = total_minutes / 10;
    end

endmodule
