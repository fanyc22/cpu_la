`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/07/20 19:23:39
// Design Name:
// Module Name: ghr
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


module ghr(
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

    parameter GHR_WIDTH = 8; // GHR有8位，记录最近8次的分支结果

    input wire [31:0] if1_pc;
    input wire [31:0] ex_pc;
    input wire we;
    input wire rst_n;
    input wire clk;
    input wire branched;

    output wire answ;

    reg [GHR_WIDTH - 1 : 0] ghr;

    // update GHR
    always @(posedge clk) begin
        if(!rst_n) begin
            ghr <= 0;
        end
        else if (we) begin
            ghr <= {ghr[GHR_WIDTH - 2 : 0], branched};
        end
    end

    GHR_PHTs #(.GHR_WIDTH(GHR_WIDTH))
             U_GHR_PHTs(
                 // input
                 .if1_pc(if1_pc),
                 .ex_pc(ex_pc),
                 .ghr(ghr),
                 .clk(clk),
                 .rst_n(rst_n),
                 .we(we),
                 .branched(branched),
                 // output
                 .answ(answ)
             );

endmodule
