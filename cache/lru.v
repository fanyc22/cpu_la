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
    
endmodule