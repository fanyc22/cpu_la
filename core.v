`include "./stage_if1/pc.v"
`include "./stage_if2/bp.v"
`include "./icache.v"
`include "./reg_between_stage/reg_if1_if2.v"
`include "./reg_between_stage/reg_if2_id.v"
`include "./reg_between_stage/reg_id_ex.v"
`include "./reg_between_stage/reg_ex_mm1.v"
`include "./reg_between_stage/reg_mm1_mm2.v"
`include "./reg_between_stage/reg_mm2_wb.v"
`include "gr.v"
`include "./stage_id/decoder.v"

module core (
//output
            
//input
            clk,
            rst_n);

parameter WITH_CACHE = 0;
parameter WITH_TLB = 0;

input wire clk;
input wire rst_n;

wire if1_if2_flush;
wire if2_id_flush;
wire id_ex_flush;
wire ex_mm1_flush;
wire mm1_mm2_flush;
wire mm2_wb_flush;

wire if1_if2_wen;
wire if2_id_wen;
wire id_ex_wen;
wire ex_mm1_wen;
wire mm1_mm2_wen;

wire [31:0] if1_pc;

wire if2_branch_taken;
wire [31:0] if2_branch_address;
wire [31:0] if2_inst;
wire if2_icache_hit;

wire [31:0] id_rj_from_gr;
wire [31:0] id_rk_from_gr;
wire [4:0] id_reg_d;
wire [4:0] id_reg_j;
wire [4:0] id_reg_k;
wire [7:0] id_op;
wire [7:0] id_op_type;
wire [25:0] id_imm;
wire [2:0] id_imm_sz;
wire [14:0] id_bns_code;
wire [4:0] id_shift_imm;
wire [19:0] id_u12imm;
wire id_flag_unsigned;
wire [2:0] id_access_sz;
wire id_is_branch;

pc U_pc(
         .pc_reg(if1_pc),
         .rst_n(rst_n),
         .clk(clk),
         .enable(en_pc),
        //  .is_exception(flush),
        //  .exception_new_pc(exp_entry_addr),
         .is_branch(if2_branch_taken),
         .branch_address(if2_branch_address));

icache U_icache(
            .rdata(if2_inst),
            .hit(if2_icache_hit),
            .clk(clk),
            .rst_n(rst_n),
            .re(1'b1),
            .raddr(if1_pc),
            .we(1'b0),
            .waddr(32'b0),
            .wdata(32'b0),
            .wsz(3'b0));

reg_if1_if2 if1_if2(
            .clk(clk),
            .rst_n(rst_n),
            .wen(if1_if2_wen),
            .flush(if1_if2_flush),
            .if1_pc(if1_pc));

bp U_bp(
            .branch(if2_branch_taken),
            .target(if2_branch_address),
            .clk(clk),
            .rst_n(rst_n),
            .pc_low(if1_if2.pc[5:0])
            // .we(),
            // .hitted(),
            // .wtarget(),
            // .hit_addr()
            // TODO: add the rest of the signals
            );

reg_if2_id if2_id(
            .clk(clk),
            .rst_n(rst_n),
            .wen(if2_id_wen),
            .flush(if2_id_flush),
            .if2_pc(if1_if2.pc),
            .if2_inst(if2_inst),
            .if2_icache_hit(if2_icache_hit));

gr U_gr(
            .rdata1(id_rj_from_gr),
            .rdata2(id_rk_from_gr),
            .clk(clk),
            .rst_n(rst_n),
            // .we(),
            // .waddr(),
            // .wdata(),
            // TODO: add the rest of the signals
            .raddr1(id_reg_j),
            .raddr2(id_reg_k));

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
            .inst(if2_inst));

reg_id_ex id_ex(
            .clk(clk),
            .rst_n(rst_n),
            .wen(id_ex_wen),
            .flush(id_ex_flush),
            .id_pc(if2_id.pc),
            .id_rj_from_gr(id_rj_from_gr),
            .id_rk_from_gr(id_rk_from_gr),
            .id_reg_d(id_reg_d),
            .id_op(id_op),
            .id_op_type(id_op_type),
            .id_imm(id_imm),
            .id_imm_sz(id_imm_sz),
            .id_bns_code(id_bns_code),
            .id_shift_imm(id_shift_imm),
            .id_u12imm(id_u12imm),
            .id_flag_unsigned(id_flag_unsigned),
            .id_access_sz(id_access_sz),
            .id_is_branch(id_is_branch));

endmodule
