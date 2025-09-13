
 module config_block #(
    parameter MAX_ITEMS = 1024
)(
    input  wire              pclk,
    input  wire              prstn,
    input  wire              cfg_mode,
    
    // APB Interface
    input  wire              psel,
    input  wire              pwrite,
    input  wire [14:0]       paddr,
    input  wire [31:0]       pwdata,
    output wire [31:0]       prdata, //SAT
    output reg               pready,
//SAT    output reg prdataout,

    // Memory interface
    output reg               mem_we,
    output reg  [$clog2(MAX_ITEMS)-1:0] mem_waddr,
    output reg  [31:0]       mem_wdata,
    output reg  [$clog2(MAX_ITEMS)-1:0] mem_raddr,
    input  wire [31:0]       mem_rdata
);
// wire  [31:0]       prdata;
  //reg read_enable;
  
  
  reg [31:0] mem_rdata_reg;        
reg cfg_mode_ff1, cfg_mode_ff2;
wire cfg_mode_sync;
//SAT assign cfg_mode_sync = cfg_mode_ff2;
assign cfg_mode_sync = cfg_mode;
always@(posedge pclk or negedge prstn) begin           //  Causing ambiguous clock error due to insertion of  PCLK

if (!prstn) begin
cfg_mode_ff1 <= 0;
cfg_mode_ff2 <= 0;
end
else begin					// two-stage synchronizer
cfg_mode_ff1 <= cfg_mode;
cfg_mode_ff2 <= cfg_mode_ff1;
end

end
    always @(posedge pclk or negedge prstn) begin
        if (!prstn) begin
            pready      <= 0;
        //    prdata      <= 0;
            mem_we      <= 0;
            mem_waddr   <= 0;
            mem_raddr   <= 0;
            mem_wdata   <= 0;
        end
        else begin
            // Default values
            pready    <= 0;
            mem_we    <= 0;

            if (cfg_mode_sync && psel) begin
 
                    pready <= 1;    ///////   0,1, 2,,3 ,4 , 5,
                // Calculate address offset (skip 0x0000 base)
              mem_waddr <= (paddr - 'h4) >> 2;  // if paddr = 0x0004  (0004 - 0004) divided by 2 = 0           //   paddr = 0x0008  (0008 - 0004) divided by 2 = 0
              mem_raddr <= (paddr - 'h4) >> 2;

                if (pwrite) begin
                    mem_we    <= 1;
                    mem_wdata <= pwdata;

                end 
             // else begin
               // prdata    <= mem_rdata;
                    
            // end 
            end
        end
    end
assign prdata = mem_rdata;

endmodule



