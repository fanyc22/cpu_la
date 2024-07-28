module realcache (
    clk,
    resetn,
//input from CPU
    op,
    valid,
    addr,
    wsize,
    wdata,    
//output to CPU
    rdata,
    rdata_valid,
    wdata_valid,
//read from RAM
    rd_req,
    rd_type,
    rd_addr,
    rd_rdy,
    ret_valid,
    ret_last,
    ret_data,
//write to RAM
    wr_req,
    wr_type,
    wr_addr,
    wr_wstrb,
    wr_size,
    wr_data,
    wr_rdy
);

input wire clk;

endmodule