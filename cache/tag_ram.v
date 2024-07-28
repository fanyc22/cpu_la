`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module tag_ram(
    input                clk,
    input                resetn,
    input                we,
    input [`LOG_W-1:0]   way,
    input [`LOG_H-1:0]   addr,
    input [`TAG_LEN-1:0] din ,
    output[`N*`TAG_LEN-1:0] dout
);

reg [`TAG_LEN-1:0] ram [`H-1:0][`N-1:0];
integer i,j;
always @(posedge clk)begin
    if(~resetn)begin
        for(i=0;i<`H;i=i+1)begin
            for(j=0;j<`N;j=j+1)begin
                ram[i][j] <= `TAG_LEN'b0;
            end
        end 
    end
    else begin
        if(we) ram[addr][way] <=din;        
    end
end
assign  dout = {ram[addr][3],ram[addr][2],ram[addr][1],ram[addr][0]};

endmodule