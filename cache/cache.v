`include "/home/loongsonarch_1/Desktop/cdp_ede_local/mycpu_env/myCPU/defs.v"
/*
    对于N路组相联，共有H组，每组有N行，每行有W个字，即4W个Byte
    index为LOG_H位的组索引
    offset为LOG_W+2位的行内索引
    tag为32-`LOG_H-`LOG_W-2位的标签,定义为TAG_LEN
    总容量=2^`h * 2^`n * 2^`w * 32 bits
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
IDLE
RW
MISS
REFILL */
parameter   IDLE    =3'b000;
parameter   RW      =3'b001;
parameter   MISS    =3'b010;
parameter   REFILL  =3'b011;
parameter   WRBUF_IDLE =1'b0;
parameter   WRBUF_WRITE=1'b1;

input  wire         clk;
input  wire         resetn;
//input from CPU
input  wire         op;
input  wire         valid;
input  wire  [31:0] addr;
input  wire  [ 1:0] wsize;
input  wire  [31:0] wdata;
//output to CPU
output wire         rdata_valid;
output wire         wdata_valid;
output wire [31:0]  rdata;
//read from RAM
output wire         rd_req;     //cache向RAM请求读取之
output wire [ 2:0]  rd_type; //3'b000-BYTE  3'b001-HALFWORD 3'b010-WORD 3'b100我不清楚
output wire [31:0]  rd_addr; //
input  wire         rd_rdy; //RAM准备好被cache读取
input  wire         ret_valid; //RAM被cache读取有效
input  wire         ret_last;  //RAM读取完成
input  wire [31:0]  ret_data;//
//write to RAM
output wire         wr_req;     //cache向RAM请求写入之
output wire [ 2:0]  wr_type; //同rd_type
output wire [31:0]  wr_addr; //
output wire [ 3:0]  wr_wstrb; //wr_data的掩码
output wire [2:0]   wr_size;
output wire[127:0]  wr_data;  //    
input  wire         wr_rdy; //RAM准备好被cache写入

wire [`LOG_H-1:0]        index;
wire [`LOG_W+1:0]        offset;
wire [`TAG_LEN-1:0]      tag;
assign index = addr[`LOG_H+`LOG_W+1 : `LOG_W+2       ];
assign tag   = addr[31              : `LOG_H+`LOG_W+2];
assign offset= addr[`LOG_W+1        : 0              ];

reg [2:0] state;
reg [2:0] next_state;
reg [`LOG_W-1:0] refill_count;//充当一个0~W计数器的作用
reg  tag_dirty [`H-1:0][`N-1:0];
reg  tag_valid [`H-1:0][`N-1:0];

wire [`N-1:0]  tag_hit;
wire hit;
wire [`LOG_N-1:0] hit_way;
wire dirty;

/*cache的存储空间分为：
标签存储（tag_ram）：一读读一组N个
数据存储（data_bank）：
*/
//tag_ram
//tag一次读一整组，共N个TAG_LEN位数据
//tag一次写一行，共1个TAG_LEN位数据
wire                tag_ram_we;  //tag写使能
wire [`LOG_W-1:0]   tag_ram_way; //tag写哪一路(0~N)
wire [`LOG_H-1:0]   tag_ram_index;
wire [`TAG_LEN-1:0] tag_ram_wdata; 
wire [`N*`TAG_LEN-1:0] tag_ram_rdata;

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

genvar i,j;

generate
     for(i=0;i<`H;i=i+1)begin
         for(j=0;j<`N;j=j+1)begin
             always @(posedge clk) begin
                 if (~resetn) begin
                     tag_dirty[i][j] <= 0;
                     tag_valid[i][j] <= 0;
                 end
                 else begin
                     tag_valid[index][hit_way] <= ((state == IDLE ||state == RW )&&valid&&op)||(state==REFILL&&ret_valid&&ret_last);
                     tag_dirty[index][hit_way] <= (state == IDLE ||state == RW )&&valid&&op;
                 end
             end
         end
     end    
endgenerate

//Cache计数器,为了LRU算法
reg   tag_count [`H-1:0][`N-1:0];

//LRU等待完善
wire [`LOG_N-1:0] replace_way;
assign replace_way = `LOG_N'b0;
//data_ram
wire                data_ram_we;
wire [`LOG_H-1:0]   data_ram_index;
wire [`LOG_N-1:0]   data_ram_way  ;
wire [`LOG_W-1:0]   data_ram_offset;
wire [31:0] data_ram_wdata;//一次写一字
wire [31:0] data_ram_rdata;//一次读一字
wire [`W*32-1 :0]data_ram_rdata_replace;//一次读一行

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
    if(~resetn)begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always@(*) begin
    if(valid)    
        case(state)
        IDLE:
            if      (hit)         next_state = RW;
            else if (~hit && op)  next_state = RW;
            else if (~hit && ~op) next_state = MISS;
            else                  next_state = IDLE;
        RW:
            if      (hit)         next_state = RW;
            else if (~hit && op)  next_state = RW;
            else if (~hit && ~op) next_state = MISS;
            else                  next_state = IDLE;
        MISS:
            if      (rd_rdy)      next_state = REFILL; 
            else                  next_state = MISS;
        REFILL:
            if(ret_valid&&ret_last)     next_state = IDLE;
            else                        next_state = REFILL;
        endcase
end

//cpubuf 
//CPU向cache发送请求，暂存至cpubuf中
reg   [67:0]            cpubuf;
wire                    op_r;
wire                    valid_r;
wire  [31:0]            addr_r;
wire  [`TAG_LEN-1:0]    tag_r;
wire  [`LOG_H-1:0]      index_r;
wire  [`LOG_W+1:0]      offset_r;
wire  [ 1:0] wsize_r;
wire  [31:0] wdata_r;
always @ (posedge clk) begin
    if (~resetn) begin
        cpubuf <= 68'b0;
    end
    else if((state == IDLE ||state == RW) &&valid)begin
        cpubuf <= {op,valid,addr,wsize,wdata};
    end
end
assign   {op_r,valid_r,addr_r,wsize_r,wdata_r} = cpubuf;
assign   {tag_r,index_r,offset_r} = addr_r;




assign tag_ram_index = index;
assign dirty = valid && ~hit && tag_dirty[index][replace_way];

assign tag_hit[0] = (state == IDLE ||state == RW ) && valid && (tag_valid[index][0]) && (tag == tag_ram_rdata[`TAG_LEN-1:0]); 
assign tag_hit[1] = (state == IDLE ||state == RW ) && valid && (tag_valid[index][1]) && (tag == tag_ram_rdata[2*`TAG_LEN-1:`TAG_LEN]);
assign tag_hit[2] = (state == IDLE ||state == RW ) && valid && (tag_valid[index][2]) && (tag == tag_ram_rdata[3*`TAG_LEN-1:2*`TAG_LEN]);
assign tag_hit[3] = (state == IDLE ||state == RW ) && valid && (tag_valid[index][3]) && (tag == tag_ram_rdata[4*`TAG_LEN-1:3*`TAG_LEN]);

assign hit_way = (tag_hit == 4'b1000)?2'd3:
                 (tag_hit == 4'b0100)?2'd2:
                 (tag_hit == 4'b0010)?2'd1:
                 (tag_hit == 4'b0001)?2'd0:2'd0;

 
assign hit        = tag_hit[0] || tag_hit[1] || tag_hit[2] || tag_hit[3];


assign data_ram_index  = (state == IDLE ||state == RW )?index:index_r;
assign data_ram_offset = (state == IDLE ||state == RW )?offset:refill_count;
assign data_ram_way    = (state == IDLE ||state == RW )? hit_way : replace_way; 
assign data_ram_we     = ((state == IDLE ||state == RW )&&valid&&op)||(state==REFILL&&ret_valid);
assign data_ram_wdata  = (state == IDLE ||state == RW )?wdata:ret_data;
assign data_valid      = state==RW && op_r;
assign rdata           = (state==REFILL&&refill_count == offset_r)? data_ram_rdata : ret_data;
assign rdata_valid     = (state==RW && ~op_r)||(state==REFILL&&refill_count == offset_r);
assign tag_ram_index   = index;
assign tag_ram_way     = replace_way;
assign tag_ram_we      = (state == IDLE ||state == RW )&&valid&&~hit&&(op==1'b1);
assign tag_ram_wdata   = tag;


/*
if(state == IDLE ||state == RW ) begin
    //tag比较
    if(valid)begin
    hit = 1'b0;
        for(integer j=0;j<`N;j+=1)begin
            tag_hit[j] = (tag_valid[index][j]) && (tag == tag_ram_rdata[j]) 
            if(tag_hit[j]) hit_way = j;
            hit = hit ||tag_hit[j];
        end
    end
    //命中了，分为写和读两种情况
    if(valid&&hit&&op)begin
        tag_valid[index][hit_way] =1'b1;
        tag_dirty[index][hit_way] =1'b1;
        data_ram_index = index;
        data_ram_offset= offset;
        data_ram_way   = hit_way;
        data_ram_we    = 1'b1;
        data_ram_wdata = wdata;
    end
    else if(valid&&hit&&~op)begin
        data_ram_index = index;
        data_ram_offset= offset;
        data_ram_way   = hit_way;
    end

    //RW: 上一拍发出了读/写指令并命中，这一拍返回，同时正常接收读写指令
    if(state==RW && op_r)begin
        data_valid = 1'b1;        
    end

    else if(state==RW && ~op_r)begin
        rdata = data_ram_rdata;
        rdata_valid =1'b1;
    end

    //MISS了，但是写，比较好处理
    //锁住此时的replace_way
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
    //MISS了，是读，不好处理，要阻塞
end
*/



always @(posedge clk)begin
    if(state==MISS && next_state == REFILL)begin
        refill_count <= `LOG_W'b0;
    end
    else if(state == REFILL)begin
        refill_count <=refill_count + 1'b1;
    end
end

/*
if(state == REFILL)begin
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
        wrbuf_state<= WRBUF_IDLE;
    end
    else begin
        wrbuf_next_state <= next_state;
    end
end
always@(*) begin    
    case(wrbuf_state)
        WRBUF_IDLE:
            if(valid&&~hit&&dirty) wrbuf_next_state = WRBUF_WRITE;
            else                   wrbuf_next_state = WRBUF_IDLE;
        WRBUF_WRITE:
            if(wr_rdy)          wrbuf_next_state = IDLE;
            else                wrbuf_next_state = WRBUF_WRITE;
    endcase
end
reg [32*`W-1:0]  write_buf_data;
reg [31    :0]  write_buf_addr;
always@(posedge clk)begin
    if(valid&&~hit&&dirty)begin
        write_buf_addr <= {tag_ram_rdata[replace_way],data_ram_index,data_ram_offset,2'b0} ;
        write_buf_data <= data_ram_rdata_replace;
    end
end

assign     wr_req      = (wrbuf_state==WRBUF_WRITE);
assign     wr_type     = 3'b010;
assign     wr_addr     = write_buf_addr;
assign     wr_wstrb    = 4'hf;
assign     wr_size     = 3'b010;
assign     wr_data     = write_buf_data;

/*
if(wrbuf_state==WRBUF_WRITE)begin
    wr_req      = 1'b1;
    wr_type     = 3'b010;
    wr_addr     = write_buf_addr;
    wr_wstrb    = 4'hf;
    wr_size     = 3'b010;
    wr_data     = write_buf_data;
end
*/
endmodule