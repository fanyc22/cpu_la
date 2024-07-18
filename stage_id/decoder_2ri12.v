`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module decoder_2ri12 (
//output
            op,
//input
            inst);

input wire [31:0] inst;
output reg [7:0] op;

always @(*) begin
    casez (inst[31:22])
        10'b0000001000: op = `OP_SLTI;
        10'b0000001001: op = `OP_SLTUI;
        10'b0000001010: op = `OP_ADDI;
        10'b0000001101: op = `OP_ANDI;
        10'b0000001110: op = `OP_ORI;
        10'b0000001111: op = `OP_XORI;
        10'b0000011000: op = `OP_CACOP;
        10'b00101000??: op = `OP_LD;
        10'b00101001??: op = `OP_ST;
        10'b00101010??: op = `OP_LDU;
        default: op = `OP_INVALID;
    endcase
end

endmodule