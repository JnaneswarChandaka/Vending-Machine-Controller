module main_controller (
    input  wire clk,
    input  wire rstn,
    input  wire cfg_mode,
    input  wire selection_valid,
    input  wire currency_avail,
		input wire dispense_valid, //SAT Use item dispensed to stay in currency
    output reg  dispense_enable
);
parameter IDLE     = 2'b00;
parameter SELECTED = 2'b01;
parameter CURRENCY = 2'b10;

reg [1:0] current_state, next_state;




    // State register
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        dispense_enable = 0;

        if (cfg_mode) begin
            next_state = IDLE;  // FSM inactive during config
        end else begin
            case (current_state)
                IDLE: begin
                    if (selection_valid)
                        next_state = SELECTED;
                end
                SELECTED: begin
                    if (currency_avail)
                        next_state = CURRENCY;
                end
                CURRENCY: begin
										if (dispense_valid) begin
											next_state = IDLE;
											dispense_enable <= 'b0; //SAT
										end
										else begin
                      next_state = CURRENCY; //SAT stay in currency receiving mode until dispensed
                      dispense_enable = 1;
										end
                end
            endcase
        end
    end

endmodule
