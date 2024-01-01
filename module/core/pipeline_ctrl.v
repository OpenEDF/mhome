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
module pipeline_ctrl
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire [31:0]  id_instruction_ctrl,

    // outputs
    output reg [2:0]   id_imm_src_ctrl,
    output reg         id_write_register_en,
    output reg [7:0]   id_inst_encoding,
    output reg         id_mem_write_en,
    output reg [1:0]   id_mem_oper_size,
    output reg         id_rs2_shamt_en,
    output reg [1:0]   id_wb_result_src,
    output reg         id_sel_imm_rs2data_alu,
    output reg         id_pc_jump_en,
    output reg         id_pc_branch_en,
    output reg         id_csr_read_en,
    output reg         id_csr_write_en,
    output reg         id_rs1_uimm_en,
    output reg         id_mul_div_pp_stall
);

//--------------------------------------------------------------------------
// Design: instruction feild internal signal
//--------------------------------------------------------------------------
wire [6:0] inst_opcode;
wire [4:0] inst_rd;
wire [2:0] inst_funct3;
wire [4:0] inst_rs1;
//wire [4:0] inst_rs2;
//wire [6:0] inst_funct7;
wire       inst_30bit;
wire       inst_25bit;
wire       inst_20bit_exten;

assign inst_opcode = id_instruction_ctrl[6:0];
assign inst_rd = id_instruction_ctrl[11:7];
assign inst_funct3 = id_instruction_ctrl[14:12];
assign inst_rs1 = id_instruction_ctrl[19:15];
//assign inst_rs2 = id_instruction_ctrl[24:20];
//assign inst_funct7 = id_instruction_ctrl[31:25];
assign inst_30bit = id_instruction_ctrl[30];
assign inst_25bit = id_instruction_ctrl[25];
assign inst_20bit_exten = id_instruction_ctrl[20];

//--------------------------------------------------------------------------
// Design: Anslyze the corresponding control signal according to each
//         insstruction
//--------------------------------------------------------------------------
always @(id_instruction_ctrl
         or inst_funct3
         or inst_opcode
         or inst_30bit
         or inst_20bit_exten
         or inst_rd
         or inst_rs1
         or inst_25bit) begin
    /* default value, TODO: deleted it */
    begin: def_val
        id_imm_src_ctrl <= `R_TYPE_INST;
        id_write_register_en <= `PP_WRITE_DEST_REG_DISABLE;
        id_inst_encoding <= `RV32_ILLEGAL_INST;
        id_mem_write_en <= `MEM_READ;
        id_mem_oper_size <= `MEM_OPER_WORD;
        id_rs2_shamt_en <= `RS2_SHAMT_DISABLE;
        id_wb_result_src <= `WB_SEL_ALU_RESULT;
        id_sel_imm_rs2data_alu <= `ALU_SEL_RS2DATA_INPUT;
        id_pc_jump_en <= `PP_JUMP_DISABLE;
        id_pc_branch_en <= `PP_BRANCH_DISABLE;
        id_csr_read_en  <= `PP_REWAD_CSR_DISABLE;
        id_csr_write_en <= `PP_WRITE_CSR_DISABLE;
        id_rs1_uimm_en  <= `RS1_UIMM_DISABLE;
        id_mul_div_pp_stall <= `INST_MUL_DIV_PP_STALL_DISABLE;
    end
    case (inst_opcode)
        `OPCODE_LUI_U: begin
            id_imm_src_ctrl <= `U_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_inst_encoding <= `RV32_BASE_INST_LUI;
        end
        `OPCODE_AUIPC_U: begin
            id_imm_src_ctrl <= `U_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_inst_encoding <= `RV32_BASE_INST_AUIPC;
        end
        `OPCODE_JAL_J: begin
            id_imm_src_ctrl <= `J_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_pc_jump_en <= `PP_JUMP_ENABLE;
            id_wb_result_src <= `WB_SEL_PCP4_RESULT;
            id_inst_encoding <= `RV32_BASE_INST_JAL;
        end
        `OPCODE_JALR_I: begin
            id_imm_src_ctrl <= `I_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_pc_jump_en <= `PP_JUMP_ENABLE;
            id_wb_result_src <= `WB_SEL_PCP4_RESULT;
            id_inst_encoding <= `RV32_BASE_INST_JALR;
        end
        `OPCODE_BRANCH_B: begin
            id_imm_src_ctrl <= `B_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_DISABLE;
            id_pc_branch_en <= `PP_BRANCH_ENABLE;
            case (inst_funct3)
                3'b000: id_inst_encoding <= `RV32_BASE_INST_BEQ;
                3'b001: id_inst_encoding <= `RV32_BASE_INST_BNE;
                3'b100: id_inst_encoding <= `RV32_BASE_INST_BLT;
                3'b101: id_inst_encoding <= `RV32_BASE_INST_BGE;
                3'b110: id_inst_encoding <= `RV32_BASE_INST_BLTU;
                3'b111: id_inst_encoding <= `RV32_BASE_INST_BGEU;
                default: id_inst_encoding <= `RV32_ILLEGAL_INST;
            endcase
        end
        `OPCODE_LOAD_I: begin
            id_imm_src_ctrl <= `I_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_wb_result_src <= `WB_SEL_MEM_RESULT;
            id_mem_oper_size <= `MEM_OPER_WORD;
            id_mem_write_en <= `MEM_READ;
            case (inst_funct3)
                3'b000: begin
                    id_inst_encoding <= `RV32_BASE_INST_LB;
                    id_mem_oper_size <= `MEM_OPER_BYTE;
                end
                3'b001: begin
                    id_inst_encoding <= `RV32_BASE_INST_LH;
                    id_mem_oper_size <= `MEM_OPER_HALFWORD;
                end
                3'b010: begin
                    id_inst_encoding <= `RV32_BASE_INST_LW;
                    id_mem_oper_size <= `MEM_OPER_WORD;
                end
                3'b100: begin
                    id_inst_encoding <= `RV32_BASE_INST_LBU;
                    id_mem_oper_size <= `MEM_OPER_BYTE;
                end
                3'b101: begin
                    id_inst_encoding <= `RV32_BASE_INST_LHU;
                    id_mem_oper_size <= `MEM_OPER_HALFWORD;
                end
                default: begin
                    id_inst_encoding <= `RV32_ILLEGAL_INST;
                    id_mem_oper_size <= `MEM_OPER_WORD;
                end
            endcase
         end
        `OPCODE_STORE_S: begin
            id_imm_src_ctrl <= `S_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_DISABLE;
            id_mem_write_en <= `MEM_WRITE;
            case (inst_funct3)
                3'b000: begin
                    id_inst_encoding <= `RV32_BASE_INST_SB;
                    id_mem_oper_size <= `MEM_OPER_BYTE;
                end
                3'b001: begin
                    id_inst_encoding <= `RV32_BASE_INST_SH;
                    id_mem_oper_size <= `MEM_OPER_HALFWORD;
                end
                3'b010: begin
                    id_inst_encoding <= `RV32_BASE_INST_SW;
                    id_mem_oper_size <= `MEM_OPER_WORD;
                end
                default: id_inst_encoding <= `RV32_ILLEGAL_INST;
            endcase
         end
        `OPCODE_ALU_I: begin
            id_imm_src_ctrl <= `I_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_wb_result_src <= `WB_SEL_ALU_RESULT;
            id_sel_imm_rs2data_alu <= `ALU_SEL_IMM_INPUT;
            id_rs2_shamt_en <= `RS2_SHAMT_DISABLE;
            case (inst_funct3)
                3'b000: id_inst_encoding <= `RV32_BASE_INST_ADDI;
                3'b010: id_inst_encoding <= `RV32_BASE_INST_SLTI;
                3'b011: id_inst_encoding <= `RV32_BASE_INST_SLTIU;
                3'b100: id_inst_encoding <= `RV32_BASE_INST_XORI;
                3'b110: id_inst_encoding <= `RV32_BASE_INST_ORI;
                3'b111: id_inst_encoding <= `RV32_BASE_INST_ANDI;
                3'b001: begin
                    id_inst_encoding <= `RV32_BASE_INST_SLLI;
                    id_rs2_shamt_en <= `RS2_SHAMT_ENABLE;
                end
                3'b101: begin
                    if (inst_30bit)
                        id_inst_encoding <= `RV32_BASE_INST_SRAI;
                    else
                        id_inst_encoding <= `RV32_BASE_INST_SRLI;
                    id_rs2_shamt_en <= `RS2_SHAMT_ENABLE;
                end
                default: begin
                    id_inst_encoding <= `RV32_ILLEGAL_INST;
                    id_rs2_shamt_en <= `RS2_SHAMT_DISABLE;
                end
            endcase
        end
        `OPCODE_ALU_R: begin
            id_imm_src_ctrl <= `R_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_wb_result_src <= `WB_SEL_ALU_RESULT;
            id_sel_imm_rs2data_alu <= `ALU_SEL_RS2DATA_INPUT;
            case ({inst_30bit, inst_25bit, inst_funct3})
                5'b00000: id_inst_encoding  <= `RV32_BASE_INST_ADD;
                5'b10000: id_inst_encoding  <= `RV32_BASE_INST_SUB;
                5'b00001: id_inst_encoding  <= `RV32_BASE_INST_SLL;
                5'b00010: id_inst_encoding  <= `RV32_BASE_INST_SLT;
                5'b00011: id_inst_encoding  <= `RV32_BASE_INST_SLTU;
                5'b00100: id_inst_encoding  <= `RV32_BASE_INST_XOR;
                5'b00101: id_inst_encoding  <= `RV32_BASE_INST_SRL;
                5'b10101: id_inst_encoding  <= `RV32_BASE_INST_SRA;
                5'b00110: id_inst_encoding  <= `RV32_BASE_INST_OR;
                5'b00111: id_inst_encoding  <= `RV32_BASE_INST_AND;
                /* TODO: optimization */
                5'b01000: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_MUL;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                5'b01001: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_MULH;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                5'b01010: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_MULHSU;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                5'b01011: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_MULHU;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                5'b01100: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_DIV;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                5'b01101: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_DIVU;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                5'b01110: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_REM;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                5'b01111: begin
                    id_inst_encoding        <= `RV32_M_STAND_INST_REMU;
                    id_mul_div_pp_stall     <= `INST_MUL_DIV_PP_STALL_ENABLE;
                end
                default:  id_inst_encoding  <= `RV32_ILLEGAL_INST;
            endcase
        end
        `OPCODE_FENCE_I: begin
            id_imm_src_ctrl        <= `I_TYPE_INST;
            id_write_register_en   <= `PP_WRITE_DEST_REG_ENABLE;
            id_wb_result_src       <= `WB_SEL_ALU_RESULT;
            id_sel_imm_rs2data_alu <= `ALU_SEL_IMM_INPUT;
            case (inst_funct3)
                3'b000: begin
                    id_inst_encoding  <= `RV32_BASE_INST_FENCE;
                end
                3'b001: begin
                    id_inst_encoding  <= `RV32_ZIFEN_STAND_INST_FENCE_I;
                end
                default: begin 
                    id_inst_encoding  <= `RV32_ILLEGAL_INST;
                end
            endcase
        end
        /* system operation: TODO: design redundancy */
        `OPCODE_SYS_I: begin
            id_imm_src_ctrl      <= `I_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_ENABLE;
            id_csr_write_en      <= `PP_WRITE_CSR_ENABLE;
            id_csr_read_en       <= `PP_REWAD_CSR_ENABLE;
            id_rs1_uimm_en       <= `RS1_UIMM_DISABLE;
            id_wb_result_src     <= `WB_SEL_ALU_RESULT;
            case(inst_funct3)
                3'b000: begin
                    id_write_register_en <= `PP_WRITE_DEST_REG_DISABLE;
                    if (inst_20bit_exten) begin
                        id_inst_encoding <= `RV32_BASE_INST_ECALL;
                        /* TODO: connect branch */
                    end else begin
                        id_inst_encoding <= `RV32_BASE_INST_EBREAK;
                    end
                end
                3'b001: begin
                    id_inst_encoding <= `RV32_ZICSR_STAND_INST_CSRRW;
                    if (inst_rd == 5'b00000) begin
                       id_csr_read_en <= `PP_REWAD_CSR_DISABLE;
                    end else begin
                       id_csr_read_en <= `PP_REWAD_CSR_ENABLE;
                    end
                end
                3'b010: begin
                    id_inst_encoding <= `RV32_ZICSR_STAND_INST_CSRRS;
                    if (inst_rs1 == 5'b00000) begin
                        id_csr_write_en <= `PP_WRITE_CSR_DISABLE;
                    end else begin
                        id_csr_write_en <= `PP_WRITE_CSR_ENABLE;
                    end
                end
                3'b011: begin
                    id_inst_encoding <= `RV32_ZICSR_STAND_INST_CSRRC;
                    if (inst_rs1 == 5'b00000) begin
                        id_csr_write_en <= `PP_WRITE_CSR_DISABLE;
                    end else begin
                        id_csr_write_en <= `PP_WRITE_CSR_ENABLE;
                    end
                end
                3'b101: begin
                    id_inst_encoding <= `RV32_ZICSR_STAND_INST_CSRRWI;
                    id_rs1_uimm_en   <= `RS1_UIMM_ENABLE;
                    if (inst_rd == 5'b00000) begin
                       id_csr_read_en <= `PP_REWAD_CSR_DISABLE;
                    end else begin
                       id_csr_read_en <= `PP_REWAD_CSR_ENABLE;
                    end
                end
                3'b110: begin
                    id_inst_encoding <= `RV32_ZICSR_STAND_INST_CSRRSI;
                    id_rs1_uimm_en   <= `RS1_UIMM_ENABLE;
                    if (inst_rs1 == 5'b00000) begin
                        id_csr_write_en <= `PP_WRITE_CSR_DISABLE;
                    end else begin
                        id_csr_write_en <= `PP_WRITE_CSR_ENABLE;
                    end
                end
                3'b111: begin
                    id_inst_encoding <= `RV32_ZICSR_STAND_INST_CSRRCI;
                    id_rs1_uimm_en   <= `RS1_UIMM_ENABLE;
                    if (inst_rs1 == 5'b00000) begin
                        id_csr_write_en <= `PP_WRITE_CSR_DISABLE;
                    end else begin
                        id_csr_write_en <= `PP_WRITE_CSR_ENABLE;
                    end
                end
                default: begin
                    id_inst_encoding <= `RV32_ILLEGAL_INST;
                end
            endcase
        end
        default: begin
            id_imm_src_ctrl <= `R_TYPE_INST;
            id_write_register_en <= `PP_WRITE_DEST_REG_DISABLE;
            id_inst_encoding <= `RV32_ILLEGAL_INST;
            id_mem_write_en <= `MEM_READ;
            id_mem_oper_size <= `MEM_OPER_WORD;
            id_rs2_shamt_en <= `RS2_SHAMT_DISABLE;
            id_wb_result_src <= `WB_SEL_ALU_RESULT;
            id_sel_imm_rs2data_alu <= `ALU_SEL_RS2DATA_INPUT;
            id_pc_jump_en <= `PP_JUMP_DISABLE;
            id_pc_branch_en <= `PP_BRANCH_DISABLE;
            id_csr_read_en  <= `PP_REWAD_CSR_DISABLE;
            id_csr_write_en <= `PP_WRITE_CSR_DISABLE;
            id_rs1_uimm_en  <= `RS1_UIMM_DISABLE;
            id_csr_read_en  <= `PP_REWAD_CSR_DISABLE;
            id_mul_div_pp_stall <= `INST_MUL_DIV_PP_STALL_DISABLE;
        end
    endcase
end

endmodule
//--------------------------------------------------------------------------
