
# Entity: core 
- **File**: core.v

## Diagram
![Diagram](core.svg "Diagram")
## Ports

| Port name | Direction | Type | Description |
| --------- | --------- | ---- | ----------- |
| clk       | input     | wire |             |
| rst_n     | input     | wire |             |

## Signals

| Name               | Type        | Description |
| ------------------ | ----------- | ----------- |
| if1_if2_flush      | wire        |             |
| if2_id_flush       | wire        |             |
| id_ex_flush        | wire        |             |
| ex_mm1_flush       | wire        |             |
| mm1_mm2_flush      | wire        |             |
| mm2_wb_flush       | wire        |             |
| if1_if2_wen        | wire        |             |
| if2_id_wen         | wire        |             |
| id_ex_wen          | wire        |             |
| ex_mm1_wen         | wire        |             |
| mm1_mm2_wen        | wire        |             |
| mm2_wb_wen         | wire        |             |
| if1_pc             | wire [31:0] |             |
| if2_branch_taken   | wire        |             |
| if2_branch_address | wire [31:0] |             |
| if2_inst           | wire [31:0] |             |
| if2_icache_hit     | wire        |             |
| id_rj_from_gr      | wire [31:0] |             |
| id_rk_from_gr      | wire [31:0] |             |
| id_rd_from_gr      | wire [31:0] |             |
| id_reg_d           | wire [4:0]  |             |
| id_reg_j           | wire [4:0]  |             |
| id_reg_k           | wire [4:0]  |             |
| id_op              | wire [7:0]  |             |
| id_op_type         | wire [2:0]  |             |
| id_imm             | wire [25:0] |             |
| id_imm_sz          | wire [2:0]  |             |
| id_bns_code        | wire [14:0] |             |
| id_shift_imm       | wire [4:0]  |             |
| id_u12imm          | wire [19:0] |             |
| id_flag_unsigned   | wire        |             |
| id_access_sz       | wire [2:0]  |             |
| id_is_branch       | wire        |             |
| id_csr             | wire [13:0] |             |
| ex_alu_in2         | wire [31:0] |             |
| ex_alu_out         | wire [31:0] |             |
| ex_alu_zero        | wire        |             |
| ex_mm_access_sz    | wire [2:0]  |             |
| ex_mm_addr         | wire [31:0] |             |
| ex_exe_out         | wire [31:0] |             |
| ex_mm_re           | wire        |             |
| ex_mm_we           | wire        |             |
| ex_mm_wdata        | wire [31:0] |             |
| ex_branch          | wire        |             |
| ex_pc_branch       | wire [31:0] |             |
| mm2_rdata          | wire [31:0] |             |
| mm2_hit            | wire        |             |
| wb_gr_we           | wire        |             |
| wb_gr_waddr        | wire [4:0]  |             |
| wb_gr_wdata        | wire [31:0] |             |

## Constants

| Name       | Type | Value | Description |
| ---------- | ---- | ----- | ----------- |
| WITH_CACHE |      | 0     |             |
| WITH_TLB   |      | 0     |             |

## Instantiations

- U_pc: pc
- U_icache: icache
- if1_if2: reg_if1_if2
- U_bp: bp
- if2_id: reg_if2_id
- U_gr: gr
- U_decoder: decoder
- id_ex: reg_id_ex
- U_alu: alu
- U_ex_ctrl: ex_ctrl
- ex_mm1: reg_ex_mm1
- U_dcache: dcache
- mm1_mm2: reg_mm1_mm2
- mm2_wb: reg_mm2_wb
- U_regwrite: regwrite
