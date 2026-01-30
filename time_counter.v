// =============================================================================
// Time Counter Module
// =============================================================================

module time_counter (
    input wire clk,                // 50 MHz clock input
    input wire rst_n,              // Active-low reset
    input wire clk_en,             // 1000 Hz clock enable
    input wire enable,             // Count enable (from FSM)
    input wire reset_counter,      // Synchronous reset
    
    output reg [3:0] ms_tens,      // 10ms digit (0-9), displayed on HEX0
    output reg [3:0] ms_hundreds,  // 100ms digit (0-9), displayed on HEX1
    output reg [3:0] sec_ones,     // Seconds ones (0-9), displayed on HEX2
    output reg [3:0] sec_tens      // Seconds tens (0-5), displayed on HEX3
);

    // Internal counter for 1ms units (0-9, not displayed)
    reg [3:0] ms_units;
    
    // Cascaded BCD counter logic - only advances on clock enable (1ms tick)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ms_units    <= 4'd0;
            ms_tens     <= 4'd0;
            ms_hundreds <= 4'd0;
            sec_ones    <= 4'd0;
            sec_tens    <= 4'd0;
        end else if (reset_counter) begin
            ms_units    <= 4'd0;
            ms_tens     <= 4'd0;
            ms_hundreds <= 4'd0;
            sec_ones    <= 4'd0;
            sec_tens    <= 4'd0;
        end else if (clk_en && enable) begin
            // Cascaded BCD counting: 1ms -> 10ms -> 100ms -> 1s -> 10s
            
            if (ms_units == 4'd9) begin
                ms_units <= 4'd0;
                
                if (ms_tens == 4'd9) begin
                    ms_tens <= 4'd0;
                    
                    if (ms_hundreds == 4'd9) begin
                        ms_hundreds <= 4'd0;
                        
                        if (sec_ones == 4'd9) begin
                            sec_ones <= 4'd0;
                            
                            if (sec_tens == 4'd5) begin
                                // Max reached (59.99 seconds), stop counting
                                sec_tens <= 4'd5;
                                sec_ones <= 4'd9;
                                ms_hundreds <= 4'd9;
                                ms_tens <= 4'd9;
                                ms_units <= 4'd9;
                            end else begin
                                sec_tens <= sec_tens + 4'd1;
                            end
                            
                        end else begin
                            sec_ones <= sec_ones + 4'd1;
                        end
                        
                    end else begin
                        ms_hundreds <= ms_hundreds + 4'd1;
                    end
                    
                end else begin
                    ms_tens <= ms_tens + 4'd1;
                end
                
            end else begin
                ms_units <= ms_units + 4'd1;
            end
        end
    end

endmodule
