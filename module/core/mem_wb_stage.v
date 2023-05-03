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
    input wire [1:0]   mem_wb_result_src_wb,
    input wire [8*3:1] mem_inst_debug_str_wb,

    // outputs
    output reg  [31:0]  wb_cycle_count_end,
    output wire [4:0]   wb_write_dest_register_index_id,
    output wire         wb_write_register_en_id,
    output wire [31:0]  wb_sel_result_to_register_id,
    output wire [31:0]  wb_sel_result_to_register_ex,
    output wire [4:0]   wb_write_dest_register_index_hazard,
    output wire         wb_write_register_en_hazard,
    output reg  [8*3:1] wb_inst_debug_str_finish
);

//--------------------------------------------------------------------------
// Design: pipelile write back internal logic
//--------------------------------------------------------------------------
reg [31:0] wb_sel_result_to_register_r;
assign wb_sel_result_to_register_id = wb_sel_result_to_register_r;

//--------------------------------------------------------------------------
// Design: pipelile select data write to register
//--------------------------------------------------------------------------
assign wb_write_dest_register_index_id = mem_write_dest_register_index_wb;
assign wb_write_register_en_id = mem_write_register_en_wb;

//--------------------------------------------------------------------------
// Design: pipeline output the data hazards signal to execute and hazards
//         unit.
//--------------------------------------------------------------------------
assign wb_sel_result_to_register_ex = wb_sel_result_to_register_r;
assign wb_write_dest_register_index_hazard = wb_write_dest_register_index_id;
assign wb_write_register_en_hazard = wb_write_register_en_id;

//--------------------------------------------------------------------------
//Design: According to the control signal selection
//--------------------------------------------------------------------------
always @(mem_wb_result_src_wb or mem_alu_result_direct_wb or mem_read_mem_data_wb or mem_pc_plus4_wb) begin
    case (mem_wb_result_src_wb)
        `WB_SEL_ALU_RESULT:
            wb_sel_result_to_register_r <= mem_alu_result_direct_wb;
        `WB_SEL_MEM_RESULT:
            wb_sel_result_to_register_r <= mem_read_mem_data_wb;
        `WB_SEL_PCP4_RESULT:
            wb_sel_result_to_register_r <= mem_pc_plus4_wb;
        default:
            wb_sel_result_to_register_r <= 32'h0000_0000;
    endcase
end

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
        wb_inst_debug_str_finish <= "adi";
    end else begin
        wb_inst_debug_str_finish <= mem_inst_debug_str_wb;
    end
end

endmodule
//--------------------------------------------------------------------------
