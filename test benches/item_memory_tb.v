`timescale 1ns/1ps

module item_memory_tb;

    localparam MAX_ITEMS = 1024;
    localparam ITEM_ADDR_WIDTH = $clog2(MAX_ITEMS);

    // DUT interface signals
    reg clk;
    reg we;
    reg dispense_valid;
    reg [ITEM_ADDR_WIDTH-1:0] waddr;
    reg [7:0] dispensed_item;
    reg [7:0] count;
    reg [15:0] price;
    wire [31:0] item_data_out;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT instance
    item_memory #(.MAX_ITEMS(MAX_ITEMS)) dut (
        .clk(clk),
        .we(we),
        .dispense_valid(dispense_valid),
        .waddr(waddr),
        .dispensed_item(dispensed_item),
        .count(count),
        .price(price),
        .item_data_out(item_data_out)
    );

    // Helper task to display item info
    task show_item_data(input [ITEM_ADDR_WIDTH-1:0] addr);
        begin
            waddr = addr;
            @(negedge clk); // wait for output to be updated
            $display("@%0t: ITEM[%0d] = {Dispensed: %0d, Count: %0d, Price: %0d}",
                     $time, addr, item_data_out[31:24], item_data_out[23:16], item_data_out[15:0]);
        end
    endtask

    // Test sequence
    initial begin
        $display("---- ITEM MEMORY TEST START ----");

        // Initialize
        we = 0;
        dispense_valid = 0;
        waddr = 0;
        dispensed_item = 0;
        count = 0;
        price = 0;

        @(negedge clk);

        // CONFIG: Item 3 -> Price: 30, Count: 2
        we = 1;
        waddr = 3;
        dispensed_item = 8'd0;  // initial dispensed count
        count = 8'd2;
        price = 16'd30;
        @(negedge clk);

        // CONFIG: Item 5 -> Price: 20, Count: 1
        waddr = 5;
        dispensed_item = 8'd0;
        count = 8'd1;
        price = 16'd20;
        @(negedge clk);

        we = 0;

        // Wait and read back values
        @(negedge clk); #1; show_item_data(3);
        @(negedge clk); #1; show_item_data(5);

        // DISPENSE: Item 3
        dispense_valid = 1;
        waddr = 3;
        @(negedge clk);
        dispense_valid = 0;
        @(negedge clk); #1; show_item_data(3);

        // DISPENSE: Item 5
        dispense_valid = 1;
        waddr = 5;
        @(negedge clk);
        dispense_valid = 0;
        @(negedge clk); #1; show_item_data(5);

        $display("---- ITEM MEMORY TEST DONE ----");
        $finish;
    end

endmodule
