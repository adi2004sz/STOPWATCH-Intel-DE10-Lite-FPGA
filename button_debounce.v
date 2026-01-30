// =============================================================================
// Button Debounce Module
// =============================================================================

module button_debounce (
    input wire clk,                // 50 MHz clock input
    input wire rst_n,              // Active-low reset
    input wire clk_en,             // Clock enable (~1 kHz rate)
    input wire button_in,          // Raw button input (active-low)
    
    output reg button_out          // Debounced button output (active-low)
);

    // Debounce time: 20ms at 1kHz enable rate = 20 enable cycles
    localparam DEBOUNCE_COUNT = 20;
    
    reg [4:0] debounce_counter;
    reg button_sync1, button_sync2;
    
    // Synchronize input with double flip-flop to avoid metastability
    // This runs at full 50 MHz for best metastability protection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            button_sync1 <= 1'b1;
            button_sync2 <= 1'b1;
        end else begin
            button_sync1 <= button_in;
            button_sync2 <= button_sync1;
        end
    end
    
    // Debounce logic - only advances when clock enable is active
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            debounce_counter <= 5'd0;
            button_out <= 1'b1;
        end else if (clk_en) begin
            if (button_sync2 != button_out) begin
                // Button state is different from output, start counting
                debounce_counter <= debounce_counter + 1;
                if (debounce_counter >= DEBOUNCE_COUNT - 1) begin
                    button_out <= button_sync2;
                    debounce_counter <= 5'd0;
                end
            end else begin
                // Button state is stable
                debounce_counter <= 5'd0;
            end
        end
    end

endmodule
