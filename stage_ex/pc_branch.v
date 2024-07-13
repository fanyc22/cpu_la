`include "/Users/fanyuchen/Desktop/la/cpu/defs.v"
module pc_branch (
//output
            pc_branch,
//input
            op,
            rj,
            pc,
            offset);

input wire [7:0] op;
input wire [31:0] rj;
input wire [31:0] pc;
input wire [25:0] offset;

output reg [31:0] pc_branch;

always @(*) begin
    case (op)
        `OP_JIRL: pc_branch = rj+{{16{offset[15]}}, offset[15:0]};
        `OP_B: pc_branch = pc + {{6{offset[25]}}, offset[25:0]};
        `OP_BL: pc_branch = pc + {{6{offset[25]}}, offset[25:0]};
        default: pc_branch = pc + {{16{offset[15]}}, offset[15:0]};
    endcase
end
    
endmodule