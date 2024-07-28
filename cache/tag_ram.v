`include "/home/loongsonarch_1/Desktop/cdp_ede_local/myCPU/defs.v"

module tag_ram(
    input wire                clk,
    input wire               resetn,
    input wire               we,
    input wire [`CACHE_LOG_W-1:0]   way,
    input wire [`CACHE_LOG_H-1:0]   addr,
    input wire [`CACHE_TAG_LEN-1:0] din ,
    output wire [`CACHE_N*`CACHE_TAG_LEN-1:0] dout
);



reg [`CACHE_TAG_LEN-1:0] ram [`CACHE_H-1:0][`CACHE_N-1:0];
integer i,j;
always @(posedge clk)begin
    if(!resetn)begin
        for(i=0;i<`CACHE_H;i=i+1)begin
            for(j=0;j<`CACHE_N;j=j+1)begin
                ram[i][j] <= `CACHE_TAG_LEN'b0;
            end
        end 
    end
    else begin
        if(we) ram[addr][way] <=din;        
    end
end
assign  dout = {ram[addr][3],ram[addr][2],ram[addr][1],ram[addr][0]};

endmodule