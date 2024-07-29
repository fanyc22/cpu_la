
//use，指的是命中或者被替换

module cache_lru(
    input wire  clk,
    input wire  resetn,
    input wire  use,
    input wire  [`CACHE_LOG_N-1:0] use_way, // 0,1,2,3
    input wire  [`CACHE_LOG_H-1:0] index,   // 0~255
    output wire [`CACHE_LOG_N-1:0] replace_way//0,1,2,3
);
reg [`CACHE_N -1 :0] lru_matrix [`CACHE_H -1 : 0][`CACHE_N -1 :0];
genvar i,j;
generate
    for(i=0;i<`CACHE_H;i=i+1)begin
        for(j=0;j<`CACHE_W;j=j+1)begin
            always @(posedge clk)begin
                if(~resetn)begin
                    lru_matrix[i][j] <= `CACHE_W'b0;
                end
                else if(use && i==index)begin                    
                    if(j==use_way)begin
                        lru_matrix[i][j] <= `CACHE_W'b1;
                    end
                    lru_matrix[i][j][use_way] <= 1'b0;//有一位被先置为1再置为0，我不知是否正确。
                end
            end
    end
endgenerate
//当作四位来写了，暂时没有除了for循环以外更好的办法
assign replace_way = lru_matrix[index][0]==4'b0? 2'b0:
                     lru_matrix[index][1]==4'b0? 2'b1:
                     lru_matrix[index][2]==4'b0? 2'b2:
                     lru_matrix[index][3]==4'b0? 2'b3:
endmodule