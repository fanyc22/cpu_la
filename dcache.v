`include "C:\Users\Lenovo\Desktop\cdp_ede_local-master\mycpu_env\myCPU\defs.v"

module dcache (
//output
            rdata,
            hit,
//input
            clk,
            rst_n,
            re,
            raddr,
            we,
            waddr,
            wdata,
            wsz);

input wire clk;
input wire rst_n;

input wire re;
input wire[31:0] raddr;

input wire we;
input wire[31:0] waddr;
input wire[31:0] wdata;
input wire[2:0] wsz;

output reg[31:0] rdata;
output reg hit;

reg [7:0] mem [0:8191];

reg [31:0] buffer_rdata;
reg buffer_hit;

reg buffer_we;
reg [31:0] buffer_waddr;
reg [31:0] buffer_wdata;
reg [2:0] buffer_wsz;

//write buffer
integer i;
always @(posedge clk) begin
    if(!rst_n) begin
        for (i = 0; i<8192 ;i=i+1 ) begin
            mem[i] <= 8'b0;
        end
    end
    else if(buffer_we && (buffer_waddr<8192) ) begin
        case (buffer_wsz)
            `ACCESS_SZ_BYTE: begin
                mem[buffer_waddr] <= buffer_wdata[7:0];
            end
            `ACCESS_SZ_HALF: begin
                mem[buffer_waddr] <= buffer_wdata[15:8];
                mem[buffer_waddr+1] <= buffer_wdata[7:0];
            end
            default: begin
                mem[buffer_waddr] <= buffer_wdata[31:24];
                mem[buffer_waddr+1] <= buffer_wdata[23:16];
                mem[buffer_waddr+2] <= buffer_wdata[15:8];
                mem[buffer_waddr+3] <= buffer_wdata[7:0];
            end
        endcase
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        buffer_we <= 1'b0;
        buffer_waddr <= 32'b0;
        buffer_wdata <= 32'b0;
        buffer_wsz <= 3'b0;
    end
    else begin
        buffer_we <= we;
        buffer_waddr <= waddr;
        buffer_wdata <= wdata;
        buffer_wsz <= wsz;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        buffer_rdata <= 32'b0;
        buffer_hit <= 1'b0;
    end
    else if(re && raddr==buffer_waddr) begin
        case (buffer_wsz)
            `ACCESS_SZ_BYTE: begin
                buffer_rdata <= {mem[raddr+3], 
                mem[raddr+2], 
                mem[raddr+1], 
                buffer_wdata[7:0]};
            end
            `ACCESS_SZ_HALF: begin
                buffer_rdata <= {mem[raddr+3], 
                mem[raddr+2], 
                buffer_wdata[15:8], 
                buffer_wdata[7:0]};
            end
            default: begin
                buffer_rdata <= {buffer_wdata[31:24], 
                buffer_wdata[23:16], 
                buffer_wdata[15:8], 
                buffer_wdata[7:0]};
            end
        endcase
        buffer_hit <= 1'b1;
    end
    else if (re && raddr<8192) begin
        buffer_rdata <= {mem[raddr+3], 
                mem[raddr+2], 
                mem[raddr+1], 
                mem[raddr]};
        buffer_hit <= 1'b1;
    end
    else begin
        buffer_rdata <= 32'b0;
        buffer_hit <= 1'b0;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        rdata <= 32'b0;
        hit <= 1'b0;
    end
    else begin
        rdata <= buffer_rdata;
        hit <= buffer_hit;
    end
end

endmodule