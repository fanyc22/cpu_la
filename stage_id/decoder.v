`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
// 暂时未考虑 BREAK 和 SYSCALL

module decoder (
//output
            id_sys,
            id_brk,
            id_ine,
            id_ecode,
            reg_d,
            reg_j,
            reg_k,
            op,
            op_type,
            imm,
            imm_sz,
            bns_code,
            shift_imm,
            u12imm,
            flag_unsigned,
            access_sz,
            is_branch,
            csr_addr,
            reg_j_ren,
            reg_k_ren,
            reg_d_ren,
//input
            inst);

input wire [31:0] inst;

output reg id_sys;
output reg id_brk;
output reg id_ine;
output reg [14:0] id_ecode;
output reg [4:0] reg_d;
output reg [4:0] reg_j;
output reg [4:0] reg_k;
output reg [7:0] op;
output reg [3:0] op_type;
output reg [25:0] imm;
output reg [2:0] imm_sz;
output reg flag_unsigned;
output reg [2:0] access_sz;
output reg is_branch;
output reg [14:0] bns_code;
output reg [4:0] shift_imm;
output reg [19:0] u12imm;
output reg [13:0] csr_addr;
output reg reg_j_ren;
output reg reg_k_ren;
output reg reg_d_ren;

wire [7:0] op_3r;
wire [7:0] op_2ri12;
wire [7:0] op_bj;
wire [7:0] op_atomic;
wire [7:0] op_csr;
wire [7:0] op_u12i;
wire [7:0] op_rdcnt;
wire [7:0] op_etrn;

always@(*) begin
    reg_d <= inst[4:0];
    reg_j <= inst[9:5];
    reg_k <= inst[14:10];
end

always @(*) begin
    imm <= {inst[9:0],inst[25:10]};
    bns_code <= inst[14:0];
    shift_imm <= inst[14:10];
    u12imm <= inst[24:5];
end

always @(*) begin
    is_branch <= (inst[31:26] == 6'b010100 
    || inst[31:26] == 6'b010101
    || inst[31:26] == 6'b010110
    || inst[31:26] == 6'b010111
    || inst[31:26] == 6'b011000
    || inst[31:26] == 6'b011001
    || inst[31:26] == 6'b011010
    || inst[31:26] == 6'b011011);
end

decoder_3r U_decoder_3r(
            .inst(inst),
            .op(op_3r)
);

decoder_2ri12 U_decoder_2ri12(
            .inst(inst),
            .op(op_2ri12)
);

decoder_bj U_decoder_bj(
            .inst(inst),
            .op(op_bj)
);

decoder_atomic U_decoder_atomic(
            .inst(inst),
            .op(op_atomic)
);

decoder_csr U_decoder_csr(
            .inst(inst),
            .op(op_csr)
);

decoder_u12i U_decoder_u12i(
            .inst(inst),
            .op(op_u12i)
);

decoder_rdcnt U_decoder_rdcnt(
            .inst(inst),
            .op(op_rdcnt)
);

always @(*) begin
    if(inst == 32'b00000110_01001000_00111000_00000000)
        op_etrn = `OP_ETRN;
    else
        op_etrn = `OP_INVALID;
end

always @(*) begin
    if(op_2ri12 != `OP_INVALID) begin
        op_type = `OP_TYPE_2RI12;
    end
    else if(op_3r != `OP_INVALID) begin
        op_type = `OP_TYPE_3R;
    end
    else if(op_bj != `OP_INVALID) begin
        op_type = `OP_TYPE_BJ;
    end
    else if(op_atomic != `OP_INVALID) begin
        op_type = `OP_TYPE_ATOMIC;
    end
    else if(op_csr != `OP_INVALID) begin
        op_type = `OP_TYPE_CSR;
    end
    else if(op_u12i != `OP_INVALID) begin
        op_type = `OP_TYPE_U12I;
    end
    else if(op_rdcnt != `OP_INVALID) begin
        op_type = `OP_TYPE_RDCNT;
    end
    else if(op_etrn != `OP_INVALID) begin
        op_type = `OP_TYPE_ETRN;
    end
    else begin
        op_type = `OP_TYPE_INVALID;
    end
end

always @(*) begin
    case (op_type)
        `OP_TYPE_3R: op = op_3r;
        `OP_TYPE_2RI12: op = op_2ri12;
        `OP_TYPE_BJ: op = op_bj;
        `OP_TYPE_ATOMIC: op = op_atomic;
        `OP_TYPE_CSR: op = op_csr;
        `OP_TYPE_U12I: op = op_u12i;
        `OP_TYPE_RDCNT: op = op_rdcnt;
        `OP_TYPE_ETRN: op = op_etrn;
        default: op = `OP_INVALID;
    endcase
end

always @(*) begin
    access_sz = inst[23:22];
end

always @(*) begin
    csr_addr = inst[23:10];
end

always @(*) begin
    flag_unsigned = (inst[31:22]==10'b0000001101
                    ||inst[31:22]==10'b0000001110
                    ||inst[31:22]==10'b0000001111)?1:0;
end

always @(*) begin
    imm_sz <= inst[31:25] == 7'b0000001 ? `IMM_SZ_12 :
              inst[31:25] == 7'b0000011 ? `IMM_SZ_12 :
              inst[31:26] == 6'b001010 ? `IMM_SZ_12 :
              inst[31:26] == 6'b001000 ? `IMM_SZ_14 :
              inst[31:27] == 5'b01010 ? `IMM_SZ_16:
              inst[31:30] == 2'b01 ? `IMM_SZ_26 : `IMM_SZ_0;
end

always @(*) begin
    reg_j_ren = op != `OP_BREAK && 
                op != `OP_SYSCALL &&
                op != `OP_CSRRD &&
                op != `OP_CSRWR &&
                op != `OP_B &&
                op != `OP_BL &&
                op_type != `OP_TYPE_U12I;
end

always @(*) begin
    reg_k_ren = op_type == `OP_TYPE_3R &&
                op != `OP_BREAK &&
                op != `OP_SYSCALL;
end

always @(*) begin
    reg_d_ren = (op_type == `OP_TYPE_CSR && op != `OP_CSRRD) ||
                (op_type == `OP_TYPE_2RI12 && op == `OP_ST) ||
                (op_type == `OP_TYPE_BJ && op != `OP_JIRL && op != `OP_B && op != `OP_BL);
end

always @(*) begin
    id_sys <= (inst[32:15] == 17'b00000000001010100);
    id_brk <= (inst[32:15] == 17'b00000000001010110);
    id_ecode <= inst[14:0];
    id_ine <= (op_type == `OP_TYPE_INVALID);
end

endmodule