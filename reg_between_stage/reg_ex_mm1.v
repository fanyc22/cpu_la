`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module reg_ex_mm1 (
//output

//input
            clk,
            rst_n,
            flush,
            wen,
            ex_adef,
            ex_sys,
            ex_brk,
            ex_ine,
            ex_ale,
            ex_ertn,
            ex_interrupt,
            ex_sbcode,
            ex_flush_before,
            ex_csr_wdata,
            ex_csr_wmask,
            ex_csr_addr,
            ex_csr_re,
            ex_csr_we,
            ex_exe_out,
            ex_mm_access_sz,
            ex_mm_addr,
            ex_mm_re,
            ex_mm_we,
            ex_mm_wdata,
            ex_reg_d,
            ex_op,
            ex_op_type,
            ex_reg_d_wen,
            ex_pc);

input wire clk;
input wire rst_n;
input wire flush;
input wire wen;
input wire ex_adef;
input wire ex_sys;
input wire ex_brk;
input wire ex_ine;
input wire ex_ale;
input wire ex_ertn;
input wire ex_interrupt;
input wire [14:0] ex_sbcode;
input wire ex_flush_before;
input wire [31:0] ex_csr_wdata;
input wire [31:0] ex_csr_wmask;
input wire [13:0] ex_csr_addr;
input wire ex_csr_re;
input wire ex_csr_we;
// input wire ex_soft_int_gen;
input wire [31:0] ex_exe_out;
input wire [1:0] ex_mm_access_sz;
input wire [31:0] ex_mm_addr;
input wire ex_mm_re;
input wire ex_mm_we;
input wire [31:0] ex_mm_wdata;
input wire [4:0] ex_reg_d;
input wire [7:0] ex_op;
input wire [3:0] ex_op_type;
input wire ex_reg_d_wen;
input wire [31:0] ex_pc;

reg adef;
reg sys;
reg brk;
reg ine;
reg ale;
reg ertn;
reg interrupt;
reg [14:0] sbcode;
reg flush_before;
reg [31:0] csr_wdata;
reg [31:0] csr_wmask;
reg [31:0] csr_addr;
reg csr_re;
reg csr_we;
// reg soft_int_gen;
reg [31:0] exe_out;
reg [1:0] mm_access_sz;
reg [31:0] mm_addr;
reg mm_re;
reg mm_we;
reg [31:0] mm_wdata;
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
        ertn <= 1'b0;
        interrupt <= 1'b0;
        sbcode <= 15'b0;
        flush_before <= 1'b0;
        csr_wdata <= 32'b0;
        csr_wmask <= 32'b0;
        csr_addr <= 32'b0;
        csr_re <= 1'b0;
        csr_we <= 1'b0;
        // soft_int_gen <= 1'b0;
        exe_out <= 32'b0;
        mm_access_sz <= 3'b0;
        mm_addr <= 32'b0;
        mm_re <= 1'b0;
        mm_we <= 1'b0;
        mm_wdata <= 32'b0;
        reg_d <= 5'b0;
        op <= 8'b0;
        op_type <= 3'b0;
        reg_d_wen <= 1'b0;
        pc <= 32'b0;
    end
    else if(wen) begin
        adef <= flush ? 0 : ex_adef;
        sys <= flush ? 0 : ex_sys;
        brk <= flush ? 0 : ex_brk;
        ine <= flush ? 0 : ex_ine;
        ale <= flush ? 0 : ex_ale;
        ertn <= flush ? 0 : ex_ertn;
        interrupt <= flush ? 0 : ex_interrupt;
        sbcode <= flush ? 0 : ex_sbcode;
        flush_before <= flush ? 0 : ex_flush_before;
        csr_wdata <= flush ? 0 : ex_csr_wdata;
        csr_wmask <= flush ? 0 : ex_csr_wmask;
        csr_addr <= flush ? 0 : ex_csr_addr;
        csr_re <= flush ? 0 : ex_csr_re;
        csr_we <= flush ? 0 : ex_csr_we;
        // soft_int_gen <= flush ? 0 : ex_soft_int_gen;
        exe_out <= flush ? 0 : ex_exe_out;
        mm_access_sz <= ex_mm_access_sz;
        mm_addr <= ex_mm_addr;
        mm_re <= flush ? 0 : (ex_flush_before ? 0 : ex_mm_re);
        mm_we <= flush ? 0 : (ex_flush_before ? 0 : ex_mm_we);
        mm_wdata <= ex_mm_wdata;
        reg_d <= ex_reg_d;
        op <= flush ? 0 : ex_op;
        op_type <= flush ? 0 : ex_op_type;
        reg_d_wen <= flush ? 0 : (ex_flush_before ? 0 : ex_reg_d_wen);
        pc <= flush ? 0 : ex_pc;
    end
end

endmodule