`include "/home/loongsonarch_1/Desktop/cdp_ede_local/myCPU/defs.v"
/*
    对于N路组相联，共有H组，每组有N行，每行有W个字，即4W个Byte
    index为LOG_H位的组索引
    offset为LOG_W+2位的行内索引
    tag为32-`CACHE_LOG_H-`CACHE_LOG_W-2位的标签,定义为TAG_LEN
    总容量=2^`CACHE_H * 2^`CACHE_N * 2^`CACHE_W * 32 bits
*/
module cache(
    clk,
    resetn,
//input from CPU
    op,
    valid,
    addr,
    wsize,
    wdata,    
//output to CPU
    raddr_out,
    raddr_valid,
    rdata,
    rdata_valid,
    wdata_valid,
//read from RAM
    rd_req,
    rd_type,
    rd_addr,
    rd_rdy,
    ret_valid,
    ret_last,
    ret_data,
//write to RAM
    wr_req,
    wr_type,
    wr_addr,
    wr_wstrb,
    wr_size,
    wr_data,
    wr_rdy
);

/*FSM的4个状态
`CACHE_STATE_IDLE
`CACHE_STATE_RW
`CACHE_STATE_MISS
`CACHE_STATE_MISS */
// parameter   `CACHE_STATE_IDLE    =3'b000;
// parameter   `CACHE_STATE_RW      =3'b001;
// parameter   `CACHE_STATE_MISS    =3'b010;
// parameter   `CACHE_STATE_MISS  =3'b011;
// parameter   `CACHE_WRBUF_IDLE =1'b0;
// parameter   `CACHE_WRBUF_WRITE=1'b1;

input  wire         clk;
input  wire         resetn;
//input from CPU
input  wire         op;
input  wire         valid;
input  wire  [31:0] addr;
input  wire  [ 1:0] wsize;
input  wire  [31:0] wdata;
//output to CPU
output wire         raddr_valid;
output wire  [31:0] raddr_out;
output wire         rdata_valid;
output wire         wdata_valid;
output wire [31:0]  rdata;
//read from RAM
output wire         rd_req;     //cache向RAM请求读取之
output wire [ 2:0]  rd_type; //3'b000-BYTE  3'b001-HALFWORD 3'b010-WORD 3'b100我不清楚
output wire [31:0]  rd_addr; //
input  wire         rd_rdy; //RAM准备好被cache读取
input  wire         ret_valid; //RAM被cache读取有效
input  wire         ret_last; //RA取完成
input  wire [31:0]  ret_data;//
//write to RAM
output wire         wr_req;     //cache向RAM请求写入之
output wire [ 2:0]  wr_type; //同rd_type
output wire [31:0]  wr_addr; //
output wire [ 3:0]  wr_wstrb; //wr_data的掩码
output wire [2:0]   wr_size;
output wire[127:0]  wr_data;  //    
input  wire         wr_rdy; //RAM准备好被cache写入

assign raddr_valid = rd_rdy;

assign rd_req = (state == `CACHE_STATE_IDLE || state == `CACHE_STATE_RW) && valid && (!hit);
assign rd_type = 3'b100;
assign rd_addr = {addr[31:4],4'b0};

wire [`CACHE_LOG_H-1:0]        index;
wire [`CACHE_LOG_W+1:0]        offset;
wire [`CACHE_TAG_LEN-1:0]      tag;
assign index = addr[`CACHE_LOG_H+`CACHE_LOG_W+1 : `CACHE_LOG_W+2       ];
assign tag   = addr[31              : `CACHE_LOG_H+`CACHE_LOG_W+2];
assign offset= addr[`CACHE_LOG_W+1        : 0              ];

reg [2:0] state;
reg [2:0] next_state;
reg [`CACHE_LOG_W-1:0] refill_count;//充当一个0~W计数器的作用
reg  tag_dirty [`CACHE_H-1:0][`CACHE_N-1:0];
reg  tag_valid [`CACHE_H-1:0][`CACHE_N-1:0];

wire [`CACHE_N-1:0]  tag_hit;
wire hit;
wire [`CACHE_LOG_N-1:0] hit_way;
wire dirty;

reg [31:0]  rdata_buf;
reg         rdata_from_buf;

/*cache的存储空间分为：
标签存储（tag_ram）：一读读一组N个
数据存储（data_bank）：
*/
//tag_ram
//tag一次读一整组，共N个TAG_LEN位数据
//tag一次写一行，共1个TAG_LEN位数据
wire                tag_ram_we;  //tag写使能
wire [`CACHE_LOG_W-1:0]   tag_ram_way; //tag写哪一路(0~N)
wire [`CACHE_LOG_H-1:0]   tag_ram_index;
wire [`CACHE_TAG_LEN-1:0] tag_ram_wdata; 
wire [`CACHE_N*`CACHE_TAG_LEN-1:0] tag_ram_rdata;

tag_ram my_tag_ram(
    .clk    (clk),
    .resetn (resetn),
    .we     (tag_ram_we),
    .way    (tag_ram_way),
    .addr   (tag_ram_index),
    .din    (tag_ram_wdata),
    .dout   (tag_ram_rdata)
);

//V位和D位

integer i;
integer j;
always @(posedge clk) begin
    if(!resetn) begin
        for(i=0;i<`CACHE_H;i=i+1)begin
            for(j=0;j<`CACHE_N;j=j+1)begin
                tag_valid[i][j] <= 1'b0;
                tag_dirty[i][j] <= 1'b0;
            end
        end
    end
    else if(tag_ram_we)begin
        tag_valid[index][hit_way] <= ((state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )&&valid)||(state==`CACHE_STATE_MISS&&ret_valid&&ret_last);
        tag_dirty[index][hit_way] <= ((state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )&&valid)||(state==`CACHE_STATE_MISS&&ret_valid&&ret_last&&op_r);//只有写操作会创造valid
    end
end

//Cache计数器,为了LRU算法
reg   tag_count [`CACHE_H-1:0][`CACHE_N-1:0];

//LRU等待完善
wire [`CACHE_LOG_N-1:0] replace_way;
assign replace_way = `CACHE_LOG_N'b0;
//data_ram
wire                data_ram_we;
wire [`CACHE_LOG_H-1:0]   data_ram_index;
wire [`CACHE_LOG_N-1:0]   data_ram_way  ;
wire [`CACHE_LOG_W-1:0]   data_ram_offset;
wire [31:0] data_ram_wdata;//一次写一字
wire [31:0] data_ram_rdata;//一次读一字
wire [`CACHE_W*32-1 :0]data_ram_rdata_replace;//一次读一行

data_ram my_data_ram(
    .clk(clk),
    .resetn(resetn),
    .we(data_ram_we),
    .index(data_ram_index),
    .way(data_ram_way),
    .offset(data_ram_offset),
    .din(data_ram_wdata),
    .dout(data_ram_rdata),
    .dout_replace(data_ram_rdata_replace)
);



//FSM

always@(posedge clk)begin
    if(!resetn)begin
        state <= `CACHE_STATE_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always@(*) begin
    case(state)
    `CACHE_STATE_IDLE:
        if      (valid & hit)   next_state = `CACHE_STATE_RW;
        //else if (op)    next_state = `CACHE_STATE_RW;
        else if (valid) begin
            next_state = `CACHE_STATE_MISS;
        end
    `CACHE_STATE_RW:
        if      (valid & hit)   next_state = `CACHE_STATE_RW;
        //else if (op)    next_state = `CACHE_STATE_RW;
        else if(valid) begin
            next_state = `CACHE_STATE_MISS;
        end
        else begin
            next_state = `CACHE_STATE_IDLE;
        end
    `CACHE_STATE_MISS:
        if(ret_last)     next_state = `CACHE_STATE_RW;
        else             next_state = `CACHE_STATE_MISS;
    default:
        next_state = `CACHE_STATE_IDLE;
    endcase
end

always @(posedge clk) begin
    if(!resetn) begin
        rdata_from_buf <= 1'b0;
    end
    else if(state == `CACHE_STATE_MISS && ret_last) begin
        rdata_from_buf <= 1'b1;
    end
    else begin
        rdata_from_buf <= 1'b0;
    end
end

//cpubuf 
//CPU向cache发送请求，暂存至cpubuf中
reg   [67:0]            cpubuf;
wire                    op_r;
wire                    valid_r;
wire  [31:0]            addr_r;
wire  [`CACHE_TAG_LEN-1:0]    tag_r;
wire  [`CACHE_LOG_H-1:0]      index_r;
wire  [`CACHE_LOG_W+1:0]      offset_r;
wire  [ 1:0] wsize_r;
wire  [31:0] wdata_r;
always @ (posedge clk) begin
    if (~resetn) begin
        cpubuf <= 68'b0;
    end
    else if((state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW) &&valid)begin
        cpubuf <= {op,valid,addr,wsize,wdata};
    end
end
assign   {op_r,valid_r,addr_r,wsize_r,wdata_r} = cpubuf;
assign   {tag_r,index_r,offset_r} = addr_r;
assign raddr_out = addr_r;

always@(posedge clk) begin
    if(!resetn) begin
        rdata_buf <=32'b0;
    end
    else if((state == `CACHE_STATE_MISS) && ret_valid && (refill_count == offset_r[3:2])) begin
        rdata_buf <=ret_data;
    end
end


assign tag_ram_index = index;
assign dirty = valid && ~hit && tag_dirty[index][replace_way];

assign tag_hit[0] = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW ) && valid && (tag_valid[index][0]) && (tag == tag_ram_rdata[`CACHE_TAG_LEN-1:0]); 
assign tag_hit[1] = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW ) && valid && (tag_valid[index][1]) && (tag == tag_ram_rdata[2*`CACHE_TAG_LEN-1:`CACHE_TAG_LEN]);
assign tag_hit[2] = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW ) && valid && (tag_valid[index][2]) && (tag == tag_ram_rdata[3*`CACHE_TAG_LEN-1:2*`CACHE_TAG_LEN]);
assign tag_hit[3] = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW ) && valid && (tag_valid[index][3]) && (tag == tag_ram_rdata[4*`CACHE_TAG_LEN-1:3*`CACHE_TAG_LEN]);

assign hit_way = (tag_hit == 4'b1000)?2'd3:
                 (tag_hit == 4'b0100)?2'd2:
                 (tag_hit == 4'b0010)?2'd1:
                 (tag_hit == 4'b0001)?2'd0:2'd0;

 
assign hit        = tag_hit[0] || tag_hit[1] || tag_hit[2] || tag_hit[3];


assign data_ram_index  = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )?index:index_r;
assign data_ram_offset = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )?offset[3:2]:refill_count;
assign data_ram_way    = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )? hit_way : replace_way; 
assign data_ram_we     = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )?(valid && op):(state==`CACHE_STATE_MISS && ret_valid);
assign data_ram_wdata  = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )?wdata:
                            (refill_count == offset_r[3:2])? wdata_r :ret_data;
// assign data_valid      = state==`CACHE_STATE_RW && op_r;
assign rdata           = (rdata_from_buf)? rdata_buf : data_ram_rdata;
assign rdata_valid     = state ==`CACHE_STATE_RW && (~op_r||rdata_from_buf);

assign wdata_valid     = state ==`CACHE_STATE_RW && (op_r ||rdata_from_buf); //rdata_from_buf被cpu读写公用了，在refill过程的末尾，向下一拍RW表明它是来自于连续的MISS拍

assign tag_ram_index   = index;
assign tag_ram_way     = replace_way;
assign tag_ram_we      = (state == `CACHE_STATE_IDLE ||state == `CACHE_STATE_RW )&&valid&&(!hit);
assign tag_ram_wdata   = tag;

assign wdata_valid     = state == `CACHE_STATE_RW && op_r;
/*
    if(valid&&~hit&&op)begin
assign tag_valid[index][replace_way] =1'b1;
        tag_dirty[index][replace_way] =1'b1;

        data_ram_index = index;
        data_ram_offset= offset;
        data_ram_way   = replace_way;
        data_bank_we   = 1'b1;
        data_ram_wdata = wdata;

        tag_ram_index  = index;
        tag_ram_way    = replace_way;
        tag_ram_we     = 1'b1;
        tag_ram_wdata  = tag;
    end
    //`CACHE_STATE_MISS了，是读，不好处理，要阻塞
end
*/



always @(posedge clk)begin
    if(!resetn)begin
        refill_count <= `CACHE_LOG_W'b0;
    end
    else if(state==`CACHE_STATE_MISS && ret_valid) begin
        refill_count <= refill_count + 1'b1;
    end
    else begin
        refill_count <= `CACHE_LOG_W'b0;
    end
end

/*
if(state == `CACHE_STATE_MISS)begin
    if(ret_valid)begin
        data_ram_we[refill_count] =1'b1;
        data_ram_index  = index_r;
        data_ram_way    = replace_way;
        data_ram_offset = refill_count;
        data_ram_wdata[refill_count] = ret_data;
        //如果从AXI返回的时候到了CPU要求的这个字，直接返回给CPU
        if(refill_count == offset_r)begin
            rdata = ret_data;
            rdata_valid = 1'b1;
        end
    end    
    if(ret_valid && ret_last)begin
        tag_valid[index_r][replace_way] = 1'b1;
    end
end
*/    

//如果tag比较发生了dirty，把另一个状态机wirte_buf置为1,把要被写回的行放入wrbuf

reg wrbuf_state;
reg wrbuf_next_state;
always@(posedge clk)begin
    if(!resetn)begin
        wrbuf_state<= `CACHE_WRBUF_IDLE;
    end
    else begin
        wrbuf_next_state <= wrbuf_next_state;
    end
end
always@(*) begin    
    case(wrbuf_state)
        `CACHE_WRBUF_IDLE:
            if(valid && ~hit && dirty) wrbuf_next_state = `CACHE_WRBUF_WRITE;
            else                   wrbuf_next_state = `CACHE_WRBUF_IDLE;
        `CACHE_WRBUF_WRITE:
            if(wr_rdy)          wrbuf_next_state = `CACHE_STATE_IDLE;
            else                wrbuf_next_state = `CACHE_WRBUF_WRITE;
        default:
            wrbuf_next_state = `CACHE_STATE_IDLE;
    endcase
end
reg [32*`CACHE_W-1:0]  write_buf_data;
reg [31    :0]  write_buf_addr;
always@(posedge clk)begin
    if(valid&&~hit&&dirty)begin
        write_buf_addr <= {tag_ram_rdata[replace_way],data_ram_index,data_ram_offset,2'b0} ;
        write_buf_data <= data_ram_rdata_replace;
    end
end

assign     wr_req      = (wrbuf_state==`CACHE_WRBUF_WRITE);     //是wrbuf-next_state还是wrbuf-state?
assign     wr_type     = 3'b100;
assign     wr_addr     = write_buf_addr;
assign     wr_wstrb    = 4'hf;
assign     wr_size     = 3'b010;
assign     wr_data     = write_buf_data;

endmodule