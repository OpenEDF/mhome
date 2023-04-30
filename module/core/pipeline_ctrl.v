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
    output reg [7:0]   id_inst_encoding
);

//--------------------------------------------------------------------------
// Design: internal signal
//--------------------------------------------------------------------------
wire [6:0] inst_opcode;
wire [4:0] inst_rd;
wire [2:0] inst_funct3;
wire [4:0] inst_rs1;
wire [4:0] inst_rs2;
wire [6:0] inst_funct7;
wire       inst_30bit;

assign inst_opcode = id_instruction_ctrl[6:0];
assign inst_rd = id_instruction_ctrl[11:7];
assign inst_funct3 = id_instruction_ctrl[14:12];
assign inst_rs1 = id_instruction_ctrl[19:15];
assign inst_rs2 = id_instruction_ctrl[24:20];
assign inst_funct7 = id_instruction_ctrl[31:25];
assign inst_30bit = id_instruction_ctrl[30];

//--------------------------------------------------------------------------
// Design: Anslyze the corresponding control signal according to each
//         insstruction
//--------------------------------------------------------------------------
always @(id_instruction_ctrl or inst_funct3 or inst_opcode or inst_30bit) begin
    case (inst_opcode)
        `OPCODE_LUI_U: begin
            id_imm_src_ctrl <= `U_TYPE_INST;
            id_write_register_en <= 1'b1;
            id_inst_encoding <= `RV32_BASE_INST_LUI;
        end
        `OPCODE_AUIPC_U: begin
            id_imm_src_ctrl <= `U_TYPE_INST;
            id_write_register_en <= 1'b1;
            id_inst_encoding <= `RV32_BASE_INST_AUIPC;
        end
        `OPCODE_JAL_J: begin
            id_imm_src_ctrl <= `J_TYPE_INST;
            id_write_register_en <= 1'b1;
            id_inst_encoding <= `RV32_BASE_INST_JAL;
        end
        `OPCODE_JALR_I: begin
            id_imm_src_ctrl <= `I_TYPE_INST;
            id_write_register_en <= 1'b1;
            id_inst_encoding <= `RV32_BASE_INST_JALR;
        end
        `OPCODE_ALU_I: begin
            id_imm_src_ctrl <= `I_TYPE_INST;
            id_write_register_en <= 1'b1;
            id_inst_encoding <= `RV32_BASE_INST_ADDI;
        end
        `OPCODE_LOAD_I: begin
            id_imm_src_ctrl <= `I_TYPE_INST;
            id_write_register_en <= 1'b1;
            case (inst_funct3)
                3'b000: id_inst_encoding <= `RV32_BASE_INST_LB;
                3'b001: id_inst_encoding <= `RV32_BASE_INST_LH;
                3'b010: id_inst_encoding <= `RV32_BASE_INST_LW;
                3'b100: id_inst_encoding <= `RV32_BASE_INST_LBU;
                3'b101: id_inst_encoding <= `RV32_BASE_INST_LHU;
                default: id_inst_encoding <= `RV32_ILLEGAL_INST;
            endcase
        end
        default: begin
            id_imm_src_ctrl <= `R_TYPE_INST;
            id_write_register_en <= 1'b0;
            id_inst_encoding <= `RV32_ILLEGAL_INST;
        end
    endcase
end

endmodule
//--------------------------------------------------------------------------
