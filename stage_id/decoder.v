// 暂时未考虑 BREAK 和 SYSCALL
`include "/Users/fanyuchen/Desktop/la/cpu/defs.v"
`include "/Users/fanyuchen/Desktop/la/cpu/stage_id/decoder_3r.v"
`include "/Users/fanyuchen/Desktop/la/cpu/stage_id/decoder_2ri12.v"
`include "/Users/fanyuchen/Desktop/la/cpu/stage_id/decoder_bj.v"
`include "/Users/fanyuchen/Desktop/la/cpu/stage_id/decoder_atomic.v"
`include "/Users/fanyuchen/Desktop/la/cpu/stage_id/decoder_csr.v"
`include "/Users/fanyuchen/Desktop/la/cpu/stage_id/decoder_u12i.v"

module decoder (
//output
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
            csr,
//input
            inst);

input wire [31:0] inst;

output reg [4:0] reg_d;
output reg [4:0] reg_j;
output reg [4:0] reg_k;
output reg [7:0] op;
output reg [2:0] op_type;
output reg [25:0] imm;
output reg [2:0] imm_sz;
output reg flag_unsigned;
output reg [2:0] access_sz;
output reg is_branch;
output reg [14:0] bns_code;
output reg [4:0] shift_imm;
output reg [19:0] u12imm;
output reg [13:0] csr;

wire [7:0] op_3r;
wire [7:0] op_2ri12;
wire [7:0] op_bj;
wire [7:0] op_atomic;
wire [7:0] op_csr;
wire [7:0] op_u12i;

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
        default: op = `OP_INVALID;
    endcase
end

always @(*) begin
    access_sz = inst[23:22];
end

always @(*) begin
    csr = inst[23:10];
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


endmodule