`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module decoder_bj (
//output
            op,
//input
            inst);

input wire [31:0] inst;
output reg [7:0] op;

always @(*) begin
    case (inst[31:26])
        6'b010011: op = `OP_JIRL;
        6'b010100: op = `OP_B;
        6'b010101: op = `OP_BL;
        6'b010110: op = `OP_BEQ;
        6'b010111: op = `OP_BNE;
        6'b011000: op = `OP_BLT;
        6'b011001: op = `OP_BGE;
        6'b011010: op = `OP_BLTU;
        6'b011011: op = `OP_BGEU;
        default: op = `OP_INVALID;
    endcase
end

endmodule