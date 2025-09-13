module vending_machine_top #(
    parameter ITEM_ADDR_WIDTH = 10,
    parameter CURRENCY_WIDTH  = 7,
    parameter MAX_ITEMS       = 1024
)(
    input  wire clk,
    input  wire rstn,
    input  wire cfg_mode,

    // User inputs
    input  wire [ITEM_ADDR_WIDTH-1:0] item_select,
    input  wire item_select_valid,
    input  wire [CURRENCY_WIDTH-1:0] currency_value,
    input  wire currency_valid,

    // APB Config Interface
    input  wire pclk,
    input  wire prstn,
    input  wire psel,
    input  wire pwrite,
    input  wire [14:0] paddr,
    input  wire [31:0] pwdata,
    output wire [31:0] prdata,
    output wire pready,

    // Output to user
    output wire dispense_valid,
    output wire [ITEM_ADDR_WIDTH-1:0] item_dispensed,
    output wire [CURRENCY_WIDTH-1:0] currency_change
);

    // Internal signals
    wire [ITEM_ADDR_WIDTH-1:0] item_selected;
    wire selection_valid;
    wire currency_avail;
    wire [CURRENCY_WIDTH-1:0] total_currency;
    wire dispense_enable;

    wire [$clog2(MAX_ITEMS)-1:0] mem_waddr, mem_raddr;
    wire [31:0] mem_wdata, mem_rdata;
    wire mem_we;

    wire [15:0] item_price;
    wire [7:0]  avail_count;
    wire [7:0]  stored_item_id;

    // item_select
    item_select #(
        .ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
    ) u_item_select (
        .clk(clk),
        .rstn(rstn),
        .item_select(item_select),
        .item_select_valid(item_select_valid),
        .item_selected(item_selected),
        .selection_valid(selection_valid)
    );

    // currency_val
    currency_val #(
        .CURRENCY_WIDTH(CURRENCY_WIDTH)
    ) u_currency_val (
        .clk(clk),
        .rstn(rstn),
        .currency_value(currency_value),
        .currency_valid(currency_valid),
        .total_currency(total_currency),
				.dispense_valid(dispense_valid),
        .currency_avail(currency_avail)
    );

    // main_controller
    main_controller u_main_controller (
        .clk(clk),
        .rstn(rstn),
        .cfg_mode(cfg_mode),
        .selection_valid(selection_valid),
        .currency_avail(currency_avail),
				.dispense_valid(dispense_valid),
        .dispense_enable(dispense_enable)
    );

    // config_block
    config_block #(
        .MAX_ITEMS(MAX_ITEMS)
    ) u_config_block (
        .pclk(pclk),
        .prstn(prstn),
        .cfg_mode(cfg_mode),
        .psel(psel),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .mem_we(mem_we),
        .mem_waddr(mem_waddr),
        .mem_wdata(mem_wdata),
        .mem_raddr(mem_raddr),
        .mem_rdata(mem_rdata)
    );

    // item_memory
    item_memory #(
        .MAX_ITEMS(MAX_ITEMS)
    ) u_item_memory (
        .clk(clk),
        .we(mem_we),
        .waddr(mem_waddr),
        .dispensed_item(mem_wdata[31:24]),
        .count(mem_wdata[23:16]),
        .price(mem_wdata[15:0]),
        .dispense_valid(dispense_valid),
        .dispensed_item_index(item_dispensed),
        .raddr(item_selected),
        .item_price(item_price),
        .avail_count(avail_count),
        .stored_item_id()
    );

    // output_logic
    output_logic #(
        .CURRENCY_WIDTH(CURRENCY_WIDTH),
        .ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
    ) u_output_logic (
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

endmodule
