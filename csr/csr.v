`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
//LLBit is fake
module csr (
//output
            csr_rdata,
            exception_entry,
            exception_return_entry,
            interrupt,
            timer,
            timer_id,
            csr_ecfg_lie_soft,
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
output reg interrupt;
output reg [63:0] timer;
output reg [31:0] timer_id;
output reg [1:0] csr_ecfg_lie_soft;

reg last_tcfg_en;

reg ticlr;
reg wcllb;

reg [31:0] csr_reg[`CSR_REG_SIZE -1 :0];
reg [63:0] stable_counter;

always @(*) begin
    csr_ecfg_lie_soft = csr_reg[`CSR_ECFG][1:0];
end

always @(*) begin
    ticlr = csr_we && (csr_addr == `CSR_TICLR) && csr_wdata[0] && csr_wmask[0];
end

always @(*) begin
    wcllb = csr_we && (csr_addr == `CSR_LLBCTL) && csr_wdata[1] && csr_wmask[1];
end

always @(posedge clk) begin
    if(!rst_n) begin
        stable_counter <= 64'h0000_0000_0000_0000;
    end
    else begin
        stable_counter <= stable_counter + 64'd1;
    end
end

always @(*) begin
    exception_entry <= csr_reg[`CSR_EENTRY];
    exception_return_entry <= csr_reg[`CSR_ERA];
end

// always @(posedge clk) begin
//     if(!rst_n) begin
//         csr_reg[`CSR_CRMD] <= 32'h0000_0008;
//         csr_reg[`CSR_EUEN] <= 32'h0000_0000;
//         csr_reg[`CSR_ECFG] <= 32'h0000_0000;
//         csr_reg[`CSR_ESTAT] <= 32'h0000_0000;
//         csr_reg[`CSR_TCFG] <= 32'h0000_0000;
//         csr_reg[`CSR_LLBCTL] <= 32'h0000_0000;
//         csr_reg[`CSR_TICLR ] <= 32'h0000_0000;
//     end
//     else if(wb_exception) begin
//         csr_reg[`CSR_PRMD][`CSR_PRMD_PPLV] <= csr_reg[`CSR_CRMD][`CSR_CRMD_PLV];
//         csr_reg[`CSR_PRMD][`CSR_PRMD_PIE] <= csr_reg[`CSR_CRMD][`CSR_CRMD_IE];
//         csr_reg[`CSR_CRMD][`CSR_CRMD_PLV] <= 0;
//         csr_reg[`CSR_CRMD][`CSR_CRMD_IE] <= 0;
//         csr_reg[`CSR_ERA] <= wb_pc;
//         csr_reg[`CSR_ESTAT][`CSR_ESTAT_ECODE] <= wb_ecode;
//         csr_reg[`CSR_ESTAT][`CSR_ESTAT_ESUBCODE] <= wb_esubcode;
//         csr_reg[`CSR_BADV] <= wb_vaddr;
//     end
//     else if(ertn_flush) begin
//         csr_reg[`CSR_CRMD][`CSR_CRMD_PLV] <= csr_reg[`CSR_PRMD][`CSR_PRMD_PPLV];
//         csr_reg[`CSR_CRMD][`CSR_CRMD_IE] <= csr_reg[`CSR_PRMD][`CSR_PRMD_PIE];
//     end
//     else if(csr_we) begin
//         csr_reg[csr_addr] <= (csr_wdata & csr_wmask) | (csr_reg[csr_addr] & ~csr_wmask);
//     end

//     if(csr_reg[`CSR_TCFG][`CSR_TCFG_EN]) begin
//         if(csr_reg[`CSR_TVAL]==0) begin
//             csr_reg[`CSR_ESTAT][11] <= 1;
//             if(csr_reg[`CSR_TCFG][`CSR_TCFG_PERIOD]) begin
//                 csr_reg[`CSR_TVAL] <= {csr_reg[`CSR_TCFG][`CSR_TCFG_INITV],2'b00};
//             end
//         end
//         else begin
//             csr_reg[`CSR_TVAL] <= csr_reg[`CSR_TVAL] - 1;
//         end
//     end
// end

//CRMD
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_CRMD] <= 32'h0000_0008;
    end
    else if(wb_exception) begin
        csr_reg[`CSR_CRMD][`CSR_CRMD_PLV] <= 0;
        csr_reg[`CSR_CRMD][`CSR_CRMD_IE] <= 0;
    end
    else if(ertn_flush) begin
        csr_reg[`CSR_CRMD][`CSR_CRMD_PLV] <= csr_reg[`CSR_PRMD][`CSR_PRMD_PPLV];
        csr_reg[`CSR_CRMD][`CSR_CRMD_IE] <= csr_reg[`CSR_PRMD][`CSR_PRMD_PIE];
        csr_reg[`CSR_CRMD][`CSR_CRMD_DA] <= (csr_reg[`CSR_ESTAT][`CSR_ESTAT_ECODE] != 6'h3f);
        csr_reg[`CSR_CRMD][`CSR_CRMD_PG] <= (csr_reg[`CSR_ESTAT][`CSR_ESTAT_ECODE] == 6'h3f);
    end
    else if(csr_we && csr_addr == `CSR_CRMD) begin
        csr_reg[`CSR_CRMD][8:0] <= ((csr_wdata[8:0] & csr_wmask[8:0]) | (csr_reg[`CSR_CRMD][8:0] & ~csr_wmask[8:0]));
    end
end

//PRMD
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_PRMD] <= 32'h0000_0000;
    end
    else if(wb_exception) begin
        csr_reg[`CSR_PRMD][`CSR_PRMD_PPLV] <= csr_reg[`CSR_CRMD][`CSR_CRMD_PLV];
        csr_reg[`CSR_PRMD][`CSR_PRMD_PIE] <= csr_reg[`CSR_CRMD][`CSR_CRMD_IE];
    end
    else if(csr_we && csr_addr == `CSR_PRMD) begin
        csr_reg[`CSR_PRMD][2:0] <= ((csr_wdata[2:0] & csr_wmask[2:0]) | (csr_reg[`CSR_PRMD][2:0] & ~csr_wmask[2:0]));
    end
end

//ENEU
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_EUEN] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_EUEN) begin
        csr_reg[`CSR_EUEN][0] <= ((csr_wdata[0] & csr_wmask[0]) | (csr_reg[`CSR_EUEN][0] & ~csr_wmask[0]));
    end
end

//ECFG
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_ECFG] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_ECFG) begin
        csr_reg[`CSR_ECFG][9:0] <= ((csr_wdata[9:0] & csr_wmask[9:0]) | (csr_reg[`CSR_ECFG][9:0] & ~csr_wmask[9:0]));
        csr_reg[`CSR_ECFG][12:11] <= ((csr_wdata[12:11] & csr_wmask[12:11]) | (csr_reg[`CSR_ECFG][12:11] & ~csr_wmask[12:11]));
    end
end

//ESTAT
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_ESTAT] <= 32'h0000_0000;
    end
    else if(wb_exception) begin
        csr_reg[`CSR_ESTAT][`CSR_ESTAT_ECODE] <= wb_ecode;
        csr_reg[`CSR_ESTAT][`CSR_ESTAT_ESUBCODE] <= wb_esubcode;
        csr_reg[`CSR_ESTAT][11] <= (last_tcfg_en) && csr_reg[`CSR_TCFG][0] ? (ticlr ? 0 : 
                                (csr_reg[`CSR_TVAL] == 0) ? 1:
                                csr_reg[`CSR_ESTAT][11]) : 0;
    end
    else if(csr_we && csr_addr == `CSR_ESTAT) begin
        csr_reg[`CSR_ESTAT][1:0] <= ((csr_wdata[1:0] & csr_wmask[1:0]) | (csr_reg[`CSR_ESTAT][1:0] & ~csr_wmask[1:0]));
        csr_reg[`CSR_ESTAT][11] <= (last_tcfg_en) && csr_reg[`CSR_TCFG][0] ? (ticlr ? 0 : 
                                (csr_reg[`CSR_TVAL] == 0) ? 1:
                                csr_reg[`CSR_ESTAT][11]) : 0;
    end
    else begin
        csr_reg[`CSR_ESTAT][11] <= (last_tcfg_en) && csr_reg[`CSR_TCFG][0] ? (ticlr ? 0 : 
                                (csr_reg[`CSR_TVAL] == 0) ? 1:
                                csr_reg[`CSR_ESTAT][11]) : 0;
    end
end

//ERA
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_ERA] <= 32'h0000_0000;
    end
    else if(wb_exception) begin
        csr_reg[`CSR_ERA] <= wb_pc;
    end
    else if(csr_we && csr_addr == `CSR_ERA) begin
        csr_reg[`CSR_ERA] <= (csr_wdata & csr_wmask) | (csr_reg[`CSR_ERA] & ~csr_wmask);
    end
end

//BADV
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_BADV] <= 32'h0000_0000;
    end
    else if(wb_exception && wb_ecode == `ECODE_ADE) begin
        csr_reg[`CSR_BADV] <= wb_pc;
    end
    else if(wb_exception && wb_ecode == `ECODE_ALE) begin
        csr_reg[`CSR_BADV] <= wb_vaddr;
    end
    else if(csr_we && csr_addr == `CSR_BADV) begin
        csr_reg[`CSR_BADV] <= (csr_wdata & csr_wmask) | (csr_reg[`CSR_BADV] & ~csr_wmask);
    end
end

//EENTRY
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_EENTRY] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_EENTRY) begin
        csr_reg[`CSR_EENTRY][31:6] <= ((csr_wdata[31:6] & csr_wmask[31:6]) | (csr_reg[`CSR_EENTRY][31:6] & ~csr_wmask[31:6]));
    end
end

//CPUID
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_CPUID] <= 32'h0000_0000;
    end
end

//SAVE0
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_SAVE0] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_SAVE0) begin
        csr_reg[`CSR_SAVE0] <= (csr_wdata & csr_wmask) | (csr_reg[`CSR_SAVE0] & ~csr_wmask);
    end
end

//SAVE1
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_SAVE1] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_SAVE1) begin
        csr_reg[`CSR_SAVE1] <= (csr_wdata & csr_wmask) | (csr_reg[`CSR_SAVE1] & ~csr_wmask);
    end
end

//SAVE2
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_SAVE2] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_SAVE2) begin
        csr_reg[`CSR_SAVE2] <= (csr_wdata & csr_wmask) | (csr_reg[`CSR_SAVE2] & ~csr_wmask);
    end
end

//SAVE3
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_SAVE3] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_SAVE3) begin
        csr_reg[`CSR_SAVE3] <= (csr_wdata & csr_wmask) | (csr_reg[`CSR_SAVE3] & ~csr_wmask);
    end
end

//LLBCTL
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_LLBCTL] <= 32'h0000_0000;
    end
    else if(ertn_flush) begin
        csr_reg[`CSR_LLBCTL][0] <= csr_reg[`CSR_LLBCTL][2] ? 
                                    csr_reg[`CSR_LLBCTL][0] : 0;
        csr_reg[`CSR_LLBCTL][2] <= 0;
    end
    else if(csr_we && csr_addr == `CSR_LLBCTL) begin
        csr_reg[`CSR_LLBCTL][2] <= ((csr_wdata[2] & csr_wmask[2]) | (csr_reg[`CSR_LLBCTL][2] & ~csr_wmask[2]));
        csr_reg[`CSR_LLBCTL][0] <= wcllb ? 0 : csr_reg[`CSR_LLBCTL][0];
    end
end

//TLBIDX
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_TLBIDX] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_TLBIDX) begin
        csr_reg[`CSR_TLBIDX][15:0] <= ((csr_wdata[15:0] & csr_wmask[15:0]) | (csr_reg[`CSR_TLBIDX][15:0] & ~csr_wmask[15:0]));
        csr_reg[`CSR_TLBIDX][29:24] <= ((csr_wdata[29:24] & csr_wmask[29:24]) | (csr_reg[`CSR_TLBIDX][29:24] & ~csr_wmask[29:24]));
        csr_reg[`CSR_TLBIDX][31] <= ((csr_wdata[31] & csr_wmask[31]) | (csr_reg[`CSR_TLBIDX][31] & ~csr_wmask[31]));
    end
end

//TLBEHI
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_TLBHI] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_TLBHI) begin
        csr_reg[`CSR_TLBHI][31:13] <= ((csr_wdata[31:13] & csr_wmask[31:13]) | (csr_reg[`CSR_TLBHI][31:13] & ~csr_wmask[31:13]));
    end
end

//TLBLO0
//TLBLO1

//ASID
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_ASID] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_ASID) begin
        csr_reg[`CSR_ASID][9:0] <= ((csr_wdata[9:0] & csr_wmask[9:0]) | (csr_reg[`CSR_ASID][9:0] & ~csr_wmask[9:0]));
    end
end

//PGDL
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_PGDL] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_PGDL) begin
        csr_reg[`CSR_PGDL][31:12] <= ((csr_wdata[31:12] & csr_wmask[31:12]) | (csr_reg[`CSR_PGDL][31:12] & ~csr_wmask[31:12]));
    end
end

//PGDH
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_PGDH] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_PGDH) begin
        csr_reg[`CSR_PGDH][31:12] <= ((csr_wdata[31:12] & csr_wmask[31:12]) | (csr_reg[`CSR_PGDH][31:12] & ~csr_wmask[31:12]));
    end
end

//PGD
always @(*) begin
    csr_reg[`CSR_PGD] = csr_reg[`CSR_BADV][31] ? 
                        csr_reg[`CSR_PGDH] : csr_reg[`CSR_PGDL];
end

//TLBRENTRY
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_TLBRENTRY] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_TLBRENTRY) begin
        csr_reg[`CSR_TLBRENTRY][31:6] <= ((csr_wdata[31:6] & csr_wmask[31:6]) | (csr_reg[`CSR_TLBRENTRY][31:6] & ~csr_wmask[31:6]));
    end
end

//DMW0
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_DMW0] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_DMW0) begin
        csr_reg[`CSR_DMW0][0] <= ((csr_wdata[0] & csr_wmask[0]) | (csr_reg[`CSR_DMW0][0] & ~csr_wmask[0]));
        csr_reg[`CSR_DMW0][5:3] <= ((csr_wdata[5:3] & csr_wmask[5:3]) | (csr_reg[`CSR_DMW0][5:3] & ~csr_wmask[5:3]));
        csr_reg[`CSR_DMW0][27:25] <= ((csr_wdata[27:25] & csr_wmask[27:25]) | (csr_reg[`CSR_DMW0][27:25] & ~csr_wmask[27:25]));
        csr_reg[`CSR_DMW0][31:29] <= ((csr_wdata[31:29] & csr_wmask[31:29]) | (csr_reg[`CSR_DMW0][31:29] & ~csr_wmask[31:29]));
    end
end

//TID
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_TID] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_TID) begin
        csr_reg[`CSR_TID] <= (csr_wdata & csr_wmask) | (csr_reg[`CSR_TID] & ~csr_wmask);
    end
end

//TCFG
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_TCFG] <= 32'h0000_0000;
    end
    else if(csr_we && csr_addr == `CSR_TCFG) begin
        csr_reg[`CSR_TCFG] <= ((csr_wdata & csr_wmask) | (csr_reg[`CSR_TCFG] & ~csr_wmask));
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        last_tcfg_en <= 0;
    end
    else begin
        last_tcfg_en <= csr_reg[`CSR_TCFG][`CSR_TCFG_EN];
    end
end

//TVAl
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_TVAL] <= 32'h0000_0000;
    end
    else if(csr_reg[`CSR_TCFG][`CSR_TCFG_EN]) begin
        if(!last_tcfg_en) begin
            csr_reg[`CSR_TVAL] <= {csr_reg[`CSR_TCFG][31:3],2'b00};
        end
        else if(csr_reg[`CSR_TVAL]==0 && csr_reg[`CSR_TCFG][`CSR_TCFG_PERIOD]) begin
            csr_reg[`CSR_TVAL] <= {csr_reg[`CSR_TCFG][31:3],2'b00};
        end
        else begin
            csr_reg[`CSR_TVAL] <= csr_reg[`CSR_TVAL] - 1;
        end
    end
end

//TICLR
always @(posedge clk) begin
    if(!rst_n) begin
        csr_reg[`CSR_TICLR] <= 32'h0000_0000;
    end
end

always @(*) begin
    csr_rdata = csr_reg[csr_addr];
end

always @(*) begin
    interrupt = (|(csr_reg[`CSR_ESTAT][`CSR_ESTAT_IS] & csr_reg[`CSR_ECFG][`CSR_ECFG_LIE])) && (csr_reg[`CSR_CRMD][`CSR_CRMD_IE]);
end

always @(*) begin
    timer_id <= csr_reg[`CSR_TID];
    timer <= stable_counter;
end
    
endmodule