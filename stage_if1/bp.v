`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module bp (
//output
            branch,
            target,
//input
            clk,
            rst_n,
            // if1_if2_flushed,
            pc_low,
            we,
            hitted,
            wtarget,
            hit_addr);

input wire clk;
input wire rst_n;
// input wire if1_if2_flushed;
input wire[5:0] pc_low;
input wire we;
input wire hitted;
input wire[31:0] wtarget;
input wire[5:0] hit_addr;

output reg branch;
output reg[31:0] target;

reg [`BTB_WIDTH-1:0] btb[0:63];

integer i;
always @(posedge clk ) begin
    if(!rst_n) begin
        for (i = 0; i<64 ;i=i+1 ) begin
            btb[i] <= 0;
        end
    end
    else if(we) begin
        btb[pc_low][`VALID_BIT] <= 1;
        btb[pc_low][`PREDICT_BIT] <= {btb[pc_low][`LOW_PREDICT_BIT],hitted};
        btb[pc_low][`TARGET_BIT] <= wtarget;
    end
end

always @(*) begin
    if(!rst_n) begin
        branch <= 1'b0;
        target <= 32'b0;
    end
    else if(btb[pc_low][`VALID_BIT] && btb[pc_low][`HIGH_PREDICT_BIT] == 1'b1) begin
            branch <= 1'b1;
            target <= btb[hit_addr][`TARGET_BIT];
        end
    else begin
            branch <= 1'b0;
            target <= 32'b0;
    end
end

endmodule