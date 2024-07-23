`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/07/20 15:19:47
// Design Name:
// Module Name: bp_top
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


module bp_top(
        //output
        target, // 预测的目标地址
        answ, // 预测是否分支
        if1_answ_bht, // if1的BHT预测结果
        if1_answ_ghr, // if1的GHR预测结果
        //input
        if1_pc, // if1的PC
        ex_pc, // ex的PC
        wtarget, // 实际的分支目标地址
        branched, // 分支且执行
        ex_answ_bht, // ex的BHT的预测结果
        ex_answ_ghr, // ex的GHR的预测结果
        ex_answ, // ex的指令在当时的预测结果
        we, // 写使能，是否更新BHT和BTB和GHR，是不是分支指令
        clk,
        rst_n
    );

    parameter BTB_WIDTH = 37; // validbit:1, Tag:2, target:32
    parameter BTB_WAY_BIT = 4;  // 16-way set associative, =tag bit
    parameter BTB_WAY = 16;
    parameter BTB_GROUP_BIT = 6; // 64 groups, =index bit
    parameter BTB_GROUP = 64;
    parameter VALID_BIT = 36;
    parameter TAG_MSB = 35;
    parameter TAG_LSB = 32;
    parameter TARGET_BIT = 32;

    parameter BHR_WIDTH = 4; // BHT PHT size: 16
    parameter BHT_BIT = 5; // BHT: 128 BHR

    parameter GHR_WIDTH = 8; // GHR PHT size: 256
    parameter CPHT_PC_BIT = 8;

    input wire [31:0] if1_pc;
    input wire [31:0] ex_pc;
    input wire [31:0] wtarget;
    input wire we;
    input wire clk;
    input wire rst_n;
    input wire branched;
    input wire ex_answ_bht;
    input wire ex_answ_ghr;
    input wire ex_answ;

    output wire [31:0] target;
    output wire answ;
    output wire if1_answ_bht;
    output wire if1_answ_ghr;


    btb #(.BTB_WIDTH(BTB_WIDTH),
          .BTB_WAY_BIT(BTB_WAY_BIT),
          .BTB_WAY(BTB_WAY),
          .BTB_GROUP_BIT(BTB_GROUP_BIT),
          .BTB_GROUP(BTB_GROUP),
          .VALID_BIT(VALID_BIT),
          .TAG_MSB(TAG_MSB),
          .TAG_LSB(TAG_LSB),
          .TARGET_BIT(TARGET_BIT)
         )
        U_btb(
            .target(target),
            .clk(clk),
            .rst_n(rst_n),
            .if1_pc(if1_pc),
            .ex_pc(ex_pc),
            .we(we),
            .wtarget(wtarget)
        );

    BHT #(.BHR_WIDTH(BHR_WIDTH),
          .BHT_BIT(BHT_BIT)
         )
        U_BHT(
            .answ(if1_answ_bht),
            .if1_pc(if1_pc),
            .ex_pc(ex_pc),
            .we(we),
            .branched(branched),
            .clk(clk),
            .rst_n(rst_n)
        );

    ghr #(.GHR_WIDTH(GHR_WIDTH)
         )
        U_ghr(
            .answ(if1_answ_ghr),
            .if1_pc(if1_pc),
            .ex_pc(ex_pc),
            .we(we),
            .branched(branched),
            .clk(clk),
            .rst_n(rst_n)
        );

    cpht #(.CPHT_PC_BIT(CPHT_PC_BIT)
          )
         U_cpht(
             .answ(answ),
             .clk(clk),
             .rst_n(rst_n),
             .if1_pc(if1_pc),
             .if1_answ_bht(if1_answ_bht),
             .if1_answ_ghr(if1_answ_ghr),
             .ex_pc(ex_pc),
             .branched(branched),
             .ex_answ_bht(ex_answ_bht),
             .ex_answ_ghr(ex_answ_ghr)
         );


    integer bht_succ_times, ghr_succ_times, succ_times, total_times, branch_take_times, branch_inst_num;
    always @(posedge clk) begin
        if(!rst_n) begin
            bht_succ_times <= 0;
            ghr_succ_times <= 0;
            succ_times <= 0;
            total_times <= 0;
            branch_take_times <= 0;
            branch_inst_num <= 0;
        end
        else begin
            bht_succ_times <= bht_succ_times + (ex_answ_bht == branched);
            ghr_succ_times <= ghr_succ_times + (ex_answ_ghr == branched);
            succ_times <= succ_times + (ex_answ == branched);
            total_times <= total_times + 1;
            branch_take_times <= branch_take_times + branched;
            branch_inst_num <= branch_inst_num + we;
        end
    end


endmodule
