`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module regwrite (
//output
        gr_waddr,
        gr_wdata,
//input
        exe_out,
        csr_timer,
        csr_timer_id,
        reg_d,
        op,
        // op_type,
        wb_mm_access_sz,
        rdata);

input wire[63:0] csr_timer;
input wire[31:0] csr_timer_id;
input wire[31:0] exe_out;
input wire[4:0] reg_d;
input wire[7:0] op;
// input wire[3:0] op_type;
input wire[1:0] wb_mm_access_sz;
input wire[31:0] rdata;

output reg[4:0] gr_waddr;
output reg[31:0] gr_wdata;

always @(*) begin
    // if(op == `OP_LL || op == `OP_LD || op == `OP_LDU) begin
    //     gr_wdata = rdata;
    // end
    if(op == `OP_LD) begin
        case(wb_mm_access_sz)
            `ACCESS_SZ_BYTE: gr_wdata = {{24{rdata[7]}}, rdata[7:0]};
            `ACCESS_SZ_HALF: gr_wdata = {{16{rdata[15]}}, rdata[15:0]};
            default: gr_wdata = rdata;
        endcase
    end
    else if(op == `OP_LDU) begin
        case(wb_mm_access_sz)
            `ACCESS_SZ_BYTE: gr_wdata = {{24{1'b0}}, rdata[7:0]};
            `ACCESS_SZ_HALF: gr_wdata = {{16{1'b0}}, rdata[15:0]};
            default: gr_wdata = rdata;
        endcase
    end
    else if(op == `OP_LL) begin
        gr_wdata = rdata;
    end
    else if(op == `OP_RDCNTVL) begin
        gr_wdata = csr_timer[31:0];
    end
    else if(op == `OP_RDCNTID) begin
        gr_wdata = csr_timer_id;
    end
    else if(op == `OP_RDCNTVH) begin
        gr_wdata = csr_timer[63:32];
    end
    else begin
        gr_wdata = exe_out;
    end
end

always @(*) begin
    if(op == `OP_BL) 
        gr_waddr = 5'h01;
    else
        gr_waddr = reg_d;
end
    
endmodule