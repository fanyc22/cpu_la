`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/07/19 20:12:41
// Design Name:
// Module Name: PHTs
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


module GHR_PHTs(
        //input
        if1_pc,
        ex_pc,
        ghr,
        clk,
        rst_n,
        we,
        branched,
        //output
        answ
    );

    parameter GHR_WIDTH = 8;

    input wire [31:0] if1_pc;
    input wire [31:0] ex_pc;
    input wire [GHR_WIDTH - 1 : 0] ghr;
    input wire we;
    input wire branched;
    input wire clk;
    input wire rst_n;

    output wire answ;

    reg [1:0] PHTs[(1 << GHR_WIDTH) - 1 : 0];

    wire [GHR_WIDTH-1:0] index_if1;
    wire [GHR_WIDTH-1:0] index_ex;
    assign index_if1 = ghr ^ if1_pc[GHR_WIDTH + 1 : 2];
    assign index_ex = ghr ^ ex_pc[GHR_WIDTH + 1 : 2];

    // update PHTs
    integer i;
    always @(posedge clk) begin
        if(!rst_n) begin
            for( i = 0; i < (1 << GHR_WIDTH); i = i + 1) begin
                PHTs[i] <= 2'b01;
            end
        end
        else if(we) begin
            case({PHTs[index_ex], branched})
                3'b000:
                    PHTs[index_ex] <= 2'b00;
                3'b001:
                    PHTs[index_ex] <= 2'b01;
                3'b010:
                    PHTs[index_ex] <= 2'b00;
                3'b011:
                    PHTs[index_ex] <= 2'b10;
                3'b100:
                    PHTs[index_ex] <= 2'b01;
                3'b101:
                    PHTs[index_ex] <= 2'b11;
                3'b110:
                    PHTs[index_ex] <= 2'b10;
                3'b111:
                    PHTs[index_ex] <= 2'b11;
                default:
                    PHTs[index_ex] <= 2'b10;
            endcase
        end
    end

    // make branch prediction
    assign answ = PHTs[index_if1] [1];

endmodule
