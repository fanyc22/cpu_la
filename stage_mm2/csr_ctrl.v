`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module csr_ctrl (
//output
        mm2_csr_we,
        mm2_ecode,
        mm2_esubcode,

//input
        op,
        mm2_adef,
        mm2_sys,
        mm2_brk,
        mm2_ine,
        mm2_ale,
        mm2_interrupt);

input wire [7:0] op;
input wire mm2_adef;
input wire mm2_sys;
input wire mm2_brk;
input wire mm2_ine;
input wire mm2_ale;
input wire mm2_interrupt;

output reg mm2_csr_we;
output reg [5:0] mm2_ecode;
output reg [8:0] mm2_esubcode;

always @(*) begin
    if(mm2_adef | mm2_sys | mm2_brk | mm2_ine | mm2_ale | mm2_interrupt) begin
        mm2_csr_we = 1'b0;
        mm2_ecode = mm2_interrupt ? `ECODE_INT:
                    mm2_adef ? `ECODE_ADE:
                    mm2_ale ? `ECODE_ALE:
                    mm2_sys ? `ECODE_SYS:
                    mm2_brk ? `ECODE_BRK:
                    mm2_ine ? `ECODE_INE:
                    6'b0;
        mm2_esubcode = 9'b000000000;
    end 
    else begin
        mm2_csr_we = (op == `OP_CSRWR || op == `OP_CSRXCHG);
        mm2_ecode = 6'b000000;
        mm2_esubcode = 9'b000000000;
    end
end
    
endmodule
