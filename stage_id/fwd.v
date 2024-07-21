`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module fwd (
//output
        reg_out,
//input
        reg_from_gr,
        reg_from_ex,
        reg_from_mm1,
        reg_from_mm2,
        mem_from_mm2,
        reg_from_wb,
        fwd_ctrl);

input wire [2:0] fwd_ctrl;
input wire [31:0] reg_from_gr;
input wire [31:0] reg_from_ex;
input wire [31:0] reg_from_mm1;
input wire [31:0] reg_from_mm2;
input wire [31:0] mem_from_mm2;
input wire [31:0] reg_from_wb;

output reg [31:0] reg_out;
    
always @(*) begin
    case (fwd_ctrl)
        `FWD_SRC_EX: reg_out = reg_from_ex;
        `FWD_SRC_MM1: reg_out = reg_from_mm1;
        `FWD_SRC_MM2_REG: reg_out = reg_from_mm2;
        `FWD_SRC_MM2_MEM: reg_out = mem_from_mm2;
        `FWD_SRC_WB: reg_out = reg_from_wb;
        default: reg_out = reg_from_gr;
    endcase
end

endmodule