`timescale 1ns/1ps

module currency_val_tb;

    // Parameters
    localparam CURRENCY_WIDTH = 7;

    // DUT Signals
    reg clk;
    reg rstn;
    reg [CURRENCY_WIDTH-1:0] currency_value;
    reg currency_valid;
    reg dispense_valid;
    wire [CURRENCY_WIDTH-1:0] total_currency;
    wire currency_avail;

    // Instantiate DUT
    currency_val #(.CURRENCY_WIDTH(CURRENCY_WIDTH)) dut (
        .clk(clk),
        .rstn(rstn),
        .currency_value(currency_value),
        .currency_valid(currency_valid),
        .dispense_valid(dispense_valid),
        .total_currency(total_currency),
        .currency_avail(currency_avail)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    // Stimulus
    initial begin
        $display("---- CURRENCY_VAL TEST START ----");

        // Initial state
        rstn = 0;
        currency_value = 0;
        currency_valid = 0;
        dispense_valid = 0;

        // Apply reset
        @(posedge clk);
        rstn = 1;
        @(posedge clk);
      $display("Test 1: Multiple currency insertions");
        // Insert currency 10
        currency_value = 7'd10;
        currency_valid = 1;
        @(posedge clk);
        currency_valid = 0;
        currency_value = 0;
        @(posedge clk); @(posedge clk); // allow sync
        $display("@%0t: Inserted 10 => total = %0d, avail = %b", 
                 $time, total_currency, currency_avail);

        // Insert currency 25
        currency_value = 7'd25;
        currency_valid = 1;
        @(posedge clk);
        currency_valid = 0;
        currency_value = 0;
        @(posedge clk); @(posedge clk);
        $display("@%0t: Inserted 25 => total = %0d, avail = %b", 
                 $time, total_currency, currency_avail);

        // Insert currency 30
        currency_value = 7'd30;
        currency_valid = 1;
        @(posedge clk);
        currency_valid = 0;
        currency_value = 0;
        @(posedge clk); @(posedge clk);
        $display("@%0t: Inserted 30 => total = %0d, avail = %b", 
                 $time, total_currency, currency_avail);

        // Dispense signal (reset currency)
        dispense_valid = 1;
        @(posedge clk);
        dispense_valid = 0;
        @(posedge clk);
        $display("@%0t: Dispense -> total = %0d, avail = %b", 
                 $time, total_currency, currency_avail);
      
      
      $display("Test 2: Single currency insertion (value=50)");
        // Insert currency 50
        currency_value = 7'd50;
        currency_valid = 1;
        @(posedge clk);
        currency_valid = 0;
        currency_value = 0;
        @(posedge clk); @(posedge clk);
        $display("@%0t: Inserted 50 => total = %0d, avail = %b", 
                 $time, total_currency, currency_avail);

        #20;
        $display("---- CURRENCY_VAL TEST END ----");
        $finish;
    end

endmodule
