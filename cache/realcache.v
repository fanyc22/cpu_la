`include "C:\\Users\\Lenovo\\Desktop\\nscscc-team-la32r\\func_test\\myCPU\\defs.v"
`define CONF_ADDR_BASE 32'h1faf_0000
`define CONF_ADDR_MASK 32'h1fff_0000 //for bfaf or 1faf

module realcache (
//output to CPU
    output_rdata,
    output_rdata_valid,
    output_wdata_valid,
//input from CPU
    cpu_flush,
    cpu_rw_op,
    cpu_rw_en,
    cpu_rw_addr,
    cpu_rw_wsize,
    cpu_rw_wdata,   
//read from RAM
//output to RAM
    axib_rd_req,
    axib_rd_type,
    axib_rd_addr,
//input from RAM
    axib_rd_rdy,
    axib_ret_valid,
    axib_ret_last,
    axib_ret_data,
//write to RAM
//output to RAM
    axib_wr_req,
    axib_wr_type,
    axib_wr_addr,
    axib_wr_wstrb,
    axib_wr_data,
//input from RAM
    axib_wr_rdy,
//input
    clk,
    rst_n
);

input wire clk;
input wire rst_n;

//output to CPU
output reg [31:0] output_rdata;
output reg output_rdata_valid;
output reg output_wdata_valid;

//input from CPU
input wire cpu_flush;
input wire cpu_rw_op;
input wire cpu_rw_en;
input wire [31:0] cpu_rw_addr;
input wire [1:0] cpu_rw_wsize;
input wire [31:0] cpu_rw_wdata;

//output to RAM for read
output reg axib_rd_req;
output reg [2:0] axib_rd_type;
output reg [31:0] axib_rd_addr;

//input from RAM for read
input wire axib_rd_rdy;
input wire axib_ret_valid;
input wire axib_ret_last;
input wire [31:0] axib_ret_data;

//output to RAM for write
output reg axib_wr_req;
output reg [2:0] axib_wr_type;
output reg [31:0] axib_wr_addr;
output reg [3:0] axib_wr_wstrb;
output reg [127:0] axib_wr_data;

//input from RAM for write
input wire axib_wr_rdy;

//internal signals
reg [`CC_LINE_WIDTH-1:0] cache_ram [`CC_SET_SIZE-1:0][`CC_WAY_SIZE-1:0];

reg cache_hit;
reg cache_way_full;
reg [1:0] cache_way_to_load;
wire [1:0] cache_way_to_replace;
reg [31:0] cache_replace_addr;
wire cache_replace_dirty;
reg [127:0] cache_replace_line;
reg [`CC_WAY_BIT_WIDTH-1:0] cache_hit_way;
reg [3:0] cache_last_state;
reg [3:0] cache_state;

reg [`CC_SET_BIT_WIDTH-1:0] cpu_addr_set;
reg [`CC_TAG_BIT_WIDTH-1:0] cpu_addr_tag;
reg [`CC_OFFSET_BIT_WIDTH-1:0] cpu_addr_offset;
wire cpu_uncache;

reg buffer_cpu_rw_en;
reg buffer_cpu_rw_op;
reg [31:0] buffer_cpu_rw_addr;
reg [`CC_SET_BIT_WIDTH-1:0] buffer_cpu_addr_set;
reg [`CC_TAG_BIT_WIDTH-1:0] buffer_cpu_addr_tag;
reg [`CC_OFFSET_BIT_WIDTH-1:0] buffer_cpu_addr_offset;
reg [1:0] buffer_cpu_rw_wsize;
reg [31:0] buffer_cpu_rw_wdata;
reg buffer_cpu_uncache;
reg [1:0] buffer_cache_way_hit;
reg [1:0] buffer_cache_way_to_load;
reg [31:0] buffer_cache_replace_addr;
reg [127:0] buffer_cache_replace_line;
// reg [`CC_LINE_WIDTH-1:0] buffer_axi_load_line;
reg [31:0] buffer_shift_load_line [`CC_LINE_SIZE-2:0];
reg [1:0] load_cnt;
//unassigned!!!

// reg axi_reading;
// reg [1:0] axi_op_reg;

reg buffer_axi_rdata_to_cpu;
reg [31:0] buffer_uncache_rdata;

always @(posedge clk) begin
    if(!rst_n) begin
        buffer_uncache_rdata <= 32'b0;
    end
    else begin
        buffer_uncache_rdata <= axib_ret_data;
    end
end

assign cpu_uncache = (cpu_rw_addr & `CONF_ADDR_MASK) == `CONF_ADDR_BASE;

//buffer_cpu and buffer_cache
always @(posedge clk) begin
    if(!rst_n) begin
        buffer_cpu_rw_en <= 0;
        buffer_cpu_rw_op <= 0;
        buffer_cpu_rw_addr <= 32'b0;
        buffer_cpu_addr_set <= 0;
        buffer_cpu_addr_tag <= 0;
        buffer_cpu_addr_offset <= 0;
        buffer_cpu_rw_wsize <= 2'b00;
        buffer_cpu_rw_wdata <= 32'b0;
        buffer_cpu_uncache <= 0;
        buffer_cache_way_hit <= 2'd0;
        buffer_cache_way_to_load <= 2'd0;
        buffer_cache_replace_addr <= 32'b0;
        buffer_cache_replace_line <= 128'b0;
    end
    else if(cache_last_state == `CC_STATE_AXILOADING_LAST 
        || cache_last_state == `CC_STATE_AVAILABLE
        || cache_last_state == `CC_STATE_FLUSH
        ||(cache_last_state == `CC_STATE_UNCACHE_AXIWRITING && !axib_wr_rdy)) begin
        buffer_cpu_rw_en <= cpu_rw_en;
        buffer_cpu_rw_op <= cpu_rw_op;
        buffer_cpu_rw_addr <= cpu_rw_addr;
        buffer_cpu_addr_set <= cpu_addr_set;
        buffer_cpu_addr_tag <= cpu_addr_tag;
        buffer_cpu_addr_offset <= cpu_addr_offset;
        buffer_cpu_rw_wsize <= cpu_rw_wsize;
        buffer_cpu_rw_wdata <= cpu_rw_wdata;
        buffer_cpu_uncache <= cpu_uncache;
        buffer_cache_way_hit <= cache_hit_way;
        buffer_cache_way_to_load <= cache_way_to_load;
        buffer_cache_replace_addr <= cache_replace_addr;
        buffer_cache_replace_line <= cache_replace_line;
    end
end

//output_rdata and output_rdata_valid
always @(*) begin
    if(!rst_n) begin
        output_rdata_valid <= 0;
        output_rdata <= 32'b0;
    end
    else begin
        if(cache_last_state == `CC_STATE_AXILOADING_LAST
            && buffer_cpu_rw_op == `CC_CPU_OP_RD
            && buffer_cpu_rw_en ) begin
            output_rdata_valid <= 1;
            // output_rdata <= buffer_axi_rdata_to_cpu;
            if(buffer_cpu_uncache) begin
                output_rdata <= buffer_uncache_rdata;
            end
            else begin
                case (buffer_cpu_addr_offset)
                    2'd0: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_to_load][`CC_LINE_DATA0];
                    2'd1: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_to_load][`CC_LINE_DATA1];
                    2'd2: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_to_load][`CC_LINE_DATA2];
                    default: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_to_load][`CC_LINE_DATA3];
                endcase
            end
        end
        else if(cache_last_state == `CC_STATE_AVAILABLE
            && buffer_cpu_rw_op == `CC_CPU_OP_RD
            && buffer_cpu_rw_en) begin
            output_rdata_valid <= 1;
            case (buffer_cpu_addr_offset)
                2'd0: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_hit][`CC_LINE_DATA0];
                2'd1: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_hit][`CC_LINE_DATA1];
                2'd2: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_hit][`CC_LINE_DATA2];
                default: output_rdata <= cache_ram[buffer_cpu_addr_set][buffer_cache_way_hit][`CC_LINE_DATA3];
            endcase
            end
        else begin
            output_rdata_valid <= 0;
            output_rdata <= 32'b0;
        end
    end
end

//output_wdata_valid
always @(*) begin
    if(!rst_n) begin
        output_wdata_valid = 0;
    end
    else begin
        if((cache_last_state == `CC_STATE_AXILOADING_LAST || cache_last_state == `CC_STATE_AVAILABLE || (cache_last_state == `CC_STATE_UNCACHE_AXIWRITING && !axib_wr_rdy))
            && buffer_cpu_rw_op == `CC_CPU_OP_WR
            && buffer_cpu_rw_en) begin
            output_wdata_valid = 1;
        end
        else begin
            output_wdata_valid = 0;
        end
    end
end

//axib_rd_req, axib_rd_type, axib_rd_addr
always @(*) begin
    if(!rst_n)begin
        axib_rd_req <= 0;
        axib_rd_type <= 2'b00;
        axib_rd_addr <= 32'b0;
    end
    else begin
        if(cache_state == `CC_STATE_AXIREADING && axib_rd_rdy) begin
            axib_rd_req <= 1;
            // axib_rd_type <= 3'b111;
            // axib_rd_addr <= (cache_last_state==`CC_STATE_AXISTALL_READ) ? 
            //                 {buffer_cpu_rw_addr[31:4], 4'b0} :
            //                 {cpu_rw_addr[31:4], 4'b0};
            if(cache_last_state == `CC_STATE_AXISTALL_READ) begin
                axib_rd_type <= buffer_cpu_uncache? 3'b000 : 3'b111;
                axib_rd_addr <= buffer_cpu_uncache?  {buffer_cpu_rw_addr[31:2], 2'b0} : {buffer_cpu_rw_addr[31:4], 4'b0};
            end
            else begin
                axib_rd_type <= cpu_uncache? 3'b000 : 3'b111;
                axib_rd_addr <= cpu_uncache? {cpu_rw_addr[31:2], 2'b0} : {cpu_rw_addr[31:4], 4'b0};
            end
        end
        else begin
            axib_rd_req <= 0;
            axib_rd_type <= 3'b000;
            axib_rd_addr <= 32'b0;
        end
    end
end

//axib_wr_req, axib_wr_type, axib_wr_addr, axib_wr_wstrb, axib_wr_data
always @(*) begin
    if(!rst_n) begin
        axib_wr_req <= 0;
        axib_wr_type <= 3'b00;
        axib_wr_addr <= 32'b0;
        axib_wr_wstrb <= 4'b0;
        axib_wr_data <= 128'b0;
    end
    else begin
        if(cache_state == `CC_STATE_AXIWRITING && axib_wr_rdy) begin
            axib_wr_req <= 1;
            axib_wr_type <= 3'b111;
            axib_wr_addr <= (cache_last_state == `CC_STATE_AXISTALL_WRITE) ? 
                            buffer_cache_replace_addr : 
                            cache_replace_addr;
            axib_wr_wstrb <= 4'b1111;
            axib_wr_data <= (cache_last_state == `CC_STATE_AXISTALL_WRITE) ? 
                            buffer_cache_replace_line : 
                            cache_replace_line;
        end
        else if(cache_state == `CC_STATE_UNCACHE_AXIWRITING && axib_wr_rdy) begin
            axib_wr_req <= 1;
            axib_wr_type <= 3'b000;
            axib_wr_addr <= (cache_last_state == `CC_STATE_AXISTALL_WRITE) ? 
                            buffer_cpu_rw_addr:
                            cpu_rw_addr; 
            axib_wr_wstrb <= 4'b1111;
            axib_wr_data <= (cache_last_state == `CC_STATE_AXISTALL_WRITE) ? 
                            {96'd0 ,buffer_cpu_rw_wdata}:
                            {96'd0 ,cpu_rw_wdata}; 
        end
        else begin
            axib_wr_req <= 0;
            axib_wr_type <= 3'b000;
            axib_wr_addr <= 32'b0;
            axib_wr_wstrb <= 4'b0;
            axib_wr_data <= 128'b0;
        end
    end
end


//cache_last_state, cache_state
always @(posedge clk) begin
    if(!rst_n) begin
        cache_last_state <= `CC_STATE_AVAILABLE;
    end
    else begin
        cache_last_state <= cache_state;
    end
end

always @(*) begin
    if(!rst_n) begin
        cache_last_state <= `CC_STATE_AVAILABLE;
    end
    else if(cpu_flush) begin
        cache_last_state <= `CC_STATE_FLUSH;
    end
    else begin
        case (cache_last_state)
            // `CC_STATE_AVAILABLE: begin
            //     if(cpu_rw_en & cache_hit) begin
            //         cache_state <= `CC_STATE_AVAILABLE;
            //     end
            //     else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_RD) begin
            //         if(axib_rd_rdy) begin
            //             cache_state <= `CC_STATE_AXIREADING;
            //         end
            //         else begin
            //             cache_state <= `CC_STATE_AXISTALL_READ;
            //         end
            //     end
            //     else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_WR) begin
            //         if(cpu_uncache && axib_wr_rdy) begin
            //             cache_state <= `CC_STATE_UNCACHE_AXIWRITING;
            //         end
            //         else if(cpu_uncache) begin
            //             cache_state <= `CC_STATE_UNCACHE_AXISTALL_WRITE;
            //         end
            //         else if(cache_way_full && cache_replace_dirty && axib_wr_rdy) begin
            //             cache_state <= `CC_STATE_AXIWRITING;
            //         end
            //         else if(cache_way_full && cache_replace_dirty) begin
            //             cache_state <= `CC_STATE_AXISTALL_WRITE;
            //         end
            //         else if(axib_rd_rdy) begin
            //             cache_state <= `CC_STATE_AXIREADING;
            //         end
            //         else begin
            //             cache_state <= `CC_STATE_AXISTALL_READ;
            //         end
            //     end
            //     else begin
            //         cache_state <= `CC_STATE_AVAILABLE;
            //     end
            // end
            `CC_STATE_AXISTALL_READ: begin
                if(axib_rd_rdy) begin
                    cache_state <= `CC_STATE_AXIREADING;
                end
                else begin
                    cache_state <= `CC_STATE_AXISTALL_READ;
                end
            end
            `CC_STATE_AXISTALL_WRITE: begin
                if(axib_wr_rdy) begin
                    cache_state <= `CC_STATE_AXIWRITING;
                end
                else begin
                    cache_state <= `CC_STATE_AXISTALL_WRITE;
                end
            end
            `CC_STATE_UNCACHE_AXISTALL_WRITE: begin
                if(axib_wr_rdy) begin
                    cache_state <= `CC_STATE_UNCACHE_AXIWRITING;
                end
                else begin
                    cache_state <= `CC_STATE_UNCACHE_AXISTALL_WRITE;
                end
            end
            `CC_STATE_AXIWRITING: begin
                if(!axib_wr_rdy) begin
                    if(axib_rd_rdy) begin
                        cache_state <= `CC_STATE_AXIREADING;
                    end
                    else begin
                        cache_state <= `CC_STATE_AXISTALL_READ;
                    end
                end
                else begin
                    cache_state <= `CC_STATE_AXIWRITING;
                end
            end
            `CC_STATE_AXIREADING: begin
                if(axib_ret_valid && axib_ret_last) begin
                    cache_state <= `CC_STATE_AXILOADING_LAST;
                end
                else if(axib_ret_valid) begin
                    cache_state <= `CC_STATE_AXILOADING;
                end
                else begin
                    cache_state <= `CC_STATE_AXIREADING;
                end
            end
            `CC_STATE_AXILOADING: begin
                if(axib_ret_last) begin
                    cache_state <= `CC_STATE_AXILOADING_LAST;
                end
                else begin
                    cache_state <= `CC_STATE_AXILOADING;
                end
            end
            // `CC_STATE_AXILOADING_LAST: begin
            //     if(cpu_rw_en & cache_hit) begin
            //         cache_state <= `CC_STATE_AVAILABLE;
            //     end
            //     else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_RD) begin
            //         if(axib_rd_rdy) begin
            //             cache_state <= `CC_STATE_AXIREADING;
            //         end
            //         else begin
            //             cache_state <= `CC_STATE_AXISTALL_READ;
            //         end
            //     end
            //     else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_WR) begin
            //         if(cache_way_full && cache_replace_dirty && axib_wr_rdy) begin
            //             cache_state <= `CC_STATE_AXIWRITING;
            //         end
            //         else if(cache_way_full && cache_replace_dirty) begin
            //             cache_state <= `CC_STATE_AXISTALL_WRITE;
            //         end
            //         else if(axib_rd_rdy) begin
            //             cache_state <= `CC_STATE_AXIREADING;
            //         end
            //         else begin
            //             cache_state <= `CC_STATE_AXISTALL_READ;
            //         end
            //     end
            //     else begin
            //         cache_state <= `CC_STATE_AVAILABLE;
            //     end
            // end
            `CC_STATE_UNCACHE_AXIWRITING:begin
                if(!axib_wr_rdy) begin
                    if(cpu_rw_en & cache_hit) begin
                        cache_state <= `CC_STATE_AVAILABLE;
                    end
                    else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_RD) begin
                        if(axib_rd_rdy) begin
                            cache_state <= `CC_STATE_AXIREADING;
                        end
                        else begin
                            cache_state <= `CC_STATE_AXISTALL_READ;
                        end
                    end
                    else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_WR) begin
                        if(cpu_uncache && axib_wr_rdy) begin
                            cache_state <= `CC_STATE_UNCACHE_AXIWRITING;
                        end
                        else if(cpu_uncache) begin
                            cache_state <= `CC_STATE_UNCACHE_AXISTALL_WRITE;
                        end
                        else if(cache_way_full && cache_replace_dirty && axib_wr_rdy) begin
                            cache_state <= `CC_STATE_AXIWRITING;
                        end
                        else if(cache_way_full && cache_replace_dirty) begin
                            cache_state <= `CC_STATE_AXISTALL_WRITE;
                        end
                        else if(axib_rd_rdy) begin
                            cache_state <= `CC_STATE_AXIREADING;
                        end
                        else begin
                            cache_state <= `CC_STATE_AXISTALL_READ;
                        end
                    end
                    else begin
                        cache_state <= `CC_STATE_AVAILABLE;
                    end
                end
                else begin
                    cache_state <= `CC_STATE_UNCACHE_AXIWRITING;
                end
            end
            default: begin //`CC_STATE_AVAILABLE & `CC_STATE_AXILOADING_LAST & `CC_STATE_UNCACHE_AXIWRITE
                if(cpu_rw_en & cache_hit) begin
                    cache_state <= `CC_STATE_AVAILABLE;
                end
                else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_RD) begin
                    if(axib_rd_rdy) begin
                        cache_state <= `CC_STATE_AXIREADING;
                    end
                    else begin
                        cache_state <= `CC_STATE_AXISTALL_READ;
                    end
                end
                else if(cpu_rw_en && cpu_rw_op == `CC_CPU_OP_WR) begin
                    if(cpu_uncache && axib_wr_rdy) begin
                        cache_state <= `CC_STATE_UNCACHE_AXIWRITING;
                    end
                    else if(cpu_uncache) begin
                        cache_state <= `CC_STATE_UNCACHE_AXISTALL_WRITE;
                    end
                    else if(cache_way_full && cache_replace_dirty && axib_wr_rdy) begin
                        cache_state <= `CC_STATE_AXIWRITING;
                    end
                    else if(cache_way_full && cache_replace_dirty) begin
                        cache_state <= `CC_STATE_AXISTALL_WRITE;
                    end
                    else if(axib_rd_rdy) begin
                        cache_state <= `CC_STATE_AXIREADING;
                    end
                    else begin
                        cache_state <= `CC_STATE_AXISTALL_READ;
                    end
                end
                else begin
                    cache_state <= `CC_STATE_AVAILABLE;
                end
            end
        endcase
    end
end

// always @(posedge clk)begin
//     if(!rst_n) begin
//         axi_reading <= 0;
//     end
//     else if(axi_reading) begin
//         if(axib_ret_valid && axib_ret_last) begin
//             axi_reading <= 0;
//         end
//         else begin
//             axi_reading <= 1;
//         end
//     end
//     else begin
//         if(axib_rd_req && axib_rd_rdy) begin
//             axi_reading <= 1;
//         end
//         else begin
//             axi_reading <= 0;
//         end
//     end
// end

// always @(posedge clk) begin
//     if(!rst_n) begin
//         axi_op_reg <= `CC_AXI_OP_INVALID;
//     end
//     else begin
// //TODO
//     end
// end

always @(*) begin
    cpu_addr_set <= cpu_rw_addr[`CC_ADDR_SET];
    cpu_addr_tag <= cpu_rw_addr[`CC_ADDR_TAG];
    cpu_addr_offset <= cpu_rw_addr[`CC_ADDR_OFFSET];
end

// cache_hit and cache_hit_way
always @(*) begin
    if(!rst_n) begin
        cache_hit <= 0;
        cache_hit_way <= 2'd0;
    end
    else begin
        if(cpu_addr_tag == cache_ram[cpu_addr_set][0][`CC_LINE_TAG] 
            && cache_ram[cpu_addr_set][0][`CC_LINE_VALID]) begin
            cache_hit <= 1;
            cache_hit_way <= 2'd0;
        end
        else if(cpu_addr_tag == cache_ram[cpu_addr_set][1][`CC_LINE_TAG] 
            && cache_ram[cpu_addr_set][1][`CC_LINE_VALID]) begin
            cache_hit <= 1;
            cache_hit_way <= 2'd1;
        end
        else if(cpu_addr_tag == cache_ram[cpu_addr_set][2][`CC_LINE_TAG] 
            && cache_ram[cpu_addr_set][2][`CC_LINE_VALID]) begin
            cache_hit <= 1;
            cache_hit_way <= 2'd2;
        end
        else if(cpu_addr_tag == cache_ram[cpu_addr_set][3][`CC_LINE_TAG] 
            && cache_ram[cpu_addr_set][3][`CC_LINE_VALID]) begin
            cache_hit <= 1;
            cache_hit_way <= 2'd3;
        end
        else begin
            cache_hit <= 0;
            cache_hit_way <= 2'd0;
        end
    end
end

// cache_way_full and cache_way_to_load
always @(*) begin
    if(!rst_n)begin
        cache_way_full <= 0;
        cache_way_to_load <= 2'd0;
    end
    else begin
        // cache_way_full <= cache_ram[cpu_addr_set][0][`CC_LINE_VALID] 
        //     && cache_ram[cpu_addr_set][1][`CC_LINE_VALID] 
        //     && cache_ram[cpu_addr_set][2][`CC_LINE_VALID] 
        //     && cache_ram[cpu_addr_set][3][`CC_LINE_VALID];
        if (!cache_ram[cpu_addr_set][0][`CC_LINE_VALID]) begin
            cache_way_full <= 0;
            cache_way_to_load <= 2'd0;
        end
        else if (!cache_ram[cpu_addr_set][1][`CC_LINE_VALID]) begin
            cache_way_full <= 0;
            cache_way_to_load <= 2'd1;
        end
        else if (!cache_ram[cpu_addr_set][2][`CC_LINE_VALID]) begin
            cache_way_full <= 0;
            cache_way_to_load <= 2'd2;
        end
        else if (!cache_ram[cpu_addr_set][3][`CC_LINE_VALID]) begin
            cache_way_full <= 0;
            cache_way_to_load <= 2'd3;
        end
        else begin
            cache_way_full <= 1;
            cache_way_to_load <= cache_way_to_replace;
        end
    end
end

//cache_way_to_replace
//TBD
assign cache_way_to_replace = 2'd0;

//cache_replace_dirty
assign cache_replace_dirty = cache_ram[cpu_addr_set][cache_way_to_replace][`CC_LINE_DIRTY];

//cache_replace_addr
always @(*) begin
    cache_replace_addr <= {cache_ram[cpu_addr_set][cache_way_to_replace][`CC_LINE_TAG], cpu_addr_set, 4'b0};
    cache_replace_line <= {cache_ram[cpu_addr_set][cache_way_to_replace][`CC_LINE_DATA3],
                            cache_ram[cpu_addr_set][cache_way_to_replace][`CC_LINE_DATA2],
                            cache_ram[cpu_addr_set][cache_way_to_replace][`CC_LINE_DATA1],
                            cache_ram[cpu_addr_set][cache_way_to_replace][`CC_LINE_DATA0]};
end

integer i;
integer j;
always @(posedge clk) begin
    if(!rst_n) begin
        for(i=0; i<`CC_SET_SIZE; i=i+1) begin
            for(j=0; j<`CC_WAY_SIZE; j=j+1) begin
                cache_ram[i][j] <= `CC_LINE_WIDTH'b0;
            end
        end
    end
    else if(cache_state == `CC_STATE_AVAILABLE 
        && cpu_rw_op == `CC_CPU_OP_WR && cpu_rw_en && !cpu_uncache) begin
        case (cpu_addr_offset)
            2'd0:
                case (cpu_rw_wsize)
                    `ACCESS_SZ_WORD: begin
                        cache_ram[cpu_addr_set][cache_hit_way][`CC_LINE_DATA0] <= cpu_rw_wdata;
                    end
                    `ACCESS_SZ_HALF: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][15:0] <= cpu_rw_wdata[15:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][31:16] <= cpu_rw_wdata[15:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][31:16] <= cpu_rw_wdata[15:0];
                        end
                    end
                    `ACCESS_SZ_BYTE: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][7:0] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b01) begin
                            cache_ram[cpu_addr_set][cache_hit_way][15:8] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][23:16] <= cpu_rw_wdata[7:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][31:24] <= cpu_rw_wdata[7:0];
                        end
                    end
                endcase
            2'd1:
                case (cpu_rw_wsize)
                    `ACCESS_SZ_WORD: begin
                        cache_ram[cpu_addr_set][cache_hit_way][`CC_LINE_DATA1] <= cpu_rw_wdata;
                    end
                    `ACCESS_SZ_HALF: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][47:32] <= cpu_rw_wdata[15:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][63:48] <= cpu_rw_wdata[15:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][63:48] <= cpu_rw_wdata[15:0];
                        end
                    end
                    `ACCESS_SZ_BYTE: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][39:32] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b01) begin
                            cache_ram[cpu_addr_set][cache_hit_way][47:40] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][55:48] <= cpu_rw_wdata[7:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][63:56] <= cpu_rw_wdata[7:0];
                        end
                    end
                endcase
            2'd2:
                case (cpu_rw_wsize)
                    `ACCESS_SZ_WORD: begin
                        cache_ram[cpu_addr_set][cache_hit_way][`CC_LINE_DATA2] <= cpu_rw_wdata;
                    end
                    `ACCESS_SZ_HALF: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][79:64] <= cpu_rw_wdata[15:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][95:80] <= cpu_rw_wdata[15:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][95:80] <= cpu_rw_wdata[15:0];
                        end
                    end
                    `ACCESS_SZ_BYTE: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][71:64] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b01) begin
                            cache_ram[cpu_addr_set][cache_hit_way][79:72] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][87:80] <= cpu_rw_wdata[7:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][95:88] <= cpu_rw_wdata[7:0];
                        end
                    end
                endcase
            default:
                case (cpu_rw_wsize)
                    `ACCESS_SZ_WORD: begin
                        cache_ram[cpu_addr_set][cache_hit_way][`CC_LINE_DATA3] <= cpu_rw_wdata;
                    end
                    `ACCESS_SZ_HALF: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][111:96] <= cpu_rw_wdata[15:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][127:112] <= cpu_rw_wdata[15:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][127:112] <= cpu_rw_wdata[15:0];
                        end
                    end
                    `ACCESS_SZ_BYTE: begin
                        if(cpu_rw_addr[1:0] == 2'b00) begin
                            cache_ram[cpu_addr_set][cache_hit_way][103:96] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b01) begin
                            cache_ram[cpu_addr_set][cache_hit_way][111:104] <= cpu_rw_wdata[7:0];
                        end
                        else if(cpu_rw_addr[1:0] == 2'b10) begin
                            cache_ram[cpu_addr_set][cache_hit_way][119:112] <= cpu_rw_wdata[7:0];
                        end
                        else begin
                            cache_ram[cpu_addr_set][cache_hit_way][127:120] <= cpu_rw_wdata[7:0];
                        end
                    end
                endcase
        endcase
        cache_ram[cpu_addr_set][cache_hit_way][`CC_LINE_DIRTY] <= 1;
    end
    else if(cache_state == `CC_STATE_AXILOADING_LAST && !buffer_cpu_uncache) begin
        cache_ram[buffer_cpu_addr_set][buffer_cache_way_to_load] <= {buffer_cpu_addr_tag, 1'b1,buffer_cpu_rw_op==`CC_CPU_OP_WR, axib_ret_data, buffer_shift_load_line[0], buffer_shift_load_line[1], buffer_shift_load_line[2]};
    end
end

reg [31:0] ram_wdata;
always @(*) begin
    if(buffer_cpu_rw_op==`CC_CPU_OP_WR && load_cnt == buffer_cpu_addr_offset) begin
        case (buffer_cpu_rw_wsize)
            `ACCESS_SZ_WORD: begin
                ram_wdata = buffer_cpu_rw_wdata;
            end
            `ACCESS_SZ_HALF: begin
                if(buffer_cpu_rw_addr[1:0] == 2'b00) begin
                    ram_wdata = {buffer_cpu_rw_wdata[15:0], axib_ret_data[15:0]};
                end
                else begin
                    ram_wdata = {axib_ret_data[31:16], buffer_cpu_rw_wdata[15:0]};
                end
            end
            `ACCESS_SZ_BYTE: begin
                if(buffer_cpu_rw_addr[1:0] == 2'b00) begin
                    ram_wdata = {buffer_cpu_rw_wdata[7:0], axib_ret_data[23:0]};
                end
                else if(buffer_cpu_rw_addr[1:0] == 2'b01) begin
                    ram_wdata = {axib_ret_data[31:24], buffer_cpu_rw_wdata[7:0], axib_ret_data[15:0]};
                end
                else if(buffer_cpu_rw_addr[1:0] == 2'b10) begin                    
                    ram_wdata = {axib_ret_data[31:16], buffer_cpu_rw_wdata[7:0], axib_ret_data[7:0]};
                end
                else begin
                    ram_wdata = {axib_ret_data[31:8], buffer_cpu_rw_wdata[7:0]};                    
                end
            end
            default: begin
                ram_wdata = 32'b0;
            end
        endcase
    end
    else begin
        ram_wdata = axib_ret_data;
    end
end

always @(posedge clk) begin
    if(!rst_n)begin
        buffer_shift_load_line[0] <= 32'b0;
        buffer_shift_load_line[1] <= 32'b0;
        buffer_shift_load_line[2] <= 32'b0;
        load_cnt <= 2'd0;
        buffer_axi_rdata_to_cpu <= 32'b0;
    end
    else if(cache_state == `CC_STATE_AXILOADING) begin
        buffer_shift_load_line[0] <= ram_wdata;
        buffer_shift_load_line[1] <= buffer_shift_load_line[0];
        buffer_shift_load_line[2] <= buffer_shift_load_line[1];
        buffer_axi_rdata_to_cpu <= (load_cnt == buffer_cpu_addr_offset) 
                                    ? axib_ret_data
                                    : buffer_axi_rdata_to_cpu;
        load_cnt <= load_cnt + 1;
    end
end

endmodule