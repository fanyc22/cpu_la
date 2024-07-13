`include "defs.v"

module ex_ctrl (
//output
        // mm_access_op,
        mm_access_sz,
        mm_re,
        mm_we,
        mm_addr,
        mm_wdata,
        //reg_d,
        exe_out,
//input
        // clk,
        // rst_n,
        // mul需要时序逻辑
        op,
        op_type,
        alu_out,
        ex_access_sz,
        ex_rd_from_gr);

input wire [7:0] op;
input wire [7:0] op_type;
input wire [31:0] alu_out;
input wire [2:0] ex_access_sz;
input wire [31:0] ex_rd_from_gr;

// output reg [2:0] mm_access_op;
output reg [2:0] mm_access_sz;
output reg [31:0] mm_addr;
output reg [31:0] ex_out;
output reg mm_re;
output reg mm_we;
output reg [31:0] mm_wdata;

always @(*) begin
    mm_addr = alu_out;
end

always @(*) begin
    exe_out = alu_out;
end

always @(*) begin
    mm_access_sz = ex_access_sz;
end

always @(*) begin
    mm_re = (op == `OP_LD) || (op == `OP_LDU) || (op == `OP_LL);
end

always @(*) begin
    mm_we = (op == `OP_ST) || (op == `OP_SC);
end

always @(*) begin
    mm_wdata = ex_rd_from_gr;
end
    
endmodule