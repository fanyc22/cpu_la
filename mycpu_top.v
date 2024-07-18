`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"

module mycpu_top(
    input  wire        clk,
    input  wire        resetn,
    // inst sram interface
    output wire        inst_sram_en,
    output wire  [3:0] inst_sram_we,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata,
    // data sram interface
    output wire        data_sram_en,
    output wire  [3:0] data_sram_we,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input  wire [31:0] data_sram_rdata,
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

wire inst_cache_re;
wire [31:0] inst_cache_raddr;
wire [31:0] inst_cache_rdata;
wire inst_cache_hit;
wire inst_cache_we;
wire [31:0] inst_cache_waddr;
wire [31:0] inst_cache_wdata;
wire [2:0] inst_cache_access_sz;
wire data_cache_re;
wire [31:0] data_cache_raddr;
wire [31:0] data_cache_rdata;
wire data_cache_hit;
wire data_cache_we;
wire [31:0] data_cache_waddr;
wire [31:0] data_cache_wdata;
wire [2:0] data_cache_access_sz;

core U_core (
//output
            .inst_cache_re(inst_cache_re),
            .inst_cache_we(inst_cache_we),
            .inst_cache_raddr(inst_cache_raddr),
            .inst_cache_waddr(inst_cache_waddr),
            .inst_cache_wdata(inst_cache_wdata),
            .inst_cache_access_sz(inst_cache_access_sz),

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
            .clk(clk),
            .rst_n(resetn));

fakecache U_fakecache_inst(
            .clk(clk),
            .rst_n(resetn),
            .cache_re(inst_cache_re),
            .cache_raddr(inst_cache_raddr),
            .cache_rdata(inst_cache_rdata),
            .cache_hit(inst_cache_hit),
            .cache_we(inst_cache_we),
            .cache_waddr(inst_cache_waddr),
            .cache_wdata(inst_cache_wdata),
            .cache_access_sz(inst_cache_access_sz),
            .sram_en(inst_sram_en),
            .sram_we(inst_sram_we),
            .sram_addr(inst_sram_addr),
            .sram_wdata(inst_sram_wdata),
            .sram_rdata(inst_sram_rdata));
    
fakecache U_fakecache_data(
            .clk(clk),
            .rst_n(resetn),
            .cache_re(data_cache_re),
            .cache_raddr(data_cache_raddr),
            .cache_rdata(data_cache_rdata),
            .cache_hit(data_cache_hit),
            .cache_we(data_cache_we),
            .cache_waddr(data_cache_waddr),
            .cache_wdata(data_cache_wdata),
            .cache_access_sz(data_cache_access_sz),
            .sram_en(data_sram_en),
            .sram_we(data_sram_we),
            .sram_addr(data_sram_addr),
            .sram_wdata(data_sram_wdata),
            .sram_rdata(data_sram_rdata));


endmodule