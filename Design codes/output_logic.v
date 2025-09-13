// Code your design here
module output_logic #(
    parameter CURRENCY_WIDTH = 7,
    parameter ITEM_ADDR_WIDTH = 10
)(
    input  wire                        clk,
    input  wire                        rstn,

    // Trigger from FSM
    input  wire                        dispense_enable,

    // From input_block
    input  wire [ITEM_ADDR_WIDTH-1:0]  item_selected,
    input  wire [CURRENCY_WIDTH-1:0]   total_currency,

    // From memory
    input  wire [15:0] item_price,
    input  wire [7:0]  avail_count,

    // Outputs
    output reg                        dispense_valid,
    output reg  [ITEM_ADDR_WIDTH-1:0] item_dispensed,
    output reg  [CURRENCY_WIDTH-1:0]  currency_change
);

   always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dispense_valid   <= 0;
        item_dispensed   <= 0;
        currency_change  <= 0;
    end else begin
        dispense_valid <= 0;

        if (dispense_enable) begin
            if (avail_count > 0 && total_currency >= item_price) begin

                dispense_valid  <= 1;
                item_dispensed  <= item_selected;
                currency_change <= total_currency - item_price;
            end else begin
                dispense_valid  <= 0;
                item_dispensed  <= 0;
                currency_change <= total_currency;
            end
        end else begin
            item_dispensed <= 0;
        end
    end
end

endmodule
