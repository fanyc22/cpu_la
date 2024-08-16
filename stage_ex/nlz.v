module nlz(
//output
        shift,
//input
        src);

input wire [15:0] src;
output reg [4:0] shift;


always @(*) begin
    casez (src)
        16'b0000_0000_0000_0000: shift = 5'b10000;
        16'b0000_0000_0000_0001: shift = 5'b01111;
        16'b0000_0000_0000_001z: shift = 5'b01110;
        16'b0000_0000_0000_01zz: shift = 5'b01101;
        16'b0000_0000_0000_1zzz: shift = 5'b01100;
        16'b0000_0000_0001_zzzz: shift = 5'b01011;
        16'b0000_0000_001z_zzzz: shift = 5'b01010;
        16'b0000_0000_01zz_zzzz: shift = 5'b01001;
        16'b0000_0000_1zzz_zzzz: shift = 5'b01000;
        16'b0000_0001_zzzz_zzzz: shift = 5'b00111;
        16'b0000_001z_zzzz_zzzz: shift = 5'b00110;
        16'b0000_01zz_zzzz_zzzz: shift = 5'b00101;
        16'b0000_1zzz_zzzz_zzzz: shift = 5'b00100;
        16'b0001_zzzz_zzzz_zzzz: shift = 5'b00011;
        16'b001z_zzzz_zzzz_zzzz: shift = 5'b00010;
        16'b01zz_zzzz_zzzz_zzzz: shift = 5'b00001;
        default: shift = 5'b00000;
    endcase
end
endmodule