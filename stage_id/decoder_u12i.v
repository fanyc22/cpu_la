`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module decoder_u12i (
//output
            op,
//input
            inst);

input wire [31:0] inst;
output reg [7:0] op;

always @(*) begin
    case (inst[31:25])
        7'b0001010: op = `OP_LU12I;
        7'b0001110: op = `OP_PCADDU12I;
        default: op = `OP_INVALID;
    endcase
end

endmodule