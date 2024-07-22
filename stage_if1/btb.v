module btb(
        //output
        target,
        //input
        clk,
        rst_n,
        // if1_if2_flushed,
        if1_pc,
        ex_pc,
        we,
        wtarget
    );

    parameter BTB_WIDTH = 37; // validbit:1, Tag:2, target:32
    parameter BTB_WAY_BIT = 4;  // 16-way set associative, =tag bit
    parameter BTB_WAY = 16;
    parameter BTB_GROUP_BIT = 6; // 64 groups, =index bit
    parameter BTB_GROUP = 64;
    parameter VALID_BIT = 36;
    parameter TAG_MSB = 35;
    parameter TAG_LSB = 32;
    parameter TARGET_BIT = 32;

    input wire clk;
    input wire rst_n;
    // input wire if1_if2_flushed;
    input wire [31:0] if1_pc;
    input wire [31:0] ex_pc;
    input wire we;
    input wire [31:0] wtarget;

    output reg [31:0] target;

    reg [BTB_WIDTH-1:0] btb[BTB_GROUP-1:0][BTB_WAY-1:0];
    reg [BTB_WAY_BIT-1:0] fifo_ptr[BTB_GROUP-1:0]; // FIFO pointer, to replace which way in the group


    // update btb from ex_pc
    integer i, j;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < BTB_GROUP; i = i + 1) begin
                for (j = 0; j < BTB_WAY; j = j + 1) begin
                    btb[i][j] <= 0;
                end
                fifo_ptr[i] <= 0;
            end
        end
        else if (we) begin
            btb[ex_pc[BTB_GROUP_BIT+1:2]] [fifo_ptr[ex_pc[BTB_GROUP_BIT+1:2]]] [VALID_BIT] <= 1;
            btb[ex_pc[BTB_GROUP_BIT+1:2]] [fifo_ptr[ex_pc[BTB_GROUP_BIT+1:2]]] [TAG_MSB:TAG_LSB] <= ex_pc[BTB_WAY_BIT+BTB_GROUP_BIT+1:BTB_GROUP_BIT+2];
            btb[ex_pc[BTB_GROUP_BIT+1:2]] [fifo_ptr[ex_pc[BTB_GROUP_BIT+1:2]]] [TARGET_BIT-1:0] <= wtarget;
            fifo_ptr[ex_pc[BTB_GROUP_BIT+1:2]] <= (fifo_ptr[ex_pc[BTB_GROUP_BIT+1:2]] + 1) % BTB_WAY;
        end
    end


    // make prediction for if1_pc
    always @(*) begin
        if (!rst_n) begin
            target <= 32'b0;
        end
        else begin
            for (j = 0; j < BTB_WAY; j = j + 1) begin
                if (btb[if1_pc[BTB_GROUP_BIT+1:2]] [j] [VALID_BIT]
                        && btb[if1_pc[BTB_GROUP_BIT+1:2]] [j] [TAG_MSB:TAG_LSB] == if1_pc[BTB_WAY_BIT+BTB_GROUP_BIT+1:BTB_GROUP_BIT+2]
                   ) begin
                    target <= btb[if1_pc[BTB_GROUP_BIT+1:2]] [j] [TARGET_BIT-1:0];
                end
            end
        end
    end

endmodule
