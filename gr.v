`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"
module gr (
//output
            rdata1,
            rdata2,
            rdata3,
//input
            clk,
            rst_n,
            we,
            waddr,
            wdata,
            raddr1,
            raddr2,
            raddr3);

input wire clk;
input wire rst_n;

input wire we;
input wire[4:0] waddr;
input wire[31:0] wdata;

input wire[4:0] raddr1;
output reg[31:0] rdata1;

input wire[4:0] raddr2;
output reg[31:0] rdata2;

input wire[4:0] raddr3;
output reg[31:0] rdata3;

reg[31:0] registers[0:31];

//write regs
integer i;
always @(posedge clk) begin
    if(!rst_n) begin
        for (i = 0; i<32 ;i=i+1 ) begin
            registers[i] <= 32'b0;
        end
    end
    else if(we && waddr!=5'h0) begin
        registers[waddr] <= wdata;
    end
end

//read regs
always @(*) begin
    if(raddr1 == 32'b0)
        rdata1 <= 32'b0;
    // else if(raddr1 == waddr && we)
    //     rdata1 <= wdata;
    else
        rdata1 <= registers[raddr1];
end

always @(*) begin
    if(raddr2 == 32'b0)
        rdata2 <= 32'b0;
    // else if(raddr2 == waddr && we)
    //     rdata2 <= wdata;
    else
        rdata2 <= registers[raddr2];
end

always @(*) begin
    if(raddr3 == 32'b0)
        rdata3 <= 32'b0;
    // else if(raddr3 == waddr && we)
    //     rdata3 <= wdata;
    else
        rdata3 <= registers[raddr3];
end
    
endmodule