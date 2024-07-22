`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
module reg_if2_id (
        //output

        //input
        clk,
        rst_n,
        wen,
        flush,
        if2_adef,
        if2_pc,
        if2_inst,
        if2_icache_hit,
        if2_branch_bp,
        if1_if2_cache_valid,
        if1_if2_flushed,
        if2_answ_bht,
        if2_answ_ghr);

    input wire clk;
    input wire rst_n;
    input wire wen;
    input wire flush;
    input wire if2_adef;
    input wire [31:0] if2_pc;
    input wire [31:0] if2_inst;
    input wire if2_icache_hit;
    input wire if2_branch_bp;
    input wire if1_if2_cache_valid;
    input wire if1_if2_flushed;
    //**************************
    input wire if2_answ_bht;
    input wire if2_answ_ghr;
    reg id_answ_bht;
    reg id_answ_ghr;
    //**************************

    reg adef;
    reg [31:0] pc;
    reg [31:0] inst;
    reg hit;
    reg branch_bp;
    reg stalled;
    reg [31:0] buffer_inst;
    reg flushed;

    always @(posedge clk ) begin
        if(!rst_n) begin
            adef <= 1'b0;
            pc <= 32'b0;
            inst <= 32'b0;
            hit <= 1'b0;
            branch_bp <= 1'b0;
            flushed <= 1'b1;
        end
        else if(wen) begin
            adef <= flush ? 0 : if2_adef;
            pc <= flush ? 0 : if2_pc;
            inst <= flush ? 0 :
                 if1_if2_cache_valid ? (stalled ? buffer_inst : if2_inst) : 32'b0;
            hit <= flush ? 0 :
                if1_if2_cache_valid ? if2_icache_hit : 1'b0;
            branch_bp <= flush ? 0 : if2_branch_bp;
            flushed <= flush || if1_if2_flushed;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            stalled <= 1'b0;
        end
        else begin
            stalled <= !wen;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            buffer_inst <= 32'b0;
        end
        else begin
            if(!stalled && !wen)
                buffer_inst <= if2_inst;
            else
                buffer_inst <= buffer_inst;
        end
    end

    // ****************************
    always @(posedge clk) begin
        if(!rst_n) begin
            id_answ_bht <= 1'b0;
            id_answ_ghr <= 1'b0;
        end
        else begin
            id_answ_bht <= flush ? 0 : if2_answ_bht;
            id_answ_ghr <= flush ? 0 : if2_answ_ghr;
        end
    end
    // ****************************

endmodule
