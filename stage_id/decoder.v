// 暂时未考虑 BREAK 和 SYSCALL
`include "defs.v"
`include "./stage_id/decoder_3r.v"
`include "./stage_id/decoder_2ri12.v"

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
//input
            inst);

input wire [31:0] inst;

output reg [4:0] reg_d;
output reg [4:0] reg_j;
output reg [4:0] reg_k;
output reg [7:0] op;
output reg [7:0] op_type;
output reg [25:0] imm;
output reg [2:0] imm_sz;
output reg flag_unsigned;
output reg [2:0] access_sz;
output reg is_branch;
output reg [14:0] bns_code;
output reg [4:0] shift_imm;
output reg [19:0] u12imm;

wire [7:0] op_3r;
wire [7:0] op_2ri12;

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

// always @(*) begin
//     imm_sz <= inst[31:25] == 7'b0000001 ? `IMM_SZ_12 :
//               inst[31:25] == 7'b0000011 ? `IMM_SZ_12 :
//               inst[31:26] == 6'b001010 ? `IMM_SZ_12 :
//               inst[31:26] == 6'b001000 ? `IMM_SZ_14 :

// end


endmodule