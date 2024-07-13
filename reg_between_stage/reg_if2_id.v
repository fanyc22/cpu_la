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
            if2_branch_bp);
    
input wire clk;
input wire rst_n;
input wire wen;
input wire flush;
input wire [31:0] if2_pc;
input wire [31:0] if2_inst;
input wire if2_icache_hit;
input wire if2_branch_bp;

reg [31:0] pc;
reg [31:0] inst;
reg hit;
reg branch_bp;

always @(posedge clk ) begin
    if(!rst_n) begin
        pc <= 32'b0;
        inst <= 32'b0;
        hit <= 1'b0;
        branch_bp <= 1'b0;
    end
    else if(wen) begin
        pc <= if2_pc;
        inst <= if2_inst;
        hit <= if2_icache_hit;
        branch_bp <= if2_branch_bp;
    end
end

endmodule