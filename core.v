`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"

module core (
        //output
        inst_cache_re,
        inst_cache_raddr,
        inst_cache_we,
        inst_cache_waddr,
        inst_cache_wdata,
        inst_cache_access_sz,

        data_cache_re,
        data_cache_raddr,
        data_cache_we,
        data_cache_waddr,
        data_cache_wdata,
        data_cache_access_sz,

        debug_wb_pc,
        debug_wb_rf_we,
        debug_wb_rf_wnum,
        debug_wb_rf_wdata,
        //input
        inst_cache_rdata,
        inst_cache_hit,
        data_cache_rdata,
        data_cache_hit,
        clk,
        rst_n);

    parameter WITH_CACHE = 0;
    parameter WITH_TLB = 0;

    input wire clk;
    input wire rst_n;
    input wire [31:0] inst_cache_rdata;
    input wire inst_cache_hit;
    input wire [31:0] data_cache_rdata;
    input wire data_cache_hit;

    output reg inst_cache_re;
    output reg [31:0] inst_cache_raddr;
    output reg inst_cache_we;
    output reg [31:0] inst_cache_waddr;
    output reg [31:0] inst_cache_wdata;
    output reg [1:0] inst_cache_access_sz;

    output wire data_cache_re;
    output wire [31:0] data_cache_raddr;
    output wire data_cache_we;
    output wire [31:0] data_cache_waddr;
    output wire [31:0] data_cache_wdata;
    output wire [1:0] data_cache_access_sz;

    output wire [31:0] debug_wb_pc;
    output wire [3:0] debug_wb_rf_we;
    output wire [4:0] debug_wb_rf_wnum;
    output wire [31:0] debug_wb_rf_wdata;

    wire pc_wen;
    wire pc_is_wrong;
    wire [31:0] pc_correct;

    wire if1_if2_flush;
    wire if2_id_flush;
    wire id_ex_flush;
    wire ex_mm1_flush;
    wire mm1_mm2_flush;
    wire mm2_wb_flush;

    wire if1_if2_wen;
    wire if2_id_wen;
    wire id_ex_wen;
    wire id_ex_bp_flush;
    wire ex_mm1_wen;
    wire mm1_mm2_wen;
    wire mm2_wb_wen;

    wire [31:0] if1_pc;
    wire if1_adef;
    wire if1_icache_re;
    wire if1_branch_taken;
    wire [31:0] if1_branch_address;

    // *******************
    // for bp
    wire if1_answ_bht;
    wire if1_answ_ghr;
    // wire if2_answ_bht;
    // wire if2_answ_ghr;
    // wire id_answ_bht;
    // wire id_answ_ghr;
    // wire ex_answ_bht;
    // wire ex_answ_ghr;
    //*********************

    wire [31:0] if2_inst;
    wire if2_icache_hit;

    wire id_sys;
    wire id_brk;
    wire id_ine;
    wire [14:0] id_sbcode;
    wire [31:0] id_rj_from_gr;
    wire [31:0] id_rk_from_gr;
    wire [31:0] id_rd_from_gr;
    wire [4:0] id_reg_d;
    wire [4:0] id_reg_j;
    wire [4:0] id_reg_k;
    wire [7:0] id_op;
    wire [3:0] id_op_type;
    wire [25:0] id_imm;
    wire [2:0] id_imm_sz;
    wire [14:0] id_bns_code;
    wire [4:0] id_shift_imm;
    wire [19:0] id_u12imm;
    wire id_flag_unsigned;
    wire [1:0] id_access_sz;
    wire id_is_branch;
    wire [13:0] id_csr_addr;
    wire id_reg_j_ren;
    wire id_reg_k_ren;
    wire id_reg_d_ren;
    wire [31:0] id_rj_from_fwd;
    wire [31:0] id_rk_from_fwd;
    wire [31:0] id_rd_from_fwd;

    wire [31:0] ex_alu_in2;
    wire [31:0] ex_alu_out;
    wire ex_alu_zero;
    wire [31:0] ex_mul_out;
    wire ex_mul_out_valid;
    wire [31:0] ex_div_out;
    wire ex_div_out_valid;
    // wire ex_mm_access_op;
    wire [1:0] ex_mm_access_sz;
    wire [31:0] ex_mm_addr;
    wire [31:0] ex_exe_out;
    wire ex_exe_out_valid;
    wire ex_mm_re;
    wire ex_mm_we;
    wire [31:0] ex_mm_wdata;
    wire ex_csr_re;
    wire ex_branch;
    wire [31:0] ex_pc_branch;
    wire ex_reg_d_wen;
    // reg [4:0] ex_reg_d;
    reg [31:0] ex_csr_wmask;
    reg ex_flush_before;
    wire ex_interrupt;
    wire ex_ertn;
    wire ex_ale;
    wire ex_soft_int_gen;
    reg ex_csr_we;
    reg soft_int_gened;

    wire [31:0] mm2_rdata;
    wire mm2_hit;
    wire mm2_csr_we;
    wire [5:0] mm2_ecode;
    wire [8:0] mm2_esubcode;

    wire [4:0] wb_gr_waddr;
    wire [31:0] wb_gr_wdata;
    wire [31:0] wb_csr_rdata;
    reg wb_exception;
    wire [31:0] wb_exception_entry;
    wire [31:0] wb_exception_return_entry;
    reg [31:0] wb_entry;
    reg [31:0] wb_gr_wdata_include_csr;

    wire [63:0] csr_timer;
    wire [31:0] csr_timer_id;
    wire [1:0] csr_ecfg_lie_soft;

    wire [2:0] fwd_src_j;
    wire [2:0] fwd_src_k;
    wire [2:0] fwd_src_d;

    hazard_ctrl U_hazard_ctrl(
                    .if1_if2_flush(if1_if2_flush),
                    .if2_id_flush(if2_id_flush),
                    .id_ex_flush(id_ex_flush),
                    .ex_mm1_flush(ex_mm1_flush),
                    .mm1_mm2_flush(mm1_mm2_flush),
                    .mm2_wb_flush(mm2_wb_flush),
                    .if1_if2_wen(if1_if2_wen),
                    .if2_id_wen(if2_id_wen),
                    .id_ex_wen(id_ex_wen),
                    .id_ex_bp_flush(id_ex_bp_flush),
                    .ex_mm1_wen(ex_mm1_wen),
                    .mm1_mm2_wen(mm1_mm2_wen),
                    .mm2_wb_wen(mm2_wb_wen),
                    .pc_wen(pc_wen),
                    .fwd_src_j(fwd_src_j),
                    .fwd_src_k(fwd_src_k),
                    .fwd_src_d(fwd_src_d),
                    .pc_is_wrong(pc_is_wrong),
                    .pc_correct(pc_correct),
                    .ex_flush_before(ex_flush_before),
                    .mm1_flush_before(ex_mm1.flush_before),
                    .mm2_flush_before(mm1_mm2.flush_before),
                    .wb_flush_before(mm2_wb.flush_before),
                    .wb_entry(wb_entry),
                    .ex_exe_out_valid(ex_exe_out_valid),
                    .ex_pc(id_ex.pc),
                    .ex_branch(ex_branch),
                    .ex_pc_branch(ex_pc_branch),
                    .ex_branch_bp(id_ex.branch_bp),
                    .id_pc(if2_id.pc),
                    .id_is_branch(id_is_branch),
                    .id_branch_bp(if2_id.branch_bp),
                    .id_reg_j_ren(id_reg_j_ren),
                    .id_reg_j(id_reg_j),
                    .id_reg_k_ren(id_reg_k_ren),
                    .id_reg_k(id_reg_k),
                    .id_reg_d_ren(id_reg_d_ren),
                    .id_reg_d(id_reg_d),
                    .ex_reg_d_wen(ex_reg_d_wen),
                    .ex_reg_d(id_ex.reg_d),
                    .ex_mm_load(ex_mm_re),
                    .ex_csr_re(ex_csr_re),
                    .mm1_reg_d_wen(ex_mm1.reg_d_wen),
                    .mm1_reg_d(ex_mm1.reg_d),
                    .mm1_mm_load(ex_mm1.mm_re),
                    .mm1_csr_re(ex_mm1.csr_re),
                    .mm2_reg_d_wen(mm1_mm2.reg_d_wen),
                    .mm2_reg_d(mm1_mm2.reg_d),
                    .mm2_mm_load(mm1_mm2.mm_re),
                    .mm2_csr_re(mm1_mm2.csr_re),
                    .wb_reg_d_wen(mm2_wb.reg_d_wen),
                    .wb_reg_d(wb_gr_waddr),
                    .wb_csr_re(mm2_wb.csr_re));

    pc U_pc(
           .pc_reg(if1_pc),
           .rst_n(rst_n),
           .clk(clk),
           .pc_wen(pc_wen),
           .pc_is_wrong(pc_is_wrong),
           .pc_correct(pc_correct),
           .if1_adef(if1_adef),
           .is_branch(if1_branch_taken),
           .branch_address(if1_branch_address),
           .icache_re(if1_icache_re));

    // icache U_icache(
    //             .rdata(if2_inst),
    //             .hit(if2_icache_hit),
    //             .clk(clk),
    //             .rst_n(rst_n),
    //             .re(if1_icache_re),
    //             .raddr(if1_pc),
    //             .we(1'b0),
    //             .waddr(32'b0),
    //             .wdata(32'b0),
    //             .wsz(3'b0));

    assign if2_inst = inst_cache_rdata;
    assign if2_icache_hit = inst_cache_hit;


    always @(*) begin
        inst_cache_re <= if1_icache_re;
        inst_cache_raddr <= if1_pc;
        inst_cache_we <= 4'b0;
        inst_cache_access_sz <= `ACCESS_SZ_WORD;
        inst_cache_waddr <= 32'b0;
        inst_cache_wdata <= 32'b0;
    end


    reg_if1_if2 if1_if2(
                    .clk(clk),
                    .rst_n(rst_n),
                    .wen(if1_if2_wen),
                    .flush(if1_if2_flush),
                    .if1_adef(if1_adef),
                    .if1_pc(if1_pc),
                    .if1_branch_bp(if1_branch_taken),
                    .if1_answ_bht(if1_answ_bht),
                    .if1_answ_ghr(if1_answ_ghr));

    // bp U_bp(
    //             .branch(if1_branch_taken),
    //             .target(if1_branch_address),
    //             .clk(clk),
    //             .rst_n(rst_n),
    //         //     .if1_if2_flushed(if1_if2.flushed),
    //             .pc_low(if1_pc[5:0]),
    //             .we(id_ex.is_branch),
    //             .hitted(ex_branch),
    //             .wtarget(ex_pc_branch),
    //             .hit_addr(id_ex.pc[5:0])
    //             );

    bp_top U_bp_top(
               .clk(clk),
               .rst_n(rst_n),
               .if1_pc(if1_pc),
               .ex_pc(id_ex.pc),
               .wtarget(ex_pc_branch),
               .branched(ex_branch),
               .ex_answ_bht(id_ex.ex_answ_bht),
               .ex_answ_ghr(id_ex.ex_answ_ghr),
               .ex_answ(id_ex.branch_bp),
               .we(id_ex.is_branch),
               .target(if1_branch_address),
               .answ(if1_branch_taken),
               .if1_answ_bht(if1_answ_bht),
               .if1_answ_ghr(if1_answ_ghr)
           );



    reg_if2_id if2_id(
                   .clk(clk),
                   .rst_n(rst_n),
                   .wen(if2_id_wen),
                   .flush(if2_id_flush),
                   .if2_adef(if1_if2.adef),
                   .if2_pc(if1_if2.pc),
                   .if2_inst(if2_inst),
                   .if2_icache_hit(if2_icache_hit),
                   .if2_branch_bp(if1_if2.branch_bp),
                   .if1_if2_cache_valid(if1_if2.cache_valid),
                   .if1_if2_flushed(if1_if2.flushed),
                   .if2_answ_bht(if1_if2.if2_answ_bht),
                   .if2_answ_ghr(if1_if2.if2_answ_ghr)
               );

    always @(*) begin
        wb_gr_wdata_include_csr = mm2_wb.op_type == `OP_TYPE_CSR ? wb_csr_rdata : wb_gr_wdata;
    end

    gr U_gr(
           .rdata1(id_rj_from_gr),
           .rdata2(id_rk_from_gr),
           .rdata3(id_rd_from_gr),
           .clk(clk),
           .rst_n(rst_n),
           .we(mm2_wb.reg_d_wen),
           .waddr(wb_gr_waddr),
           .wdata(wb_gr_wdata_include_csr),
           .raddr1(id_reg_j),
           .raddr2(id_reg_k),
           .raddr3(id_reg_d));

    assign debug_wb_pc = mm2_wb.pc;
    assign debug_wb_rf_we = {4{mm2_wb.reg_d_wen}};
    assign debug_wb_rf_wnum = wb_gr_waddr;
    assign debug_wb_rf_wdata = wb_gr_wdata_include_csr;

    decoder U_decoder(
                .id_sys(id_sys),
                .id_brk(id_brk),
                .id_ine(id_ine),
                .id_sbcode(id_sbcode),
                .reg_d(id_reg_d),
                .reg_j(id_reg_j),
                .reg_k(id_reg_k),
                .op(id_op),
                .op_type(id_op_type),
                .imm(id_imm),
                .imm_sz(id_imm_sz),
                .bns_code(id_bns_code),
                .shift_imm(id_shift_imm),
                .u12imm(id_u12imm),
                .flag_unsigned(id_flag_unsigned),
                .access_sz(id_access_sz),
                .is_branch(id_is_branch),
                .inst(if2_id.inst),
                .csr_addr(id_csr_addr),
                .reg_j_ren(id_reg_j_ren),
                .reg_k_ren(id_reg_k_ren),
                .reg_d_ren(id_reg_d_ren),
                .id_flushed(if2_id.flushed));

    fwd U_fwd_j(
            .reg_out(id_rj_from_fwd),
            .reg_from_gr(id_rj_from_gr),
            .reg_from_ex(ex_exe_out),
            .reg_from_mm1(ex_mm1.exe_out),
            .reg_from_mm2(mm1_mm2.exe_out),
            .mem_from_mm2(mm2_rdata),
            .reg_from_wb(wb_gr_wdata_include_csr),
            .fwd_ctrl(fwd_src_j));

    fwd U_fwd_k(
            .reg_out(id_rk_from_fwd),
            .reg_from_gr(id_rk_from_gr),
            .reg_from_ex(ex_exe_out),
            .reg_from_mm1(ex_mm1.exe_out),
            .reg_from_mm2(mm1_mm2.exe_out),
            .mem_from_mm2(mm2_rdata),
            .reg_from_wb(wb_gr_wdata_include_csr),
            .fwd_ctrl(fwd_src_k));

    fwd U_fwd_d(
            .reg_out(id_rd_from_fwd),
            .reg_from_gr(id_rd_from_gr),
            .reg_from_ex(ex_exe_out),
            .reg_from_mm1(ex_mm1.exe_out),
            .reg_from_mm2(mm1_mm2.exe_out),
            .mem_from_mm2(mm2_rdata),
            .reg_from_wb(wb_gr_wdata_include_csr),
            .fwd_ctrl(fwd_src_d));

    reg_id_ex id_ex(
                  .clk(clk),
                  .rst_n(rst_n),
                  .wen(id_ex_wen),
                  .flush(id_ex_flush),
                  .bp_flush(id_ex_bp_flush),
                  .id_adef(if2_id.adef),
                  .id_sys(id_sys),
                  .id_brk(id_brk),
                  .id_ine(id_ine),
                  .id_sbcode(id_sbcode),
                  .id_pc(if2_id.pc),
                  .id_rj_from_fwd(id_rj_from_fwd),
                  .id_rk_from_fwd(id_rk_from_fwd),
                  .id_rd_from_fwd(id_rd_from_fwd),
                  .id_reg_d(id_reg_d),
                  .id_reg_j(id_reg_j),
                  .id_reg_k(id_reg_k),
                  .id_op(id_op),
                  .id_op_type(id_op_type),
                  .id_imm(id_imm),
                  .id_imm_sz(id_imm_sz),
                  .id_bns_code(id_bns_code),
                  .id_shift_imm(id_shift_imm),
                  .id_u12imm(id_u12imm),
                  .id_flag_unsigned(id_flag_unsigned),
                  .id_access_sz(id_access_sz),
                  .id_is_branch(id_is_branch),
                  .id_csr_addr(id_csr_addr),
                  .id_branch_bp(if2_id.branch_bp),
                  .id_reg_j_ren(id_reg_j_ren),
                  .id_reg_k_ren(id_reg_k_ren),
                  .id_reg_d_ren(id_reg_d_ren),
                  .id_answ_bht(if2_id.id_answ_bht),
                  .id_answ_ghr(if2_id.id_answ_ghr));

    alu_in2_mux U_alu_in2_mux(
                    .alu_in2(ex_alu_in2),
                    .op(id_ex.op),
                    .op_type(id_ex.op_type),
                    .rk_from_fwd(id_ex.rk_from_fwd),
                    .imm_unext(id_ex.imm),
                    .imm_sz(id_ex.imm_sz),
                    .shift_imm(id_ex.shift_imm),
                    .flag_unsigned(id_ex.flag_unsigned));

    alu U_alu(
            .alu_in1(id_ex.rj_from_fwd),
            .alu_in2(ex_alu_in2),
            .alu_op(id_ex.op),
            .alu_out(ex_alu_out),
            .alu_zero(ex_alu_zero));

    mul U_mul(
            .clk(clk),
            .rst_n(rst_n),
            .op(id_ex.op),
            .mul_in_a(id_ex.rj_from_fwd),
            .mul_in_b(id_ex.rk_from_fwd),
            .mul_out(ex_mul_out),
            .mul_out_valid(ex_mul_out_valid));

    div U_div(
            .clk(clk),
            .rst_n(rst_n),
            .op(id_ex.op),
            .div_in_dividend(id_ex.rj_from_fwd),
            .div_in_divisor(id_ex.rk_from_fwd),
            .div_out(ex_div_out),
            .div_out_valid(ex_div_out_valid));

    branch U_branch(
               .branch(ex_branch),
               .op(id_ex.op),
               .op_type(id_ex.op_type),
               .rj(id_ex.rj_from_fwd),
               .rd(id_ex.rd_from_fwd));

    pc_branch U_pc_branch(
                  .pc_branch(ex_pc_branch),
                  .op(id_ex.op),
                  .rj(id_ex.rj_from_fwd),
                  .pc(id_ex.pc),
                  .offset(id_ex.imm));

    ex_ctrl U_ex_ctrl(
                .op(id_ex.op),
                .op_type(id_ex.op_type),
                .alu_out(ex_alu_out),
                .mul_out(ex_mul_out),
                .mul_out_valid(ex_mul_out_valid),
                .div_out(ex_div_out),
                .div_out_valid(ex_div_out_valid),
                .ex_access_sz(id_ex.access_sz),
                .ex_rd_from_fwd(id_ex.rd_from_fwd),
                .ex_ale(ex_ale),
                .ex_ertn(ex_ertn),
                .mm_access_sz(ex_mm_access_sz),
                .mm_addr(ex_mm_addr),
                .exe_out(ex_exe_out),
                .exe_out_valid(ex_exe_out_valid),
                .mm_re(ex_mm_re),
                .mm_we(ex_mm_we),
                .mm_wdata(ex_mm_wdata),
                .csr_re(ex_csr_re),
                .reg_d_wen(ex_reg_d_wen),
                .pc(id_ex.pc),
                .u12imm(id_ex.u12imm));

    always @(*) begin
        // ex_reg_d <= (id_ex.op == `OP_RDCNTID) ? id_ex.reg_j : id_ex.reg_d;
        ex_csr_wmask <= (id_ex.op == `OP_CSRXCHG) ? id_ex.rj_from_fwd : 32'b11111111_11111111_11111111_11111111;
        ex_flush_before <= (id_ex.adef |
                            id_ex.sys |
                            id_ex.brk |
                            id_ex.ine |
                            ex_interrupt |
                            ex_ale |
                            ex_ertn |
                            soft_int_gened) & ( | id_ex.pc);
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            soft_int_gened <= 1'b0;
        end
        else if(soft_int_gened && | id_ex.pc) begin
            soft_int_gened <= 1'b0;
        end
        else if(ex_soft_int_gen) begin
            soft_int_gened <= 1'b1;
        end
    end

    always @(*) begin
        ex_csr_we = (!ex_flush_before) && ((id_ex.op == `OP_CSRWR) || (id_ex.op == `OP_CSRXCHG));
    end

    soft_int_gen U_soft_int_gen(
                     .ex_soft_int_gen(ex_soft_int_gen),
                     .ex_csr_addr(id_ex.csr_addr),
                     .ex_csr_wdata(id_ex.rd_from_fwd),
                     .ex_csr_we(ex_csr_we),
                     .ex_csr_wmask(ex_csr_wmask),
                     .mm1_csr_addr(ex_mm1.csr_addr),
                     .mm1_csr_wdata(ex_mm1.csr_wdata),
                     .mm1_csr_we(ex_mm1.csr_we),
                     .mm1_csr_wmask(ex_mm1.csr_wmask),
                     .mm2_csr_addr(mm1_mm2.csr_addr),
                     .mm2_csr_wdata(mm1_mm2.csr_wdata),
                     .mm2_csr_we(mm1_mm2.csr_we),
                     .mm2_csr_wmask(mm1_mm2.csr_wmask),
                     .csr_ecfg_lie_soft(csr_ecfg_lie_soft));


    reg_ex_mm1 ex_mm1(
                   .clk(clk),
                   .rst_n(rst_n),
                   .wen(ex_mm1_wen),
                   .ex_csr_wdata(id_ex.rd_from_fwd),
                   .ex_csr_wmask(ex_csr_wmask),
                   .ex_csr_addr(id_ex.csr_addr),
                   .ex_csr_re(ex_csr_re),
                   .ex_csr_we(ex_csr_we),
                   // .ex_soft_int_gen(ex_soft_int_gen),
                   .flush(ex_mm1_flush),
                   .ex_adef(id_ex.adef),
                   .ex_sys(id_ex.sys),
                   .ex_brk(id_ex.brk),
                   .ex_ine(id_ex.ine),
                   .ex_ale(ex_ale),
                   .ex_ertn(ex_ertn),
                   .ex_interrupt(ex_interrupt),
                   .ex_sbcode(id_ex.sbcode),
                   .ex_flush_before(ex_flush_before),
                   .ex_exe_out(ex_exe_out),
                   .ex_mm_access_sz(ex_mm_access_sz),
                   .ex_mm_addr(ex_mm_addr),
                   .ex_mm_re(ex_mm_re),
                   .ex_mm_we(ex_mm_we),
                   .ex_mm_wdata(ex_mm_wdata),
                   .ex_reg_d(id_ex.reg_d),
                   .ex_op(id_ex.op),
                   .ex_op_type(id_ex.op_type),
                   .ex_reg_d_wen(ex_reg_d_wen),
                   .ex_pc(id_ex.pc));

    // dcache U_dcache(
    //             .clk(clk),
    //             .rst_n(rst_n),
    //             .re(ex_mm1.mm_re),
    //             .raddr(ex_mm1.mm_addr),
    //             .we(ex_mm1.mm_we),
    //             .waddr(ex_mm1.mm_addr),
    //             .wdata(ex_mm1.mm_wdata),
    //             .wsz(ex_mm1.mm_access_sz),
    //             .rdata(mm2_rdata),
    //             .hit(mm2_hit));

    assign data_cache_re = ex_mm1.mm_re;
    assign data_cache_raddr = ex_mm1.mm_addr;
    assign data_cache_we = ex_mm1.mm_we;
    assign data_cache_waddr = ex_mm1.mm_addr;
    assign data_cache_wdata = ex_mm1.mm_wdata;
    assign data_cache_access_sz = ex_mm1.mm_access_sz;
    assign mm2_rdata = data_cache_rdata >> {mm1_mm2.mm_addr[1:0], 3'b000};
    assign mm2_hit = data_cache_hit;

    reg_mm1_mm2 mm1_mm2(
                    .clk(clk),
                    .rst_n(rst_n),
                    .wen(mm1_mm2_wen),
                    .flush(mm1_mm2_flush),
                    .mm1_adef(ex_mm1.adef),
                    .mm1_sys(ex_mm1.sys),
                    .mm1_brk(ex_mm1.brk),
                    .mm1_ine(ex_mm1.ine),
                    .mm1_ale(ex_mm1.ale),
                    .mm1_interrupt(ex_mm1.interrupt),
                    .mm1_ertn(ex_mm1.ertn),
                    .mm1_sbcode(ex_mm1.sbcode),
                    .mm1_flush_before(ex_mm1.flush_before),
                    .mm1_csr_wdata(ex_mm1.csr_wdata),
                    .mm1_csr_wmask(ex_mm1.csr_wmask),
                    .mm1_csr_addr(ex_mm1.csr_addr),
                    .mm1_csr_re(ex_mm1.csr_re),
                    .mm1_csr_we(ex_mm1.csr_we),
                    .mm1_exe_out(ex_mm1.exe_out),
                    .mm1_mm_access_sz(ex_mm1.mm_access_sz),
                    .mm1_mm_addr(ex_mm1.mm_addr),
                    .mm1_mm_re(ex_mm1.mm_re),
                    .mm1_reg_d(ex_mm1.reg_d),
                    .mm1_op(ex_mm1.op),
                    .mm1_op_type(ex_mm1.op_type),
                    .mm1_reg_d_wen(ex_mm1.reg_d_wen),
                    .mm1_pc(ex_mm1.pc));

    csr_ctrl U_csr_ctrl(
                 .mm2_csr_we(mm2_csr_we),
                 .mm2_ecode(mm2_ecode),
                 .mm2_esubcode(mm2_esubcode),
                 .op(mm1_mm2.op),
                 .mm2_adef(mm1_mm2.adef),
                 .mm2_sys(mm1_mm2.sys),
                 .mm2_brk(mm1_mm2.brk),
                 .mm2_ine(mm1_mm2.ine),
                 .mm2_ale(mm1_mm2.ale),
                 .mm2_interrupt(mm1_mm2.interrupt));

    reg_mm2_wb mm2_wb(
                   .clk(clk),
                   .rst_n(rst_n),
                   .wen(mm2_wb_wen),
                   .flush(mm2_wb_flush),
                   .mm2_csr_we(mm2_csr_we),
                   .mm2_ecode(mm2_ecode),
                   .mm2_esubcode(mm2_esubcode),
                   .mm2_adef(mm1_mm2.adef),
                   .mm2_sys(mm1_mm2.sys),
                   .mm2_brk(mm1_mm2.brk),
                   .mm2_ine(mm1_mm2.ine),
                   .mm2_ale(mm1_mm2.ale),
                   .mm2_interrupt(mm1_mm2.interrupt),
                   .mm2_ertn(mm1_mm2.ertn),
                   .mm2_sbcode(mm1_mm2.sbcode),
                   .mm2_flush_before(mm1_mm2.flush_before),
                   .mm2_csr_wdata(mm1_mm2.csr_wdata),
                   .mm2_csr_wmask(mm1_mm2.csr_wmask),
                   .mm2_csr_addr(mm1_mm2.csr_addr),
                   .mm2_csr_re(mm1_mm2.csr_re),
                   // .mm2_csr_we(mm1_mm2.csr_we),
                   .mm2_exe_out(mm1_mm2.exe_out),
                   .mm2_reg_d(mm1_mm2.reg_d),
                   .mm2_op(mm1_mm2.op),
                   .mm2_op_type(mm1_mm2.op_type),
                   .mm2_rdata(mm2_rdata),
                   .mm2_mm_addr(mm1_mm2.mm_addr),
                   .mm2_mm_access_sz(mm1_mm2.mm_access_sz),
                   .mm2_reg_d_wen(mm1_mm2.reg_d_wen),
                   .mm2_pc(mm1_mm2.pc));

    always @(*) begin
        wb_exception = (mm2_wb.flush_before && !mm2_wb.ertn);
    end

    csr U_csr(
            .clk(clk),
            .rst_n(rst_n),
            .csr_we(mm2_wb.csr_we),
            .csr_addr(mm2_wb.csr_addr),
            .csr_wdata(mm2_wb.csr_wdata),
            .csr_wmask(mm2_wb.csr_wmask),
            .ertn_flush(mm2_wb.ertn),
            .wb_exception(wb_exception),
            .wb_ecode(mm2_wb.ecode),
            .wb_esubcode(mm2_wb.esubcode),
            .wb_vaddr(mm2_wb.mm_addr),
            .wb_pc(mm2_wb.pc),
            .csr_rdata(wb_csr_rdata),
            .interrupt(ex_interrupt),
            .timer(csr_timer),
            .timer_id(csr_timer_id),
            .exception_entry(wb_exception_entry),
            .exception_return_entry(wb_exception_return_entry),
            .csr_ecfg_lie_soft(csr_ecfg_lie_soft));

    always @(*) begin
        wb_entry = mm2_wb.op == `OP_ERTN ? wb_exception_return_entry : wb_exception_entry;
    end

    regwrite U_regwrite(
                 .exe_out(mm2_wb.exe_out),
                 .reg_d(mm2_wb.reg_d),
                 .op(mm2_wb.op),
                 // .op_type(mm2_wb.op_type),
                 .csr_timer(csr_timer),
                 .csr_timer_id(csr_timer_id),
                 .wb_mm_access_sz(mm2_wb.mm_access_sz),
                 .rdata(mm2_wb.rdata),
                 .gr_waddr(wb_gr_waddr),
                 .gr_wdata(wb_gr_wdata));

endmodule
