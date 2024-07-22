`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module reg_if1_if2 (
        //output

        //input
        clk,
        rst_n,
        wen,
        flush,
        if1_adef,
        if1_pc,
        if1_branch_bp,
        if1_answ_bht,
        if1_answ_ghr);

    input wire clk;
    input wire rst_n;
    input wire wen;
    input wire flush;
    input wire if1_adef;
    input wire [31:0] if1_pc;
    input wire if1_branch_bp;

    //**********************
    input wire if1_answ_bht;
    input wire if1_answ_ghr;
    reg if2_answ_bht;
    reg if2_answ_ghr;
    //**********************

    reg [31:0] pc;
    reg cache_valid;
    reg flushed;
    reg branch_bp;
    reg adef;

    always @(posedge clk ) begin
        if(!rst_n) begin
            pc <= 32'b0;
            cache_valid <= 1'b0;
            flushed <= 1'b1;
            branch_bp <= 1'b0;
            adef <= 1'b0;
        end
        else if(wen) begin
            pc <= flush ? 0 : if1_pc;
            cache_valid <= !flush && !if1_adef;
            flushed <= flush;
            branch_bp <= flush ? 0 : if1_branch_bp;
            adef <= flush ? 0 : if1_adef;
        end
    end

    // ***************************
    always @(posedge clk) begin
        if(!rst_n) begin
            if2_answ_bht <= 1'b0;
            if2_answ_ghr <= 1'b0;
        end
        else if(wen) begin
            if2_answ_bht <= flush ? 0 : if1_answ_bht;
            if2_answ_ghr <= flush ? 0 : if1_answ_ghr;
        end
    end
    // ***************************

endmodule
