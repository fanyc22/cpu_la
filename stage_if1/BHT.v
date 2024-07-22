`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/07/19 13:26:26
// Design Name:
// Module Name: BHT
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module BHT(
        //input
        if1_pc,
        ex_pc,
        we,
        branched,
        clk,
        rst_n,
        //output
        answ
    );

    parameter BHR_WIDTH = 4; // BHR有4位，记录最近4次的分支结果，用于寻址PHT
    parameter BHT_BIT = 5; // BHT有32个BHR，使用PC中的5位作为索引寻址BHT

    input wire [31:0] if1_pc;
    input wire [31:0] ex_pc;
    input wire we;
    input wire rst_n;
    input wire clk;
    input wire branched;

    output wire answ;

    reg [BHR_WIDTH - 1 : 0] bht[(1 << BHT_BIT) - 1 : 0];

    wire [BHT_BIT - 1 : 0] find_b;
    wire [BHT_BIT - 1 : 0] write_b;
    assign find_b = if1_pc[BHT_BIT + 1 : 2];
    assign write_b = ex_pc[BHT_BIT + 1 : 2];

    integer i;
    always @(posedge clk) begin
        if(!rst_n) begin
            for(i = 0; i < (1 << BHT_BIT) ; i = i + 1) begin
                bht[i] <= 0;
            end
        end
        else if(we) begin
            bht[write_b] <= {bht[write_b][BHR_WIDTH - 2 : 0], branched};
        end
    end

    BHT_PHTs #(.BHR_WIDTH(BHR_WIDTH))
             U_BHT_PHTs(
                 //input
                 .fbhr(bht[find_b]),
                 .wbhr(bht[write_b]),
                 .if1_pc(if1_pc),
                 .ex_pc(ex_pc),
                 .clk(clk),
                 .rst_n(rst_n),
                 .we(we),
                 .branched(branched),
                 //output
                 .answ(answ)
             );

endmodule
