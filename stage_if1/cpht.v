module cpht(
        //input
        if1_pc,
        if1_answ_bht,
        if1_answ_ghr,
        ex_pc,
        ex_answ_bht,
        ex_answ_ghr,
        branched,
        clk,
        rst_n,
        //output
        answ
    );

    parameter CPHT_PC_BIT = 8;

    input wire if1_answ_bht;
    input wire if1_answ_ghr;
    input wire ex_answ_bht;
    input wire ex_answ_ghr;
    input wire [31:0] if1_pc;
    input wire [31:0] ex_pc;
    input wire branched;
    input wire clk;
    input wire rst_n;

    output wire answ;

    wire succ_bht;
    wire succ_ghr;
    assign succ_bht = (ex_answ_bht == branched);
    assign succ_ghr = (ex_answ_ghr == branched);

    reg [1:0] cpht[(1 << CPHT_PC_BIT) - 1 : 0];

    integer i;
    always @(posedge clk) begin
        if(!rst_n) begin
            for(i = 0; i < (1 << CPHT_PC_BIT); i = i + 1) begin
                cpht[i] <= 0;
            end
        end
        else begin
            case({cpht[ex_pc[CPHT_PC_BIT - 1 : 0]], succ_bht, succ_ghr})
                4'b0000:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b00;
                4'b0001:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b01;
                4'b0010:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b00;
                4'b0011:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b00;
                4'b0100:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b01;
                4'b0101:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b10;
                4'b0110:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b00;
                4'b0111:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b01;
                4'b1000:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b10;
                4'b1001:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b11;
                4'b1010:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b01;
                4'b1011:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b10;
                4'b1100:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b11;
                4'b1101:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b11;
                4'b1110:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b10;
                4'b1111:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b11;
                default:
                    cpht[ex_pc[CPHT_PC_BIT - 1 : 0]] <= 2'b10;
            endcase
        end
    end

    // 00,01:select BHT, 10,11:select GHR
    assign answ = (cpht[if1_pc[CPHT_PC_BIT - 1 : 0]] [1] == 0) ? if1_answ_bht : if1_answ_ghr;


endmodule
