module regwrite (
//output
        gr_we,
        gr_waddr,
        gr_wdata,
//input
        exe_out,
        reg_d,
        op,
        op_type,
        rdata);

input wire[31:0] exe_out;
input wire[4:0] reg_d;
input wire[7:0] op;
input wire[2:0] op_type;
input wire[31:0] rdata;

output reg gr_we;
output reg[4:0] gr_waddr;
output reg[31:0] gr_wdata;

always @(*) begin
    gr_we = (op_type == `OP_TYPE_3R && (op != `OP_BREAK && op != `OP_SYSCALL)) || 
            (op_type == `OP_TYPE_2RI12 && (op != `OP_ST && op != `OP_CACOP)) ||
            (op_type == `OP_TYPE_BJ && (op == `OP_JIRL)) ||
            (op_type == `OP_TYPE_ATOMIC && (op == `OP_LL)) ||
            (op_type == `OP_TYPE_CSR) ||
            (op_type == `OP_TYPE_U12I);
end

always @(*) begin
    if(op == `OP_LL || op == `OP_LD || op == `OP_LDU) begin
        gr_wdata = rdata;
    end
    else begin
        gr_wdata = exe_out;
    end
end

always @(*) begin
    gr_waddr = reg_d;
end
    
endmodule