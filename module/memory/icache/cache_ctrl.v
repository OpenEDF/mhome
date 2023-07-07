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
`include "mhome_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module cache_ctrl
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

    // outputs
    output reg         cache_stall_cpu,
    output reg  [31:0] cache_inst_data_cpu
);

//--------------------------------------------------------------------------
// Design: cache controller siganl
//--------------------------------------------------------------------------
localparam RESET          = 8'b0000_0001;
localparam REQ_FROM_CPU   = 8'b0000_0010;
localparam WRITE_CACHE    = 8'b0000_0100;
localparam WRITE_MAIN_MEM = 8'b0000_1000;
localparam READ_CACHE     = 8'b0001_0000;
localparam READ_MAIN_MEM  = 8'b0010_0000;
localparam BRING_DATA     = 8'b0100_0000;
localparam RET_TO_CPU     = 8'b1000_0000;
reg hit_miss;

//--------------------------------------------------------------------------
// Design: cache FSM, one always sequential logic register output
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state  <= RESET;
        cache_stall_cpu <= 1'b0;
    end else begin
        cur_state  <= IDLE;
        cache_stall_cpu <= 1'b0;
        case(cache_state)
            IDLE: begin
                /* compare the cpu address tag and cache line tag */
                hit_miss = (way1_vaild[set] && (way1_tag[set] == tag))
                if (!hit_miss) begin /* miss */
                    cur_state <= READ_MAIN_MEM;
                end else begin /* hit */
                    if (read_req) begin
                        cur_state <= READ_CACHE;
                    end else if (write_req) begin
                        cur_state <= WRITE_CACHE;
                    end else begin
                        cur_state <= IDLE;
                    end
                end
            end
            READ_MAIN_MEM:
                cur_state <= BRING_DATA;
            READ_CACHE:
                cur_state <= RET_DATA;
            WRITE_CACHE:
                if (dirty)
                    cur_state <= WRITE_BACK_MEM;
                else
                    cur_state <= IDLE;
            WRITE_BACK_MEM:  /* write old value to main memory */
                cur_state <= IDLE;
            BRING_DATA:
                if (read_req) begin
                    cur_state <= READ_CACHE;
                end else if begin
                    cur_state <= WRITE_CACHE;
                end
            RET_DATA:
                cur_state <= IDLE;
            default:
                cur_state <= IDLE;
        endcase
    end
end

//--------------------------------------------------------------------------
// Design: cache write data
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Design: cache read data
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Design: read cache miss
//--------------------------------------------------------------------------


endmodule
//--------------------------------------------------------------------------
