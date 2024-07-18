`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module reg_if1_if2 (
//output

//input
            clk,
            rst_n,
            wen,
            flush,
            if1_pc,
            if1_branch_bp);
    
input wire clk;
input wire rst_n;
input wire wen;
input wire flush;
input wire [31:0] if1_pc;
input wire if1_branch_bp;

reg [31:0] pc;
reg cache_valid;
reg flushed;
reg branch_bp;

always @(posedge clk ) begin
    if(!rst_n) begin
        pc <= 32'b0;
        cache_valid <= 1'b0;
        flushed <= 1'b0;
        branch_bp <= 1'b0;
    end
    else if(wen) begin
        pc <= flush ? 0 : if1_pc;
        cache_valid <= !flush;
        flushed <= flush;
        branch_bp <= flush ? 0 : if1_branch_bp;
    end
end

endmodule