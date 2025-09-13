module output_logic_tb;

  // Parameters
  parameter CURRENCY_WIDTH = 7;
  parameter ITEM_ADDR_WIDTH = 10;

  // Signals
  reg clk;
  reg rstn;
  reg dispense_enable;
  reg [ITEM_ADDR_WIDTH-1:0] item_selected;
  reg [CURRENCY_WIDTH-1:0] total_currency;
  reg [15:0] item_price;
  reg [7:0] avail_count;

  wire dispense_valid;
  wire [ITEM_ADDR_WIDTH-1:0] item_dispensed;
  wire [CURRENCY_WIDTH-1:0] currency_change;

  // Instantiate the module
  output_logic #(
    .CURRENCY_WIDTH(CURRENCY_WIDTH),
    .ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
  ) uut (
    .clk(clk),
    .rstn(rstn),
    .dispense_enable(dispense_enable),
    .item_selected(item_selected),
    .total_currency(total_currency),
    .item_price(item_price),
    .avail_count(avail_count),
    .dispense_valid(dispense_valid),
    .item_dispensed(item_dispensed),
    .currency_change(currency_change)
  );

  // Clock generation (10 ns period)
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, output_logic_tb);

    clk = 0;
    rstn = 0;
    dispense_enable = 0;
    item_selected = 0;
    total_currency = 0;
    item_price = 0;
    avail_count = 0;

    // Reset
    #10 rstn = 1;

    //Case 1: Successful dispense
    item_selected = 10;
    total_currency = 50;
    item_price = 30;
    avail_count = 5;
    #10 dispense_enable = 1;
    #10 dispense_enable = 0;
    #10;

    //Case 2: Not enough money
    item_selected = 11;
    total_currency = 20;
    item_price = 30;
    avail_count = 5;
    #10 dispense_enable = 1;
    #10 dispense_enable = 0;
    #10;

    //Case 3: Item out of stock
    item_selected = 12;
    total_currency = 50;
    item_price = 30;
    avail_count = 0;
    #10 dispense_enable = 1;
    #10 dispense_enable = 0;
    #10;

    $finish;
  end

endmodule
