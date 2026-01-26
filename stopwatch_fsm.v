// =============================================================================
// Stopwatch FSM
// Finite State Machine for stopwatch control: IDLE, RUN, PAUSE
// =============================================================================

module stopwatch_fsm (
    input wire clk,                // Clock input (1 Hz for state timing)
    input wire rst_n,              // Active-low reset
    input wire start_pause_btn,    // Start/Pause button (active-low)
    input wire reset_btn,          // Reset button (active-low)
    
    output reg counting,           // High when stopwatch is counting
    output reg reset_timer         // High to reset timer
);

    // State machine states
    localparam IDLE = 2'b00;
    localparam RUN = 2'b01;
    localparam PAUSE = 2'b10;
    
    reg [1:0] current_state, next_state;
    reg prev_start_pause;
    reg start_pause_edge;
    
    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            prev_start_pause <= 1'b1;
        end else begin
            current_state <= next_state;
            prev_start_pause <= start_pause_btn;
        end
    end
    
    // Edge detection for start/pause button
    always @(*) begin
        start_pause_edge = prev_start_pause & ~start_pause_btn;
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
        reset_timer = !reset_btn;
    end

endmodule
