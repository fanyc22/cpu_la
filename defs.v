`define OP_TYPE_3R 4'd15
`define OP_TYPE_2RI12 4'd1
`define OP_TYPE_BJ 4'd2
`define OP_TYPE_ATOMIC 4'd3
`define OP_TYPE_CSR 4'd4
`define OP_TYPE_U12I 4'd5
`define OP_TYPE_RDCNT 4'd6
`define OP_TYPE_ETRN 4'd8

`define OP_TYPE_INVALID 4'd0

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
//rdcnt
`define OP_RDCNT 8'd49
`define OP_RDCNTH 8'd50
//etrn
`define OP_ETRN 8'd51

`define OP_INVALID 8'd0

`define ACCESS_SZ_BYTE 2'b00
`define ACCESS_SZ_HALF 2'b01
`define ACCESS_SZ_WORD 2'b10    
`define ACCESS_SZ_INVALID 2'b11

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

`define FWD_SRC_EX 3'd1
`define FWD_SRC_MM1 3'd2
`define FWD_SRC_MM2_REG 3'd3
`define FWD_SRC_MM2_MEM 3'd4
`define FWD_SRC_WB 3'd5
`define FWD_SRC_NONE 3'd0

`define MUL_CYCLES 6'd5 // real clyles needed is MUL_CYCLES+1
`define DIV_CYCLES 6'd20 // real clyles needed is MUL_CYCLES+1

`define CSR_CRMD_PLV    1 :0
`define CSR_CRMD_IE     2
`define CSR_PRMD_PPLV   1 :0
`define CSR_PRMD_PIE    2
`define CSR_ECFG_LIE    12:0
`define CSR_ECFG_LIE90  9 :0
`define CSR_ESTAT_IS10  1 :0
`define CSR_ESTAT_IS    9 :0
`define CSR_ERA_PC      31:0
`define CSR_EENTRY_VADDR   31:6
`define CSR_SAVE_DATA   31:0
`define CSR_TID_TID     31:0
`define CSR_TCFG_EN     0
`define CSR_TCFG_PERIOD 1
`define CSR_TCFG_INITV  31:2
`define CSR_TICLR_CLR   0

`define CSR_CRMD   14'h00
`define CSR_PRMD   14'h01
`define CSR_EUEN   14'h02
`define CSR_ECFG   14'h04
`define CSR_ESTAT  14'h05
`define CSR_ERA    14'h06
`define CSR_BADV   14'h07
`define CSR_EENTRY 14'h0c
`define CSR_TLBIDX 14'h10
`define CSR_TLBHI  14'h11
`define CSR_TLBLO0 14'h12
`define CSR_TLBLO1 14'h13
`define CSR_ASID   14'h18
`define CSR_PGDL   14'h19
`define CSR_PGDH   14'h1a
`define CSR_PGD    14'h1b
`define CSR_CPUID  14'h20
`define CSR_SAVE0  14'h30
`define CSR_SAVE1  14'h31
`define CSR_SAVE2  14'h32
`define CSR_SAVE3  14'h33
`define CSR_TID    14'h40
`define CSR_TCFG   14'h41
`define CSR_TVAL   14'h42
`define CSR_TICLR  14'h44
`define CSR_LLBCTL 14'h60
`define CSR_TLBRENTRY 14'h88
`define CSR_CTAG   14'h98
`define CSR_DMW0   14'h180
`define CSR_DMW1   14'h181


`define ECODE_INT       6'h00
`define ECODE_ADE       6'h08   // ADEM: esubcode=1; ADEF: esubcode=0
`define ECODE_ALE       6'h09   
`define ECODE_SYS       6'h0B
`define ECODE_BRK       6'h0C   
`define ECODE_INE       6'h0D
`define ECODE_TLBR      6'h3F

`define ESUBCODE_ADEF   9'b00

`define CSR_REG_SIZE 64