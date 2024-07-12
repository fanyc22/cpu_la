module reg_if1_if2 (
//output

//input
            clk,
            rst_n,
            wen,
            flush,
            if1_pc);
    
input wire clk;
input wire rst_n;
input wire wen;
input wire flush;
input wire [31:0] if1_pc;

reg [31:0] pc;

always @(posedge clk ) begin
    if(!rst_n) begin
        pc <= 32'b0;
    end
    else if(wen) begin
        pc <= if1_pc;
    end
end

endmodule