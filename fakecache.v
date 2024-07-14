`include "defs.v"
module fakecache(
//output
        sram_en,
        sram_we,
        sram_addr,
        sram_wdata,

        cache_rdata,
        cache_hit,

//input
        sram_rdata,
        cache_re,
        cache_raddr,
        cache_we,
        cache_waddr,
        cache_wdata,
        cache_access_sz,
        clk,
        rst_n);

input wire clk;
input wire rst_n;
input wire cache_re;
input wire [31:0] cache_raddr;
input wire cache_we;
input wire [31:0] cache_waddr;
input wire [31:0] cache_wdata;
input wire [2:0] cache_access_sz;

input wire [31:0] sram_rdata;

output reg sram_en;
output reg [3:0] sram_we;
output reg [31:0] sram_addr;
output reg [31:0] sram_wdata;

output reg [31:0] cache_rdata;
output reg cache_hit;

reg [31:0] buffer_rdata;
reg buffer_hit;

always @(*) begin
    sram_en <= cache_re || cache_we;
    sram_we <=  (!cache_we) ? 4'b0000 :
                (cache_access_sz == `ACCESS_SZ_WORD) ? 4'b1111 :
                (cache_access_sz == `ACCESS_SZ_HALF) ? 4'b0011 :
                (cache_access_sz == `ACCESS_SZ_BYTE) ? 4'b0001 :
                4'b0000;
    sram_addr <= sram_we? cache_waddr : cache_raddr;
    sram_wdata <= cache_wdata;
end

always @(posedge clk ) begin
    if(!rst_n) begin
        buffer_rdata <= 32'b0;
        buffer_hit <= 1'b0;
    end
    else begin
        buffer_rdata <= sram_rdata;
        buffer_hit <= 1'b1;
    end
end

always @(*) begin
    cache_rdata <= buffer_rdata;
    cache_hit <= buffer_hit;
end



endmodule