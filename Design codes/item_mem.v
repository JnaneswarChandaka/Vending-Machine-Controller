module item_memory #(
    parameter MAX_ITEMS = 1024
)(
    input  wire clk,
    
    // Config interface
    input  wire we,   // Write enable (from config)
    input  wire [$clog2(MAX_ITEMS)-1:0] waddr,
    input  wire [7:0]  dispensed_item,   // Stored in [31:24]
    input  wire [7:0]  count,            // Stored in [23:16]
    input  wire [15:0] price,            // Stored in [15:0]
    
    // Dispense update interface
    input  wire dispense_valid,
  input  wire [$clog2(MAX_ITEMS)-1:0] dispensed_item_index,//the item just dispensed
    
    // Read interface
    input  wire [$clog2(MAX_ITEMS)-1:0] raddr,
    output reg [15:0] item_price,
    output reg [7:0]  avail_count,
    output reg [7:0]  stored_item_id
);

    reg [31:0] mem [0:MAX_ITEMS-1];
    reg [31:0] temp;

    // Write & dispense update logic
    always @(posedge clk) begin
        if (we) begin
            // Config write: load full item info
            mem[waddr] <= {dispensed_item, count, price};
        end else if (dispense_valid) begin
            // Dispense logic: safely update count
            temp = mem[dispensed_item_index];

            // Increment dispensed count (bits [31:24])
            temp[31:24] = temp[31:24] + 1;

            // Decrement available count (bits [23:16]), if not zero
            if (temp[23:16] > 0)
                temp[23:16] = temp[23:16] - 1;

            mem[dispensed_item_index] = temp;
        end
    end

    // Read logic
    always @(posedge clk) begin
        item_price     <= mem[raddr][15:0];   // Price
        avail_count    <= mem[raddr][23:16];  // Stock
        stored_item_id <= mem[raddr][31:24];  // Sales count (dispensed)
    end

endmodule
