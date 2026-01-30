// =============================================================================
// Stopwatch FSM Module
// =============================================================================

module stopwatch_fsm (
    input wire clk,                // 50 MHz clock input
    input wire rst_n,              // Active-low reset
    input wire clk_en,             // Clock enable (~1 kHz rate)
    input wire start_pause_btn,    // Start/Pause button (active-low, debounced)
    input wire reset_btn,          // Reset button (active-low)
    
    output reg counting,           // High when stopwatch is counting
    output reg reset_timer,        // High to reset timer
    output reg paused              // High when stopwatch is paused
);

    // State machine states
    localparam IDLE = 2'b00;
    localparam RUN = 2'b01;
    localparam PAUSE = 2'b10;
    
    reg [1:0] current_state, next_state;
    reg prev_start_pause;
    wire start_pause_edge;
    
    // Edge detection for start/pause button (active-low, so detect falling edge)
    assign start_pause_edge = prev_start_pause & ~start_pause_btn;
    
    // State register - only updates on clock enable
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            prev_start_pause <= 1'b1;
        end else if (clk_en) begin
            current_state <= next_state;
            prev_start_pause <= start_pause_btn;
        end
    end
    
    // State transition logic
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (start_pause_edge)
                    next_state = RUN;
            end
            RUN: begin
                if (start_pause_edge)
                    next_state = PAUSE;
            end
            PAUSE: begin
                if (start_pause_edge)
                    next_state = RUN;
            end
            default:
                next_state = IDLE;
        endcase
        
        // Reset takes priority
        if (!reset_btn)
            next_state = IDLE;
    end
    
    // Output logic
    always @(*) begin
        counting = (current_state == RUN);
        paused = (current_state == PAUSE);
        reset_timer = !reset_btn;
    end

endmodule
