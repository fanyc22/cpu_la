`include "C:\\Users\\41229\\Desktop\\cdp_ede_local-master\\mycpu_env\\myCPU\\defs.v"

module mul (
//output
        div_out_valid,
        div_out,
//input
        clk,
        rst_n,
        op,
        div_in_divisor,
        div_in_dividend);

input wire clk;
input wire rst_n;
input wire [7:0] op;
input wire [31:0] div_in_divisor;
input wire [31:0] div_in_dividend;

output reg div_out_valid;
output reg [31:0] div_out;

wire div_in_valid;
wire [63:0] div_out_total_signed;
wire [63:0] div_out_total_unsigned;
wire axi_result_valid_signed;
wire axi_result_valid_unsigned;

reg oprating;
reg [5:0] cycle_cnt;

always @(*) begin
    if(!rst_n)
        div_in_valid = 1'b0;
    else if(op == `OP_DIV || op == `OP_MOD)
        div_in_valid = 1'b1;
    else
        div_in_valid = 1'b0;
end

always @(posedge clk) begin
    if(!rst_n) begin
        oprating <= 1'b0;
        cycle_cnt <= 6'd0;
    end
    else if(!oprating) begin
        if(div_in_valid) begin
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
        if(cycle_cnt == `div_CYCLES) begin
            oprating <= 1'b0;
            // div_out_valid <= 1'b1;
            cycle_cnt <= 6'd0;
        end
    end
end

always @(*) begin
    if(!rst_n)
        div_out_valid = 1'b0;
    else 
        div_out_valid = (cycle_cnt == `DIV_CYCLES);
end

div_gen_0 U_div_gen_signed (
    .aclk(clk),
    .arstn(rst_n),
    .s_axis_divisor_tdata(div_in_divisor),
    .s_axis_divisor_tvalid(div_in_valid),
    .s_axis_dividend_tdata(div_in_dividend),
    .s_axis_dividend_tvalid(div_in_valid),
    .m_axis_result_tdata(div_out_total_signed),
    .m_axis_result_tvalid(axi_reslut_valid_signed));

div_gen_1 U_div_gen_unsigned (
    .aclk(clk),
    .arstn(rst_n),
    .s_axis_divisor_tdata(div_in_divisor),
    .s_axis_divisor_tvalid(div_in_valid),
    .s_axis_dividend_tdata(div_in_dividend),
    .s_axis_dividend_tvalid(div_in_valid),
    .m_axis_result_tdata(div_out_total_unsigned),
    .m_axis_result_tvalid(axi_reslut_valid_unsigned));

always @(*) begin
    if(!rst_n) begin
        div_out = 32'b0;
    end
    else begin
        if(op == `OP_DIV)
            div_out = div_out_total_signed[31:0];
        else if(op == `OP_MOD)
            div_out = div_out_total_signed[63:32];
        else if(op == `OP_DIVU)
            div_out = div_out_total_unsigned[31:0];
        else if(op == `OP_MODU)
            div_out = div_out_total_unsigned[63:32];
        else
            div_out = 32'b0;
    end
end

endmodule