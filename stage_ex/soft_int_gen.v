`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module soft_int_gen (
//output
        ex_soft_int_gen,
//input
        ex_csr_addr,
        ex_csr_we,
        ex_csr_wdata,
        ex_csr_wmask,

        mm1_csr_addr,
        mm1_csr_we,
        mm1_csr_wdata,
        mm1_csr_wmask,

        mm2_csr_addr,
        mm2_csr_we,
        mm2_csr_wdata,
        mm2_csr_wmask,

        wb_csr_addr,
        wb_csr_we,
        wb_csr_wdata,
        wb_csr_wmask,

        csr_ecfg_lie_soft,
);

input wire [13:0] ex_csr_addr;
input wire ex_csr_we;
input wire [31:0] ex_csr_wdata;
input wire [31:0] ex_csr_wmask;

input wire [13:0] mm1_csr_addr;
input wire mm1_csr_we;
input wire [31:0] mm1_csr_wdata;
input wire [31:0] mm1_csr_wmask;

input wire [13:0] mm2_csr_addr;
input wire mm2_csr_we;
input wire [31:0] mm2_csr_wdata;
input wire [31:0] mm2_csr_wmask;

input wire [13:0] wb_csr_addr;
input wire wb_csr_we;
input wire [31:0] wb_csr_wdata;
input wire [31:0] wb_csr_wmask;

input wire [1:0] csr_ecfg_lie_soft;

output wire ex_soft_int_gen;

reg ex_soft_int_gen_0;
reg ex_soft_int_gen_1;

always @(*) begin
    if(ex_csr_we && ex_csr_addr == `CSR_ESTAT && (|(ex_csr_wdata[0] & ex_csr_wmask[0]))) begin
        if(mm1_csr_we && mm1_csr_addr == `CSR_ECFG && mm1_csr_wmask[0]) begin
            if(mm1_csr_wdata[0]) begin
                ex_soft_int_gen_0 = 1'b1;
            end
            else begin
                ex_soft_int_gen_0 = 1'b0;
            end
        end
        else if (mm2_csr_we && mm2_csr_addr == `CSR_ECFG && mm2_csr_wmask[0]) begin
            if(mm2_csr_wdata[0]) begin
                ex_soft_int_gen_0 = 1'b1;
            end
            else begin
                ex_soft_int_gen_0 = 1'b0;
            end
        end
        else if (wb_csr_we && wb_csr_addr == `CSR_ECFG && wb_csr_wmask[0]) begin
            if(wb_csr_wdata[0]) begin
                ex_soft_int_gen_0 = 1'b1;
            end
            else begin
                ex_soft_int_gen_0 = 1'b0;
            end
        end
        else begin
            ex_soft_int_gen_0 = csr_ecfg_lie_soft[0];
        end
    end
    else begin
        ex_soft_int_gen_0 = 1'b0;
    end
end

always @(*) begin
    if(ex_csr_we && ex_csr_addr == `CSR_ESTAT && (|(ex_csr_wdata[1] & ex_csr_wmask[1]))) begin
        if(mm1_csr_we && mm1_csr_addr == `CSR_ECFG && mm1_csr_wmask[1]) begin
            if(mm1_csr_wdata[1]) begin
                ex_soft_int_gen_1 = 1'b1;
            end
            else begin
                ex_soft_int_gen_1 = 1'b0;
            end
        end
        else if (mm2_csr_we && mm2_csr_addr == `CSR_ECFG && mm2_csr_wmask[1]) begin
            if(mm2_csr_wdata[1]) begin
                ex_soft_int_gen_1 = 1'b1;
            end
            else begin
                ex_soft_int_gen_1 = 1'b0;
            end
        end
        else if (wb_csr_we && wb_csr_addr == `CSR_ECFG && wb_csr_wmask[1]) begin
            if(wb_csr_wdata[1]) begin
                ex_soft_int_gen_1 = 1'b1;
            end
            else begin
                ex_soft_int_gen_1 = 1'b0;
            end
        end
        else begin
            ex_soft_int_gen_1 = csr_ecfg_lie_soft[1];
        end
    end
    else begin
        ex_soft_int_gen_1 = 1'b0;
    end
end

assign ex_soft_int_gen = ex_soft_int_gen_1 | ex_soft_int_gen_0;


endmodule