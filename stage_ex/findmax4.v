module findmax4(
//output
        max_shift,
//input
        shift0,
        shift1,
        shift2,
        shift3);

input wire [4:0] shift0;
input wire [4:0] shift1;
input wire [4:0] shift2;
input wire [4:0] shift3;

output wire [4:0] max_shift;

wire [4:0] max_shift01;
wire [4:0] max_shift23;

assign max_shift01 = (shift0 > shift1) ? shift0 : shift1;
assign max_shift23 = (shift2 > shift3) ? shift2 : shift3;
assign max_shift = (max_shift01 > max_shift23) ? max_shift01 : max_shift23;


endmodule