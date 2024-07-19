`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module reg_mm1_mm2 (
//output

//input
            clk,
            rst_n,
            flush,
            wen,
            mm1_csr_wdata,
            mm1_csr_wmask,
            mm1_csr_addr,
            mm1_exe_out,
            mm1_mm_access_sz,
            mm1_mm_addr_l,
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
input wire [31:0] mm1_csr_wdata;
input wire [31:0] mm1_csr_wmask;
input wire [13:0] mm1_csr_addr;
input wire [31:0] mm1_exe_out;
input wire [1:0] mm1_mm_access_sz;
input wire [1:0] mm1_mm_addr_l;
input wire mm1_mm_re;
input wire [4:0] mm1_reg_d;
input wire [7:0] mm1_op;
input wire [3:0] mm1_op_type;
input wire mm1_reg_d_wen;
input wire [31:0] mm1_pc;

reg [31:0] csr_wdata;
reg [31:0] csr_wmask;
reg [31:0] csr_addr;
reg [31:0] exe_out;
reg [1:0] mm_access_sz;
reg [1:0] mm_addr_l;
reg mm_re;
reg [4:0] reg_d;
reg [7:0] op;
reg [3:0] op_type;
reg reg_d_wen;
reg [31:0] pc;

always @(posedge clk ) begin
    if(!rst_n) begin
        csr_wdata <= 32'b0;
        csr_wmask <= 32'b0;
        csr_addr <= 32'b0;
        exe_out <= 32'b0;
        mm_access_sz <= 3'b0;
        mm_addr_l <= 2'b0;
        mm_re <= 1'b0;
        reg_d <= 5'b0;
        op <= 8'b0;
        op_type <= 3'b0;
        reg_d_wen <= 1'b0;
        pc <= 32'b0;
    end
    else if(wen) begin
        csr_wdata <= mm1_csr_wdata;
        csr_wmask <= mm1_csr_wmask;
        csr_addr <= mm1_csr_addr;
        exe_out <= mm1_exe_out;
        mm_access_sz <= mm1_mm_access_sz;
        mm_addr_l <= mm1_mm_addr_l;
        mm_re <= mm1_mm_re;
        reg_d <= mm1_reg_d;
        op <= mm1_op;
        op_type <= mm1_op_type;
        reg_d_wen <= mm1_reg_d_wen;
        pc <= flush ? 32'b0 : mm1_pc;
    end
end
    
endmodule