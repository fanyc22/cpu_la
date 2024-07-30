module cache_ram (
//output
    output_rdata,
//input
    clk,
    rst_n,
    wline,
    wline_

input wire clk;
input wire rst_n;

output wire [31:0] output_rdata;

reg [`CC_SET_SIZE-1:0] cache_ram_reg [CC_WAY_SIZE-1:0][CC_LINE_WIDTH-1:0];


    
endmodule