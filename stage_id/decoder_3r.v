`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module decoder_3r (
//output
            op,
//input
            inst);

input wire [31:0] inst;
output reg [7:0] op;

always @(*) begin
    if(inst[31:23] == 8'b00000000) begin
        case (inst[22:15])
            8'b00100000: op = `OP_ADD;
            8'b00100010: op = `OP_SUB;
            8'b00100100: op = `OP_SLT;
            8'b00100101: op = `OP_SLTU;
            8'b00101000: op = `OP_NOR;
            8'b00101001: op = `OP_AND;
            8'b00101010: op = `OP_OR;
            8'b00101011: op = `OP_XOR;
            8'b00101110: op = `OP_SLL;
            8'b00101111: op = `OP_SRL;
            8'b00110000: op = `OP_SRA;
            8'b00111000: op = `OP_MUL;
            8'b00111001: op = `OP_MULH;
            8'b00111010: op = `OP_MULHU;
            8'b01000000: op = `OP_DIV;
            8'b01000001: op = `OP_MOD;
            8'b01000010: op = `OP_DIVU;
            8'b01000011: op = `OP_MODU;
            8'b01010100: op = `OP_BREAK;
            8'b01010110: op = `OP_SYSCALL;
            8'b10000001: op = `OP_SLLI;
            8'b10001001: op = `OP_SRLI;
            8'b10010001: op = `OP_SRAI;
            default: op = `OP_INVALID;
        endcase
    end
    else begin
        op = `OP_INVALID;
    end
end

endmodule