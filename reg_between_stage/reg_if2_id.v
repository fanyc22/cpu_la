`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module reg_if2_id (
//output

//input
            clk,
            rst_n,
            wen,
            flush,
            if2_pc,
            if2_inst,
            if2_icache_hit,
            if2_branch_bp,
            if1_if2_cache_valid);
    
input wire clk;
input wire rst_n;
input wire wen;
input wire flush;
input wire [31:0] if2_pc;
input wire [31:0] if2_inst;
input wire if2_icache_hit;
input wire if2_branch_bp;
input wire if1_if2_cache_valid;

reg [31:0] pc;
reg [31:0] inst;
reg hit;
reg branch_bp;
reg stalled;
reg [31:0] buffer_inst;

always @(posedge clk ) begin
    if(!rst_n) begin
        pc <= 32'b0;
        inst <= 32'b0;
        hit <= 1'b0;
        branch_bp <= 1'b0;
    end
    else if(wen) begin
        pc <= flush ? 0 : if2_pc;
        inst <= flush ? 0 : 
                if1_if2_cache_valid ? (stalled ? buffer_inst : if2_inst) : 32'b0;
        hit <= flush ? 0 : 
                if1_if2_cache_valid ? if2_icache_hit : 1'b0;
        branch_bp <= flush ? 0 : if2_branch_bp;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        stalled <= 1'b0;
    end
    else begin
        stalled <= !wen;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        buffer_inst <= 32'b0;
    end
    else begin
        if(!stalled && !wen)
            buffer_inst <= if2_inst;
        else
            buffer_inst <= buffer_inst;
    end
end

endmodule