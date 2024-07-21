`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module ex_ctrl (
//output
        // mm_access_op,
        ex_ale,
        ex_ertn,
        mm_access_sz,
        mm_re,
        mm_we,
        mm_addr,
        mm_wdata,
        csr_re,
        //reg_d,
        exe_out,
        exe_out_valid,
        reg_d_wen,
//input
        // clk,
        // rst_n,
        op,
        op_type,
        alu_out,
        mul_out,
        mul_out_valid,
        div_out,
        div_out_valid,
        ex_access_sz,
        ex_rd_from_fwd,
        pc,
        u12imm);

input wire [7:0] op;
input wire [3:0] op_type;
input wire [31:0] alu_out;
input wire [31:0] mul_out;
input wire mul_out_valid;
input wire [31:0] div_out;
input wire div_out_valid;
input wire [1:0] ex_access_sz;
input wire [31:0] ex_rd_from_fwd    ;
input wire [31:0] pc;
input wire [19:0] u12imm;

// output reg [2:0] mm_access_op;
output reg ex_ale;
output reg ex_ertn;
output reg [1:0] mm_access_sz;
output reg [31:0] mm_addr;
output reg [31:0] exe_out;
output reg exe_out_valid;
output reg mm_re;
output reg mm_we;
output reg [31:0] mm_wdata;
output reg csr_re;
output reg reg_d_wen;

always @(*) begin
    ex_ertn = op == `OP_ERTN;
end

always @(*) begin
    case (op)
        `OP_MUL:  exe_out_valid = mul_out_valid;
        `OP_MULH:  exe_out_valid = mul_out_valid;
        `OP_MULHU:  exe_out_valid = mul_out_valid;
        `OP_DIV:  exe_out_valid = div_out_valid;
        `OP_MOD:  exe_out_valid = div_out_valid;
        `OP_DIVU:  exe_out_valid = div_out_valid;
        `OP_MODU:  exe_out_valid = div_out_valid;
        default: exe_out_valid = 1'b1;
    endcase
end

always @(*) begin
    mm_addr = alu_out;
end

always @(*) begin
    case (op)
        `OP_LU12I:  exe_out = {u12imm,12'b0};
        `OP_PCADDU12I:  exe_out = pc + {u12imm,12'b0};
        `OP_BL:  exe_out = pc + 32'd4;
        `OP_JIRL:  exe_out = pc + 32'd4;
        `OP_MUL:  exe_out = mul_out;
        `OP_MULH:  exe_out = mul_out;
        `OP_MULHU:  exe_out = mul_out;
        `OP_DIV:  exe_out = div_out;
        `OP_MOD:  exe_out = div_out;
        `OP_DIVU:  exe_out = div_out;
        `OP_MODU:  exe_out = div_out;
        default: exe_out = alu_out;
    endcase
    // if(op == `OP_LU12I) begin
    //     exe_out = {u12imm,12'b0};
    // end
    // else if(op == `OP_PCADDU12I) begin
    //     exe_out = pc + {u12imm,12'b0};
    // end
    // else if (op == `OP_BL) begin
    //     exe_out = pc + 32'd4;
    // end
    // else begin
    //     exe_out = alu_out;
    // end
end

always @(*) begin
    mm_access_sz = ex_access_sz;
end

always @(*) begin
    mm_re = (op == `OP_LD) || (op == `OP_LDU) || (op == `OP_LL);
end

always @(*) begin
    csr_re = (op_type == `OP_TYPE_CSR) || op_type == `OP_TYPE_RDCNT;
end

always @(*) begin
    mm_we = (op == `OP_ST) || (op == `OP_SC);
end

always @(*) begin
    mm_wdata = ex_rd_from_fwd;
end

always @(*) begin
    reg_d_wen = (op_type == `OP_TYPE_3R && (op != `OP_BREAK && op != `OP_SYSCALL)) || 
            (op_type == `OP_TYPE_2RI12 && (op != `OP_ST && op != `OP_CACOP)) ||
            (op_type == `OP_TYPE_BJ && (op == `OP_JIRL || op == `OP_BL)) ||
            (op_type == `OP_TYPE_ATOMIC && (op == `OP_LL)) ||
            (op_type == `OP_TYPE_CSR) ||
            (op_type == `OP_TYPE_U12I)||
            (op_type == `OP_TYPE_RDCNT);
end

always @(*) begin
    if(mm_re||mm_we) begin
        case (mm_access_sz)
            `ACCESS_SZ_WORD: ex_ale = | mm_addr[1:0];
            `ACCESS_SZ_HALF: ex_ale = mm_addr[0];
            default: ex_ale = 1'b0;
        endcase
    end
    else begin
        ex_ale = 1'b0;
    end
end
    
endmodule