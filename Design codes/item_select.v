// Code your design here
//item select
module item_select #(
parameter ITEM_ADDR_WIDTH =10  //the bit width of item_addr
)
(
input  wire clk,   //clk signal
input wire rstn,   //active low signal
input wire [ITEM_ADDR_WIDTH-1:0] item_select,  //the item address to be selected
input wire item_select_valid,       //indicates when item_select is valid
output reg [ITEM_ADDR_WIDTH-1:0] item_selected,  //holds the value of item_select when it's valid
output reg selection_valid   //flag indicating that the selection was successfully registered
);
always @(posedge clk or negedge rstn) 
   begin
        if (!rstn) //it clears both outputs
        begin
           item_selected <= 0;
            selection_valid <= 0;
        end 
        else begin
            if (item_select_valid)begin   //if item_select_valid is high ,it latches the value and sets selection_valid
                item_selected <= item_select;
                selection_valid <= 1;
            end 
            else begin     //otherwise, selection_ready is cleared
                selection_valid <= 0;
            end
        end
    end
endmodule
