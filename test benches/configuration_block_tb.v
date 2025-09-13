
`timescale 1ns/1ps

module config_block_tb;

    // Parameters
    localparam MAX_ITEMS = 1024;

    // Signals
    reg               pclk;
    reg               prstn;
    reg               cfg_mode;
    reg               psel;
    reg               pwrite;
    reg  [14:0]       paddr;
    reg  [31:0]       pwdata;
    wire [31:0]       prdata;
    wire              pready;

    wire              mem_we;
    wire [$clog2(MAX_ITEMS)-1:0] mem_waddr;
    wire [31:0]       mem_wdata;
    wire [$clog2(MAX_ITEMS)-1:0] mem_raddr;
    reg  [31:0]       mem_rdata;

    // Simple memory model
    reg [31:0] memory [0:MAX_ITEMS-1];
    reg [31:0] mem_rdata_reg;
  reg [31:0] write_data[0:5];
   integer i;
   reg [32:0] my_addr;
    // Clock generation
    initial pclk = 0;
    always #10 pclk = ~pclk; // 50MHz clock

    // DUT instantiation                              /// REMOVED PRDATA from ports
    config_block #(
        .MAX_ITEMS(MAX_ITEMS)
    ) uut (
        .pclk(pclk),
        .prstn(prstn),
        .cfg_mode(cfg_mode),
        .psel(psel),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        
        .pready(pready),
        .mem_we(mem_we),
        .mem_waddr(mem_waddr),
        .mem_wdata(mem_wdata),
        .mem_raddr(mem_raddr),
        .mem_rdata(mem_rdata)
    );

    // Memory behavior
//     always @(posedge pclk) begin
//         if (mem_we)
//             memory[mem_waddr] <= mem_wdata;
//       else
//             mem_rdata_reg <= memory[mem_raddr];
//     end
//    assign mem_rdata = mem_rdata_reg;
  
  // WRITING
	always @(posedge pclk) begin
        if (mem_we)
       // @(posedge pclk)
            memory[mem_waddr] <= mem_wdata;
    end
  // READING
  always @(*) begin
       mem_rdata = memory[mem_raddr];
   end

    // APB Write task
    task apb_write(input [14:0] addr, input [31:0] data);
        begin
            @(posedge pclk);
            psel   = 1;
            pwrite = 1;
            paddr  = addr;
            pwdata = data;
            @(posedge pclk);
            while (!pready) @(posedge pclk);
            $display("WRITE @ %h = %h", addr, pwdata);
            psel   = 0;
            pwrite = 0;
            pwdata = 0;
          @(posedge pclk);
        end
    endtask

    // APB Read task
  task apb_read(input [14:0] addr, input [31:0] exp_data);
        begin
            @(posedge pclk);
            psel   = 1;
            pwrite = 0;
            paddr  = addr;
            @(posedge pclk);
            while (!pready) @(posedge pclk);
          if (prdata != exp_data) begin
            $display("ERROR: READ  @ %h = %h but expected is %h", addr, prdata, exp_data);
          end
          else begin
            $display("READ  @ %h = %h", addr, prdata);
          end
            psel   = 0;
            @(posedge pclk);
        end
    endtask
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end

    // Main Test Sequence
    initial begin
        // Initial values
        psel   = 0;
        pwrite = 0;
        cfg_mode = 0;
        paddr = 0;
        pwdata = 0;
        prstn = 0;



// Reset and release
        #25;
        prstn = 1;
      write_data[0] = 'hAAAA_BBBB;
      write_data[1] = 'h5555_3333;
      write_data[2] = 'hDEAD_BEEF;
      write_data[3] = 'h0BAD_0DAD;
      write_data[4] = 'hA5A5_5A5A;

        // Enable config mode (with synchronization delay)
        cfg_mode = 1;

        // Wait for synchronization to settle
        repeat(5) @(posedge pclk);
        
        // Write to 5 config items
        
     //for( i=0; i<5; i++)
      begin
        //reg [15:0] my_addr;
        my_addr = 'h4 + 0*4;
        apb_write(my_addr, write_data[0]);
        my_addr = 'h4 + 1*4;
        apb_write(my_addr, write_data[1]);
        my_addr = 'h4 + 2*4;
        apb_write(my_addr, write_data[2]);
        my_addr = 'h4 + 3*4;
        apb_write(my_addr, write_data[3]);
        my_addr = 'h4 + 4*4;
        apb_write(my_addr, write_data[4]);
      end
         repeat(5) @(posedge pclk);     
      //for ( i=0; i<5; i++)
       begin
        //reg [15:0] my_addr;
        my_addr = 'h4 + 0*4;
        apb_read(my_addr, write_data[0]);
        my_addr = 'h4 + 1*4;
        apb_read(my_addr, write_data[1]);
        my_addr = 'h4 + 2*4;
        apb_read(my_addr, write_data[2]);
        my_addr = 'h4 + 3*4;
        apb_read(my_addr, write_data[3]);
        my_addr = 'h4 + 4*4;
        apb_read(my_addr, write_data[4]);
      end
 
        // Finish test
        #50;
        $display("Test completed.");
        $finish;
    end

endmodule
