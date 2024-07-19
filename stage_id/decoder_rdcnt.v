`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module decoder_rdcnt (
//output
            op,
//input
            inst);

input wire [31:0] inst;
output reg [7:0] op;

always @(*) begin
    if(& inst[31:15])
        op = `OP_INVALID;
    else begin
        case (inst[14:10])
            5'b11000: op = `OP_RDCNT;
            5'b11001: op = `OP_RDCNTH;
            default: op = `OP_INVALID;
        endcase
    end
end

endmodule