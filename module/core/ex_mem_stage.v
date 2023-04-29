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
module ex_mem_stage 
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [31:0]  ex_cycle_count_mem,
    input wire [31:0]  ex_pc_plus4_mem,
    input wire [4:0]   ex_write_dest_register_index_mem,
    input wire         ex_write_register_en_mem,
    input wire [31:0]  ex_alu_addr_calcul_result_mem,
    input wire [31:0]  ex_write_rs2_data_mem,
    input wire [8*3:1] ex_inst_debug_str_mem,

    // outputs
    output reg  [31:0]  mem_cycle_count_wb,
    output reg  [31:0]  mem_pc_plus4_wb,
    output reg  [4:0]   mem_write_dest_register_index_wb,
    output reg          mem_write_register_en_wb,
    output reg  [31:0]  mem_read_mem_data_wb,
    output reg  [31:0]  mem_alu_result_direct_wb,
    output reg  [8*3:1] mem_inst_debug_str_wb
);

//--------------------------------------------------------------------------
// Design: pipeline access memory internal signal
//--------------------------------------------------------------------------
wire [31:0] mem_read_mem_data_wb_w;
assign mem_read_mem_data_wb_w = ex_write_rs2_data_mem;  /* TODO: delete*/
//--------------------------------------------------------------------------
// Design: pipeline cycle counter logic
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_cycle_count_wb <= `CYCLE_COUNT_RST;
    end else begin
        mem_cycle_count_wb <= ex_cycle_count_mem;
    end
end

//--------------------------------------------------------------------------
// Design: riscv pipeline access memory update register to write back stage
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_pc_plus4_wb <= 32'h0000_0000;
        mem_write_dest_register_index_wb <= 5'b00000;
        mem_read_mem_data_wb <= 32'h0000_0000;
        mem_write_register_en_wb <= 1'b0;
        mem_alu_result_direct_wb <= 32'h00000000;
        mem_inst_debug_str_wb <= "nop";
    end else begin
        mem_pc_plus4_wb <= ex_pc_plus4_mem;
        mem_write_dest_register_index_wb <= ex_write_dest_register_index_mem;
        mem_read_mem_data_wb <= mem_read_mem_data_wb_w;
        mem_write_register_en_wb <= ex_write_register_en_mem;
        mem_alu_result_direct_wb <= ex_alu_addr_calcul_result_mem;
        mem_inst_debug_str_wb <= ex_inst_debug_str_mem;
    end
end

endmodule
//--------------------------------------------------------------------------
