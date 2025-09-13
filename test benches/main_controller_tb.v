
// or browse Examples
`timescale 1ns / 1ps

module main_controller_tb;

  // Declare signals
  reg clk;
  reg rstn;
  reg cfg_mode;
  reg selection_valid;
  reg currency_avail;
  wire dispense_enable;

  // Instantiate the DUT
  main_controller uut (
    .clk(clk),
    .rstn(rstn),
    .cfg_mode(cfg_mode),
    .selection_valid(selection_valid),
    .currency_avail(currency_avail),
    .dispense_enable(dispense_enable)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Simulation
  initial begin

    $dumpfile("waveform.vcd");
    $dumpvars(0, main_controller_tb);

    clk = 0;
    rstn = 0;
    cfg_mode = 0;
    selection_valid = 0;
    currency_avail = 0;

    #10 rstn = 1;

    // CASE 1: Normal vending machine operation
    $display(" Normal operation: item selected, then currency inserted");
    selection_valid = 1;
    #10 selection_valid = 0;
    #5;
    currency_avail = 1;
    #10 currency_avail = 0;
    #5;
    $display("dispense_enable = %b", dispense_enable);

    // CASE 2: Selection but no coin
    $display(" Item selected but no coin inserted");
    selection_valid = 1;
    #10 selection_valid = 0;
    #30;
             $display("dispense_enable = %b", dispense_enable,);

    // CASE 3: Coin without selection
    $display("Coin inserted without selection");
    currency_avail = 1;
    #10 currency_avail = 0;
    #20;
    $display("dispense_enable = %b", dispense_enable,);

    // CASE 4: Config mode active
    $display("Config mode active, no dispense should occur");
    cfg_mode = 1;
    selection_valid = 1;
    currency_avail = 1;
    #10;
    selection_valid = 0;
    currency_avail = 0;
    #10;
    $display("dispense_enable = %b (cfg_mode active)", dispense_enable,);
    cfg_mode = 0;

    $display(" Simulation complete.");
    $finish;
  end

endmodule
