
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
        reg_d_wen,
//input
        // clk,
        // rst_n,
        // mul需要时序逻辑
        op,
        op_type,
        alu_out,
        ex_access_sz,
        ex_rd_from_gr,
        pc,
        u12imm);

input wire [7:0] op;
input wire [2:0] op_type;
input wire [31:0] alu_out;
input wire [2:0] ex_access_sz;
input wire [31:0] ex_rd_from_gr;
input wire [31:0] pc;
input wire [19:0] u12imm;

// output reg [2:0] mm_access_op;
output reg [2:0] mm_access_sz;
output reg [31:0] mm_addr;
output reg [31:0] exe_out;
output reg mm_re;
output reg mm_we;
output reg [31:0] mm_wdata;
output reg reg_d_wen;

always @(*) begin
    mm_addr = alu_out;
end

always @(*) begin
    if(op == `OP_LU12I) begin
        exe_out = {u12imm,12'b0};
    end
    else if(op == `OP_PCADDU12I) begin
        exe_out = pc + {u12imm,12'b0};
    end
    else begin
        exe_out = alu_out;
    end
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

always @(*) begin
    reg_d_wen = (op_type == `OP_TYPE_3R && (op != `OP_BREAK && op != `OP_SYSCALL)) || 
            (op_type == `OP_TYPE_2RI12 && (op != `OP_ST && op != `OP_CACOP)) ||
            (op_type == `OP_TYPE_BJ && (op == `OP_JIRL)) ||
            (op_type == `OP_TYPE_ATOMIC && (op == `OP_LL)) ||
            (op_type == `OP_TYPE_CSR) ||
            (op_type == `OP_TYPE_U12I);
end
    
endmodule