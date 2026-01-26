// =============================================================================
// Clock Divider for Stopwatch
// Generates 1 Hz timebase and display refresh clock from 50 MHz input
// =============================================================================

module clock_divider (
    input wire clk_50MHz,          // 50 MHz input clock
    input wire rst_n,              // Active-low reset
    
    output reg clk_100Hz,          // 100 Hz clock for centisecond timebase
    output reg clk_display         // ~1 kHz clock for 7-segment display refresh
);

    // Parameters for clock division
    // 100 Hz: 50,000,000 / 500,000 = 100 Hz
    localparam DIVIDER_100HZ = 250_000;  // Count to 250k, then toggle = 100 Hz
    
    // Display refresh clock: ~1 kHz (actually 976 Hz with 50MHz / 25,800)
    localparam DIVIDER_DISPLAY = 25_800;  // Count to ~25.8k for ~976 Hz
    
    // Internal counters
    reg [31:0] counter_100Hz;
    reg [31:0] counter_display;

    // 100 Hz clock generation
    always @(posedge clk_50MHz or negedge rst_n) begin
        if (!rst_n) begin
            counter_100Hz <= 32'd0;
            clk_100Hz <= 1'b0;
        end else begin
            if (counter_100Hz >= DIVIDER_100HZ - 1) begin
                counter_100Hz <= 32'd0;
                clk_100Hz <= ~clk_100Hz;  // Toggle output
            end else begin
                counter_100Hz <= counter_100Hz + 1;
            end
        end
    end

    // Display refresh clock generation (~1 kHz)
    always @(posedge clk_50MHz or negedge rst_n) begin
        if (!rst_n) begin
            counter_display <= 32'd0;
            clk_display <= 1'b0;
        end else begin
            if (counter_display >= DIVIDER_DISPLAY - 1) begin
                counter_display <= 32'd0;
                clk_display <= ~clk_display;  // Toggle output
            end else begin
                counter_display <= counter_display + 1;
            end
        end
    end

endmodule
