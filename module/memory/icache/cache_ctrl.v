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
// Brief:
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
    input wire  [31:0] cpu_if_pc_cache,
    input wire         cpu_write_en_cache,
    input wire         cpu_read_en_cache,

    // outputs
    output wire        cache_miss_cpu,
    output wire [31:0] cache_inst_data_cpu
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

//--------------------------------------------------------------------------
// Design: cache FSM, one always sequential logic register output
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state  <= RESET;
    end else begin
        cur_state  <= REQ_FROM_CPU;
        case(cache_state)
            REQ_FROM_CPU: begin
                /* compare the cpu address tag and cache line tag */
                if (write_hit) begin
                    cur_state <= WRITE_CACHE;
                end
            end
            WRITE_CACHE:
            WRITE_MAIN_MEM:
            READ_CACHE:
            READ_MAIN_MEM:
            BRING_DATA:
            RET_TO_CPU:
            default:
        endcase
    end
end

//--------------------------------------------------------------------------
// Design: compare the cpu address tag and cache line tag
//--------------------------------------------------------------------------

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
