`define OP_TYPE_3R 3'd7
`define OP_TYPE_2RI12 3'd1
`define OP_TYPE_BJ 3'd2
`define OP_TYPE_ATOMIC 3'd3
`define OP_TYPE_CSR 3'd4
`define OP_TYPE_U12I 3'd5

`define OP_TYPE_INVALID 3'd0

//3r
`define OP_ADD 8'd63
`define OP_SUB 8'd1
`define OP_SLT 8'd2
`define OP_SLTU 8'd3
`define OP_NOR 8'd4
`define OP_AND 8'd5
`define OP_OR 8'd6
`define OP_XOR 8'd7
`define OP_SLL 8'd8
`define OP_SRL 8'd9
`define OP_SRA 8'd10
`define OP_MUL 8'd11
`define OP_MULH 8'd12
`define OP_MULHU 8'd13
`define OP_DIV 8'd14
`define OP_MOD 8'd15
`define OP_DIVU 8'd16
`define OP_MODU 8'd17
`define OP_BREAK 8'd18
`define OP_SYSCALL 8'd19
`define OP_SLLI 8'd20
`define OP_SRLI 8'd21
`define OP_SRAI 8'd22
//2ri12
`define OP_SLTI 8'd23
`define OP_SLTUI 8'd24
`define OP_ADDI 8'd25
`define OP_ANDI 8'd26
`define OP_ORI 8'd27
`define OP_XORI 8'd28
`define OP_CACOP 8'd32
`define OP_LD 8'd35
`define OP_ST 8'd36
`define OP_LDU 8'd37
//bj
`define OP_JIRL 8'd38
`define OP_B 8'd39
`define OP_BL 8'd40
`define OP_BEQ 8'd41
`define OP_BNE 8'd42
`define OP_BLT 8'd43
`define OP_BGE 8'd44
`define OP_BLTU 8'd45
`define OP_BGEU 8'd46
//atomic
`define OP_LL 8'd47
`define OP_SC 8'd48
//csr
`define OP_CSRRD 8'd29
`define OP_CSRWR 8'd30
`define OP_CSRXCHG 8'd31
//u12i
`define OP_LU12I 8'd33
`define OP_PCADDU12I 8'd34

`define OP_INVALID 8'd0

`define ACCESS_SZ_BYTE 3'd7
`define ACCESS_SZ_HALF 3'd1
`define ACCESS_SZ_WORD 3'd2
`define ACCESS_SZ_LEFT 3'd3
`define ACCESS_SZ_RIGHT 3'd4
`define ACCESS_SZ_INVALID 3'd0

`define BTB_NN 2'd0
`define BTB_NB 2'd1
`define BTB_BN 2'd2
`define BTB_BB 2'd3
 
`define BTB_WIDTH 35 //validbit:1,predictbit:2,target:32
`define VALID_BIT 34
`define PREDICT_BIT 33:32
`define HIGH_PREDICT_BIT 33
`define LOW_PREDICT_BIT 32
`define TARGET_BIT 31:0

`define IMM_SZ_8 3'd7
`define IMM_SZ_12 3'd1
`define IMM_SZ_14 3'd2
`define IMM_SZ_16 3'd3
`define IMM_SZ_21 3'd4
`define IMM_SZ_26 3'd5
`define IMM_SZ_0 3'd0

`define FWD_SRC_EX 3'd3
`define FWD_SRC_MM1 3'd1
`define FWD_SRC_MM2_REG 3'd2
`define FWD_SRC_MM2_MEM 3'd3
`define FWD_SRC_WB 3'd4
`define FWD_SRC_NONE 3'd0