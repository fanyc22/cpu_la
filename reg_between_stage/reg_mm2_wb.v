`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module reg_mm2_wb (
//output

//input
            clk,
            rst_n,
            flush,
            wen,
            mm2_csr_we,
            mm2_ecode,
            mm2_esubcode,
            mm2_adef,
            mm2_sys,
            mm2_brk,
            mm2_ine,
            mm2_ale,
            mm2_interrupt,
            mm2_ertn,
            mm2_sbcode,
            mm2_flush_before,
            mm2_csr_wdata,
            mm2_csr_wmask,
            mm2_csr_addr,
            mm2_csr_re,
            // mm2_csr_we,
            mm2_exe_out,
            mm2_reg_d,
            mm2_op,
            mm2_op_type,
            mm2_rdata,
            mm2_mm_addr,
            mm2_mm_access_sz,
            mm2_reg_d_wen,
            mm2_pc);

input wire clk;
input wire rst_n;
input wire flush;
input wire wen;
input wire mm2_csr_we;
input wire [5:0] mm2_ecode;
input wire [8:0] mm2_esubcode;
input wire mm2_adef;
input wire mm2_sys;
input wire mm2_brk;
input wire mm2_ine;
input wire mm2_ale;
input wire mm2_interrupt;
input wire mm2_ertn;
input wire [14:0] mm2_sbcode;
input wire mm2_flush_before;
input wire [31:0] mm2_csr_wdata;
input wire [31:0] mm2_csr_wmask;
input wire [13:0] mm2_csr_addr;
input wire mm2_csr_re;
// input wire mm2_csr_we;
input wire [31:0] mm2_exe_out;
input wire [4:0] mm2_reg_d;
input wire [7:0] mm2_op;
input wire [3:0] mm2_op_type;
input wire [31:0] mm2_rdata;
input wire [31:0] mm2_mm_addr;
input wire [1:0] mm2_mm_access_sz;
input wire mm2_reg_d_wen;
input wire [31:0] mm2_pc;

reg csr_we;
reg [5:0] ecode;
reg [8:0] esubcode;
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
// reg csr_we;
reg [31:0] exe_out;
reg [4:0] reg_d;
reg [7:0] op;
reg [3:0] op_type;
reg [31:0] rdata;
reg [31:0] mm_addr;
reg [1:0] mm_access_sz;
reg reg_d_wen;
reg [31:0] pc;

always @(posedge clk ) begin
    if(!rst_n) begin
        csr_we <= 1'b0;
        ecode <= 6'b0;
        esubcode <= 9'b0;
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
        // csr_we <= 1'b0;
        exe_out <= 32'b0;
        reg_d <= 5'b0;
        op <= 8'b0;
        op_type <= 3'b0;
        rdata <= 32'b0;
        mm_addr <= 32'b0;
        mm_access_sz <= 2'b0;
        reg_d_wen <= 1'b0;
        pc <= 32'b0;
    end
    else if(wen) begin
        csr_we <= mm2_csr_we;
        ecode <= mm2_ecode;
        esubcode <= mm2_esubcode;
        adef <= mm2_adef;
        sys <= mm2_sys;
        brk <= mm2_brk;
        ine <= mm2_ine;
        ale <= mm2_ale;
        interrupt <= mm2_interrupt;
        ertn <= mm2_ertn;
        sbcode <= mm2_sbcode;
        flush_before <= mm2_flush_before;
        csr_wdata <= mm2_csr_wdata;
        csr_wmask <= mm2_csr_wmask;
        csr_addr <= mm2_csr_addr;
        csr_re <= mm2_csr_re;
        // csr_we <= mm2_csr_we;
        exe_out <= mm2_exe_out;
        reg_d <= mm2_reg_d;
        op <= mm2_op;
        op_type <= mm2_op_type;
        rdata <= mm2_rdata;
        reg_d_wen <= mm2_reg_d_wen;
        mm_addr <= mm2_mm_addr;
        mm_access_sz <= mm2_mm_access_sz;
        pc <= flush ? 32'b0 : mm2_pc;
    end
end
    
endmodule