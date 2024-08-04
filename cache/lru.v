`include "C:\\Users\\Lenovo\\Desktop\\nscscc-team-la32r\\func_test\\myCPU\\defs.v"
module lru (
//output
        cache_way_to_replace,
//input
        clk,
        rst_n,
        cpu_rw_en,
        cpu_addr_set,
        cpu_uncache,
        cache_hit,
        cache_hit_way);

input wire clk;
input wire rst_n;
input wire cpu_rw_en;
input wire [`CC_SET_BIT_WIDTH-1:0] cpu_addr_set;
input wire cpu_uncache;
input wire cache_hit;
input wire [`CC_WAY_BIT_WIDTH-1:0] cache_hit_way;

output reg [`CC_WAY_BIT_WIDTH-1:0] cache_way_to_replace;

reg [`CC_WAY_SIZE] lru_matrix [`CC_SET_SIZE][`CC_WAY_SIZE];

integer i,j;
always @(posedge clk) begin
    if(!rst_n)begin
        for(i=0;i<`CC_SET_SIZE;i=i+1)begin
            for(j=0;j<`CC_WAY_SIZE;j=j+1)begin
                lru_matrix[i][j] <= `CC_WAY_SIZE'b0;
            end
        end
    end
    else if(cpu_rw_en && cache_hit && !cpu_uncache )begin
        for(i=0;i<`CC_WAY_SIZE;i=i+1)begin
            lru_matrix[cpu_addr_set][i][cache_hit_way] <= 1'b0;
        end
        for(j=0;j<`CC_WAY_SIZE;j=j+1)begin
            lru_matrix[cpu_addr_set][cache_hit_way][j] <= !(j == cache_hit_way);
        end    
    end
end

always @(*) begin
    if(!rst_n)begin
        cache_way_to_replace = `CC_WAY_BIT_WIDTH'b0;        
    end
    else begin
        for(i=0;i<`CC_WAY_SIZE;i=i+1)begin
            if( lru_matrix[cpu_addr_set][i] == `CC_WAY_SIZE'b0 )begin
                 cache_way_to_replace = i;
                 break;
            end
        end
    end
end
endmodule
