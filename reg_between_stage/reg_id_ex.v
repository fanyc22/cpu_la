`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module reg_id_ex (
//output

//input
            clk,
            rst_n,
            wen,
            flush,
            bp_flush,
            id_pc,
            id_rj_from_fwd,
            id_rk_from_fwd,
            id_rd_from_fwd,
            id_reg_d,
            id_reg_j,
            id_reg_k,
            id_op,
            id_op_type,
            id_imm,
            id_imm_sz,
            id_bns_code,
            id_shift_imm,
            id_u12imm,
            id_flag_unsigned,
            id_access_sz,
            id_is_branch,
            id_csr_addr,
            id_branch_bp,
            id_reg_j_ren,
            id_reg_k_ren,
            id_reg_d_ren);
    
input wire clk;
input wire rst_n;
input wire wen;
input wire flush;
input wire bp_flush;
input wire [31:0] id_pc;
input wire [31:0] id_rj_from_fwd;
input wire [31:0] id_rk_from_fwd;
input wire [31:0] id_rd_from_fwd;
input wire [4:0] id_reg_d;
input wire [4:0] id_reg_j;
input wire [4:0] id_reg_k;
input wire [7:0] id_op;
input wire [3:0] id_op_type;
input wire [25:0] id_imm;
input wire [2:0] id_imm_sz;
input wire [14:0] id_bns_code;
input wire [4:0] id_shift_imm;
input wire [19:0] id_u12imm;
input wire id_flag_unsigned;
input wire [1:0] id_access_sz;
input wire id_is_branch;
input wire [13:0] id_csr_addr;
input wire id_branch_bp;
input wire id_reg_j_ren;
input wire id_reg_k_ren;
input wire id_reg_d_ren;

reg [31:0] pc;
reg [31:0] rj_from_fwd;
reg [31:0] rk_from_fwd;
reg [31:0] rd_from_fwd;
reg [4:0] reg_d;
reg [4:0] reg_j;
reg [4:0] reg_k;
reg [7:0] op;
reg [3:0] op_type;
reg [25:0] imm;
reg [2:0] imm_sz;
reg [14:0] bns_code;
reg [4:0] shift_imm;
reg [19:0] u12imm;
reg flag_unsigned;
reg [1:0] access_sz;
reg is_branch;
reg [13:0] csr_addr;
reg branch_bp;
reg reg_j_ren;
reg reg_k_ren;
reg reg_d_ren;

always @(posedge clk ) begin
    if(!rst_n) begin
        pc <= 32'b0;
        rj_from_fwd <= 32'b0;
        rk_from_fwd <= 32'b0;
        rd_from_fwd <= 32'b0;
        reg_d <= 5'b0;
        reg_j <= 5'b0;
        reg_k <= 5'b0;
        op <= 8'b0;
        op_type <= 3'b0;
        imm <= 26'b0;
        imm_sz <= 3'b0;
        bns_code <= 15'b0;
        shift_imm <= 5'b0;
        u12imm <= 20'b0;
        flag_unsigned <= 1'b0;
        access_sz <= 3'b0;
        is_branch <= 1'b0;
        csr_addr <= 14'b0;
        branch_bp <= 1'b0;
        reg_j_ren <= 1'b0;
        reg_k_ren <= 1'b0;
        reg_d_ren <= 1'b0;
    end
    else if(wen) begin
        pc <= flush ? 0 : id_pc;
        rj_from_fwd <= flush ? 0 : id_rj_from_fwd;
        rk_from_fwd <= flush ? 0 : id_rk_from_fwd;
        rd_from_fwd <= flush ? 0 : id_rd_from_fwd;
        reg_d <= flush ? 5'b0 : id_reg_d;
        reg_j <= flush ? 5'b0 : id_reg_j;
        reg_k <= flush ? 5'b0 : id_reg_k;
        op <= flush ? 8'b0 : id_op;
        op_type <= flush ? 3'b0 : id_op_type;
        imm <= flush ? 26'b0 : id_imm;
        imm_sz <= flush ? 3'b0 : id_imm_sz;
        bns_code <= flush ? 15'b0 : id_bns_code;
        shift_imm <= flush ? 5'b0 : id_shift_imm;
        u12imm <= flush ? 20'b0 : id_u12imm;
        flag_unsigned <= flush ? 1'b0 : id_flag_unsigned;
        access_sz <= flush ? 3'b0 : id_access_sz;
        is_branch <= flush ? 1'b0 : id_is_branch;
        csr_addr <= flush ? 14'b0 : id_csr_addr;
        branch_bp <= flush ? 1'b0 : (bp_flush? 0 : id_branch_bp);
        reg_j_ren <= flush ? 1'b0 : id_reg_j_ren;
        reg_k_ren <= flush ? 1'b0 : id_reg_k_ren;
        reg_d_ren <= flush ? 1'b0 : id_reg_d_ren;
    end
end

endmodule