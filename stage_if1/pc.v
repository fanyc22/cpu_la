module pc(/*autoport*/
//output
      pc_reg,
      icache_re,
//input
      rst_n,
      clk,
      pc_wen,
      branch_address,
      is_branch,
      pc_is_wrong,
      pc_correct);

parameter PC_INITIAL = 32'h0000_0000;

input wire rst_n;
input wire clk;
input wire pc_wen;

input wire[31:0] branch_address;
input wire is_branch;
input wire pc_is_wrong;
input wire [31:0] pc_correct;

output reg[31:0] pc_reg;
output reg icache_re;

reg[31:0] pc_next;

always @(*) begin
    if (!rst_n) begin
        pc_next <= PC_INITIAL;
    end
    else if(pc_wen) begin
        if(is_branch) begin
            pc_next <= branch_address;
        end
        else if(pc_is_wrong) begin
            pc_next <= pc_correct;
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
    pc_reg <= pc_next;
    icache_re <= pc_wen;
end

// always @(posedge clk) $display("PC=%x",pc_reg);

endmodule