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
module riscv_pipeline
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         sys_clk,
    input wire         sys_rst_n,

    // outputs
    output reg         sys_led
);

//--------------------------------------------------------------------------
// Design: pipeline five stage signal
//--------------------------------------------------------------------------
// pc generate stage
wire [31:0] pc_gen_start_cycle_count_if_w; /* pc gen register to IF/ID stage */
wire [31:0] source_pc_gen_if_w;            /* source pc value */

// instruction fetch stage
wire [31:0] if_cycle_count_id_w;           /* IF/ID stage register to ID/EX stage */
wire [31:0] if_instruction_id_w;           /* instruction */
wire [31:0] if_pc_plus4_pc_gen_w;          /* pc pluse 4 to pc gen*/
wire [31:0] if_pc_plus4_id_w;              /* PC plus 4 to next stage */
wire [31:0] if_current_pc_id_w;            /* current stage PC */

// decoder stage
wire [31:0]  id_cycle_count_ex_w;           /* ID/EX stage register to EX/MEM stage */
wire [31:0]  id_pc_plus4_ex_w;              /* pc plus 4 to next stage */
wire [31:0]  id_read_rs1_data_ex_w;         /* register rs1 data */
wire [31:0]  id_read_rs2_data_ex_w;         /* register rs2 data */
wire [31:0]  id_imm_exten_data_ex_w;        /* immediate exten data */
wire [4:0]   id_write_dest_register_index_ex_w; /* write register index */
wire         id_write_register_en_ex_w;     /* write register enable */
wire [7:0]   id_inst_encoding_ex_w;         /* riscv instruction */
wire         id_mem_write_en_ex_w;          /* memory operation read and wirte */
wire [1:0]   id_mem_oper_size_ex_w;         /* memory opearation size word/halfword/byte */
wire [31:0]  id_current_pc_ex_w;            /* current stage PC */
wire [8*3:1] id_inst_debug_str_ex_w;        /* riscv instruction debug string name */

// execute stage
wire [31:0]  ex_cycle_count_mem_w;          /* EX/MEM stage register to MEM/WB stage */
wire [31:0]  ex_pc_plus4_mem_w;             /* pc plus 4 to next stage */
wire [4:0]   ex_write_dest_register_index_mem_w; /* write register file index */
wire         ex_write_register_en_mem_w;           /* write register enable */
wire [31:0]  ex_alu_addr_calcul_result_mem_w;      /* alu result or read or write memory address to mem stage */
wire [31:0]  ex_write_rs2_data_mem_w;              /* data will be write to memory */
wire         ex_mem_write_en_mem_w;                /* memory operation read and wirte */
wire [1:0]   ex_mem_oper_size_mem_w;               /* memory opearation size word/halfword/byte */
wire [8*3:1] ex_inst_debug_str_mem_w;              /* riscv instruction debug string name */

// access memory stage
wire [31:0]  mem_cycle_count_wb_w;          /* MEM/WB to other  */
wire [31:0]  mem_pc_plus4_wb_w;             /* pc plus 4 to next stage */
wire [4:0]   mem_write_dest_register_index_wb_w; /* write register file index */
wire         mem_write_register_en_wb_w;         /* write register enable */
wire [31:0]  mem_read_mem_data_wb_w;             /* access memory read data to write back */
wire [31:0]  mem_alu_result_direct_wb_w;         /* excute stage direct send data to wb stage */
wire [8*3:1] mem_inst_debug_str_wb_w;            /* riscv instruction debug string nane */

// write back stage
wire [31:0]  mem_cycle_count_end_check_w;   /* MEM/WB output pc check */
wire [8*3:1] mem_instruction_name_check_w;  /* MEM/WB output inst name check */
wire [31:0]  wb_write_pc_plus4_id_w;        /* write the pc plus4 to register */
wire [4:0]   wb_write_dest_register_index_id_w;  /* write register file index */
wire         wb_write_register_en_id_w;          /* enable write register file */
wire [31:0]  wb_select_data_write_register_id_w; /* write data to register file */

//--------------------------------------------------------------------------
// Design: led test logic show core state
//--------------------------------------------------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        sys_led <= 1'b0;
    end else begin
        sys_led <= 1'b1;
    end
end

//--------------------------------------------------------------------------
// Design: generate program counter instaniate
//--------------------------------------------------------------------------
pc_gen pc_gen_u(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .if_pc_plus4_pc_src           (if_pc_plus4_pc_gen_w),

    .cycle_count_pc_gen_start     (pc_gen_start_cycle_count_if_w),
    .source_pc_gen_if             (source_pc_gen_if_w)
);

//--------------------------------------------------------------------------
// Design: instruction fetch instaniate
//--------------------------------------------------------------------------
pc_if_stage pc_if_stage_u(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .pc_gen_start_cycle_count_if  (pc_gen_start_cycle_count_if_w),
    .pc_source_pc_gen_if          (source_pc_gen_if_w),

    .if_cycle_count_id            (if_cycle_count_id_w),
    .if_instruction_id            (if_instruction_id_w),
    .if_pc_plus4_pc_gen           (if_pc_plus4_pc_gen_w),
    .if_pc_plus4_id               (if_pc_plus4_id_w),
    .if_current_pc_id             (if_current_pc_id_w)
);

//--------------------------------------------------------------------------
// Design: instruction decoder instaniate
//--------------------------------------------------------------------------
if_id_stage if_id_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .if_cycle_count_id     (if_cycle_count_id_w),
    .if_instruction_id     (if_instruction_id_w),
    .if_pc_plus4_id        (if_pc_plus4_id_w),
    .wb_write_register_dest_id   (wb_write_dest_register_index_id_w),
    .wb_write_register_data_id   (wb_select_data_write_register_id_w),
    .wb_write_reginster_en_id    (wb_write_register_en_id_w),
    .wb_write_pc_plus4_id        (wb_write_pc_plus4_id_w),
    .if_current_pc_id            (if_current_pc_id_w),

    .id_cycle_count_ex     (id_cycle_count_ex_w),
    .id_pc_plus4_ex        (id_pc_plus4_ex_w),
    .id_read_rs1_data_ex   (id_read_rs1_data_ex_w),
    .id_read_rs2_data_ex   (id_read_rs2_data_ex_w),
    .id_imm_exten_data_ex  (id_imm_exten_data_ex_w),
    .id_write_dest_register_index_ex (id_write_dest_register_index_ex_w),
    .id_write_register_en_ex (id_write_register_en_ex_w),
    .id_inst_encoding_ex     (id_inst_encoding_ex_w),
    .id_mem_write_en_ex      (id_mem_write_en_ex_w),
    .id_mem_oper_size_ex     (id_mem_oper_size_ex_w),
    .id_current_pc_ex        (id_current_pc_ex_w),

    .id_inst_debug_str_ex    (id_inst_debug_str_ex_w)
);

//--------------------------------------------------------------------------
// Design: execute instaniate
//--------------------------------------------------------------------------
id_ex_stage id_ex_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .id_cycle_count_ex     (id_cycle_count_ex_w),
    .id_pc_plus4_ex        (id_pc_plus4_ex_w),
    .id_read_rs1_data_ex   (id_read_rs1_data_ex_w),
    .id_read_rs2_data_ex   (id_read_rs2_data_ex_w),
    .id_imm_exten_data_ex  (id_imm_exten_data_ex_w),
    .id_write_dest_register_index_ex  (id_write_dest_register_index_ex_w),
    .id_write_register_en_ex  (id_write_register_en_ex_w),
    .id_inst_encoding_ex      (id_inst_encoding_ex_w),
    .id_mem_write_en_ex       (id_mem_write_en_ex_w),
    .id_mem_oper_size_ex      (id_mem_oper_size_ex_w),
    .id_current_pc_ex         (id_current_pc_ex_w),
    .id_inst_debug_str_ex     (id_inst_debug_str_ex_w),

    .ex_cycle_count_mem    (ex_cycle_count_mem_w),
    .ex_pc_plus4_mem       (ex_pc_plus4_mem_w),
    .ex_write_dest_register_index_mem    (ex_write_dest_register_index_mem_w),
    .ex_write_register_en_mem            (ex_write_register_en_mem_w),
    .ex_alu_addr_calcul_result_mem       (ex_alu_addr_calcul_result_mem_w),
    .ex_write_rs2_data_mem               (ex_write_rs2_data_mem_w),
    .ex_mem_write_en_mem                 (ex_mem_write_en_mem_w),
    .ex_mem_oper_size_mem                (ex_mem_oper_size_mem_w),

    .ex_inst_debug_str_mem               (ex_inst_debug_str_mem_w)

);

//--------------------------------------------------------------------------
// Design: access instaniate
//--------------------------------------------------------------------------
ex_mem_stage ex_mem_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .ex_cycle_count_mem     (ex_cycle_count_mem_w),
    .ex_pc_plus4_mem        (ex_pc_plus4_mem_w),
    .ex_write_dest_register_index_mem  (ex_write_dest_register_index_mem_w),
    .ex_write_register_en_mem          (ex_write_register_en_mem_w),
    .ex_alu_addr_calcul_result_mem     (ex_alu_addr_calcul_result_mem_w),
    .ex_write_rs2_data_mem             (ex_write_rs2_data_mem_w),
    .ex_mem_write_en_mem               (ex_mem_write_en_mem_w),
    .ex_mem_oper_size_mem              (ex_mem_oper_size_mem_w),
    .ex_inst_debug_str_mem             (ex_inst_debug_str_mem_w),

    .mem_cycle_count_wb     (mem_cycle_count_wb_w),
    .mem_pc_plus4_wb        (mem_pc_plus4_wb_w),
    .mem_write_dest_register_index_wb (mem_write_dest_register_index_wb_w),
    .mem_write_register_en_wb         (mem_write_register_en_wb_w),
    .mem_read_mem_data_wb             (mem_read_mem_data_wb_w),
    .mem_alu_result_direct_wb         (mem_alu_result_direct_wb_w),
    .mem_inst_debug_str_wb            (mem_inst_debug_str_wb_w)
);

//--------------------------------------------------------------------------
// Design: write back instaniate
//--------------------------------------------------------------------------
mem_wb_stage mem_wb_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .mem_cycle_count_wb     (mem_cycle_count_wb_w),
    .mem_pc_plus4_wb        (mem_pc_plus4_wb_w),
    .mem_write_dest_register_index_wb    (mem_write_dest_register_index_wb_w),
    .mem_write_register_en_wb            (mem_write_register_en_wb_w),
    .mem_read_mem_data_wb                (mem_read_mem_data_wb_w),
    .mem_alu_result_direct_wb            (mem_alu_result_direct_wb_w),
    .mem_inst_debug_str_wb               (mem_inst_debug_str_wb_w),

    .wb_cycle_count_end     (mem_cycle_count_end_check_w),
    .wb_write_pc_plus4_id   (wb_write_pc_plus4_id_w),
    .wb_write_dest_register_index_id     (wb_write_dest_register_index_id_w),
    .wb_write_register_en_id             (wb_write_register_en_id_w),
    .wb_select_data_write_register_id    (wb_select_data_write_register_id_w),
    .wb_inst_debug_str_finish            (mem_instruction_name_check_w)
);

endmodule
//--------------------------------------------------------------------------
