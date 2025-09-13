
`timescale 1ns/1ps

module item_select_tb();
    // Parameters
    parameter ITEM_ADDR_WIDTH = 10;
    
    // Inputs
    reg clk;
    reg rstn;
    reg [ITEM_ADDR_WIDTH-1:0] item_select;
    reg item_select_valid;
    
    // Outputs
    wire [ITEM_ADDR_WIDTH-1:0] item_selected;
    wire selection_valid;
    
    // Instantiate the Unit Under Test (UUT)
    item_select #(
        .ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .item_select(item_select),
        .item_select_valid(item_select_valid),
        .item_selected(item_selected),
        .selection_valid(selection_valid)
    );
    
    // Clock generation
    always #10 clk=~clk;
    
    // Test procedure
    initial begin
        // Initialize inputs
        clk=0;
        rstn = 0;
        item_select = 0;
        item_select_valid = 0;
        
        // Reset the system
        #20;
        rstn = 1;
        #10;
        
        // Test case 1: Normal operation with valid selection
        $display("Test case 1: Normal operation with valid selection");
        item_select = 10'h123;
        item_select_valid = 1;
        #10;
        item_select_valid = 0;
        #50;
        // Test case 2: Multiple back-to-back selections
      $display("Test case 2: Multiple back-to-back selections");
        item_select = 10'h001;
        item_select_valid = 1;
        #40;
        item_select = 10'h002;
         item_select_valid = 1;
         #10;
        item_select_valid = 0;
        #40;
       
      $display("Both cases are passed successfully!");
        $finish;
    end
    
    // Monitor to track signals
    initial begin
      $monitor("Time = %0t: rstn=%b, item_select=%h, valid=%b | dispensed=%h, sel_valid=%b",
                 $time, rstn, item_select, item_select_valid, item_selected, selection_valid);
    end
  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(1);
end
endmodule
