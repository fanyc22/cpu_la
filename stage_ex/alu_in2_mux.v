`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module alu_in2_mux (
//output
    alu_in2,
//input
    op,
    op_type,
    rk_from_fwd,
    imm_unext,
    imm_sz,
    shift_imm,
    flag_unsigned);

input wire [7:0] op;
input wire [3:0] op_type;
input wire [31:0] rk_from_fwd;
input wire [25:0] imm_unext;
input wire [2:0] imm_sz;
input wire [4:0] shift_imm;
input wire flag_unsigned;

output reg [31:0] alu_in2;

reg [31:0] imm_ext;

always @(*) begin
    case (imm_sz)
        `IMM_SZ_8: imm_ext = {{24{imm_unext[7]}}, imm_unext[7:0]};
        `IMM_SZ_12: imm_ext = flag_unsigned ? {20'd0, imm_unext[11:0]} : {{20{imm_unext[11]}}, imm_unext[11:0]};
        `IMM_SZ_14: imm_ext = {{18{imm_unext[13]}}, imm_unext[13:0]};
        default: imm_ext = 32'd0;
    endcase
end

always @(*) begin
    if(op_type == `OP_TYPE_3R && op != `OP_SLLI && op != `OP_SRAI && op != `OP_SRLI) begin
        alu_in2 = rk_from_fwd;
    end
    else if(op_type == `OP_TYPE_3R) begin 
        alu_in2 = {27'd0, shift_imm};
    end
    else  begin
        alu_in2 = imm_ext;
    end
end

endmodule