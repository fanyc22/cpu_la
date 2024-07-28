`include "/home/loongsonarch_1/Desktop/cdp_ede_local/myCPU/defs.v"
module data_ram(
    input  wire             clk,
    input  wire             resetn,
    input  wire             we,
    input  wire [`CACHE_LOG_H-1:0] index,
    input  wire [`CACHE_LOG_N-1:0] way  ,
    input  wire [`CACHE_LOG_W-1:0] offset,
    input  wire [31:0]      din   ,//一次写一字
    output reg [31:0]       dout  ,//一次读一行
    output wire [`CACHE_W*32-1:0] dout_replace
);

reg [31:0] ram [`CACHE_H-1:0][`CACHE_N-1:0][`CACHE_W-1:0];
genvar i,j,k;
generate
    for(i=0;i<`CACHE_H;i=i+1)begin
        for(j=0;j<`CACHE_N;j=j+1)begin
            for(k=0;k<`CACHE_W;k=k+1)begin
                always @(posedge clk)begin
                    if(~resetn)begin
                        ram[i][j][k] <= 32'b0;
                    end
                    else begin 
                        if(we) ram[index][way][offset] <= din;
                        dout <= ram[index][way][offset];
                    end
                end
            end
        end        
    end    
endgenerate    

assign dout_replace = {ram[index][way][3],ram[index][way][2],ram[index][way][1],ram[index][way][0]};
endmodule