`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module csr (
//output
            csr_rdata,
            exception_entry,
            exception_return_entry,
            interruption,
//input
            clk,
            rst_n,
            csr_addr,
            csr_wdata,
            csr_wmask,
            csr_we,
            ertn_flush,
            wb_exception,
            wb_ecode,
            wb_esubcode,
            wb_vaddr,
            wb_pc);

input wire clk;
input wire rst_n;
input wire [13:0] csr_addr;
input wire [31:0] csr_wdata;
input wire [31:0] csr_wmask;
input wire csr_we;
input wire ertn_flush;
input wire wb_exception;
input wire [5:0] wb_ecode;
input wire [8:0] wb_esubcode;
input wire [31:0] wb_vaddr;
input wire [31:0] wb_pc;

output reg [31:0] csr_rdata;
output reg [31:0] exception_entry;
output reg [31:0] exception_return_entry;
output reg interruption;

reg [31:0] csr_reg[`CSR_REG_SIZE -1 :0];
reg [63:0] stable_counter;

always @(posedge clk) begin
    if(!rst_n) begin
        stable_counter <= 64'h0000_0000_0000_0000;
    end
    else begin
        stable_counter <= stable_counter + 64'd1;
    end
end

always @(*) begin
    exception_entry <= {csr_reg[`CSR_EENTRY][31:6], 6'b0};
    exception_return_entry <= {csr_reg[`CSR_ERA][31:6], 6'b0};
end

always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_CRMD] <= 32'h0000_0008;
        csr_reg[`CSR_EUEN] <= 32'h0000_0000;
        csr_reg[`CSR_ECFG] <= 32'h0000_0000;
        csr_reg[`CSR_ESTAT] <= 32'h0000_0000;
        csr_reg[`CSR_TCFG] <= 32'h0000_0000;
        csr_reg[`CSR_LLBCTL] <= 32'h0000_0000;
    end
    else if(wb_exception) begin
        csr_reg[`CSR_PRMD][`CSR_PRMD_PPLV] <= csr_reg[`CSR_CRMD][`CSR_CRMD_PLV];
        csr_reg[`CSR_PRMD][`CSR_PRMD_PIE] <= csr_reg[`CSR_CRMD][`CSR_CRMD_IE];
        csr_reg[`CSR_CRMD][`CSR_CRMD_PLV] <= 0;
        csr_reg[`CSR_CRMD][`CSR_CRMD_IE] <= 0;
        csr_reg[`CSR_ERA] <= wb_pc;
        csr_reg[`CSR_ESTAT][`CSR_ESTAT_ECODE] <= wb_ecode;
        csr_reg[`CSR_ESTAT][`CSR_ESTAT_ESUBCODE] <= wb_esubcode;
        csr_reg[`CSR_BDAV][`CSR_BDAV_VADDR] <= wb_vaddr;
    end
    else if(ertn_flush) begin
        csr_reg[`CSR_CRMD][`CSR_CRMD_PLV] <= csr_reg[`CSR_PRMD][`CSR_PRMD_PPLV];
        csr_reg[`CSR_CRMD][`CSR_CRMD_IE] <= csr_reg[`CSR_PRMD][`CSR_PRMD_PIE];
    end
    else if(csr_we) begin
        csr_reg[csr_addr] <= csr_wdata & csr_wmask;
    end
end

always @(*) begin
    csr_rdata = csr_reg[csr_addr];
end

always @(*) begin
    interruption = (&(csr_reg[`CSR_ESTAT][`CSR_ESTAT_IS] & csr_reg[`CSR_ECFG][`CSR_ECFG_LIE90])) && (csr_reg[`CSR_CRMD][`CSR_CRMD_IE]);
end

always @(posedge clk) begin
    if(csr_reg[`CSR_TCFG][`CSR_TCFG_EN]) begin
        if(csr_reg[`CSR_TVAL]==0) begin
            csr_reg[`CSR_ESTAT][11] <= 1;
            if(csr_reg[`CSR_TCFG][`CSR_TCFG_PERIOD]) begin
                csr_reg[`CSR_TVAL] <= {csr_reg[`CSR_TCFG][`CSR_TCFG_INITV],2'b00};
            end
        end
        else begin
            csr_reg[`CSR_TVAL] <= csr_reg[`CSR_TVAL] - 1;
        end
    end
end
    
endmodule