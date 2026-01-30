// =============================================================================
// Clock Divider Module
// =============================================================================

module clock_divider (
    input wire clk_50MHz,          // 50 MHz input clock
    input wire rst_n,              // Active-low reset
    
    output reg en_1000Hz,          // 1000 Hz enable pulse (one cycle wide)
    output reg en_display          // ~1 kHz enable pulse for display/debounce
);

    // Parameters for clock division
    // 1000 Hz: 50,000,000 / 50,000 = 1000 Hz (count to 50,000 for single pulse)
    localparam DIVIDER_1000HZ = 50_000;
    
    // Display refresh: ~1 kHz (50MHz / 50,000 = 1000 Hz)
    localparam DIVIDER_DISPLAY = 50_000;
    
    // Internal counters (16 bits is enough for counts up to 65535)
    reg [15:0] counter_1000Hz;
    reg [15:0] counter_display;

    // 1000 Hz enable pulse generation
    always @(posedge clk_50MHz or negedge rst_n) begin
        if (!rst_n) begin
            counter_1000Hz <= 16'd0;
            en_1000Hz <= 1'b0;
        end else begin
            if (counter_1000Hz >= DIVIDER_1000HZ - 1) begin
                counter_1000Hz <= 16'd0;
                en_1000Hz <= 1'b1;  // Single-cycle enable pulse
            end else begin
                counter_1000Hz <= counter_1000Hz + 1;
                en_1000Hz <= 1'b0;
            end
        end
    end

    // Display enable pulse generation (~1 kHz)
    always @(posedge clk_50MHz or negedge rst_n) begin
        if (!rst_n) begin
            counter_display <= 16'd0;
            en_display <= 1'b0;
        end else begin
            if (counter_display >= DIVIDER_DISPLAY - 1) begin
                counter_display <= 16'd0;
                en_display <= 1'b1;  // Single-cycle enable pulse
            end else begin
                counter_display <= counter_display + 1;
                en_display <= 1'b0;
            end
        end
    end

endmodule
