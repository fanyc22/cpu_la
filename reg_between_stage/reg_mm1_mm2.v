`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module reg_mm1_mm2 (
//output

//input
            clk,
            rst_n,
            flush,
            wen,
            mm1_adef,
            mm1_sys,
            mm1_brk,
            mm1_ine,
            mm1_ale,
            mm1_interrupt,
            mm1_ertn,
            mm1_sbcode,
            mm1_flush_before,
            mm1_csr_wdata,
            mm1_csr_wmask,
            mm1_csr_addr,
            mm1_csr_re,
            mm1_csr_we,
            mm1_exe_out,
            mm1_mm_access_sz,
            mm1_mm_addr,
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
input wire mm1_adef;
input wire mm1_sys;
input wire mm1_brk;
input wire mm1_ine;
input wire mm1_ale;
input wire mm1_interrupt;
input wire mm1_ertn;
input wire [14:0] mm1_sbcode;
input wire mm1_flush_before;
input wire [31:0] mm1_csr_wdata;
input wire [31:0] mm1_csr_wmask;
input wire [13:0] mm1_csr_addr;
input wire mm1_csr_re;
input wire mm1_csr_we;
input wire [31:0] mm1_exe_out;
input wire [1:0] mm1_mm_access_sz;
input wire [31:0] mm1_mm_addr;
input wire mm1_mm_re;
input wire [4:0] mm1_reg_d;
input wire [7:0] mm1_op;
input wire [3:0] mm1_op_type;
input wire mm1_reg_d_wen;
input wire [31:0] mm1_pc;

reg adef;
reg sys;
reg brk;
reg ine;
reg ale;
reg interrupt;
reg ertn;
reg [14:0] sbcode;
reg flush_before;
reg [31:0] csr_wdata;
reg [31:0] csr_wmask;
reg [31:0] csr_addr;
reg csr_re;
reg csr_we;
reg [31:0] exe_out;
reg [1:0] mm_access_sz;
reg [31:0] mm_addr;
reg mm_re;
reg [4:0] reg_d;
reg [7:0] op;
reg [3:0] op_type;
reg reg_d_wen;
reg [31:0] pc;

always @(posedge clk ) begin
    if(!rst_n) begin
        adef <= 1'b0;
        sys <= 1'b0;
        brk <= 1'b0;
        ine <= 1'b0;
        ale <= 1'b0;
        interrupt <= 1'b0;
        ertn <= 1'b0;
        sbcode <= 15'b0;
        flush_before <= 1'b0;
        csr_wdata <= 32'b0;
        csr_wmask <= 32'b0;
        csr_addr <= 32'b0;
        csr_re <= 1'b0;
        csr_we <= 1'b0;
        exe_out <= 32'b0;
        mm_access_sz <= 3'b0;
        mm_addr <= 2'b0;
        mm_re <= 1'b0;
        reg_d <= 5'b0;
        op <= 8'b0;
        op_type <= 3'b0;
        reg_d_wen <= 1'b0;
        pc <= 32'b0;
    end
    else if(wen) begin
        adef <= mm1_adef;
        sys <= mm1_sys;
        brk <= mm1_brk;
        ine <= mm1_ine;
        ale <= mm1_ale;
        interrupt <= mm1_interrupt;
        ertn <= mm1_ertn;
        sbcode <= mm1_sbcode;
        flush_before <= mm1_flush_before;
        csr_wdata <= mm1_csr_wdata;
        csr_wmask <= mm1_csr_wmask;
        csr_addr <= mm1_csr_addr;
        csr_re <= mm1_csr_re;
        csr_we <= mm1_csr_we;
        exe_out <= mm1_exe_out;
        mm_access_sz <= mm1_mm_access_sz;
        mm_addr <= mm1_mm_addr;
        mm_re <= mm1_mm_re;
        reg_d <= mm1_reg_d;
        op <= mm1_op;
        op_type <= mm1_op_type;
        reg_d_wen <= mm1_reg_d_wen;
        pc <= flush ? 32'b0 : mm1_pc;
    end
end
    
endmodule