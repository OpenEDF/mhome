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
// Brief: control pipeline flush and stall, pipeline data hazards.
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "mhome_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module hazard_unit
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // Inputs
    input wire         ex_pc_jump_en_pc_mux,
    input wire [4:0]   ex_rs1_index_hazard,
    input wire [4:0]   ex_rs2_index_hazard,
    input wire [4:0]   mem_rd_index_hazard,
    input wire         mem_write_dest_en_hazard,
    input wire [4:0]   wb_rd_index_hazard,
    input wire         wb_write_dest_en_hazard,
    input wire         id_csr_write_en_hazard,
    input wire         id_csr_write_done_hazard,
    input wire         ex_mul_div_pp_stall_hazard,

    // Outputs
    output reg        hazard_flush_pc_if_reg,
    output reg        hazard_flush_if_id_reg,
    output reg        hazard_flush_id_ex_reg,
    output reg        hazard_flush_ex_mem_reg,
    output reg        hazard_flush_mem_wb_reg,
    output reg        hazard_stall_pc_if_reg,       // pc_gen swquential always
    output reg        hazard_stall_if_id_reg,
    output reg        hazard_stall_id_ex_reg,
    output reg        hazard_stall_ex_mem_reg,
    output reg        hazard_stall_mem_wb_reg,
    output reg [1:0]  hazard_ctrl_ex_rs1data_sel_src,
    output reg [1:0]  hazard_ctrl_ex_rs2data_sel_src
);

//--------------------------------------------------------------------------
// Design: when flush is enable, if_id_register and id_ex register will
//         flush
//--------------------------------------------------------------------------
//assign hazard_flush_if_id_reg = ex_pc_jump_en_pc_mux ? `PP_FLUSH_IF_ID_REG_ENABLE : `PP_FLUSH_IF_ID_DISABLE;
//assign hazard_flush_id_ex_reg = ex_pc_jump_en_pc_mux ? `PP_FLUSH_ID_EX_REG_ENABLE : `PP_FLUSH_IF_ID_DISABLE;
always @(ex_pc_jump_en_pc_mux
        or id_csr_write_en_hazard
        or id_csr_write_done_hazard
        or ex_mul_div_pp_stall_hazard) begin
        /* TODO: modify the design */
    begin: hazard_def_val
        hazard_flush_pc_if_reg  <= `PP_FLUSH_PC_IF_REG_DISABLE;
        hazard_flush_if_id_reg  <= `PP_FLUSH_IF_ID_REG_DISABLE;
        hazard_flush_id_ex_reg  <= `PP_FLUSH_ID_EX_REG_DISABLE;
        hazard_flush_ex_mem_reg <= `PP_FLUSH_EX_MEM_REG_DISABLE;
        hazard_flush_mem_wb_reg <= `PP_FLUSH_MEM_WB_REG_DISABLE;
        hazard_stall_pc_if_reg  <= `PP_STALL_PC_IF_REG_DISABLE;
        hazard_stall_if_id_reg  <= `PP_STALL_IF_ID_REG_DISABLE;
        hazard_stall_id_ex_reg  <= `PP_STALL_ID_EX_REG_DISABLE;
        hazard_stall_ex_mem_reg <= `PP_STALL_EX_MEM_REG_DISABLE;
        hazard_stall_mem_wb_reg <= `PP_STALL_MEM_WB_REG_DISABLE;
    end
    if (ex_pc_jump_en_pc_mux) begin
        hazard_flush_if_id_reg  <= `PP_FLUSH_IF_ID_REG_ENABLE;
        hazard_flush_id_ex_reg  <= `PP_FLUSH_ID_EX_REG_ENABLE;
    end else if (id_csr_write_en_hazard) begin
        hazard_flush_if_id_reg  <= `PP_FLUSH_IF_ID_REG_ENABLE;
        hazard_stall_pc_if_reg  <= `PP_STALL_PC_IF_REG_ENABLE;
    end else if (id_csr_write_done_hazard) begin
        hazard_flush_if_id_reg  <= `PP_FLUSH_IF_ID_REG_DISABLE;
        hazard_stall_pc_if_reg  <= `PP_STALL_PC_IF_REG_DISABLE;
    end else if (ex_mul_div_pp_stall_hazard) begin
        hazard_stall_pc_if_reg  <= `PP_STALL_PC_IF_REG_ENABLE;
        hazard_stall_if_id_reg  <= `PP_STALL_IF_ID_REG_ENABLE;
        hazard_stall_id_ex_reg  <= `PP_STALL_ID_EX_REG_ENABLE;
        hazard_stall_ex_mem_reg <= `PP_STALL_EX_MEM_REG_ENABLE;
        hazard_stall_mem_wb_reg <= `PP_STALL_MEM_WB_REG_ENABLE;
    end else begin
        hazard_flush_if_id_reg  <= `PP_FLUSH_IF_ID_REG_DISABLE;
        hazard_flush_id_ex_reg  <= `PP_FLUSH_ID_EX_REG_DISABLE;
        hazard_stall_pc_if_reg  <= `PP_STALL_PC_IF_REG_DISABLE;
        hazard_stall_if_id_reg  <= `PP_STALL_IF_ID_REG_DISABLE;
    end
end

//--------------------------------------------------------------------------
// Design: sloving data hazards with forwarding for execute register 1
//         must use the blocking assignment, mem stage has hogher priority
//         over wb stage.
//--------------------------------------------------------------------------
always @(*) begin
    if (((ex_rs1_index_hazard == mem_rd_index_hazard) && (mem_rd_index_hazard != 5'b00000)) && mem_write_dest_en_hazard) begin
        hazard_ctrl_ex_rs1data_sel_src = `PP_FORWARD_EX_RSXDATA_SEL_MEM;
    end else if (((ex_rs1_index_hazard == wb_rd_index_hazard) && (wb_rd_index_hazard != 5'b00000)) && wb_write_dest_en_hazard) begin
        hazard_ctrl_ex_rs1data_sel_src = `PP_FORWARD_EX_RSXDATA_SEL_WB;
    end else begin
        hazard_ctrl_ex_rs1data_sel_src = `PP_FORWARD_EX_RSXDATA_SEL_ID;
    end
end

//--------------------------------------------------------------------------
// Design: sloving data hazards with forwarding for execute register 2
//         must use the blocking assignment, mem stage has hogher priority
//         over wb stage
//--------------------------------------------------------------------------
always @(*) begin
    if (((ex_rs2_index_hazard == mem_rd_index_hazard) && (mem_rd_index_hazard != 5'b00000)) && mem_write_dest_en_hazard) begin
        hazard_ctrl_ex_rs2data_sel_src = `PP_FORWARD_EX_RSXDATA_SEL_MEM;
    end else if (((ex_rs2_index_hazard == wb_rd_index_hazard) && (wb_rd_index_hazard != 5'b00000)) && wb_write_dest_en_hazard) begin
        hazard_ctrl_ex_rs2data_sel_src = `PP_FORWARD_EX_RSXDATA_SEL_WB;
    end else begin
        hazard_ctrl_ex_rs2data_sel_src = `PP_FORWARD_EX_RSXDATA_SEL_ID;
    end
end

endmodule
//--------------------------------------------------------------------------
