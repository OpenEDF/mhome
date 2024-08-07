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
    input wire          sys_clk,
    input wire          sys_rst_n,
    input wire  [4:0]   dm_access_gprs_index_hart,
    input wire  [31:0]  dm_write_gprs_data_hart,
    input wire          dm_write_gprs_en_hart,

    // outputs
    output wire [31:0]  hart_result_read_gprs_dm,
    output reg          sys_led
);

//--------------------------------------------------------------------------
// Design: pipeline five stage signal
//--------------------------------------------------------------------------
// pc generate stage
wire [31:0] pc_gen_start_cycle_count_if_w; /* pc gen register to IF/ID stage */
wire [31:0] source_pc_gen_if_w;            /* source pc value */

// instruction fetch stage
wire [31:0] if_cycle_count_id_w;            /* IF/ID stage register to ID/EX stage */
wire [31:0] if_instruction_id_w;            /* instruction */
wire [31:0] if_pc_plus4_pc_gen_w;           /* pc pluse 4 to pc gen*/
wire [31:0] if_pc_plus4_id_w;               /* PC plus 4 to next stage */
wire [31:0] if_current_pc_id_w;             /* current stage PC */
wire [63:0] if_minstret_count_id_w;         /* machine instructions-retired counter for if */

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
wire [4:0]   id_rs2_shamt_ex_w;             /* SLLI/SRLI/SALI shamt data */
wire [1:0]   id_wb_result_src_ex_w;         /* wb stage select data write to register */
wire         id_sel_imm_rs2data_alu_ex_w;   /* execute alu select immidate or rs2 data an input2 */
wire         id_pc_jump_en_ex_w;            /* pipeline jump enable */
wire         id_pc_branch_en_ex_w;          /* pipeline branch enable */
wire [4:0]   id_inst_rs1_w;                 /* instruction register port1 */
wire [4:0]   id_inst_rs2_w;                 /* instruction register port2 */
wire [31:0]  id_csr_read_data_ex_w;         /* csr old data */
wire [11:0]  id_csr_write_addr_ex_w;        /* crs write address */
wire         id_csr_write_en_ex_w;          /* csr write enable */
wire [31:0]  id_rs1_uimm_ex_w;              /* csr immediated operand extend data */
wire         id_csr_write_en_hazard_w;      /* csr write enable signal to hazard */
wire         id_csr_write_done_hazard_w;    /* csr write done siganl to hazard */
wire         id_mul_div_pp_stall_ex_w;      /* multiplier and divider hazard control signal */
wire [63:0]  id_minstret_count_ex_w;        /* machine instructions-retired counter for id */
wire [8*3:1] id_inst_debug_str_ex_w;        /* riscv instruction debug string name */

// execute stage
wire [31:0]  ex_cycle_count_mem_w;          /* EX/MEM stage register to MEM/WB stage */
wire [31:0]  ex_pc_plus4_mem_w;             /* pc plus 4 to next stage */
wire [4:0]   ex_write_dest_register_index_mem_w;   /* write register file index */
wire         ex_write_register_en_mem_w;           /* write register enable */
wire [31:0]  ex_alu_addr_calcul_result_mem_w;      /* alu result or read or write memory address to mem stage */
wire [31:0]  ex_write_rs2_data_mem_w;              /* data will be write to memory */
wire         ex_mem_write_en_mem_w;                /* memory operation read and wirte */
wire [1:0]   ex_mem_oper_size_mem_w;               /* memory opearation size word/halfword/byte */
wire [1:0]   ex_wb_result_src_mem_w;               /* wb stage select data write to register */
wire         ex_pc_jump_en_pc_mux_w;               /* pipeline enable jump */
wire [31:0]  ex_jump_new_pc_pc_mux_w;              /* pipeline jump to new pc */
wire [4:0]   ex_inst_rs1_hazard_w;                 /* instruction register port1 to hazard */
wire [4:0]   ex_inst_rs2_hazard_w;                 /* instruction register port2 to hazard */
wire         ex_write_csr_en_id_w;                 /* write csr enable */
wire [11:0]  ex_write_csr_addr_id_w;               /* write csr address */
wire [31:0]  ex_write_csr_data_id_w;               /* write csr data */
wire         ex_mul_div_pp_stall_hazard_w;         /* hazards signal for multipiler and divider */
wire [63:0]  ex_minstret_count_mem_w;              /* machine instructions-retired counter for ex */
wire [8*3:1] ex_inst_debug_str_mem_w;              /* riscv instruction debug string name */

// access memory stage
wire [31:0]  mem_cycle_count_wb_w;                   /* MEM/WB to other  */
wire [31:0]  mem_pc_plus4_wb_w;                      /* pc plus 4 to next stage */
wire [4:0]   mem_write_dest_register_index_wb_w;     /* write register file index */
wire         mem_write_register_en_wb_w;             /* write register enable */
wire [31:0]  mem_read_mem_data_wb_w;                 /* access memory read data to write back */
wire [31:0]  mem_alu_result_direct_wb_w;             /* excute stage direct send data to wb stage */
wire [1:0]   mem_wb_result_src_wb_w;                 /* wb stage select data write to register */
wire [31:0]  mem_alu_addr_calcul_result_mem_ex_w;    /* data hazard connect result to execute */
wire [4:0]   mem_write_dest_register_index_hazard_w; /* data hazard connect register index to hazard */
wire         mem_write_register_en_hazard_w;         /* data hazard connect register write enable to hazard */
wire [63:0]  mem_minstret_count_wb_w;                /* machine instructions-retired counter for mem */
wire [8*3:1] mem_inst_debug_str_wb_w;                /* riscv instruction debug string nane */

// write back stage
wire [31:0]  mem_cycle_count_end_check_w;           /* MEM/WB output pc check */
wire [8*3:1] mem_instruction_name_check_w;          /* MEM/WB output inst name check */
wire [4:0]   wb_write_dest_register_index_id_w;     /* write register file index */
wire         wb_write_register_en_id_w;             /* enable write register file */
wire [31:0]  wb_sel_result_to_register_id_w;        /* write the data to register file*/
wire [31:0]  wb_sel_result_to_register_ex_w;        /* data hazard connect regsiter data to execute */
wire [4:0]   wb_write_dest_register_index_hazard_w; /* data hazard connect register index to hazard */
wire         wb_write_register_en_hazard_w;         /* data hazard connect rd enable to hazard */
wire [63:0]  wb_minstret_count_if_w;                /* machine instructions-retired counter for wb */

// hazard unit
wire         hazard_flush_pc_if_reg_w;      /* hazard flush pc if stage register */
wire         hazard_flush_if_id_reg_w;      /* hazard flush if id register */
wire         hazard_flush_id_ex_reg_w;      /* hazard flush id ex register */
wire         hazard_flush_ex_mem_reg_w;     /* hazard fluse ex mem stage register */
wire         hazard_flush_mem_wb_reg_w;     /* hazard fluse mem wb stage register */
wire         hazard_stall_pc_if_reg_w;      /* hazard stall pipeline pc if register*/
wire [1:0]   hazard_ctrl_ex_rs1data_sel_src_w;    /* hazards control execute satge rs1 input data sources */
wire [1:0]   hazard_ctrl_ex_rs2data_sel_src_w;    /* hazards control execute satge rs2 input data sources */
wire         hazard_stall_if_id_reg_w;            /* hazards for flush id ex stage register */
wire         hazard_stall_id_ex_reg_w;            /* hazards for stall id ex stage register */
wire         hazard_stall_ex_mem_reg_w;           /* hazards for stall ex mem stage register */
wire         hazard_stall_mem_wb_reg_w;           /* hazards for stall mem wb stage register */

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
    .ex_pc_jump_en_pc_mux         (ex_pc_jump_en_pc_mux_w),
    .ex_jump_new_pc_pc_mux        (ex_jump_new_pc_pc_mux_w),
    .hazard_stall_pc_if_reg       (hazard_stall_pc_if_reg_w),
    .hazard_flush_pc_if_reg       (hazard_flush_pc_if_reg_w),

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
    .hazard_flush_if_id_reg       (hazard_flush_if_id_reg_w),
    .hazard_stall_if_id_reg       (hazard_stall_if_id_reg_w),

    .if_cycle_count_id            (if_cycle_count_id_w),
    .if_instruction_id            (if_instruction_id_w),
    .if_pc_plus4_pc_gen           (if_pc_plus4_pc_gen_w),
    .if_pc_plus4_id               (if_pc_plus4_id_w),
    .if_current_pc_id             (if_current_pc_id_w),
    .if_minstret_count_id         (if_minstret_count_id_w)  //O
);

//--------------------------------------------------------------------------
// Design: instruction decoder instaniate
//--------------------------------------------------------------------------
if_id_stage if_id_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .if_cycle_count_id           (if_cycle_count_id_w),
    .if_instruction_id           (if_instruction_id_w),
    .if_pc_plus4_id              (if_pc_plus4_id_w),
    .wb_write_register_dest_id   (wb_write_dest_register_index_id_w),
    .wb_write_register_data_id   (wb_sel_result_to_register_id_w),
    .wb_write_register_en_id     (wb_write_register_en_id_w),
    .if_current_pc_id            (if_current_pc_id_w),
    .hazard_flush_id_ex_reg      (hazard_flush_id_ex_reg_w),
    .dm_access_gprs_index_hart   (dm_access_gprs_index_hart),
    .dm_write_gprs_data_hart     (dm_write_gprs_data_hart),
    .dm_write_gprs_en_hart       (dm_write_gprs_en_hart),
    .ex_write_csr_en_id          (ex_write_csr_en_id_w),
    .ex_write_csr_addr_id        (ex_write_csr_addr_id_w),
    .ex_write_csr_data_id        (ex_write_csr_data_id_w),
    .hazard_stall_id_ex_reg      (hazard_stall_id_ex_reg_w),
    .if_minstret_count_id        (if_minstret_count_id_w),  //I
    .wb_minstret_count_if        (wb_minstret_count_if_w),  //I

    .id_cycle_count_ex     (id_cycle_count_ex_w),
    .id_pc_plus4_ex        (id_pc_plus4_ex_w),
    .id_read_rs1_data_ex   (id_read_rs1_data_ex_w),
    .id_read_rs2_data_ex   (id_read_rs2_data_ex_w),
    .id_imm_exten_data_ex  (id_imm_exten_data_ex_w),
    .id_write_dest_register_index_ex (id_write_dest_register_index_ex_w),
    .id_write_register_en_ex   (id_write_register_en_ex_w),
    .id_inst_encoding_ex       (id_inst_encoding_ex_w),
    .id_mem_write_en_ex        (id_mem_write_en_ex_w),
    .id_mem_oper_size_ex       (id_mem_oper_size_ex_w),
    .id_current_pc_ex          (id_current_pc_ex_w),
    .id_rs2_shamt_ex           (id_rs2_shamt_ex_w),
    .id_wb_result_src_ex       (id_wb_result_src_ex_w),
    .id_sel_imm_rs2data_alu_ex (id_sel_imm_rs2data_alu_ex_w),
    .id_pc_jump_en_ex          (id_pc_jump_en_ex_w),
    .id_pc_branch_en_ex        (id_pc_branch_en_ex_w),
    .id_inst_rs1_ex            (id_inst_rs1_w),
    .id_inst_rs2_ex            (id_inst_rs2_w),
    .hart_result_read_gprs_dm  (hart_result_read_gprs_dm),
    .id_csr_read_data_ex       (id_csr_read_data_ex_w),
    .id_csr_write_addr_ex      (id_csr_write_addr_ex_w),
    .id_csr_write_en_ex        (id_csr_write_en_ex_w),
    .id_rs1_uimm_ex            (id_rs1_uimm_ex_w),
    .id_csr_write_en_hazard    (id_csr_write_en_hazard_w),
    .id_csr_write_done_hazard  (id_csr_write_done_hazard_w),
    .id_mul_div_pp_stall_ex    (id_mul_div_pp_stall_ex_w),
    .id_minstret_count_ex      (id_minstret_count_ex_w),  //O
    .id_inst_debug_str_ex      (id_inst_debug_str_ex_w)

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
    .id_write_register_en_ex   (id_write_register_en_ex_w),
    .id_inst_encoding_ex       (id_inst_encoding_ex_w),
    .id_mem_write_en_ex        (id_mem_write_en_ex_w),
    .id_mem_oper_size_ex       (id_mem_oper_size_ex_w),
    .id_current_pc_ex          (id_current_pc_ex_w),
    .id_rs2_shamt_ex           (id_rs2_shamt_ex_w),
    .id_wb_result_src_ex       (id_wb_result_src_ex_w),
    .id_sel_imm_rs2data_alu_ex (id_sel_imm_rs2data_alu_ex_w),
    .id_pc_jump_en_ex          (id_pc_jump_en_ex_w),
    .id_pc_branch_en_ex        (id_pc_branch_en_ex_w),
    .mem_alu_addr_calcul_result_mem_ex (mem_alu_addr_calcul_result_mem_ex_w),
    .wb_sel_result_to_register_ex      (wb_sel_result_to_register_ex_w),
    .hazard_ctrl_ex_rs1data_sel_src    (hazard_ctrl_ex_rs1data_sel_src_w),
    .hazard_ctrl_ex_rs2data_sel_src    (hazard_ctrl_ex_rs2data_sel_src_w),
    .id_inst_rs1_ex                    (id_inst_rs1_w),
    .id_inst_rs2_ex                    (id_inst_rs2_w),
    .id_csr_read_data_ex               (id_csr_read_data_ex_w),
    .id_csr_write_addr_ex              (id_csr_write_addr_ex_w),
    .id_csr_write_en_ex                (id_csr_write_en_ex_w),
    .id_rs1_uimm_ex                    (id_rs1_uimm_ex_w),
    .id_mul_div_pp_stall_ex            (id_mul_div_pp_stall_ex_w),
    .hazard_flush_ex_mem_reg           (hazard_flush_ex_mem_reg_w),
    .hazard_stall_ex_mem_reg           (hazard_stall_ex_mem_reg_w),
    .id_minstret_count_ex              (id_minstret_count_ex_w),  //I

    .id_inst_debug_str_ex      (id_inst_debug_str_ex_w),

    .ex_cycle_count_mem    (ex_cycle_count_mem_w),
    .ex_pc_plus4_mem       (ex_pc_plus4_mem_w),
    .ex_write_dest_register_index_mem    (ex_write_dest_register_index_mem_w),
    .ex_write_register_en_mem            (ex_write_register_en_mem_w),
    .ex_alu_addr_calcul_result_mem       (ex_alu_addr_calcul_result_mem_w),
    .ex_write_rs2_data_mem               (ex_write_rs2_data_mem_w),
    .ex_mem_write_en_mem                 (ex_mem_write_en_mem_w),
    .ex_mem_oper_size_mem                (ex_mem_oper_size_mem_w),
    .ex_wb_result_src_mem                (ex_wb_result_src_mem_w),
    .ex_pc_jump_en_pc_mux                (ex_pc_jump_en_pc_mux_w),
    .ex_jump_new_pc_pc_mux               (ex_jump_new_pc_pc_mux_w),
    .ex_inst_rs1_hazard                  (ex_inst_rs1_hazard_w),
    .ex_inst_rs2_hazard                  (ex_inst_rs2_hazard_w),
    .ex_write_csr_en_id                  (ex_write_csr_en_id_w),
    .ex_write_csr_addr_id                (ex_write_csr_addr_id_w),
    .ex_write_csr_data_id                (ex_write_csr_data_id_w),
    .ex_mul_div_pp_stall_hazard          (ex_mul_div_pp_stall_hazard_w),
    .ex_minstret_count_mem               (ex_minstret_count_mem_w),  //O

    .ex_inst_debug_str_mem               (ex_inst_debug_str_mem_w)

);

//--------------------------------------------------------------------------
// Design: access memory instaniate
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
    .ex_wb_result_src_mem              (ex_wb_result_src_mem_w),
    .hazard_stall_mem_wb_reg           (hazard_stall_mem_wb_reg_w),
    .hazard_flush_mem_wb_reg           (hazard_flush_mem_wb_reg_w),
    .ex_minstret_count_mem             (ex_minstret_count_mem_w),  //I

    .ex_inst_debug_str_mem             (ex_inst_debug_str_mem_w),

    .mem_cycle_count_wb     (mem_cycle_count_wb_w),
    .mem_pc_plus4_wb        (mem_pc_plus4_wb_w),
    .mem_write_dest_register_index_wb (mem_write_dest_register_index_wb_w),
    .mem_write_register_en_wb         (mem_write_register_en_wb_w),
    .mem_read_mem_data_wb             (mem_read_mem_data_wb_w),
    .mem_alu_result_direct_wb         (mem_alu_result_direct_wb_w),
    .mem_wb_result_src_wb             (mem_wb_result_src_wb_w),
    .mem_alu_addr_calcul_result_mem_ex    (mem_alu_addr_calcul_result_mem_ex_w),
    .mem_write_dest_register_index_hazard (mem_write_dest_register_index_hazard_w),
    .mem_write_register_en_hazard         (mem_write_register_en_hazard_w),
    .mem_minstret_count_wb            (mem_minstret_count_wb_w),  //O
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
    .mem_wb_result_src_wb                (mem_wb_result_src_wb_w),
    .mem_minstret_count_wb               (mem_minstret_count_wb_w),  //I
    .mem_inst_debug_str_wb               (mem_inst_debug_str_wb_w),

    .wb_cycle_count_end     (mem_cycle_count_end_check_w),
    .wb_write_dest_register_index_id     (wb_write_dest_register_index_id_w),
    .wb_write_register_en_id             (wb_write_register_en_id_w),
    .wb_sel_result_to_register_id        (wb_sel_result_to_register_id_w),
    .wb_sel_result_to_register_ex        (wb_sel_result_to_register_ex_w),
    .wb_write_dest_register_index_hazard (wb_write_dest_register_index_hazard_w),
    .wb_write_register_en_hazard         (wb_write_register_en_hazard_w),
    .wb_minstret_count_if                (wb_minstret_count_if_w),  //O
    .wb_inst_debug_str_finish            (mem_instruction_name_check_w)
);

//--------------------------------------------------------------------------
// Design: pipeline control and data hazard signal
//--------------------------------------------------------------------------
hazard_unit hazard_unit_u(
    .ex_pc_jump_en_pc_mux        (ex_pc_jump_en_pc_mux_w),
    .ex_rs1_index_hazard         (ex_inst_rs1_hazard_w),
    .ex_rs2_index_hazard         (ex_inst_rs2_hazard_w),
    .mem_rd_index_hazard         (mem_write_dest_register_index_hazard_w),
    .mem_write_dest_en_hazard    (mem_write_register_en_hazard_w),
    .wb_rd_index_hazard          (wb_write_dest_register_index_hazard_w),
    .wb_write_dest_en_hazard     (wb_write_register_en_hazard_w),
    .id_csr_write_en_hazard      (id_csr_write_en_hazard_w),
    .id_csr_write_done_hazard    (id_csr_write_done_hazard_w),
    .ex_mul_div_pp_stall_hazard  (ex_mul_div_pp_stall_hazard_w),        // I

    .hazard_flush_pc_if_reg      (hazard_flush_pc_if_reg_w),            // 0
    .hazard_flush_if_id_reg      (hazard_flush_if_id_reg_w),
    .hazard_flush_id_ex_reg      (hazard_flush_id_ex_reg_w),
    .hazard_flush_ex_mem_reg     (hazard_flush_ex_mem_reg_w),
    .hazard_flush_mem_wb_reg     (hazard_flush_mem_wb_reg_w),
    .hazard_stall_pc_if_reg      (hazard_stall_pc_if_reg_w),
    .hazard_stall_if_id_reg      (hazard_stall_if_id_reg_w),           // O
    .hazard_stall_id_ex_reg      (hazard_stall_id_ex_reg_w),           // O
    .hazard_stall_ex_mem_reg     (hazard_stall_ex_mem_reg_w),          // 0
    .hazard_stall_mem_wb_reg     (hazard_stall_mem_wb_reg_w),          // O
    .hazard_ctrl_ex_rs1data_sel_src    (hazard_ctrl_ex_rs1data_sel_src_w),
    .hazard_ctrl_ex_rs2data_sel_src    (hazard_ctrl_ex_rs2data_sel_src_w)
);

endmodule

//--------------------------------------------------------------------------
