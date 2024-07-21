`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
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
            5'b11000: op = (inst[9:5] == 5'b00000) ? `OP_RDCNTVL : `OP_RDCNTID;
            5'b11001: op = `OP_RDCNTVH;
            default: op = `OP_INVALID;
        endcase
    end
end

endmodule