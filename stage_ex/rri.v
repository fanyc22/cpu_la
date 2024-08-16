module rri(
//output
        rri_out,
//input
        si11_rri,
        rj,
        rk);

input wire [10:0] si11_rri;
input wire [31:0] rj;
input wire [31:0] rk;

output wire [31:0] rri_out;
    
wire [4:0] shift0;
wire [4:0] shift1;
wire [4:0] shift2;
wire [4:0] shift3;
reg [4:0] max_shift;
wire [31:0] si11_ext;

nlz U_nlz_0(
    .shift(shift0),
    .src(rj[31:16]));

nlz U_nlz_1(
    .shift(shift1),
    .src(rj[15:0]));

nlz U_nlz_2(
    .shift(shift2),
    .src(rk[31:16]));

nlz U_nlz_3(
    .shift(shift3),
    .src(rk[15:0]));

findmax4 U_findmax4_0(
    .max_shift(max_shift),
    .shift0(shift0),
    .shift1(shift1),
    .shift2(shift2),
    .shift3(shift3));

assign si11_ext = {{21{si11_rri[10]}}, si11_rri};

assign rri_out = (si11_ext << (~max_shift + 1))|(si11_ext >> max_shift);

endmodule