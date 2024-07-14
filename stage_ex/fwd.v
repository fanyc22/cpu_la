`include "/Users/fanyuchen/Desktop/la/cpu_noram/defs.v"
module fwd (
//output
        reg_out,
//input
        reg_from_gr,
        reg_from_ex_mm1,
        reg_from_mm1_mm2,
        reg_from_mm2_wb,
        fwd_ctrl);

input wire [1:0] fwd_ctrl;
input wire [31:0] reg_from_gr;
input wire [31:0] reg_from_ex_mm1;
input wire [31:0] reg_from_mm1_mm2;
input wire [31:0] reg_from_mm2_wb;

output reg [31:0] reg_out;
    
always @(*) begin
    case (fwd_ctrl)
        `FWD_SRC_EX_MM1: reg_out = reg_from_ex_mm1;
        `FWD_SRC_MM1_MM2: reg_out = reg_from_mm1_mm2;
        `FWD_SRC_MM2_WB: reg_out = reg_from_mm2_wb;
        default: reg_out = reg_from_gr;
    endcase
end

endmodule