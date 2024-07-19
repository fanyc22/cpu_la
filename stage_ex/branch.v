`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module branch (
//output
            branch,
//input
            op,
            op_type,
            rj,
            rd);
    
input wire [7:0] op;
input wire [3:0] op_type;
input wire [31:0] rj;
input wire [31:0] rd;

wire signed [31:0] rj_s;
wire signed [31:0] rd_s;

assign rj_s = rj;
assign rd_s = rd;

output reg branch;

always @(*) begin
    if(op_type == `OP_TYPE_BJ) begin
        case(op)
            `OP_JIRL: branch = 1;
            `OP_B: branch = 1;
            `OP_BL: branch = 1;
            `OP_BEQ: branch = (rj_s == rd_s);
            `OP_BNE: branch = (rj_s != rd_s);
            `OP_BLT: branch = (rj_s < rd_s);
            `OP_BGE: branch = (rj_s >= rd_s);
            `OP_BLTU: branch = (rj < rd);
            `OP_BGEU: branch = (rj >= rd);
            default: branch = 0;
        endcase
    end
    else begin
        branch = 0;
    end
end

endmodule