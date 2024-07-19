`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"

module core (
//output
            inst_cache_re,
            inst_cache_raddr,
            inst_cache_we,
            inst_cache_waddr,
            inst_cache_wdata,
            inst_cache_access_sz,
               
            data_cache_re,
            data_cache_raddr,
            data_cache_we,
            data_cache_waddr,
            data_cache_wdata,
            data_cache_access_sz,

            debug_wb_pc,
            debug_wb_rf_we,
            debug_wb_rf_wnum,
            debug_wb_rf_wdata,
//input            
            inst_cache_rdata,
            inst_cache_hit,
            data_cache_rdata,
            data_cache_hit,
            clk,
            rst_n);

parameter WITH_CACHE = 0;
parameter WITH_TLB = 0;

input wire clk;
input wire rst_n;
input wire [31:0] inst_cache_rdata;
input wire inst_cache_hit;
input wire [31:0] data_cache_rdata;
input wire data_cache_hit;

output reg inst_cache_re;
output reg [31:0] inst_cache_raddr;
output reg inst_cache_we;
output reg [31:0] inst_cache_waddr;
output reg [31:0] inst_cache_wdata;
output reg [2:0] inst_cache_access_sz;

output wire data_cache_re;
output wire [31:0] data_cache_raddr;
output wire data_cache_we;
output wire [31:0] data_cache_waddr;
output wire [31:0] data_cache_wdata;
output wire [2:0] data_cache_access_sz;

output wire [31:0] debug_wb_pc;
output wire [3:0] debug_wb_rf_we;
output wire [4:0] debug_wb_rf_wnum;
output wire [31:0] debug_wb_rf_wdata;

wire pc_wen;
wire pc_is_wrong;
wire [31:0] pc_correct;

wire if1_if2_flush;
wire if2_id_flush;
wire id_ex_flush;
wire ex_mm1_flush;
wire mm1_mm2_flush;
wire mm2_wb_flush;

wire if1_if2_wen;
wire if2_id_wen;
wire id_ex_wen;
wire id_ex_bp_flush;
wire ex_mm1_wen;
wire mm1_mm2_wen;
wire mm2_wb_wen;

wire [31:0] if1_pc;
wire if1_icache_re;
wire if1_branch_taken;
wire [31:0] if1_branch_address;

wire [31:0] if2_inst;
wire if2_icache_hit;

wire [31:0] id_rj_from_gr;
wire [31:0] id_rk_from_gr;
wire [31:0] id_rd_from_gr;
wire [4:0] id_reg_d;
wire [4:0] id_reg_j;
wire [4:0] id_reg_k;
wire [7:0] id_op;
wire [3:0] id_op_type;
wire [25:0] id_imm;
wire [2:0] id_imm_sz;
wire [14:0] id_bns_code;
wire [4:0] id_shift_imm;
wire [19:0] id_u12imm;
wire id_flag_unsigned;
wire [2:0] id_access_sz;
wire id_is_branch;
wire [13:0] id_csr_addr;
wire id_reg_j_ren;
wire id_reg_k_ren;
wire id_reg_d_ren;
wire [31:0] id_rj_from_fwd;
wire [31:0] id_rk_from_fwd;
wire [31:0] id_rd_from_fwd;

wire [31:0] ex_alu_in2;
wire [31:0] ex_alu_out;
wire ex_alu_zero;
wire [31:0] ex_mul_out;
wire ex_mul_out_valid;
wire [31:0] ex_div_out;
wire ex_div_out_valid;
// wire ex_mm_access_op;
wire [2:0] ex_mm_access_sz;
wire [31:0] ex_mm_addr;
wire [31:0] ex_exe_out;
wire ex_exe_out_valid;
wire ex_mm_re;
wire ex_mm_we;
wire [31:0] ex_mm_wdata;
wire ex_branch;
wire [31:0] ex_pc_branch;
wire ex_reg_d_wen;

wire [31:0] mm2_rdata;
wire mm2_hit;

wire [4:0] wb_gr_waddr;
wire [31:0] wb_gr_wdata;

wire [2:0] fwd_src_j;
wire [2:0] fwd_src_k;
wire [2:0] fwd_src_d;

hazard_ctrl U_hazard_ctrl(
        .if1_if2_flush(if1_if2_flush),
        .if2_id_flush(if2_id_flush),
        .id_ex_flush(id_ex_flush),
        .ex_mm1_flush(ex_mm1_flush),
        .mm1_mm2_flush(mm1_mm2_flush),
        .mm2_wb_flush(mm2_wb_flush),
        .if1_if2_wen(if1_if2_wen),
        .if2_id_wen(if2_id_wen),
        .id_ex_wen(id_ex_wen),
        .id_ex_bp_flush(id_ex_bp_flush),
        .ex_mm1_wen(ex_mm1_wen),
        .mm1_mm2_wen(mm1_mm2_wen),
        .mm2_wb_wen(mm2_wb_wen),
        .pc_wen(pc_wen),
        .fwd_src_j(fwd_src_j),
        .fwd_src_k(fwd_src_k),
        .fwd_src_d(fwd_src_d),
        .pc_is_wrong(pc_is_wrong),
        .pc_correct(pc_correct),
        .ex_exe_out_valid(ex_exe_out_valid),
        .ex_pc(id_ex.pc),
        .ex_branch(ex_branch),
        .ex_pc_branch(ex_pc_branch),
        .ex_branch_bp(id_ex.branch_bp),
        .id_pc(if2_id.pc),
        .id_is_branch(id_is_branch),
        .id_branch_bp(if2_id.branch_bp),
        .id_reg_j_ren(id_reg_j_ren),
        .id_reg_j(id_reg_j),
        .id_reg_k_ren(id_reg_k_ren),
        .id_reg_k(id_reg_k),
        .id_reg_d_ren(id_reg_d_ren),
        .id_reg_d(id_reg_d),
        .ex_reg_d_wen(ex_reg_d_wen),
        .ex_reg_d(id_ex.reg_d),
        .ex_mm_load(ex_mm_re),
        .mm1_reg_d_wen(ex_mm1.reg_d_wen),
        .mm1_reg_d(ex_mm1.reg_d),
        .mm1_mm_load(ex_mm1.mm_re),
        .mm2_reg_d_wen(mm1_mm2.reg_d_wen),
        .mm2_reg_d(mm1_mm2.reg_d),
        .mm2_mm_load(mm1_mm2.mm_re),
        .wb_reg_d_wen(mm2_wb.reg_d_wen),
        .wb_reg_d(wb_gr_waddr));

pc U_pc(
         .pc_reg(if1_pc),
         .rst_n(rst_n),
         .clk(clk),
         .pc_wen(pc_wen),
         .pc_is_wrong(pc_is_wrong),
         .pc_correct(pc_correct),
         .is_branch(if1_branch_taken),
         .branch_address(if1_branch_address),
         .icache_re(if1_icache_re));

// icache U_icache(
//             .rdata(if2_inst),
//             .hit(if2_icache_hit),
//             .clk(clk),
//             .rst_n(rst_n),
//             .re(if1_icache_re),
//             .raddr(if1_pc),
//             .we(1'b0),
//             .waddr(32'b0),
//             .wdata(32'b0),
//             .wsz(3'b0));

assign if2_inst = inst_cache_rdata;
assign if2_icache_hit = inst_cache_hit;


always @(*) begin
        inst_cache_re <= if1_icache_re;
        inst_cache_raddr <= if1_pc;
        inst_cache_we <= 4'b0;
        inst_cache_access_sz <= 3'b0;
        inst_cache_waddr <= 32'b0;
        inst_cache_wdata <= 32'b0;
end


reg_if1_if2 if1_if2(
            .clk(clk),
            .rst_n(rst_n),
            .wen(if1_if2_wen),
            .flush(if1_if2_flush),
            .if1_pc(if1_pc),
            .if1_branch_bp(if1_branch_taken));

bp U_bp(
            .branch(if1_branch_taken),
            .target(if1_branch_address),
            .clk(clk),
            .rst_n(rst_n),
        //     .if1_if2_flushed(if1_if2.flushed),
            .pc_low(if1_pc[5:0]),
            .we(id_ex.is_branch),
            .hitted(ex_branch),
            .wtarget(ex_pc_branch),
            .hit_addr(id_ex.pc[5:0])
            );

reg_if2_id if2_id(
            .clk(clk),
            .rst_n(rst_n),
            .wen(if2_id_wen),
            .flush(if2_id_flush),
            .if2_pc(if1_if2.pc),
            .if2_inst(if2_inst),
            .if2_icache_hit(if2_icache_hit),
            .if2_branch_bp(if1_if2.branch_bp),
            .if1_if2_cache_valid(if1_if2.cache_valid));

gr U_gr(
            .rdata1(id_rj_from_gr),
            .rdata2(id_rk_from_gr),
            .rdata3(id_rd_from_gr),
            .clk(clk),
            .rst_n(rst_n),
            .we(mm2_wb.reg_d_wen),
            .waddr(wb_gr_waddr),
            .wdata(wb_gr_wdata),
            .raddr1(id_reg_j),
            .raddr2(id_reg_k),
            .raddr3(id_reg_d));

assign debug_wb_pc = mm2_wb.pc;
assign debug_wb_rf_we = {4{mm2_wb.reg_d_wen}};
assign debug_wb_rf_wnum = wb_gr_waddr;
assign debug_wb_rf_wdata = wb_gr_wdata;

decoder U_decoder(
            .reg_d(id_reg_d),
            .reg_j(id_reg_j),
            .reg_k(id_reg_k),
            .op(id_op),
            .op_type(id_op_type),
            .imm(id_imm),
            .imm_sz(id_imm_sz),
            .bns_code(id_bns_code),
            .shift_imm(id_shift_imm),
            .u12imm(id_u12imm),
            .flag_unsigned(id_flag_unsigned),
            .access_sz(id_access_sz),
            .is_branch(id_is_branch),
            .inst(if2_id.inst),
            .csr_addr(id_csr_addr),
            .reg_j_ren(id_reg_j_ren),
            .reg_k_ren(id_reg_k_ren),
            .reg_d_ren(id_reg_d_ren));

fwd U_fwd_j(
            .reg_out(id_rj_from_fwd),
            .reg_from_gr(id_rj_from_gr),
            .reg_from_ex(ex_exe_out),
            .reg_from_mm1(ex_mm1.exe_out),
            .reg_from_mm2(mm1_mm2.exe_out),
            .mem_from_mm2(mm2_rdata),
            .reg_from_wb(wb_gr_wdata),
            .fwd_ctrl(fwd_src_j));

fwd U_fwd_k(
            .reg_out(id_rk_from_fwd),
            .reg_from_gr(id_rk_from_gr),
            .reg_from_ex(ex_exe_out),
            .reg_from_mm1(ex_mm1.exe_out),
            .reg_from_mm2(mm1_mm2.exe_out),
            .mem_from_mm2(mm2_rdata),
            .reg_from_wb(wb_gr_wdata),
            .fwd_ctrl(fwd_src_k));

fwd U_fwd_d(
            .reg_out(id_rd_from_fwd),
            .reg_from_gr(id_rd_from_gr),
            .reg_from_ex(ex_exe_out),
            .reg_from_mm1(ex_mm1.exe_out),
            .reg_from_mm2(mm1_mm2.exe_out),
            .mem_from_mm2(mm2_rdata),
            .reg_from_wb(wb_gr_wdata),
            .fwd_ctrl(fwd_src_d));

reg_id_ex id_ex(
            .clk(clk),
            .rst_n(rst_n),
            .wen(id_ex_wen),
            .flush(id_ex_flush),
            .bp_flush(id_ex_bp_flush),
            .id_pc(if2_id.pc),
            .id_rj_from_fwd(id_rj_from_fwd),
            .id_rk_from_fwd(id_rk_from_fwd),
            .id_rd_from_fwd(id_rd_from_fwd),
            .id_reg_d(id_reg_d),
            .id_reg_j(id_reg_j),
            .id_reg_k(id_reg_k),
            .id_op(id_op),
            .id_op_type(id_op_type),
            .id_imm(id_imm),
            .id_imm_sz(id_imm_sz),
            .id_bns_code(id_bns_code),
            .id_shift_imm(id_shift_imm),
            .id_u12imm(id_u12imm),
            .id_flag_unsigned(id_flag_unsigned),
            .id_access_sz(id_access_sz),
            .id_is_branch(id_is_branch),
            .id_csr_addr(id_csr_addr),
            .id_branch_bp(if2_id.branch_bp),
            .id_reg_j_ren(id_reg_j_ren),
            .id_reg_k_ren(id_reg_k_ren),
            .id_reg_d_ren(id_reg_d_ren));

alu_in2_mux U_alu_in2_mux(
            .alu_in2(ex_alu_in2),
            .op(id_ex.op),
            .op_type(id_ex.op_type),
            .rk_from_fwd(id_ex.rk_from_fwd),
            .imm_unext(id_ex.imm),
            .imm_sz(id_ex.imm_sz),
            .shift_imm(id_ex.shift_imm),
            .flag_unsigned(id_ex.flag_unsigned));

alu U_alu(
            .alu_in1(id_ex.rj_from_fwd),
            .alu_in2(ex_alu_in2),
            .alu_op(id_ex.op),
            .alu_out(ex_alu_out),
            .alu_zero(ex_alu_zero));

mul U_mul(
            .clk(clk),
            .rst_n(rst_n),
            .op(id_ex.op),
            .mul_in_a(id_ex.rj_from_fwd),
            .mul_in_b(id_ex.rk_from_fwd),
            .mul_out(ex_mul_out),
            .mul_out_valid(ex_mul_out_valid));

div U_div(
            .clk(clk),
            .rst_n(rst_n),
            .op(id_ex.op),
            .div_in_dividend(id_ex.rj_from_fwd),
            .div_in_divisor(id_ex.rk_from_fwd),
            .div_out(ex_div_out),
            .div_out_valid(ex_div_out_valid));

branch U_branch(
            .branch(ex_branch),
            .op(id_ex.op),
            .op_type(id_ex.op_type),
            .rj(id_ex.rj_from_fwd),
            .rd(id_ex.rd_from_fwd));

pc_branch U_pc_branch(
            .pc_branch(ex_pc_branch),
            .op(id_ex.op),
            .rj(id_ex.rj_from_fwd),
            .pc(id_ex.pc),
            .offset(id_ex.imm));

ex_ctrl U_ex_ctrl(
            .op(id_ex.op),
            .op_type(id_ex.op_type),
            .alu_out(ex_alu_out),
            .mul_out(ex_mul_out),
            .mul_out_valid(ex_mul_out_valid),
            .div_out(ex_div_out),
            .div_out_valid(ex_div_out_valid),
            .ex_access_sz(id_ex.access_sz),
            .ex_rd_from_fwd(id_ex.rd_from_fwd),
            .mm_access_sz(ex_mm_access_sz),
            .mm_addr(ex_mm_addr),
            .exe_out(ex_exe_out),
            .exe_out_valid(ex_exe_out_valid),
            .mm_re(ex_mm_re),
            .mm_we(ex_mm_we),
            .mm_wdata(ex_mm_wdata),
            .reg_d_wen(ex_reg_d_wen),
            .pc(id_ex.pc),
            .u12imm(id_ex.u12imm));

reg_ex_mm1 ex_mm1(
            .clk(clk),
            .rst_n(rst_n),
            .wen(ex_mm1_wen),
            .ex_csr_wdata(id_ex.id_rd_from_fwd),
            .ex_csr_wmask(id_ex.id_rj_from_fwd),
            .ex_csr_addr(id_ex.csr_addr),
            .flush(ex_mm1_flush),
            .ex_exe_out(ex_exe_out),
            .ex_mm_access_sz(ex_mm_access_sz),
            .ex_mm_addr(ex_mm_addr),
            .ex_mm_re(ex_mm_re),
            .ex_mm_we(ex_mm_we),
            .ex_mm_wdata(ex_mm_wdata),
            .ex_reg_d(id_ex.reg_d),
            .ex_op(id_ex.op),
            .ex_op_type(id_ex.op_type),
            .ex_reg_d_wen(ex_reg_d_wen),
            .ex_pc(id_ex.pc));

// dcache U_dcache(
//             .clk(clk),
//             .rst_n(rst_n),
//             .re(ex_mm1.mm_re),
//             .raddr(ex_mm1.mm_addr),
//             .we(ex_mm1.mm_we),
//             .waddr(ex_mm1.mm_addr),
//             .wdata(ex_mm1.mm_wdata),
//             .wsz(ex_mm1.mm_access_sz),
//             .rdata(mm2_rdata),
//             .hit(mm2_hit));

assign data_cache_re = ex_mm1.mm_re;
assign data_cache_raddr = ex_mm1.mm_addr;
assign data_cache_we = ex_mm1.mm_we;
assign data_cache_waddr = ex_mm1.mm_addr;
assign data_cache_wdata = ex_mm1.mm_wdata;
assign data_cache_access_sz = ex_mm1.mm_access_sz;
assign mm2_rdata = data_cache_rdata >> {mm1_mm2.mm_addr_l, 3'b000};
assign mm2_hit = data_cache_hit;

reg_mm1_mm2 mm1_mm2(
            .clk(clk),
            .rst_n(rst_n),
            .wen(mm1_mm2_wen),
            .flush(mm1_mm2_flush),
            .mm1_csr_wdata(ex_mm1.csr_wdata),
            .mm1_csr_wmask(ex_mm1.csr_wmask),
            .mm1_csr_addr(ex_mm1.csr_addr),
            .mm1_exe_out(ex_mm1.exe_out),
            .mm1_mm_access_sz(ex_mm1.mm_access_sz),
            .mm1_mm_addr_l(ex_mm1.mm_addr[1:0]),
            .mm1_mm_re(ex_mm1.mm_re),
            .mm1_reg_d(ex_mm1.reg_d),
            .mm1_op(ex_mm1.op),
            .mm1_op_type(ex_mm1.op_type),
            .mm1_reg_d_wen(ex_mm1.reg_d_wen),
            .mm1_pc(ex_mm1.pc));

reg_mm2_wb mm2_wb(
            .clk(clk),
            .rst_n(rst_n),
            .wen(mm2_wb_wen),
            .mm2_csr_wdata(mm1_mm2.csr_wdata),
            .mm2_csr_wmask(mm1_mm2.csr_wmask),
            .mm2_csr_addr(mm1_mm2.csr_addr),
            .flush(mm2_wb_flush),
            .mm2_exe_out(mm1_mm2.exe_out),
            .mm2_reg_d(mm1_mm2.reg_d),
            .mm2_op(mm1_mm2.op),
            .mm2_op_type(mm1_mm2.op_type),
            .mm2_rdata(mm2_rdata),
            .mm2_mm_access_sz(mm1_mm2.mm_access_sz),
            .mm2_reg_d_wen(mm1_mm2.reg_d_wen),
            .mm2_pc(mm1_mm2.pc));

regwrite U_regwrite(
            .exe_out(mm2_wb.exe_out),
            .reg_d(mm2_wb.reg_d),
            .op(mm2_wb.op),
            // .op_type(mm2_wb.op_type),
            .wb_mm_access_sz(mm2_wb.mm_access_sz),
            .rdata(mm2_wb.rdata),
            .gr_waddr(wb_gr_waddr),
            .gr_wdata(wb_gr_wdata));

endmodule
