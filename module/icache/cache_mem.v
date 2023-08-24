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
// Brief: cache memory
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
//`include "cache_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module cache_mem #(
    parameter BLOCK_WIDTH = 32,
    parameter SET_SIZE    = 512,
    parameter SET_WIDTH   = 9,
    parameter TAG_WIDTH   = 21
)
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire [SET_WIDTH-1:0]    set_addr,
    input wire                    wr_block_en,
    input wire                    wr_block_data,
    input wire                    wr_dirty_en,
    input wire                    wr_dirty_data,
    input wire [TAG_WIDTH-1:0]    wr_tag_en,
    input wire                    wr_tag_data,
    input wire                    wr_vaild_en,
    input wire                    wr_vaild_data,
    input wire                    wr_lru_en,
    input wire                    wr_lru_data,

    // outputs
    output wire [BLOCK_WIDTH-1:0] block_data,
    output wire [TAG_WIDTH-1:0]   tag_data,
    output wire                   dirty_data,
    output wire                   vaild_data,
    output wire                   lru_data
);

//--------------------------------------------------------------------------
// Design: memory descript
//--------------------------------------------------------------------------
reg [BLOCK_WITDH-1:0] block[SET_SIZE];
reg                   dirty[SET_SIZE];
reg                   vaild[SET_SIZE];
reg                   lru[SET_SIZE];
reg [TAG_WIDTH-1:0]   tag[SET_SIZE];

//--------------------------------------------------------------------------
// Design: write memory
//--------------------------------------------------------------------------
always @(wr_block_en or
        wr_dirty_en or
        wr_tag_en or
        wr_vaild_en or
        wr_lru_en) begin
    if (wr_block_en) begin
        block[set_addr] <= wr_block_data;
    end else if (wr_tag_en) begin
        tag[set_addr]   <= wr_tag_data;
    end else if (wr_dirty_en) begin
        dirty[set_addr] <= wr_dirty_data;
    end else if (wr_vaild_en) begin
        vaild[set_addr] <= wr_vaild_data;
    end else if (wr_lru_en) begin
        lru[set_addr]   <= wr_lru_data;
    end else begin
        block[set_addr] <= block[set_addr];
        tag[set_addr]   <= tag[set_addr];
        dirty[set_addr] <= dirty[set_addr];
        vaild[set_addr] <= vaild[set_addr];
        lru[set_addr]   <= lru[set_addr];
    end
end

//--------------------------------------------------------------------------
// Design: read memory
//--------------------------------------------------------------------------
always @(wr_block_en or
        wr_dirty_en or
        wr_tag_en or
        wr_vaild_en or
        wr_lru_en) begin
    if (~wr_block_en) begin
        block_data <= block[set_addr];
    end else if (~wr_tag_en) begin
        tag_data   <= tag[set_addr];
    end else if (~wr_dirty_en) begin
        dirty_data <= dirty[set_addr];
    end else if (~wr_vaild_en) begin
        vaild_data <= vaild[set_addr];
    end else if (~wr_lru_en) begin
        lru_data   <= lru[set_addr];
    end else begin
        block_data <= BLOCK_WITDH'b0;
        tag_data   <= TAG_WIDTH'b0;
        dirty_data <= 1'b0;
        vaild_data <= 1'b0;
        lru_data   <= 1'b0;
    end
end

endmodule
//--------------------------------------------------------------------------
