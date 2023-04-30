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
module id_ex_stage
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [31:0]  id_cycle_count_ex,
    input wire [31:0]  id_pc_plus4_ex,
    input wire [31:0]  id_read_rs1_data_ex,
    input wire [31:0]  id_read_rs2_data_ex,
    input wire [31:0]  id_imm_exten_data_ex,
    input wire [4:0]   id_write_dest_register_index_ex,
    input wire         id_write_register_en_ex,
    input wire [7:0]   id_inst_encoding_ex,
    input wire         id_mem_write_en_ex,
    input wire [1:0]   id_mem_oper_size_ex,
    input wire [31:0]  id_current_pc_ex,
    input wire [8*3:1] id_inst_debug_str_ex,

    // outputs
    output reg [31:0]  ex_cycle_count_mem,
    output reg [31:0]  ex_pc_plus4_mem,
    output reg [4:0]   ex_write_dest_register_index_mem,
    output reg         ex_write_register_en_mem,
    output reg [31:0]  ex_alu_addr_calcul_result_mem,
    output reg [31:0]  ex_write_rs2_data_mem,
    output reg         ex_mem_write_en_mem,
    output reg [1:0]   ex_mem_oper_size_mem,

    output reg [8*3:1] ex_inst_debug_str_mem
);

//--------------------------------------------------------------------------
// Design: pipeline instruction execution unit internal signal
//--------------------------------------------------------------------------
reg [31:0] ex_alu_addr_calcul_result_mem_r;
//reg [31:0] ex_alu_oper_src2_data;

//--------------------------------------------------------------------------
// Design: pipeline cycle counter logic
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ex_cycle_count_mem <= `CYCLE_COUNT_RST;
    end else begin
        ex_cycle_count_mem <= id_cycle_count_ex;
    end
end

//--------------------------------------------------------------------------
// Design: ALU operational data source control
//--------------------------------------------------------------------------
//always @() begin
//    if (xxx) begin
//        ex_alu_oper_src2_data <= id_read_rs2_data_ex;
//    end else begin
//        ex_alu_oper_src2_data <= id_imm_exten_data_ex;
//    end
//end

//--------------------------------------------------------------------------
// Design: riscv pipeline execution arithmetic and instruction processing
//--------------------------------------------------------------------------
always @(id_inst_encoding_ex or id_imm_exten_data_ex or id_read_rs1_data_ex) begin
    case (id_inst_encoding_ex)
        `RV32_BASE_INST_LUI:
            ex_alu_addr_calcul_result_mem_r <= id_imm_exten_data_ex;
        `RV32_BASE_INST_AUIPC:
            ex_alu_addr_calcul_result_mem_r <= id_imm_exten_data_ex + id_current_pc_ex;
        default:
            ex_alu_addr_calcul_result_mem_r <= 32'h0000_0000;
    endcase
end

//--------------------------------------------------------------------------
// Design: pipeline update the ex_mem stage register
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ex_pc_plus4_mem <= 32'h0000_0000;
        ex_write_dest_register_index_mem <= 5'b00000;
        ex_write_register_en_mem <= 1'b0;
        ex_write_rs2_data_mem <= 32'h0000_0000;
        ex_alu_addr_calcul_result_mem <= 32'h0000_0000;
        ex_mem_write_en_mem <= `MEM_READ;
        ex_mem_oper_size_mem <= `MEM_OPER_WORD;
        ex_inst_debug_str_mem <= "nop";
    end else begin
        ex_pc_plus4_mem <= id_pc_plus4_ex;
        ex_write_dest_register_index_mem <= id_write_dest_register_index_ex;
        ex_write_register_en_mem <= id_write_register_en_ex;
        ex_write_rs2_data_mem <= id_read_rs2_data_ex;
        ex_alu_addr_calcul_result_mem <= ex_alu_addr_calcul_result_mem_r;
        ex_mem_write_en_mem <= id_mem_write_en_ex;
        ex_mem_oper_size_mem <= id_mem_oper_size_ex;
        ex_inst_debug_str_mem <= id_inst_debug_str_ex;
    end
end

endmodule
//--------------------------------------------------------------------------
