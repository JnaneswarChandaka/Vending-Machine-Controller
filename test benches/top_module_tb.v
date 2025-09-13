//`timescale 1ns/1ps

module vending_machine_top_tb;

    // Parameters
    parameter ITEM_ADDR_WIDTH = 10;
    parameter CURRENCY_WIDTH  = 7;
    parameter MAX_ITEMS       = 1024;

    // Clock & Reset
    reg clk, rstn;
    reg pclk, prstn;

    // User Inputs
    reg [ITEM_ADDR_WIDTH-1:0] item_select;
    reg item_select_valid;
    reg [CURRENCY_WIDTH-1:0] currency_value;
    reg currency_valid;

    // APB Config Inputs
    reg cfg_mode;
    reg psel;
    reg pwrite;
    reg [14:0] paddr;
    reg [31:0] pwdata;

    wire [31:0] prdata;
    wire pready;

    // Outputs
    wire dispense_valid;
    wire [ITEM_ADDR_WIDTH-1:0] item_dispensed;
    wire [CURRENCY_WIDTH-1:0] currency_change;

    // Instantiate DUT
    vending_machine_top #(
        .ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH),
        .CURRENCY_WIDTH(CURRENCY_WIDTH),
        .MAX_ITEMS(MAX_ITEMS)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .cfg_mode(cfg_mode),
        .item_select(item_select),
        .item_select_valid(item_select_valid),
        .currency_value(currency_value),
        .currency_valid(currency_valid),
        .pclk(pclk),
        .prstn(prstn),
        .psel(psel),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .dispense_valid(dispense_valid),
        .item_dispensed(item_dispensed),
        .currency_change(currency_change)
    );

    // Clock Generation
    always #5 clk = ~clk;
    always #10 pclk = ~pclk;

    // Test Sequence
    initial begin
        // Init
        clk = 0; pclk = 0;
        rstn = 0; prstn = 0;
        cfg_mode = 1;
        item_select = 0;
        item_select_valid = 0;
        currency_value = 0;
        currency_valid = 0;
        psel = 0;
        pwrite = 0;
        paddr = 0;
        pwdata = 0;

        // Reset
        #20;
        rstn = 1;
        prstn = 1;

        // Step 1: Configure item #3 with price=30, count=5
        @(posedge pclk);
        psel = 1;
        pwrite = 1;
        paddr = 15'h04 + (3 << 2);  // address for item 3
      pwdata = {8'd3, 8'd5, 16'd30}; // avail_count=5, price=3
        @(posedge pclk);
        psel = 0;
        pwrite = 0;
        $display("CONFIG: Item 3 -> Price: %0d, Count: %0d", pwdata[15:0], pwdata[23:16]);

        // Step 2: Switch to normal mode
        @(posedge clk);
        cfg_mode = 0;

        // Step 3: Select item 3
        @(posedge clk);
        item_select = 3;
        item_select_valid = 1;
        @(posedge clk);
        item_select_valid = 0;

   
        $display("SELECT: item_selected = %0d | selection_valid = %b", dut.item_selected, dut.selection_valid);

      // Step 4: Insert currency (40)
	@(posedge clk);
	currency_value = 40;
	currency_valid = 1;
	@(posedge clk);
	currency_valid = 0;

        // Allow sync
        repeat (2) @(posedge clk);

        $display("CURRENCY: total_currency = %0d | currency_avail = %b", 
                  dut.total_currency, dut.currency_avail);

        // Step 5: Wait and observe FSM & memory outputs
        repeat (1) @(posedge clk);
        $display("MEM: item_price = %0d | avail_count = %0d", 
                  dut.item_price, dut.avail_count);

        $display("FSM: dispense_enable = %b", dut.dispense_enable);
	repeat (1) @(posedge clk);
        $display("LOGIC: dispense_valid = %b", dispense_valid);

        // Final check
        if (dispense_valid) begin
            $display("DISPENSED: Item = %0d | Change = %0d", item_dispensed, currency_change);
        end else begin
            $display("FAILED: No item dispensed.");
        end
	#100;
        $finish;
    end

initial begin
	$dumpvars();
	$dumpfile("dump.vcd");
end

endmodule
