// =============================================================================
// Clock Divider for Stopwatch
// Generates 1 Hz timebase and display refresh clock from 50 MHz input
// =============================================================================

module clock_divider (
    input wire clk_50MHz,          // 50 MHz input clock
    input wire rst_n,              // Active-low reset
    
    output reg clk_1Hz,            // 1 Hz clock for stopwatch timebase
    output reg clk_display         // ~1 kHz clock for 7-segment display refresh
);

    // Parameters for clock division
    // 1 Hz: 50,000,000 / 50,000,000 = 1 Hz
    localparam DIVIDER_1HZ = 25_000_000;  // Count to 25M, then toggle = 1 Hz
    
    // Display refresh clock: ~1 kHz (actually 976 Hz with 50MHz / 25,800)
    localparam DIVIDER_DISPLAY = 25_800;  // Count to ~25.8k for ~976 Hz
    
    // Internal counters
    reg [31:0] counter_1Hz;
    reg [31:0] counter_display;

    // 1 Hz clock generation
    always @(posedge clk_50MHz or negedge rst_n) begin
        if (!rst_n) begin
            counter_1Hz <= 32'd0;
            clk_1Hz <= 1'b0;
        end else begin
            if (counter_1Hz >= DIVIDER_1HZ - 1) begin
                counter_1Hz <= 32'd0;
                clk_1Hz <= ~clk_1Hz;  // Toggle output
            end else begin
                counter_1Hz <= counter_1Hz + 1;
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
