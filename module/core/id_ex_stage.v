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
    input wire [4:0]   id_rs2_shamt_ex,
    input wire [1:0]   id_wb_result_src_ex,
    input wire         id_sel_imm_rs2data_alu_ex,
    input wire         id_pc_jump_en_ex,
    input wire         id_pc_branch_en_ex,
    input wire [31:0]  mem_alu_addr_calcul_result_mem_ex,
    input wire [31:0]  wb_sel_result_to_register_ex,
    input wire [1:0]   hazard_ctrl_ex_rs1data_sel_src,
    input wire [1:0]   hazard_ctrl_ex_rs2data_sel_src,
    input wire [4:0]   id_inst_rs1_ex,
    input wire [4:0]   id_inst_rs2_ex,
    input wire [31:0]  id_csr_read_data_ex,
    input wire [11:0]  id_csr_write_addr_ex,
    input wire         id_csr_write_en_ex,
    input wire [31:0]  id_rs1_uimm_ex,
    input wire         id_mul_div_pp_stall_ex,
    input wire         hazard_flush_ex_mem_reg,
    input wire         hazard_stall_ex_mem_reg,
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
    output reg [1:0]   ex_wb_result_src_mem,
    output wire        ex_pc_jump_en_pc_mux,
    output reg [31:0]  ex_jump_new_pc_pc_mux,
    output wire [4:0]  ex_inst_rs1_hazard,
    output wire [4:0]  ex_inst_rs2_hazard,
    output reg         ex_write_csr_en_id,
    output reg [11:0]  ex_write_csr_addr_id,
    output reg [31:0]  ex_write_csr_data_id,
    output reg         ex_mul_div_pp_stall_hazard,

    output reg [8*3:1] ex_inst_debug_str_mem
);

//--------------------------------------------------------------------------
// Design: pipeline instruction execution unit internal signal
//--------------------------------------------------------------------------
reg [31:0] ex_alu_addr_calcul_result_mem_r;
reg [31:0] ex_alu_oper_src2_data;
reg        ex_branch_comp_ctrl;
reg [31:0] ex_alu_oper_src1_data;
reg [31:0] ex_alu_oper_src2_data_pre;

//--------------------------------------------------------------------------
// Design: pipeline jump new pc
//--------------------------------------------------------------------------
wire [31:0] ex_jump_new_pc_auipc_inst_w;
wire [31:0] ex_jump_rs1data_imm_pc_w;
assign ex_jump_new_pc_auipc_inst_w = id_imm_exten_data_ex + id_current_pc_ex;
assign ex_jump_rs1data_imm_pc_w = id_imm_exten_data_ex + ex_alu_oper_src1_data;
assign ex_pc_jump_en_pc_mux = id_pc_jump_en_ex | (id_pc_branch_en_ex & ex_branch_comp_ctrl);

// SLLI/SRLI/SRAI shift amount
wire [4:0] shamt;
assign shamt = id_rs2_shamt_ex;

//--------------------------------------------------------------------------
// Design: pipeline data hazard slove for read rs1 and rs2 of execute stage
//--------------------------------------------------------------------------
assign ex_inst_rs1_hazard = id_inst_rs1_ex;
assign ex_inst_rs2_hazard = id_inst_rs2_ex;

//--------------------------------------------------------------------------
// Design: load copy a value from memory to register, address is base
//         address for rs1 data adding  offset
//--------------------------------------------------------------------------
wire [31:0] ex_load_address;
assign ex_load_address = ex_alu_oper_src1_data + id_imm_exten_data_ex;
// TODO: LBU LHU
//wire [31:0] ex_load_address_u;
//assign ex_load_address_u = ex_alu_oper_src1_data + $unsigned(id_imm_exten_data_ex);

//--------------------------------------------------------------------------
// Design: multipiler and divider signal
//--------------------------------------------------------------------------
reg  mul_start_r;
reg  [31:0] multiplier_r;
reg  [31:0] multiplicand_r;
wire [31:0] product_l_w;
wire [31:0] product_h_w;
wire mul_ready_w;
wire mul_div_ready;

// TODO: add divider mdoule
wire div_ready_w;
assign mul_div_ready = mul_ready_w; //| div_ready_w;

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
// Design: pipeline data hazards sloving forwarding select rs1 data source
//--------------------------------------------------------------------------
always @(hazard_ctrl_ex_rs1data_sel_src or id_read_rs1_data_ex or mem_alu_addr_calcul_result_mem_ex or wb_sel_result_to_register_ex) begin
    case (hazard_ctrl_ex_rs1data_sel_src)
        `PP_FORWARD_EX_RSXDATA_SEL_ID:
            ex_alu_oper_src1_data <= id_read_rs1_data_ex;
        `PP_FORWARD_EX_RSXDATA_SEL_MEM:
            ex_alu_oper_src1_data <= mem_alu_addr_calcul_result_mem_ex;
        `PP_FORWARD_EX_RSXDATA_SEL_WB:
            ex_alu_oper_src1_data <= wb_sel_result_to_register_ex;
        default:
            ex_alu_oper_src1_data <= 32'h0000_0000;
    endcase
end

//--------------------------------------------------------------------------
// Design: pipeline data hazards sloving forwarding select rs2 data source
//--------------------------------------------------------------------------
always @(hazard_ctrl_ex_rs2data_sel_src or id_read_rs2_data_ex or mem_alu_addr_calcul_result_mem_ex or wb_sel_result_to_register_ex) begin
    case (hazard_ctrl_ex_rs2data_sel_src)
        `PP_FORWARD_EX_RSXDATA_SEL_ID:
            ex_alu_oper_src2_data_pre <= id_read_rs2_data_ex;
        `PP_FORWARD_EX_RSXDATA_SEL_MEM:
            ex_alu_oper_src2_data_pre <= mem_alu_addr_calcul_result_mem_ex;
        `PP_FORWARD_EX_RSXDATA_SEL_WB:
            ex_alu_oper_src2_data_pre <= wb_sel_result_to_register_ex;
        default:
            ex_alu_oper_src2_data_pre <= 32'h0000_0000;
    endcase
end

//--------------------------------------------------------------------------
// Design: hazard for multiplier and divider, stall pipeline until ready is
//         high level
//--------------------------------------------------------------------------
always @(id_mul_div_pp_stall_ex or mul_div_ready) begin
    if (id_mul_div_pp_stall_ex && ~mul_div_ready) begin
        ex_mul_div_pp_stall_hazard <= `EX_MUL_DIV_PP_STALL_ENABLE;
    end else begin
        ex_mul_div_pp_stall_hazard <= `EX_MUL_DIV_PP_STALL_DISABLE;
    end
end

//--------------------------------------------------------------------------
// Design: ALU operational data source control
//--------------------------------------------------------------------------
always @(id_sel_imm_rs2data_alu_ex or ex_alu_oper_src2_data_pre or id_imm_exten_data_ex) begin
    if (id_sel_imm_rs2data_alu_ex) begin
        ex_alu_oper_src2_data <= id_imm_exten_data_ex;
    end else begin
        ex_alu_oper_src2_data <= ex_alu_oper_src2_data_pre;
    end
end

//--------------------------------------------------------------------------
// Design: riscv pipeline execution arithmetic and instruction processing
//--------------------------------------------------------------------------
//always @(*) begin //TODO: diifferent?
//always @(id_inst_encoding_ex or id_imm_exten_data_ex or id_read_rs1_data_ex or id_current_pc_ex or ex_jump_new_pc_auipc_inst_w or ex_alu_oper_src2_data) begin
always @(*) begin
    /* default value */
    begin
        ex_jump_new_pc_pc_mux <= 32'h0000_0000;
        ex_alu_addr_calcul_result_mem_r <= 32'h0000_0000;
        ex_branch_comp_ctrl <= `PP_BRANCH_COMP_DISABLE;
        ex_write_csr_en_id   <= id_csr_write_en_ex;
        ex_write_csr_addr_id <= id_csr_write_addr_ex;
        ex_write_csr_data_id <= 32'h0000_0000;
        mul_start_r          <= 1'b0;
        multiplier_r         <= 32'h0000_0000;
        multiplicand_r       <= 32'h0000_0000;
    end
    case (id_inst_encoding_ex)
        `RV32_BASE_INST_LUI:
            ex_alu_addr_calcul_result_mem_r <= id_imm_exten_data_ex;
        `RV32_BASE_INST_AUIPC:
            ex_alu_addr_calcul_result_mem_r <= id_imm_exten_data_ex + id_current_pc_ex;
        `RV32_BASE_INST_JAL: begin
            ex_alu_addr_calcul_result_mem_r <= 32'h0000_0000; //TODO: deleted it
            ex_jump_new_pc_pc_mux <= ex_jump_new_pc_auipc_inst_w;
        end
        `RV32_BASE_INST_JALR: begin
            ex_alu_addr_calcul_result_mem_r <= 32'h0000_0000; //TODO: deleted it
            ex_jump_new_pc_pc_mux <= ex_jump_rs1data_imm_pc_w;
        end
        `RV32_BASE_INST_BEQ: begin
            ex_jump_new_pc_pc_mux <= ex_jump_new_pc_auipc_inst_w;
            ex_branch_comp_ctrl <= (ex_alu_oper_src1_data == ex_alu_oper_src2_data) ? `PP_BRANCH_COMP_ENABLE : `PP_BRANCH_COMP_DISABLE;
        end
        `RV32_BASE_INST_BNE: begin
            ex_jump_new_pc_pc_mux <= ex_jump_new_pc_auipc_inst_w;
            ex_branch_comp_ctrl <= (ex_alu_oper_src1_data != ex_alu_oper_src2_data) ? `PP_BRANCH_COMP_ENABLE : `PP_BRANCH_COMP_DISABLE;
        end
        `RV32_BASE_INST_BLT: begin
            ex_jump_new_pc_pc_mux <= ex_jump_new_pc_auipc_inst_w;
            ex_branch_comp_ctrl <= ($signed(ex_alu_oper_src1_data) < $signed(ex_alu_oper_src2_data)) ? `PP_BRANCH_COMP_ENABLE : `PP_BRANCH_COMP_DISABLE;
        end
        `RV32_BASE_INST_BGE: begin
            ex_jump_new_pc_pc_mux <= ex_jump_new_pc_auipc_inst_w;
            ex_branch_comp_ctrl <= ($signed(ex_alu_oper_src1_data) >= $signed(ex_alu_oper_src2_data)) ? `PP_BRANCH_COMP_ENABLE : `PP_BRANCH_COMP_DISABLE;
        end
        `RV32_BASE_INST_BLTU: begin
            ex_jump_new_pc_pc_mux <= ex_jump_new_pc_auipc_inst_w;
            ex_branch_comp_ctrl <= (ex_alu_oper_src1_data < ex_alu_oper_src2_data) ? `PP_BRANCH_COMP_ENABLE : `PP_BRANCH_COMP_DISABLE;
        end
        `RV32_BASE_INST_BGEU: begin
            ex_jump_new_pc_pc_mux <= ex_jump_new_pc_auipc_inst_w;
            ex_branch_comp_ctrl <= (ex_alu_oper_src1_data >= ex_alu_oper_src2_data) ? `PP_BRANCH_COMP_ENABLE : `PP_BRANCH_COMP_DISABLE;
        end
        `RV32_BASE_INST_LB:  ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_LH:  ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_LW:  ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_LBU: ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_LHU: ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_SB:  ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_SH:  ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_SW:  ex_alu_addr_calcul_result_mem_r <= ex_load_address;
        `RV32_BASE_INST_ADDI,
        `RV32_BASE_INST_ADD: ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data + ex_alu_oper_src2_data;
        `RV32_BASE_INST_SUB: ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data - ex_alu_oper_src2_data;
        `RV32_BASE_INST_SLTI,
        `RV32_BASE_INST_SLTIU,
        `RV32_BASE_INST_SLT: ex_alu_addr_calcul_result_mem_r <= (ex_alu_oper_src1_data < ex_alu_oper_src2_data) ? 32'h1 : 32'h0;
        `RV32_BASE_INST_XORI,
        `RV32_BASE_INST_XOR:  ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data ^ ex_alu_oper_src2_data;
        `RV32_BASE_INST_ORI,
        `RV32_BASE_INST_OR:  ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data | ex_alu_oper_src2_data;
        `RV32_BASE_INST_ANDI,
        `RV32_BASE_INST_AND: ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data & ex_alu_oper_src2_data;
        `RV32_BASE_INST_SLLI,
        `RV32_BASE_INST_SLL: ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data << ex_alu_oper_src2_data[4:0];
        `RV32_BASE_INST_SRLI:  ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data >> shamt;
        `RV32_BASE_INST_SRL: ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data >> ex_alu_oper_src2_data[4:0];
        `RV32_BASE_INST_SRAI:  ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data >>> shamt;
        `RV32_BASE_INST_SRA: ex_alu_addr_calcul_result_mem_r <= ex_alu_oper_src1_data >>> ex_alu_oper_src2_data[4:0];
        `RV32_ZICSR_STAND_INST_CSRRW: begin
            ex_alu_addr_calcul_result_mem_r <= id_csr_read_data_ex;
            if (id_csr_write_en_ex) begin
                ex_write_csr_data_id <= ex_alu_oper_src1_data;
            end else begin /* TODO: spyglass check deleted else... */
                ex_write_csr_data_id <= 32'h0000_0000;
            end
        end
        `RV32_ZICSR_STAND_INST_CSRRS: begin
            ex_alu_addr_calcul_result_mem_r <= id_csr_read_data_ex;
            if (id_csr_write_en_ex) begin
                ex_write_csr_data_id <= id_csr_read_data_ex | ex_alu_oper_src1_data;
            end
        end
        `RV32_ZICSR_STAND_INST_CSRRC: begin
            ex_alu_addr_calcul_result_mem_r <= id_csr_read_data_ex;
            if (id_csr_write_en_ex) begin
                ex_write_csr_data_id <= id_csr_read_data_ex & ex_alu_oper_src1_data;
            end
        end
        `RV32_ZICSR_STAND_INST_CSRRWI: begin
            ex_alu_addr_calcul_result_mem_r <= id_csr_read_data_ex;
            if (id_csr_write_en_ex) begin
                ex_write_csr_data_id <= id_rs1_uimm_ex;
            end
        end
        `RV32_ZICSR_STAND_INST_CSRRSI: begin
            ex_alu_addr_calcul_result_mem_r <= id_csr_read_data_ex;
            if (id_csr_write_en_ex) begin
                ex_write_csr_data_id <= id_csr_read_data_ex | id_rs1_uimm_ex;
            end
        end
        `RV32_ZICSR_STAND_INST_CSRRCI: begin
            ex_alu_addr_calcul_result_mem_r <= id_csr_read_data_ex;
            if (id_csr_write_en_ex) begin
                ex_write_csr_data_id <= id_csr_read_data_ex & id_rs1_uimm_ex;
            end
        end
        `RV32_M_STAND_INST_MUL: begin
            multiplier_r                    <= ex_alu_oper_src1_data;
            multiplicand_r                  <= ex_alu_oper_src2_data;
            if (mul_ready_w) begin
                ex_alu_addr_calcul_result_mem_r <= product_l_w;
                mul_start_r                     <= 1'b0;
            end else begin
                ex_alu_addr_calcul_result_mem_r <= 32'h0000_0000;
                mul_start_r                     <= 1'b1;
            end
        end
        `RV32_M_STAND_INST_MULH: begin
            multiplier_r                    <= ex_alu_oper_src1_data;
            multiplicand_r                  <= ex_alu_oper_src2_data;
            if (mul_ready_w) begin
                ex_alu_addr_calcul_result_mem_r <= product_h_w;
                mul_start_r                     <= 1'b0;
            end else begin
                ex_alu_addr_calcul_result_mem_r <= 32'h0000_0000;
                mul_start_r                     <= 1'b1;
            end
        end
        default: begin
            ex_alu_addr_calcul_result_mem_r <= 32'h0000_0000;
            ex_jump_new_pc_pc_mux <= 32'h0000_0000;
        end
    endcase
end

//--------------------------------------------------------------------------
// Design: instance myltipiler module
//--------------------------------------------------------------------------
sequ_multi sequ_multi_u (
    .clk              (clk),             // I
    .rst_n            (rst_n),           // I
    .multiplier       (multiplier_r),    // I [31:0]
    .multiplicand     (multiplicand_r),  // I [31:0]
    .start            (mul_start_r),     // I

    .product_l        (product_l_w),     // O [31:0]
    .product_h        (product_h_w),     // O [31:0]
    .ready            (mul_ready_w)      // O
);

//--------------------------------------------------------------------------
// Design: pipeline update the ex_mem stage register
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ex_pc_plus4_mem <= 32'h0000_0000;
        ex_write_dest_register_index_mem <= 5'b00000;
        ex_write_register_en_mem <= `PP_WRITE_DEST_REG_ENABLE;
        ex_write_rs2_data_mem <= 32'h0000_0000;
        ex_alu_addr_calcul_result_mem <= 32'h0000_0000;
        ex_mem_write_en_mem <= `MEM_READ;
        ex_mem_oper_size_mem <= `MEM_OPER_WORD;
        ex_wb_result_src_mem <= `WB_SEL_ALU_RESULT;
        ex_inst_debug_str_mem <= "adi";
    end else begin
        if (hazard_flush_ex_mem_reg) begin
            ex_pc_plus4_mem <= 32'h0000_0000;
            ex_write_dest_register_index_mem <= 5'b00000;
            ex_write_register_en_mem <= `PP_WRITE_DEST_REG_ENABLE;
            ex_write_rs2_data_mem <= 32'h0000_0000;
            ex_alu_addr_calcul_result_mem <= 32'h0000_0000;
            ex_mem_write_en_mem <= `MEM_READ;
            ex_mem_oper_size_mem <= `MEM_OPER_WORD;
            ex_wb_result_src_mem <= `WB_SEL_ALU_RESULT;
            ex_inst_debug_str_mem <= "adi";
        end else if (hazard_stall_ex_mem_reg) begin
            ex_pc_plus4_mem <= ex_pc_plus4_mem;
            ex_write_dest_register_index_mem <= ex_write_dest_register_index_mem;
            ex_write_register_en_mem <= ex_write_register_en_mem;
            ex_write_rs2_data_mem <= ex_write_rs2_data_mem;
            ex_alu_addr_calcul_result_mem <= ex_alu_addr_calcul_result_mem;
            ex_mem_write_en_mem <= ex_mem_write_en_mem;
            ex_mem_oper_size_mem <= ex_mem_oper_size_mem;
            ex_wb_result_src_mem <= ex_wb_result_src_mem;
            ex_inst_debug_str_mem <= ex_inst_debug_str_mem;
        end else begin
            ex_pc_plus4_mem <= id_pc_plus4_ex;
            ex_write_dest_register_index_mem <= id_write_dest_register_index_ex;
            ex_write_register_en_mem <= id_write_register_en_ex;
            ex_write_rs2_data_mem <= ex_alu_oper_src2_data_pre;
            ex_alu_addr_calcul_result_mem <= ex_alu_addr_calcul_result_mem_r;
            ex_mem_write_en_mem <= id_mem_write_en_ex;
            ex_mem_oper_size_mem <= id_mem_oper_size_ex;
            ex_wb_result_src_mem <= id_wb_result_src_ex;
            ex_inst_debug_str_mem <= id_inst_debug_str_ex;
        end
    end
end

endmodule
//--------------------------------------------------------------------------
