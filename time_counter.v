// =============================================================================
// Time Counter Module
// Counts seconds and centiseconds, stores individual digits for display
// =============================================================================

module time_counter (
    input wire clk,                // 100 Hz clock input
    input wire rst_n,              // Active-low reset
    input wire enable,             // Count enable (from FSM)
    input wire reset_counter,      // Synchronous reset
    
    output reg [3:0] cs_ones,      // Ones digit of centiseconds (0-9)
    output reg [3:0] cs_tens,      // Tens digit of centiseconds (0-9)
    output reg [3:0] sec_ones,     // Ones digit of seconds (0-9)
    output reg [3:0] sec_tens      // Tens digit of seconds (0-5)
);

    reg [15:0] total_centiseconds;
    wire [15:0] total_seconds;
    
    assign total_seconds = total_centiseconds / 100;
    
    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            total_centiseconds <= 16'd0;
        end else if (reset_counter) begin
            total_centiseconds <= 16'd0;
        end else if (enable) begin
            // Increment centiseconds, max at 59:99 (5999 centiseconds)
            if (total_centiseconds < 16'd5999) begin
                total_centiseconds <= total_centiseconds + 1;
            end
        end
    end
    
    // Decode centiseconds into ones and tens
    always @(*) begin
        cs_ones = (total_centiseconds % 100) % 10;
        cs_tens = (total_centiseconds % 100) / 10;
    end
    
    // Decode seconds into ones and tens
    always @(*) begin
        sec_ones = total_seconds % 10;
        sec_tens = total_seconds / 10;
    end

endmodule
