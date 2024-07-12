`include "defs.v"
module decoder_csr (
//output
            op,
//input
            inst);

input wire [31:0] inst;
output reg [7:0] op;

always @(*) begin
    if(inst[31:24] != 8'b00000100) begin
        op = `OP_INVAILD;
    end
    else begin
        case (inst[9:5])
            5'b00000: op = `OP_CSRRD;
            5'b00001: op = `OP_CSRWR;
            default: op = `OP_CSRXCHG;
        endcase
    end
end

endmodule