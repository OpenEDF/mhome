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
module mem_wb_stage 
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [31:0]  mem_cycle_count_wb,
    input wire [31:0]  mem_pc_plus4_wb,
    input wire [4:0]   mem_write_dest_register_index_wb,
    input wire         mem_write_register_en_wb,
    input wire [31:0]  mem_read_mem_data_wb,
    input wire [31:0]  mem_alu_result_direct_wb,
    input wire [8*3:1] mem_inst_debug_str_wb,

    // outputs
    output reg  [31:0]  wb_cycle_count_end,
    output wire [31:0]  wb_write_pc_plus4_id,
    output wire [4:0]   wb_write_dest_register_index_id,
    output wire         wb_write_register_en_id,
    output wire [31:0]  wb_select_data_write_register_id,
    output reg  [8*3:1] wb_inst_debug_str_finish
);

//--------------------------------------------------------------------------
// Design: pipelile write back internal logic
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Design: pipelile select data write to register
//--------------------------------------------------------------------------
assign wb_write_pc_plus4_id = mem_pc_plus4_wb;
assign wb_write_dest_register_index_id = mem_write_dest_register_index_wb;
assign wb_write_register_en_id = mem_write_register_en_wb;
assign wb_select_data_write_register_id = mem_alu_result_direct_wb;

//TODO: deleted it
wire [31:0] unused_warning;
assign unused_warning = mem_read_mem_data_wb;

//TODO: According to the control signal selection
//always @() begin
//    case or if else
//end

//--------------------------------------------------------------------------
// Design: pipeline cycle counter logic
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wb_cycle_count_end <= `CYCLE_COUNT_RST;
    end else begin
        wb_cycle_count_end <= mem_cycle_count_wb;
    end
end

//--------------------------------------------------------------------------
// Design: pipelile debug instruction name
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wb_inst_debug_str_finish <= "nop";
    end else begin
        wb_inst_debug_str_finish <= mem_inst_debug_str_wb;
    end
end

endmodule
//--------------------------------------------------------------------------
