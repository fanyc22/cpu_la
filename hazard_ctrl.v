`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"

module hazard_ctrl (
//output
        if1_if2_flush,
        if2_id_flush,
        id_ex_flush,
        ex_mm1_flush,
        mm1_mm2_flush,
        mm2_wb_flush,
        if1_if2_wen,
        if2_id_wen,
        id_ex_wen,
        id_ex_bp_flush,
        ex_mm1_wen,
        mm1_mm2_wen,
        mm2_wb_wen,
        pc_wen,
        fwd_src_j,
        fwd_src_k,
        fwd_src_d,
        pc_is_wrong,
        pc_correct,
//input
        ex_exe_out_valid,

        ex_pc,
        ex_branch,
        ex_pc_branch,
        ex_branch_bp,
        id_pc,

        id_is_branch,
        id_branch_bp,

        id_reg_j_ren,
        id_reg_j,
        id_reg_k_ren,
        id_reg_k,
        id_reg_d_ren,
        id_reg_d,
        ex_reg_d_wen,
        ex_reg_d,
        ex_mm_load,
        mm1_reg_d_wen,
        mm1_reg_d,
        mm1_mm_load,
        mm2_reg_d_wen,
        mm2_reg_d,
        mm2_mm_load,
        wb_reg_d_wen,
        wb_reg_d);

input wire ex_exe_out_valid;

input wire[31:0] ex_pc;
input wire[31:0] id_pc;

input wire ex_branch;
input wire [31:0] ex_pc_branch;
input wire ex_branch_bp;

input wire id_is_branch;
input wire id_branch_bp;
    
input wire id_reg_j_ren;
input wire[4:0] id_reg_j;
input wire id_reg_k_ren;
input wire[4:0] id_reg_k;
input wire id_reg_d_ren;
input wire[4:0] id_reg_d;
input wire ex_reg_d_wen;
input wire[4:0] ex_reg_d;
input wire ex_mm_load;
input wire mm1_reg_d_wen;
input wire[4:0] mm1_reg_d;
input wire mm1_mm_load;
input wire mm2_reg_d_wen;
input wire[4:0] mm2_reg_d;
input wire mm2_mm_load;
input wire wb_reg_d_wen;
input wire[4:0] wb_reg_d;

output reg pc_is_wrong;
output reg [31:0] pc_correct;

output reg if1_if2_flush;
output reg if2_id_flush;
output reg id_ex_flush;
output reg id_ex_bp_flush;
output reg ex_mm1_flush;
output reg mm1_mm2_flush;
output reg mm2_wb_flush;
output reg if1_if2_wen;
output reg if2_id_wen;
output reg id_ex_wen;
output reg ex_mm1_wen;
output reg mm1_mm2_wen;
output reg mm2_wb_wen;
output reg pc_wen;
output reg[2:0] fwd_src_j;
output reg[2:0] fwd_src_k;
output reg[2:0] fwd_src_d;

reg not_branch;
reg bp_fault;

reg lau_j;
reg lau_k;
reg lau_d;
wire lau;

assign lau = lau_j | lau_k | lau_d;

always @(*) begin
    if(id_reg_j_ren && id_reg_j)begin
        if(id_reg_j == ex_reg_d && ex_reg_d_wen) begin
            lau_j <= ex_mm_load;
            fwd_src_j <= `FWD_SRC_EX;
        end
        else if(id_reg_j == mm1_reg_d && mm1_reg_d_wen) begin
            lau_j <= mm1_mm_load;
            fwd_src_j <= `FWD_SRC_MM1;
        end
        else if(id_reg_j == mm2_reg_d && mm2_reg_d_wen) begin
            lau_j <= 0;
            fwd_src_j <= mm2_mm_load ? `FWD_SRC_MM2_MEM :`FWD_SRC_MM2_REG;
        end
        else if(id_reg_j == wb_reg_d && wb_reg_d_wen) begin
            lau_j <= 0;
            fwd_src_j <= `FWD_SRC_WB;
        end
        else begin
            lau_j <= 0;
            fwd_src_j <= `FWD_SRC_NONE;
        end
    end
    else begin
        lau_j <= 0;
        fwd_src_j <= `FWD_SRC_NONE;
    end
end

always @(*) begin
    if(id_reg_k_ren && id_reg_k)begin
        if(id_reg_k == ex_reg_d && ex_reg_d_wen) begin
            lau_k <= ex_mm_load;
            fwd_src_k <= `FWD_SRC_EX;
        end
        else if(id_reg_k == mm1_reg_d && mm1_reg_d_wen) begin
            lau_k <= mm1_mm_load;
            fwd_src_k <= `FWD_SRC_MM1;
        end
        else if(id_reg_k == mm2_reg_d && mm2_reg_d_wen) begin
            lau_k <= 0;
            fwd_src_k <= mm2_mm_load ? `FWD_SRC_MM2_MEM :`FWD_SRC_MM2_REG;
        end
        else if(id_reg_k == wb_reg_d && wb_reg_d_wen) begin
            lau_k <= 0;
            fwd_src_k <= `FWD_SRC_WB;
        end
        else begin
            lau_k <= 0;
            fwd_src_k <= `FWD_SRC_NONE;
        end
    end
    else begin
        lau_k <= 0;
        fwd_src_k <= `FWD_SRC_NONE;
    end
end

always @(*) begin
    if(id_reg_d_ren && id_reg_d)begin
        if(id_reg_d == ex_reg_d && ex_reg_d_wen) begin
            lau_d <= ex_mm_load;
            fwd_src_d <= `FWD_SRC_EX;
        end
        else if(id_reg_d == mm1_reg_d && mm1_reg_d_wen) begin
            lau_d <= mm1_mm_load;
            fwd_src_d <= `FWD_SRC_MM1;
        end
        else if(id_reg_d == mm2_reg_d && mm2_reg_d_wen) begin
            lau_d <= 0;
            fwd_src_d <= mm2_mm_load ? `FWD_SRC_MM2_MEM :`FWD_SRC_MM2_REG;
        end
        else if(id_reg_d == wb_reg_d && wb_reg_d_wen) begin
            lau_d <= 0;
            fwd_src_d <= `FWD_SRC_WB;
        end
        else begin
            lau_d <= 0;
            fwd_src_d <= `FWD_SRC_NONE;
        end
    end
    else begin
        lau_d <= 0;
        fwd_src_d <= `FWD_SRC_NONE;
    end
end

always @(*) begin
    bp_fault = (ex_branch != ex_branch_bp) ? 1 :
                (ex_branch && (ex_pc_branch != id_pc)) ? 1 : 0;
end

always @(*) begin
    not_branch = (!id_is_branch) && id_branch_bp;
end

always @(*) begin
    if(!ex_exe_out_valid) begin
        pc_wen <= 0;
        pc_is_wrong <= 0;
        pc_correct <= 32'h0;

        if1_if2_flush <= 0;
        if2_id_flush <= 0;
        id_ex_flush <= 0;
        ex_mm1_flush <= 1;
        mm1_mm2_flush <= 0;
        mm2_wb_flush <= 0;

        if1_if2_wen <= 0;
        if2_id_wen <= 0;
        id_ex_wen <= 0;
        id_ex_bp_flush <= 0;
        ex_mm1_wen <= 1;
        mm1_mm2_wen <= 1;
        mm2_wb_wen <= 1;
    end
    else if(lau) begin
        pc_wen <= 0;
        pc_is_wrong <= 0;
        pc_correct <= 32'h0;

        if1_if2_flush <= 0;
        if2_id_flush <= 0;
        id_ex_flush <= 1;
        ex_mm1_flush <= 0;
        mm1_mm2_flush <= 0;
        mm2_wb_flush <= 0;

        if1_if2_wen <= 0;
        if2_id_wen <= 0;
        id_ex_wen <= 1;
        id_ex_bp_flush <= 0;
        ex_mm1_wen <= 1;
        mm1_mm2_wen <= 1;
        mm2_wb_wen <= 1;
    end
    else if(bp_fault) begin
        pc_wen <= 1;
        pc_is_wrong <= 1;
        pc_correct <= ex_branch ? ex_pc_branch : ex_pc + 32'd4;

        if1_if2_flush <= 1;
        if2_id_flush <= 1;
        id_ex_flush <= 1;
        ex_mm1_flush <= 0;
        mm1_mm2_flush <= 0;
        mm2_wb_flush <= 0;

        if1_if2_wen <= 1;
        if2_id_wen <= 1;
        id_ex_wen <= 1;
        id_ex_bp_flush <= 0;
        ex_mm1_wen <= 1;
        mm1_mm2_wen <= 1;
        mm2_wb_wen <= 1;
    end
    else if(not_branch) begin
        pc_wen <= 1;
        pc_is_wrong <= 1;
        pc_correct <= id_pc + 32'd4;

        if1_if2_flush <= 1;
        if2_id_flush <= 1;
        id_ex_flush <= 0;
        ex_mm1_flush <= 0;
        mm1_mm2_flush <= 0;
        mm2_wb_flush <= 0;

        if1_if2_wen <= 1;
        if2_id_wen <= 1;
        id_ex_wen <= 1;
        id_ex_bp_flush <= 1;
        ex_mm1_wen <= 1;
        mm1_mm2_wen <= 1;
        mm2_wb_wen <= 1;
    end
    else begin
        pc_wen <= 1;
        pc_is_wrong <= 0;
        pc_correct <= 32'h0;

        if1_if2_flush <= 0;
        if2_id_flush <= 0;
        id_ex_flush <= 0;
        ex_mm1_flush <= 0;
        mm1_mm2_flush <= 0;
        mm2_wb_flush <= 0;

        if1_if2_wen <= 1;
        if2_id_wen <= 1;
        id_ex_wen <= 1;
        id_ex_bp_flush <= 0;
        ex_mm1_wen <= 1;
        mm1_mm2_wen <= 1;
        mm2_wb_wen <= 1;
    end
end

endmodule