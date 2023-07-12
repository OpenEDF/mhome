//--------------------------------------------------------------------------
//                         RISC-V Core
//                            V1.0.0
//                         openedf.com
//                     Copyright 2023-2024
//
//                     makermuyi@gmail.com
//
//                       License: BSD
//--------------------------------------------------------------------------
//
// Copyright (c) 2020-2021, openedf.com
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.

//--------------------------------------------------------------------------
// Designer: macro
// Brief: 8KB instruction cache, 4-way set asssociative, 1 word block size
//        number of block: 8K / 4 = 2048 block
//        number of set:   2048 / 4 = 512
//        Tag:    21 bit
//        set:    9  bit
//        offset: 2  bit
//        ditry:  1  bit
//        vaild:  1  bit
//        lru:    1  bit
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "amba_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module cache_ctrl #(
    parameter BLOCK_WIDTH = 32,
    parameter SET_SIZE    = 512,
    parameter SET_WIDTH   = 9,
    parameter TAG_WIDTH   = 21,
    parameter MAIN_MEM_WIDTH = 128,
)
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire  [31:0] cpu_addr_cache,
    input wire         cpu_write_req_cache,
    input wire         cpu_read_req_cache,
    input wire  [31:0] cpu_write_data_cache,
    input wire  [MAIN_MEM_WIDTH-1:0] main_mem_data_cache,

    // outputs
    output reg         cache_stall_cpu,
    output reg         cache_read_ready,
    output reg  [31:0] cache_ret_data_cpu,

    // ahb master port for main memory
    //output reg         HCLK,
    //output reg         HRESETn,
    output reg  [31:0] HADDR,
    output reg  [2:0]  HBURST,
    output reg         HMASTERLOCK,
    output reg  [3:0]  HPORT,
    output reg  [2:0]  HSZIE,
    output reg  [1:0]  HTRANS,
    output reg  [MAIN_MEM_WIDTH-1:0] HWDATA,
    output reg         HWRITE
);

//--------------------------------------------------------------------------
// Design: cache controller siganl
//--------------------------------------------------------------------------
localparam RESET          = 8'b0000_0001;
localparam COMP_TAG_VAILD = 8'b0000_0010;
localparam WRITE_CACHE    = 8'b0000_0100;
localparam WRITE_BACK_MEM = 8'b0000_1000;
localparam READ_CACHE     = 8'b0001_0000;
localparam READ_MAIN_MEM  = 8'b0010_0000;
localparam BRING_DATA     = 8'b0100_0000;
localparam RET_DATA       = 8'b1000_0000;

reg [31:0] ret_data;
reg [31:0] write_back_data;
reg [31:0] miss_count;

wire [TAG_WIDTH-1:0] cpu_addr_tag;
wire [SET_WIDTH-1:0] cpu_addr_set;
wire cpu_req;
wire hit_miss_way0;
wire hit_miss_way1;
wire hit_miss_way2;
wire hit_miss_way3;
wire hit_miss;

assign cache_tag = cpu_addr_cache[31:12];
assign cache_set = cpu_addr_cache[11:2];
assign cpu_req = cpu_write_req_cache | cpu_read_req_cache;
assign hit_miss_way0 = way0_vaild[cache_set] & (way0_tag[cache_set] == cache_tag);
assign hit_miss_way1 = way1_vaild[cache_set] & (way1_tag[cache_set] == cache_tag);
assign hit_miss_way2 = way2_vaild[cache_set] & (way2_tag[cache_set] == cache_tag);
assign hit_miss_way3 = way3_vaild[cache_set] & (way3_tag[cache_set] == cache_tag);
assign hit_miss = hit_miss_way0 | hit_miss_way1 | hit_miss_way2 | hit_miss_way3;

//--------------------------------------------------------------------------
// Design: cache memory way0
//--------------------------------------------------------------------------
reg [BLOCK_WITDH-1:0] way0_block[SET_SIZE];
reg                   way0_dirty[SET_SIZE];
reg                   way0_vaild[SET_SIZE];
reg                   way0_lru[SET_SIZE];
reg [TAG_WIDTH-1:0]   way0_tag[SET_SIZE];

//--------------------------------------------------------------------------
// Design: cache memory way1
//--------------------------------------------------------------------------
reg [BLOCK_WITDH-1:0] way1_block[SET_SIZE];
reg                   way1_dirty[SET_SIZE];
reg                   way1_vaild[SET_SIZE];
reg                   way1_lru[SET_SIZE];
reg [TAG_WIDTH-1:0]   way1_tag[SET_SIZE];

//--------------------------------------------------------------------------
// Design: cache memory way2
//--------------------------------------------------------------------------
reg [BLOCK_WITDH-1:0] way2_block[SET_SIZE];
reg                   way2_dirty[SET_SIZE];
reg                   way2_vaild[SET_SIZE];
reg                   way2_lru[SET_SIZE];
reg [TAG_WIDTH-1:0]   way2_tag[SET_SIZE];

//--------------------------------------------------------------------------
// Design: cache memory way3
//--------------------------------------------------------------------------
reg [BLOCK_WITDH-1:0] way3_block[SET_SIZE];
reg                   way3_dirty[SET_SIZE];
reg                   way3_vaild[SET_SIZE];
reg                   way3_lru[SET_SIZE];
reg [TAG_WIDTH-1:0]   way3_tag[SET_SIZE];

//--------------------------------------------------------------------------
// Design: initial cache memory
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Design: cache FSM, one always sequential logic register output
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state  <= RESET;
        cache_stall_cpu <= 1'b0;
        cache_stall_cpu  <= 1'b0;
        cache_read_ready <= 1'b0;
        ret_data         <= 32'h0000_0000;
        write_back_data  <= 32'h0000_0000;
        HADDR            <= 32'h0000_0000;
        HBURST           <=;
        HMASTERLOCK      <=;
        HPORT            <=;
        HSZIE            <=;
        HTRANS           <=;
        HWDATA           <=;
        HWRITE           <=;
    end else begin
        cur_state        <= IDLE;
        cache_stall_cpu  <= 1'b0;
        cache_read_ready <= 1'b0;
        case(cache_state)
            IDLE: begin
                /* wait cpu read and write request */
                if (cpu_req) begin
                    cur_state <= COMP_TAG_VAILD;
                end else begin
                    cur_state <= IDLE;
                end
            end
            COMP_TAG_VAILD: begin
                /* compare the cpu address tag and cache line tag */
                if (!hit_miss) begin /* miss */
                    cache_stall_cpu <= 1'b1;
                    cur_state <= READ_MAIN_MEM;
                end else begin /* hit */
                    if (cpu_read_req_cache) begin
                        cur_state <= READ_CACHE;
                    end else if (cpu_write_req_cache) begin
                        cur_state <= WRITE_CACHE;
                    end else begin
                        cur_state <= IDLE;
                    end
                end
            end
            READ_MAIN_MEM: begin
                /* read main memory via ahb */
                cur_state <= BRING_DATA;
            end
            READ_CACHE: begin
                /* when cache hit read data */
                if (hit_miss_way0) begin
                    ret_data <= way0_block[cache_set];
                end else if (hit_miss_way1) begin
                    ret_data <= way1_block[cache_set];
                end else if (hit_miss_way2) begin
                    ret_data <= way2_block[cache_set];
                end else if (hit_miss_way3) begin
                    ret_data <= way3_block[cache_set];
                end else begin
                    ret_data <= ret_data;
                end
                cur_state <= RET_DATA;
            end
            WRITE_CACHE: begin
                /* when cache hit write data */
                if (hit_miss_way0) begin
                    if (way0_dirty[cache_set]) begin
                        write_back_data       <= way0_block[cache_set];
                        way0_block[cache_set] <= cpu_write_data_cache; /* block assign */
                        cur_state <= WRITE_BACK_MEM;
                    end else begin
                        way0_block[cache_set] <= cpu_write_data_cache;
                        way0_dirty[cache_set] <= 1'b1;
                        cur_state <= IDLE;
                    end
                end else if (hit_miss_way1) begin
                    if (way1_dirty[cache_set]) begin
                        write_back_data       <= way1_block[cache_set];
                        way1_block[cache_set] <= cpu_write_data_cache; /* block assign */
                        cur_state <= WRITE_BACK_MEM;
                    end else begin
                        way1_block[cache_set] <= cpu_write_data_cache;
                        way1_dirty[cache_set] <= 1'b1;
                        cur_state <= IDLE;
                    end
                end else if (hit_miss_way2) begin
                    if (way2_dirty[cache_set]) begin
                        write_back_data       <= way2_block[cache_set];
                        way2_block[cache_set] <= cpu_write_data_cache; /* block assign */
                        cur_state <= WRITE_BACK_MEM;
                    end else begin
                        way2_block[cache_set] <= cpu_write_data_cache;
                        way2_dirty[cache_set] <= 1'b1;
                        cur_state <= IDLE;
                    end
                end else if (hit_miss_way3) begin
                    if (way3_dirty[cache_set]) begin
                        write_back_data       <= way3_block[cache_set];
                        way3_block[cache_set] <= cpu_write_data_cache; /* block assign */
                        cur_state <= WRITE_BACK_MEM;
                    end else begin
                        way3_block[cache_set] <= cpu_write_data_cache;
                        way3_dirty[cache_set] <= 1'b1;
                        cur_state <= IDLE;
                    end
                end
            end
            WRITE_BACK_MEM: begin
                /* write old value to main memory */
                cur_state <= IDLE;
            end
            BRING_DATA: begin
                /* bring data to cache memory */
                cache_stall_cpu <= 1'b0;
                if (cpu_read_req_cache) begin
                    cur_state <= READ_CACHE;
                end else if (cpu_write_req_cache) begin
                    cur_state <= WRITE_CACHE;
                end else begin
                    cur_state <= BRING_DATA;  /* never */
                end
            end
            RET_DATA: begin
                /* read opeartion return data to cpu */
                cache_read_ready   <= 1'b1;
                cache_ret_data_cpu <= ret_data;
                cur_state <= IDLE;
            end
            default:
                /* never */
                cur_state <= IDLE;
        endcase
    end
end

//--------------------------------------------------------------------------
// Design: debug register for cache miss counter
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        miss_count <= 32'h0000_0000;
    end else begin
        if (hit_miss) begin
            miss_count <= miss_count + 1'b1;
        end else begin
            miss_count <= miss_count;
        end
    end
end

endmodule
//--------------------------------------------------------------------------
