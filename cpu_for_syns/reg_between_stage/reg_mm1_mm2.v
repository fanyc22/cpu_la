module reg_mm1_mm2 (
//output

//input
            clk,
            rst_n,
            flush,
            wen,
            mm1_exe_out,
            mm1_mm_access_sz,
            mm1_mm_re,
            mm1_reg_d,
            mm1_op,
            mm1_op_type,
            mm1_reg_d_wen,
            mm1_pc);

input wire clk;
input wire rst_n;
input wire flush;
input wire wen;
input wire [31:0] mm1_exe_out;
input wire [2:0] mm1_mm_access_sz;
input wire mm1_mm_re;
input wire [4:0] mm1_reg_d;
input wire [7:0] mm1_op;
input wire [2:0] mm1_op_type;
input wire mm1_reg_d_wen;
input wire [31:0] mm1_pc;

reg [31:0] exe_out;
reg [2:0] mm_access_sz;
reg mm_re;
reg [4:0] reg_d;
reg [7:0] op;
reg [2:0] op_type;
reg reg_d_wen;
reg [31:0] pc;

always @(posedge clk ) begin
    if(!rst_n) begin
        exe_out <= 32'b0;
        mm_access_sz <= 3'b0;
        mm_re <= 1'b0;
        reg_d <= 5'b0;
        op <= 8'b0;
        op_type <= 3'b0;
        reg_d_wen <= 1'b0;
        pc <= 32'b0;
    end
    else if(wen) begin
        exe_out <= mm1_exe_out;
        mm_access_sz <= mm1_mm_access_sz;
        mm_re <= mm1_mm_re;
        reg_d <= mm1_reg_d;
        op <= mm1_op;
        op_type <= mm1_op_type;
        reg_d_wen <= mm1_reg_d_wen;
        pc <= flush ? 32'b0 : mm1_pc;
    end
end
    
endmodule