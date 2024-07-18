`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
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

//reg [31:0] buffer_rdata;
//reg buffer_hit;

always @(*) begin
    sram_en <= cache_re || cache_we;
    // sram_we <=  (!cache_we) ? 4'b0000 :
    //             (cache_access_sz == `ACCESS_SZ_WORD) ? 4'b1111 :
    //             (cache_access_sz == `ACCESS_SZ_HALF) ? 4'b0011 :
    //             (cache_access_sz == `ACCESS_SZ_BYTE) ? 4'b0001 :
    //             4'b0000;
    sram_addr <= sram_we? cache_waddr : cache_raddr;
    // sram_wdata <= cache_wdata;
end

always @(*) begin
    if(cache_we) begin
        case(cache_access_sz)
            `ACCESS_SZ_WORD: begin
                sram_we <= 4'b1111;
                sram_wdata <= cache_wdata;
            end
            `ACCESS_SZ_HALF: begin
                sram_we <= 4'b0011 << (cache_waddr[1:0]);
                sram_wdata <= {cache_wdata[15:0], cache_wdata[15:0]};
            end
            `ACCESS_SZ_BYTE: begin
                sram_we <= 4'b0001 << (cache_waddr[1:0]);
                sram_wdata <= {cache_wdata[7:0], cache_wdata[7:0], cache_wdata[7:0], cache_wdata[7:0]};
            end
            default: begin
                sram_we <= 4'b0000;
                sram_wdata <= 32'b0;
            end
        endcase
    end
    else begin
        sram_we <= 4'b0000;
    end
end

always @(*) begin
    if(!rst_n) begin
        cache_rdata <= 32'b0;
        cache_hit <= 1'b0;
    end
    else begin
        cache_rdata <= sram_rdata;
        cache_hit <= 1'b1;
    end
end

//always @(*) begin
//    cache_rdata <= buffer_rdata;
//    cache_hit <= buffer_hit;
//end



endmodule