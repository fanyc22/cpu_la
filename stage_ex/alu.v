`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module alu (
//output
            alu_out,
            alu_zero,
            // overflow,
//input
            alu_in1,
            alu_in2,
            alu_op);
    

input wire[31:0] alu_in1;
input wire[31:0] alu_in2;
input wire[7:0] alu_op;

output reg[31:0] alu_out;
output reg alu_zero;
// output reg overflow;

wire signed [31:0] alu_in1_s ;
wire signed [31:0] alu_in2_s ;

wire [31:0] add_out;
wire [31:0] sub_out;
wire [31:0] and_out;
wire [31:0] or_out;
wire [31:0] nor_out;
wire [31:0] xor_out;
wire [31:0] sll_out;
wire [31:0] srl_out;
wire [31:0] sra_out;
wire lt_out;
wire ltu_out;
// wire eq_out;
// wire le_out;
// wire ge_out;
// wire geu_out;

assign alu_in1_s = alu_in1;
assign alu_in2_s = alu_in2;

assign add_out = alu_in1 + alu_in2;
assign sub_out = alu_in1 - alu_in2;
assign and_out = alu_in1 & alu_in2;
assign or_out = alu_in1 | alu_in2;
assign nor_out = ~(alu_in1 | alu_in2);
assign xor_out = alu_in1 ^ alu_in2;
assign sll_out = alu_in1 << alu_in2[4:0];
assign srl_out = alu_in1 >> alu_in2[4:0];
assign sra_out = alu_in1_s >>> alu_in2[4:0];
assign lt_out = alu_in1_s < alu_in2_s;
assign ltu_out = alu_in1 < alu_in2;
// assign eq_out = alu_in1 == alu_in2;
// assign le_out = alu_in1_s <= alu_in2_s;
// assign ge_out = alu_in1_s >= alu_in2_s;
// assign geu_out = alu_in1 >= alu_in2;


always @(*) begin
    case (alu_op)
        `OP_ADD: alu_out = add_out;
        `OP_SUB: alu_out = sub_out;
        `OP_AND: alu_out = and_out;
        `OP_OR: alu_out = or_out;
        `OP_NOR: alu_out = nor_out;
        `OP_XOR: alu_out = xor_out;
        `OP_SLL: alu_out = sll_out;
        `OP_SRL: alu_out = srl_out;
        `OP_SRA: alu_out = sra_out;
        `OP_SLT: alu_out = lt_out;
        `OP_SLTU: alu_out = ltu_out;
        //imm
        `OP_ADDI: alu_out = add_out;
        `OP_ANDI: alu_out = and_out;
        `OP_ORI: alu_out = or_out;
        `OP_XORI: alu_out = xor_out;
        `OP_SLLI: alu_out = sll_out;
        `OP_SRLI: alu_out = srl_out;
        `OP_SRAI: alu_out = sra_out;
        `OP_SLTI: alu_out = lt_out;
        `OP_SLTUI: alu_out = ltu_out;
        `OP_LD: alu_out = add_out;
        `OP_ST: alu_out = add_out;
        `OP_LDU: alu_out = add_out;
        //atomic
        `OP_LL: alu_out = add_out;
        `OP_SC: alu_out = add_out;
        //u12i
        `OP_PCADDU12I: alu_out = add_out;
        //bj
        // `OP_JIRL: alu_out = add_out;
        // `OP_BEQ: alu_out = eq_out;
        // `OP_BLT: alu_out = lt_out;
        // `OP_BGE: alu_out = ge_out;
        // `OP_BLTU: alu_out = ltu_out;
        // `OP_BGEU: alu_out = geu_out;
        default: alu_out = add_out;
    endcase
end

always @(*) begin
    alu_zero = (alu_out == 0);
end

endmodule