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
module if_id_stage
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [31:0]  if_cycle_count_id,
    input wire [31:0]  if_instruction_id,
    input wire [31:0]  if_pc_plus4_id,
    input wire [4:0]   wb_write_register_dest_id,
    input wire [31:0]  wb_write_register_data_id,
    input wire         wb_write_register_en_id,
    input wire [31:0]  if_current_pc_id,
    input wire         hazard_flush_id_ex_reg,
    input wire [4:0]   dm_access_gprs_index_hart,
    input wire [31:0]  dm_write_gprs_data_hart,
    input wire         dm_write_gprs_en_hart,
    input wire         ex_write_csr_en_id,
    input wire [11:0]  ex_write_csr_addr_id,
    input wire [31:0]  ex_write_csr_data_id,
    input wire         hazard_stall_id_ex_reg,
    input wire [63:0]  if_minstret_count_id,
    input wire [63:0]  wb_minstret_count_if,

    // outputs
    output reg [31:0]  id_cycle_count_ex,
    output reg [31:0]  id_pc_plus4_ex,
    output reg [31:0]  id_read_rs1_data_ex,
    output reg [31:0]  id_read_rs2_data_ex,
    output reg [31:0]  id_imm_exten_data_ex,
    output reg [4:0]   id_write_dest_register_index_ex,
    output reg         id_write_register_en_ex,
    output reg [7:0]   id_inst_encoding_ex,
    output reg         id_mem_write_en_ex,
    output reg [1:0]   id_mem_oper_size_ex,
    output reg [31:0]  id_current_pc_ex,
    output reg [4:0]   id_rs2_shamt_ex,
    output reg [1:0]   id_wb_result_src_ex,
    output reg         id_sel_imm_rs2data_alu_ex,
    output reg         id_pc_jump_en_ex,
    output reg         id_pc_branch_en_ex,
    output reg [4:0]   id_inst_rs1_ex,
    output reg [4:0]   id_inst_rs2_ex,
    output wire [31:0] hart_result_read_gprs_dm,
    output reg [31:0]  id_csr_read_data_ex,
    output reg [11:0]  id_csr_write_addr_ex,
    output reg         id_csr_write_en_ex,
    output reg [31:0]  id_rs1_uimm_ex,
    output wire        id_csr_write_en_hazard,
    output wire        id_csr_write_done_hazard,
    output reg         id_mul_div_pp_stall_ex,
    output reg [63:0]  id_minstret_count_ex,
    output reg [8*3:1] id_inst_debug_str_ex
);

//--------------------------------------------------------------------------
// Design: module inter signle
//--------------------------------------------------------------------------
wire [31:0] id_read_rs1_data_ex_w;
wire [31:0] id_read_rs2_data_ex_w;
wire [4:0]  id_inst_rs1_w;
wire [4:0]  id_inst_rs2_w;
wire [2:0]  id_imm_exten_src_w;
reg  [31:0] id_imm_exten_data_r;
wire [31:0] inst;
wire [7:0]  id_inst_encoding_ex_w;
wire        id_write_register_en_ex_w;
wire [4:0]  id_write_dest_register_index_ex_w;
wire        id_mem_write_en_ex_w;
wire [1:0]  id_mem_oper_size_ex_w;
reg  [4:0]  id_rs2_shamt_ex_r;
wire        id_rs2_shamt_en_w;
wire [1:0]  id_wb_result_src_w;
wire        id_sel_imm_rs2data_alu_w;
wire        id_pc_jump_en_w;
wire        id_pc_branch_en_w;
reg [31:0]  id_read_rs1_data_hazard_r;
reg [31:0]  id_read_rs2_data_hazard_r;
wire        id_csr_read_en_w;
wire        id_csr_write_en_w;
wire        id_rs1_uimm_en_w;
wire [11:0] id_csr_read_addr_w;
wire [11:0] id_csr_write_addr_w;
wire [31:0] csrs_read_csr_data_w;
reg  [31:0] id_rs1_uimm_ex_r;
wire        id_csr_write_done_hazard_w;
wire        id_mul_div_pp_stall_w;
reg  [8*3:1] id_inst_debug_str_r;

assign id_inst_rs1_w = if_instruction_id[19:15];
assign id_inst_rs2_w = if_instruction_id[24:20];
assign id_write_dest_register_index_ex_w = if_instruction_id[11:7];
assign inst = if_instruction_id;
assign id_csr_read_addr_w = if_instruction_id[31:20];
assign id_csr_write_addr_w = if_instruction_id[31:20];
assign id_csr_write_en_hazard = id_csr_write_en_w;
assign id_csr_write_done_hazard = id_csr_write_done_hazard_w;

localparam R_TYPE = `R_TYPE_INST;
localparam I_TYPE = `I_TYPE_INST;
localparam S_TYPE = `S_TYPE_INST;
localparam B_TYPE = `B_TYPE_INST;
localparam U_TYPE = `U_TYPE_INST;
localparam J_TYPE = `J_TYPE_INST;

//--------------------------------------------------------------------------
// Design: pipeline cycle couter logic
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        id_cycle_count_ex <= `CYCLE_COUNT_RST;
    end else begin
        id_cycle_count_ex <= if_cycle_count_id;
    end
end

//--------------------------------------------------------------------------
// Design: riscv immediate encoding variants
//         R-Type is no immediate
//--------------------------------------------------------------------------
always @(id_imm_exten_src_w or inst) begin
    case (id_imm_exten_src_w)
        I_TYPE:
           id_imm_exten_data_r <= {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
        S_TYPE:
           id_imm_exten_data_r <= {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
        B_TYPE:
           id_imm_exten_data_r <= {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        U_TYPE:
           id_imm_exten_data_r <= {inst[31], inst[30:20], inst[19:12], {12{1'b0}}};
        J_TYPE:
           id_imm_exten_data_r <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
        default:
           id_imm_exten_data_r <= 32'h0000_0000;
    endcase
end

//--------------------------------------------------------------------------
// Design: riscv instruction debug module
//--------------------------------------------------------------------------
always @(id_inst_encoding_ex_w) begin
    id_inst_debug_str_r = "ieg";
    case (id_inst_encoding_ex_w)
        `RV32_BASE_INST_LUI:                id_inst_debug_str_r = "lui";
        `RV32_BASE_INST_AUIPC:              id_inst_debug_str_r = "aui";
        `RV32_BASE_INST_JAL:                id_inst_debug_str_r = "jal";
        `RV32_BASE_INST_JALR:               id_inst_debug_str_r = "jar";
        `RV32_BASE_INST_BEQ:                id_inst_debug_str_r = "beq";
        `RV32_BASE_INST_BNE:                id_inst_debug_str_r = "bne";
        `RV32_BASE_INST_BLT:                id_inst_debug_str_r = "blt";
        `RV32_BASE_INST_BGE:                id_inst_debug_str_r = "bge";
        `RV32_BASE_INST_BLTU:               id_inst_debug_str_r = "blu";
        `RV32_BASE_INST_BGEU:               id_inst_debug_str_r = "bgu";
        `RV32_BASE_INST_LB:                 id_inst_debug_str_r = "l_b";
        `RV32_BASE_INST_LH:                 id_inst_debug_str_r = "l_h";
        `RV32_BASE_INST_LW:                 id_inst_debug_str_r = "l_w";
        `RV32_BASE_INST_LBU:                id_inst_debug_str_r = "lbu";
        `RV32_BASE_INST_LHU:                id_inst_debug_str_r = "lhu";
        `RV32_BASE_INST_SB:                 id_inst_debug_str_r = "s_b";
        `RV32_BASE_INST_SH:                 id_inst_debug_str_r = "s_h";
        `RV32_BASE_INST_SW:                 id_inst_debug_str_r = "s_w";
        `RV32_BASE_INST_ADDI:               id_inst_debug_str_r = "adi";
        `RV32_BASE_INST_SLTI:               id_inst_debug_str_r = "sli";
        `RV32_BASE_INST_SLTIU:              id_inst_debug_str_r = "slu";
        `RV32_BASE_INST_XORI:               id_inst_debug_str_r = "xoi";
        `RV32_BASE_INST_ORI:                id_inst_debug_str_r = "ori";
        `RV32_BASE_INST_ANDI:               id_inst_debug_str_r = "ani";
        `RV32_BASE_INST_SLLI:               id_inst_debug_str_r = "sli";
        `RV32_BASE_INST_SRLI:               id_inst_debug_str_r = "sri";
        `RV32_BASE_INST_SRAI:               id_inst_debug_str_r = "sai";
        `RV32_BASE_INST_ADD:                id_inst_debug_str_r = "add";
        `RV32_BASE_INST_SUB:                id_inst_debug_str_r = "sub";
        `RV32_BASE_INST_SLL:                id_inst_debug_str_r = "sll";
        `RV32_BASE_INST_SLT:                id_inst_debug_str_r = "slt";
        `RV32_BASE_INST_SLTU:               id_inst_debug_str_r = "slu";
        `RV32_BASE_INST_XOR:                id_inst_debug_str_r = "xor";
        `RV32_BASE_INST_SRL:                id_inst_debug_str_r = "srl";
        `RV32_BASE_INST_SRA:                id_inst_debug_str_r = "sra";
        `RV32_BASE_INST_OR:                 id_inst_debug_str_r = "o_r";
        `RV32_BASE_INST_AND:                id_inst_debug_str_r = "and";
        `RV32_BASE_INST_FENCE:              id_inst_debug_str_r = "fee";
        `RV32_BASE_INST_ECALL:              id_inst_debug_str_r = "eca";
        `RV32_BASE_INST_EBREAK:             id_inst_debug_str_r = "ebr";
        `RV32_ZIFEN_STAND_INST_FENCE_I:     id_inst_debug_str_r = "fei";
        `RV32_ZICSR_STAND_INST_CSRRW:       id_inst_debug_str_r = "crw";
        `RV32_ZICSR_STAND_INST_CSRRS:       id_inst_debug_str_r = "crs";
        `RV32_ZICSR_STAND_INST_CSRRC:       id_inst_debug_str_r = "crc";
        `RV32_ZICSR_STAND_INST_CSRRWI:      id_inst_debug_str_r = "cwi";
        `RV32_ZICSR_STAND_INST_CSRRSI:      id_inst_debug_str_r = "csi";
        `RV32_ZICSR_STAND_INST_CSRRCI:      id_inst_debug_str_r = "cci";
        `RV32_M_STAND_INST_MUL:             id_inst_debug_str_r = "mul";
        `RV32_M_STAND_INST_MULH:            id_inst_debug_str_r = "muh";
        `RV32_M_STAND_INST_MULHSU:          id_inst_debug_str_r = "msu";
        `RV32_M_STAND_INST_MULHU:           id_inst_debug_str_r = "mhu";
        `RV32_M_STAND_INST_DIV:             id_inst_debug_str_r = "div";
        `RV32_M_STAND_INST_DIVU:            id_inst_debug_str_r = "diu";
        `RV32_M_STAND_INST_REM:             id_inst_debug_str_r = "rem";
        `RV32_M_STAND_INST_REMU:            id_inst_debug_str_r = "reu";
        default:                            id_inst_debug_str_r = "nop";
    endcase
end

//--------------------------------------------------------------------------
// Design: output the shamt for SLLI/SRLI/SRAI
//--------------------------------------------------------------------------
always @(id_rs2_shamt_en_w or id_inst_rs2_w) begin
    if (id_rs2_shamt_en_w)
        id_rs2_shamt_ex_r <= id_inst_rs2_w;
    else
        id_rs2_shamt_ex_r <= 5'b00000;
end

//--------------------------------------------------------------------------
// Design: output the uimm for CSR immediate operand
//--------------------------------------------------------------------------
always @(id_rs1_uimm_en_w or id_inst_rs1_w) begin
    if (id_rs1_uimm_en_w)
        id_rs1_uimm_ex_r <= {{27{1'b0}}, id_inst_rs1_w};
    else
        id_rs1_uimm_ex_r <= 32'h0000_0000;
end

//--------------------------------------------------------------------------
// Design: write back clock hazard rs1, rs1 == 5'b0
//--------------------------------------------------------------------------
always @(*)begin
    if ((id_inst_rs1_w == wb_write_register_dest_id) && wb_write_register_en_id)
        id_read_rs1_data_hazard_r <= wb_write_register_data_id;
    else
        id_read_rs1_data_hazard_r <= id_read_rs1_data_ex_w;
end

//--------------------------------------------------------------------------
// Design: write back clock hazard rs2, rs2 == 5'b0
//--------------------------------------------------------------------------
always @(*)begin
    if ((id_inst_rs2_w == wb_write_register_dest_id) && wb_write_register_en_id)
        id_read_rs2_data_hazard_r <= wb_write_register_data_id;
    else
        id_read_rs2_data_hazard_r <= id_read_rs2_data_ex_w;
end

//--------------------------------------------------------------------------
// Design: instantiate riscv register file
//--------------------------------------------------------------------------
register_file register_file_u(
    .clk    (clk),
    .rst_n  (rst_n),
    .id_inst_read_1_src        (id_inst_rs1_w),
    .id_inst_read_2_src        (id_inst_rs2_w),
    .wb_inst_write_dest        (wb_write_register_dest_id),
    .wb_inst_write_data        (wb_write_register_data_id),
    .wb_inst_write_en          (wb_write_register_en_id),
    .dm_access_gprs_index_hart (dm_access_gprs_index_hart),
    .dm_write_gprs_data_hart   (dm_write_gprs_data_hart),
    .dm_write_gprs_en_hart     (dm_write_gprs_en_hart),

    .id_inst_read_1_data       (id_read_rs1_data_ex_w),
    .id_inst_read_2_data       (id_read_rs2_data_ex_w),
    .hart_result_read_gprs_dm  (hart_result_read_gprs_dm)
);

//--------------------------------------------------------------------------
// Design: instantiate riscv csrs module
//--------------------------------------------------------------------------
rv_csrs rv_csrs_u(
    .clk                         (clk),
    .rst_n                       (rst_n),
    .id_read_csr_addr_csrs       (id_csr_read_addr_w),
    .id_read_en_csrs             (id_csr_read_en_w),
    .id_write_csr_addr_csrs      (ex_write_csr_addr_id),
    .id_write_en_csrs            (ex_write_csr_en_id),
    .id_write_data_csrs          (ex_write_csr_data_id),
    .wb_pp_minstret_csrs         (wb_minstret_count_if[31:0]),
    .wb_pp_minstrethh_csrs       (wb_minstret_count_if[63:32]),

    .csrs_read_csr_data          (csrs_read_csr_data_w), // O
    .csr_write_done              (id_csr_write_done_hazard_w)
);

//--------------------------------------------------------------------------
// Design: instantiate riscv pipeline control module
//--------------------------------------------------------------------------
pipeline_ctrl pipeline_ctrl_u(
    .id_instruction_ctrl    (if_instruction_id),          // I

    .id_imm_src_ctrl        (id_imm_exten_src_w),         // O
    .id_write_register_en   (id_write_register_en_ex_w),
    .id_inst_encoding       (id_inst_encoding_ex_w),
    .id_mem_write_en        (id_mem_write_en_ex_w),
    .id_mem_oper_size       (id_mem_oper_size_ex_w),
    .id_rs2_shamt_en        (id_rs2_shamt_en_w),
    .id_wb_result_src       (id_wb_result_src_w),
    .id_sel_imm_rs2data_alu (id_sel_imm_rs2data_alu_w),
    .id_pc_jump_en          (id_pc_jump_en_w),
    .id_pc_branch_en        (id_pc_branch_en_w),
    .id_csr_read_en         (id_csr_read_en_w),
    .id_csr_write_en        (id_csr_write_en_w),
    .id_rs1_uimm_en         (id_rs1_uimm_en_w),
    .id_mul_div_pp_stall    (id_mul_div_pp_stall_w)
);

//--------------------------------------------------------------------------
// Design: pipeline if id stage register update
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        id_pc_plus4_ex <= 32'h0000_0000;
        id_read_rs1_data_ex <= 32'h0000_0000;
        id_read_rs2_data_ex <= 32'h0000_0000;
        id_imm_exten_data_ex <= 32'h0000_0000;
        id_inst_encoding_ex  <= `RV32_BASE_INST_ADDI;
        id_write_register_en_ex <= `PP_WRITE_DEST_REG_ENABLE;
        id_write_dest_register_index_ex <= 5'b00000;
        id_mem_write_en_ex <= `MEM_READ;
        id_mem_oper_size_ex <= `MEM_OPER_WORD;
        id_current_pc_ex <= `MHOME_START_PC;
        id_rs2_shamt_ex <= 5'b00000;
        id_wb_result_src_ex <= `WB_SEL_ALU_RESULT;
        id_sel_imm_rs2data_alu_ex <= `ALU_SEL_RS2DATA_INPUT;
        id_pc_jump_en_ex <= `PP_JUMP_DISABLE;
        id_pc_branch_en_ex <= `PP_BRANCH_DISABLE;
        id_inst_rs1_ex <= 5'b00000;
        id_inst_rs2_ex <= 5'b00000;
        id_csr_read_data_ex  <= 32'h0000_0000;
        id_csr_write_addr_ex <= 12'h000;
        id_csr_write_en_ex  <= `PP_WRITE_CSR_DISABLE;
        id_rs1_uimm_ex      <= 32'h0000_0000;
        id_mul_div_pp_stall_ex <= `INST_MUL_DIV_PP_STALL_DISABLE;
        id_minstret_count_ex   <= 64'h0000_0000_0000_0000;
        id_inst_debug_str_ex <= "adi";
    end else begin
        if (hazard_flush_id_ex_reg) begin
            id_pc_plus4_ex <= 32'h0000_0000;
            id_read_rs1_data_ex <= 32'h0000_0000;
            id_read_rs2_data_ex <= 32'h0000_0000;
            id_imm_exten_data_ex <= 32'h0000_0000;
            id_inst_encoding_ex  <= `RV32_BASE_INST_ADDI;  // nop: addi x0, x0, 0
            id_write_register_en_ex <= `PP_WRITE_DEST_REG_ENABLE;
            id_write_dest_register_index_ex <= 5'b00000;
            id_mem_write_en_ex <= `MEM_READ;
            id_mem_oper_size_ex <= `MEM_OPER_WORD;
            id_current_pc_ex <= `MHOME_START_PC;
            id_rs2_shamt_ex <= 5'b00000;
            id_wb_result_src_ex <= `WB_SEL_ALU_RESULT;
            id_sel_imm_rs2data_alu_ex <= `ALU_SEL_RS2DATA_INPUT;
            id_pc_jump_en_ex <= `PP_JUMP_DISABLE;
            id_pc_branch_en_ex <= `PP_BRANCH_DISABLE;
            id_inst_rs1_ex <= 5'b00000;
            id_inst_rs2_ex <= 5'b00000;
            id_csr_read_data_ex <= 32'h0000_0000;
            id_csr_write_addr_ex <= 12'h000;
            id_csr_write_en_ex  <= `PP_WRITE_CSR_DISABLE;
            id_rs1_uimm_ex      <= 32'h0000_0000;
            id_mul_div_pp_stall_ex <= `INST_MUL_DIV_PP_STALL_DISABLE;
            id_inst_debug_str_ex <= "adi";
        end else if (hazard_stall_id_ex_reg) begin
            id_pc_plus4_ex       <= id_pc_plus4_ex;
            id_read_rs1_data_ex  <= id_read_rs1_data_ex;
            id_read_rs2_data_ex  <= id_read_rs2_data_ex;
            id_imm_exten_data_ex <= id_imm_exten_data_ex;
            id_inst_encoding_ex  <= id_inst_encoding_ex;
            id_write_register_en_ex         <= id_write_register_en_ex;
            id_write_dest_register_index_ex <= id_write_dest_register_index_ex;
            id_mem_write_en_ex        <= id_mem_write_en_ex;
            id_mem_oper_size_ex       <= id_mem_oper_size_ex;
            id_current_pc_ex          <= id_current_pc_ex;
            id_rs2_shamt_ex           <= id_rs2_shamt_ex;
            id_wb_result_src_ex       <= id_wb_result_src_ex;
            id_sel_imm_rs2data_alu_ex <= id_sel_imm_rs2data_alu_ex;
            id_pc_jump_en_ex          <= id_pc_jump_en_ex;
            id_pc_branch_en_ex        <= id_pc_branch_en_ex;
            id_inst_rs1_ex            <= id_inst_rs1_ex;
            id_inst_rs2_ex            <= id_inst_rs2_ex;
            id_csr_read_data_ex       <= id_csr_read_data_ex;
            id_csr_write_addr_ex      <= id_csr_write_addr_ex;
            id_csr_write_en_ex        <= id_csr_write_en_ex;
            id_rs1_uimm_ex            <= id_rs1_uimm_ex;
            id_mul_div_pp_stall_ex    <= id_mul_div_pp_stall_ex;
            id_minstret_count_ex      <= id_minstret_count_ex;
            id_inst_debug_str_ex      <= id_inst_debug_str_ex;
        end else begin
            id_pc_plus4_ex <= if_pc_plus4_id;
            id_read_rs1_data_ex  <= id_read_rs1_data_hazard_r;
            id_read_rs2_data_ex  <= id_read_rs2_data_hazard_r;
            id_imm_exten_data_ex <= id_imm_exten_data_r;
            id_inst_encoding_ex  <= id_inst_encoding_ex_w;
            id_write_register_en_ex <= id_write_register_en_ex_w;
            id_write_dest_register_index_ex <= id_write_dest_register_index_ex_w;
            id_mem_write_en_ex <= id_mem_write_en_ex_w;
            id_mem_oper_size_ex <= id_mem_oper_size_ex_w;
            id_current_pc_ex <= if_current_pc_id;
            id_rs2_shamt_ex <= id_rs2_shamt_ex_r;
            id_wb_result_src_ex <= id_wb_result_src_w;
            id_sel_imm_rs2data_alu_ex <= id_sel_imm_rs2data_alu_w;
            id_pc_jump_en_ex <= id_pc_jump_en_w;
            id_pc_branch_en_ex <= id_pc_branch_en_w;
            id_inst_rs1_ex <= id_inst_rs1_w;
            id_inst_rs2_ex <= id_inst_rs2_w;
            id_csr_read_data_ex  <= csrs_read_csr_data_w;
            id_csr_write_addr_ex <= id_csr_write_addr_w;
            id_csr_write_en_ex   <= id_csr_write_en_w;
            id_rs1_uimm_ex       <= id_rs1_uimm_ex_r;
            id_mul_div_pp_stall_ex <= id_mul_div_pp_stall_w;
            id_minstret_count_ex   <= if_minstret_count_id;
            id_inst_debug_str_ex <= id_inst_debug_str_r;
        end
    end
end
endmodule
//--------------------------------------------------------------------------
