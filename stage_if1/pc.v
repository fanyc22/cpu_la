`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module pc(/*autoport*/
//output
      pc_reg,
      icache_re,
      if1_adef,
//input
      rst_n,
      clk,
      pc_wen,
      branch_address,
      is_branch,
      pc_is_wrong,
      pc_correct);

parameter PC_INITIAL = 32'h1c00_0000;

input wire rst_n;
input wire clk;
input wire pc_wen;

input wire[31:0] branch_address;
input wire is_branch;
input wire pc_is_wrong;
input wire [31:0] pc_correct;

output reg [31:0] pc_reg;
output reg icache_re;
output reg if1_adef;

reg[31:0] pc_next;

always @(*) begin
    if (!rst_n) begin
        pc_next <= PC_INITIAL;
    end
    else if(pc_wen) begin
        if(pc_is_wrong) begin
            pc_next <= pc_correct;
        end
        else if(is_branch) begin
            pc_next <= branch_address;
        end
        else begin
            pc_next <= pc_reg+32'd4;
        end
    end 
    else begin 
        pc_next <= pc_reg;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        icache_re <= 1;
    end
    else begin
        icache_re <= pc_wen;
    end
end

always @(posedge clk) begin
    pc_reg <= pc_next;
end

always @(*) begin
    if1_adef = | pc_reg[1:0];
end
// always @(posedge clk) $display("PC=%x",pc_reg);

endmodule