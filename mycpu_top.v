`include "/home/loongsonarch_1/Desktop/cdp_ede_local/myCPU/defs.v"

module mycpu_top(
    input  [7:0] ext_int,
    input  aclk   ,
    input  aresetn,
    // read req channel
    output [ 3:0] arid   , // 读请求ID
    output [31:0] araddr , // 读请求地址
    output [ 7:0] arlen  , // 读请求传输长度（数据传输拍数）
    output [ 2:0] arsize , // 读请求传输大小（数据传输每拍的字节数）
    output [ 1:0] arburst, // 传输类型
    output [ 1:0] arlock , // 原子锁
    output [ 3:0] arcache, // Cache属性
    output [ 2:0] arprot , // 保护属性
    output        arvalid, // 读请求地址有效
    input         arready, // 读请求地址握手信号
    // read response channel
    input [ 3:0]  rid    , // 读请求ID号，同一请求rid与arid一致
    input [31:0]  rdata  , // 读请求读出的数据
    input [ 1:0]  rresp  , // 读请求是否完成                        [可忽略]
    input         rlast  , // 读请求最后一拍数据的指示信号           [可忽略]
    input         rvalid , // 读请求数据有效
    output        rready , // Master端准备好接受数据
    // write req channel
    output [ 3:0] awid   , // 写请求的ID号
    output [31:0] awaddr , // 写请求的地址
    output [ 7:0] awlen  , // 写请求传输长度（拍数）
    output [ 2:0] awsize , // 写请求传输每拍字节数
    output [ 1:0] awburst, // 写请求传输类型
    output [ 1:0] awlock , // 原子锁
    output [ 3:0] awcache, // Cache属性
    output [ 2:0] awprot , // 保护属性
    output        awvalid, // 写请求地址有效
    input         awready, // Slave端准备好接受地址传输   
    // write data channel
    output [ 3:0] wid    , // 写请求的ID号
    output [31:0] wdata  , // 写请求的写数据
    output [ 3:0] wstrb  , // 写请求字节选通位
    output        wlast  , // 写请求的最后一拍数据的指示信号
    output        wvalid , // 写数据有效
    input         wready , // Slave端准备好接受写数据传输   
    // write response channel
    input  [ 3:0] bid    , // 写请求的ID号            [可忽略]
    input  [ 1:0] bresp  , // 写请求完成信号          [可忽略]
    input         bvalid , // 写请求响应有效
    output        bready , // Master端准备好接收响应信号
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

wire inst_cache_re;
wire [31:0] inst_cache_raddr;
reg [31:0] inst_cache_rdata;
reg inst_cache_hit;
wire inst_cache_we;
wire [31:0] inst_cache_waddr;
wire [31:0] inst_cache_wdata;
wire [1:0] inst_cache_access_sz;
wire data_cache_re;
wire [31:0] data_cache_raddr;
reg [31:0] data_cache_rdata;
reg data_cache_hit;
wire data_cache_we;
wire [31:0] data_cache_waddr;
wire [31:0] data_cache_wdata;
wire [1:0] data_cache_access_sz;

wire icache_rd_req;
wire [2:0] icache_rd_type;
wire [31:0] icache_rd_addr;
wire icache_rd_rdy;
wire icache_ret_valid;
wire icache_ret_last;
wire [31:0] icache_ret_data;

wire dcache_rd_req;
wire [2:0] dcache_rd_type;
wire [31:0] dcache_rd_addr;
wire dcache_rd_rdy;
wire dcache_ret_valid;
wire dcache_ret_last;
wire [31:0] dcache_ret_data;

wire dcahce_wr_req;
wire [2:0] dcache_wr_type;
wire [31:0] dcache_wr_addr;
wire [3:0] dcache_wr_wstrb;
wire [127:0] dcache_wr_data;
wire dcache_wr_rdy;

reg icache_op;
reg icache_valid;
reg [31:0] icache_addr;
reg [1:0] icache_wsize;
reg [31:0] icache_wdata;

wire icache_rdata_valid;
wire icache_wdata_valid;
wire [31:0] icache_rdata;
wire [31:0] icache_raddr_out;
wire icache_raddr_valid;

reg dcache_op;
reg dcache_valid;
reg [31:0] dcache_addr;
reg [1:0] dcache_wsize;
reg [31:0] dcache_wdata;

wire dcache_rdata_valid;
wire dcache_wdata_valid;
wire [31:0] dcache_rdata;

always @(*) begin
    icache_valid <= inst_cache_re;
    icache_op <= `CC_CPU_OP_RD;
    icache_addr <= inst_cache_raddr;
    icache_wsize <= inst_cache_access_sz;
    icache_wdata <= inst_cache_wdata;
end

always @(*) begin
    inst_cache_rdata <= icache_rdata;
    inst_cache_hit <= icache_rdata_valid;
end

always @(*) begin
    dcache_valid <= data_cache_re | data_cache_we;
    dcache_op <= data_cache_re ? `CC_CPU_OP_RD : `CC_CPU_OP_WR;
    dcache_addr <= data_cache_re ? data_cache_raddr : data_cache_waddr;
    dcache_wsize <= data_cache_access_sz;
    dcache_wdata <= data_cache_wdata;
end

always @(*) begin
    data_cache_rdata <= dcache_rdata;
    data_cache_hit <= dcache_rdata_valid | dcache_wdata_valid;
end

core U_core (
//output
            .inst_cache_re(inst_cache_re),
            .inst_cache_we(inst_cache_we),
            .inst_cache_raddr(inst_cache_raddr),
            .inst_cache_waddr(inst_cache_waddr),
            .inst_cache_wdata(inst_cache_wdata),
            .inst_cache_access_sz(inst_cache_access_sz),
            .icache_raddr_out(icache_raddr_out),
            .icache_raddr_valid(icache_raddr_valid),

            .data_cache_re(data_cache_re),
            .data_cache_we(data_cache_we),
            .data_cache_raddr(data_cache_raddr),
            .data_cache_waddr(data_cache_waddr),
            .data_cache_wdata(data_cache_wdata),
            .data_cache_access_sz(data_cache_access_sz),

            .debug_wb_pc(debug_wb_pc),
            .debug_wb_rf_we(debug_wb_rf_we),
            .debug_wb_rf_wnum(debug_wb_rf_wnum),
            .debug_wb_rf_wdata(debug_wb_rf_wdata),
//input
            .inst_cache_rdata(inst_cache_rdata),
            .inst_cache_hit(inst_cache_hit),
            .data_cache_rdata(data_cache_rdata),
            .data_cache_hit(data_cache_hit),
            .clk(aclk),
            .rst_n(aresetn));

// fakecache U_fakecache_inst(
//             .clk(clk),
//             .rst_n(resetn),
//             .cache_re(inst_cache_re),
//             .cache_raddr(inst_cache_raddr),
//             .cache_rdata(inst_cache_rdata),
//             .cache_hit(inst_cache_hit),
//             .cache_we(inst_cache_we),
//             .cache_waddr(inst_cache_waddr),
//             .cache_wdata(inst_cache_wdata),
//             .cache_access_sz(inst_cache_access_sz),
//             .sram_en(inst_sram_en),
//             .sram_we(inst_sram_we),
//             .sram_addr(inst_sram_addr),
//             .sram_wdata(inst_sram_wdata),
//             .sram_rdata(inst_sram_rdata));
    
// fakecache U_fakecache_data(
//             .clk(clk),
//             .rst_n(resetn),
//             .cache_re(data_cache_re),
//             .cache_raddr(data_cache_raddr),
//             .cache_rdata(data_cache_rdata),
//             .cache_hit(data_cache_hit),
//             .cache_we(data_cache_we),
//             .cache_waddr(data_cache_waddr),
//             .cache_wdata(data_cache_wdata),
//             .cache_access_sz(data_cache_access_sz),
//             .sram_en(data_sram_en),
//             .sram_we(data_sram_we),
//             .sram_addr(data_sram_addr),
//             .sram_wdata(data_sram_wdata),
//             .sram_rdata(data_sram_rdata));

realcache U_icache(
    .clk(aclk),
    .resetn(aresetn),

    .op(icache_op),
    .valid(icache_valid),
    .addr(icache_addr),
    .wsize(icache_wsize),
    .wdata(icache_wdata),

    .rdata(icache_rdata),
    .rdata_valid(icache_rdata_valid),
    .wdata_valid(icache_wdata_valid),
    .raddr_out(icache_raddr_out),
    .raddr_valid(icache_raddr_valid),

    .rd_req(icache_rd_req),
    .rd_type(icache_rd_type),
    .rd_addr(icache_rd_addr),
    .rd_rdy(icache_rd_rdy),
    .ret_valid(icache_ret_valid),
    .ret_last(icache_ret_last),
    .ret_data(icache_ret_data),

    .wr_req(),
    .wr_type(),
    .wr_addr(),
    .wr_wstrb(),
    .wr_size(),
    .wr_data(),
    .wr_rdy()
);

realcache U_dcache(
    .clk(aclk),
    .resetn(aresetn),

    .op(dcache_op),
    .valid(dcache_valid),
    .addr(dcache_addr),
    .wsize(dcache_wsize),
    .wdata(dcache_wdata),

    .rdata(dcache_rdata),
    .rdata_valid(dcache_rdata_valid),
    .wdata_valid(dcache_wdata_valid),

    .rd_req(dcache_rd_req),
    .rd_type(dcache_rd_type),
    .rd_addr(dcache_rd_addr),
    .rd_rdy(dcache_rd_rdy),
    .ret_valid(dcache_ret_valid),
    .ret_last(dcache_ret_last),
    .ret_data(dcache_ret_data),

    .wr_req(dcahce_wr_req),
    .wr_type(dcache_wr_type),
    .wr_addr(dcache_wr_addr),
    .wr_wstrb(dcache_wr_wstrb),
    .wr_data(dcache_wr_data),
    .wr_rdy(dcache_wr_rdy)
);

axi_bridge U_axi_bridge(
    .aclk(aclk),
    .aresetn(aresetn),
    // read req channel
    .arid(arid),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arlock(arlock),
    .arcache(arcache),
    .arprot(arprot),
    .arvalid(arvalid),
    .arready(arready),
    // read response channel
    .rid(rid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),
    // write req channel
    .awid(awid),
    .awaddr(awaddr),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .awlock(awlock),
    .awcache(awcache),
    .awprot(awprot),
    .awvalid(awvalid),
    .awready(awready),
    // write data channel
    .wid(wid),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),
    // write response channel
    .bid(bid),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready),
    // icache rd interface
    .icache_rd_req(icache_rd_req),
    .icache_rd_type(icache_rd_type),
    .icache_rd_addr(icache_rd_addr),
    .icache_rd_rdy(icache_rd_rdy),
    .icache_ret_valid(icache_ret_valid),
    .icache_ret_last(icache_ret_last),
    .icache_ret_data(icache_ret_data),
    // dcache rd interface
    .dcache_rd_req(dcache_rd_req),
    .dcache_rd_type(dcache_rd_type),
    .dcache_rd_addr(dcache_rd_addr),
    .dcache_rd_rdy(dcache_rd_rdy),
    .dcache_ret_valid(dcache_ret_valid),
    .dcache_ret_last(dcache_ret_last),
    .dcache_ret_data(dcache_ret_data),
    // dcache wr interface
    .dcache_wr_req(dcahce_wr_req),
    .dcache_wr_type(dcache_wr_type),
    .dcache_wr_addr(dcache_wr_addr),
    .dcache_wr_wstrb(dcache_wr_wstrb),
    .dcache_wr_data(dcache_wr_data),
    .dcache_wr_rdy(dcache_wr_rdy)
);


endmodule