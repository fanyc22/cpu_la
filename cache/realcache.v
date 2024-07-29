module realcache (
    clk,
    resetn,
//input from CPU
    cpu_rw_op,
    cpu_rw_en,
    cpu_rw_addr,
    cpu_rw_wsize,
    cpu_rw_wdata,   
//output to CPU
    output_rdata,
    output_rdata_valid,
    output_wdata_valid,
//read from RAM
//output to RAM
    axib_rd_req,
    axib_rd_type,
    axib_rd_addr,
//input from RAM
    axib_rd_rdy,
    axib_ret_valid,
    axib_ret_last,
    axib_ret_data,
//write to RAM
//output to RAM
    axib_wr_req,
    axib_wr_type,
    axib_wr_addr,
    axib_wr_wstrb,
    axib_wr_size,
    axib_wr_data,
//input from RAM
    axib_wr_rdy
);

input wire clk;
input wire resetn;
input wire op;
input wire valid;
input wire [31:0] addr;
input wire [1:0] wsize;
input wire [31:0] wdata;

input wire rd_rdy;
input wire ret_valid;
input wire ret_last;
input wire [31:0] ret_data;

input wire wr_rdy;

output wire rdata_valid;
output wire wdata_valid;
output wire [31:0] rdata;

output wire rd_req;
output wire [2:0] rd_type;
output wire [31:0] rd_addr;

output wire wr_req;
output wire [2:0] wr_type;
output wire [31:0] wr_addr;
output wire [3:0] wr_wstrb;
output wire [2:0] wr_size;
output wire [127:0] wr_data;

reg [31:0] buffer_addr;
reg [31:0] buffer_data;
reg mming;

assign rd_req = valid && !op;
assign rd_type = 3'b000;
assign rd_addr = {addr[31:2], 2'b00};

assign wr_req = valid && op;
assign wr_type = 3'b000;
assign wr_addr = {addr[31:2], 2'b00};
assign wr_wstrb = 4'b1111;
assign wr_size = 3'b000;
assign wr_data = wdata;

endmodule