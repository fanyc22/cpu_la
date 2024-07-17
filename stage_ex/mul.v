`include "C:\\Users\\41229\\Desktop\\cdp_ede_local-master\\mycpu_env\\myCPU\\defs.v"

module mul (
//output
        mul_out_valid,
        mul_out_h,
        mul_out_l,
//input
        clk,
        rst_n,
        op,
        mul_in_a,
        mul_in_b
);

input wire clk;
input wire rst_n;
input wire [7:0] op;
input wire [31:0] mul_in_a;
input wire [31:0] mul_in_b;

output reg mul_out_valid;
output reg [31:0] mul_out_h;
output reg [31:0] mul_out_l;

wire mul_in_valid;
wire [63:0] mul_out;

reg oprating;
reg [5:0] cycle_cnt;

always @(*) begin
    if(!rst_n)
        mul_in_valid = 1'b0;
    else if(op == `OP_MUL || op == `OP_MULH)
        mul_in_valid = 1'b1;
    else
        mul_in_valid = 1'b0;
end

always @(posedge clk) begin
    if(!rst_n) begin
        oprating <= 1'b0;
        cycle_cnt <= 6'd0;
    end
    else if(!oprating) begin
        if(mul_in_valid) begin
            oprating <= 1'b1;
            cycle_cnt <= 6'd1;
        end
        else begin
            oprating <= 1'b0;
            cycle_cnt <= 6'd0;
        end
    end
    else begin
        cycle_cnt <= cycle_cnt + 6'd1;
        if(cycle_cnt == `MUL_CYCLES) begin
            oprating <= 1'b0;
            // mul_out_valid <= 1'b1;
            cycle_cnt <= 6'd0;
        end
    end
end

always @(*) begin
    if(!rst_n)
        mul_out_valid = 1'b0;
    else 
        mul_out_valid = (cycle_cnt == `MUL_CYCLES);
end

mult_gen_0 U_mult_gen_0 (
    .CLK(clk),
    .SCLR(rst_n),
    .A(mul_in_a),
    .B(mul_in_b),
    .P(mul_out));

always @(*) begin
    if(!rst_n) begin
        mul_out_h = 32'b0;
        mul_out_l = 32'b0;
    end
    else begin
        mul_out_h = mul_out[63:32];
        mul_out_l = mul_out[31:0];
    end
end

endmodule