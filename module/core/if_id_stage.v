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
    input wire         wb_write_reginster_en_id,
    input wire [31:0]  wb_write_pc_plus4_id,

    // outputs
    output reg [31:0]  id_cycle_count_ex,
    output reg [31:0]  id_pc_plus4_ex,
    output reg [31:0]  id_read_rs1_data_ex,
    output reg [31:0]  id_read_rs2_data_ex,
    output reg [31:0]  id_imm_exten_data_ex,
    output reg [4:0]   id_write_dest_register_index_ex,
    output reg         id_write_register_en_ex,
    output reg [7:0]   id_inst_encoding_ex,

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
reg  [8*3:1] id_inst_debug_str_r;

assign id_inst_rs1_w = if_instruction_id[19:15];
assign id_inst_rs2_w = if_instruction_id[24:20];
assign id_write_dest_register_index_ex_w = if_instruction_id[11:7];
assign inst = if_instruction_id;

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
           id_imm_exten_data_r <= {inst[31], inst[30:20], inst[19:12], {12{1'b0}}};
        default:
           id_imm_exten_data_r <= 32'h0000_0000;
    endcase
end

//--------------------------------------------------------------------------
// Design: riscv instruction debug module
//--------------------------------------------------------------------------
always @(id_inst_encoding_ex_w) begin
    case (id_inst_encoding_ex_w)
        `RV32_BASE_INST_LUI:
            id_inst_debug_str_r = "lui";
        `RV32_BASE_INST_AUIPC:
            id_inst_debug_str_r = "aui";
        `RV32_BASE_INST_ADDI:
            id_inst_debug_str_r = "adi";
        default:
            id_inst_debug_str_r = "nop";
    endcase
end
//--------------------------------------------------------------------------
// Design: instantiate riscv register file
//--------------------------------------------------------------------------
register_file register_file_u(
    .clk    (clk),
    .rst_n  (rst_n),
    .id_inst_read_1_src     (id_inst_rs1_w),
    .id_inst_read_2_src     (id_inst_rs2_w),
    .wb_inst_write_dest     (wb_write_register_dest_id),
    .wb_inst_write_data     (wb_write_register_data_id),
    .wb_inst_write_en       (wb_write_reginster_en_id),
    .wb_comp_pc_plus4_id    (wb_write_pc_plus4_id),

    .id_inst_read_1_data    (id_read_rs1_data_ex_w),
    .id_inst_read_2_data    (id_read_rs2_data_ex_w)
);

//--------------------------------------------------------------------------
// Design: instantiate riscv pipeline control module
//--------------------------------------------------------------------------
pipeline_ctrl pipeline_ctrl_u(
    .id_instruction_ctrl    (if_instruction_id),

    .id_imm_src_ctrl        (id_imm_exten_src_w),
    .id_write_register_en   (id_write_register_en_ex_w),
    .id_inst_encoding       (id_inst_encoding_ex_w)
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
        id_inst_encoding_ex  <= 8'h00;
        id_write_register_en_ex <= 1'b0;
        id_write_dest_register_index_ex <= 5'b00000;
        id_inst_debug_str_ex <= "nop";
    end else begin
        id_pc_plus4_ex <= if_pc_plus4_id;
        id_read_rs1_data_ex  <= id_read_rs1_data_ex_w;
        id_read_rs2_data_ex  <= id_read_rs2_data_ex_w;
        id_imm_exten_data_ex <= id_imm_exten_data_r;
        id_inst_encoding_ex  <= id_inst_encoding_ex_w;
        id_write_register_en_ex <= id_write_register_en_ex_w;
        id_write_dest_register_index_ex <= id_write_dest_register_index_ex_w;
        id_inst_debug_str_ex <= id_inst_debug_str_r;
    end
end
endmodule
//--------------------------------------------------------------------------
