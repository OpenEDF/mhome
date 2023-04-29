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
module register_file
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [4:0]   id_inst_read_1_src,
    input wire [4:0]   id_inst_read_2_src,
    input wire [4:0]   wb_inst_write_dest,
    input wire [31:0]  wb_inst_write_data,
    input wire         wb_inst_write_en,
    input wire [31:0]  wb_comp_pc_plus4_id,

    // outputs
    output wire [31:0] id_inst_read_1_data,
    output wire [31:0] id_inst_read_2_data
);

//--------------------------------------------------------------------------
// Design: RV32 register file
//--------------------------------------------------------------------------
//| Register| ABI Name| Description                        | Saver
//| x0      | zero    | Hard-wired zero                    | —
//| x1      | ra      | Return address                     | Caller
//| x2      | sp      | Stack pointer                      | Callee
//| x3      | gp      | Global pointer                     | —
//| x4      | tp      | Thread pointer                     | —
//| x5      | t0      | Temporary/alternate link register  | Caller
//| x6–7    | t1–2    | Temporaries                        | Caller
//| x8      | s0/fp   | Saved register/frame pointer       | Callee
//| x9      | s1      | Saved register                     | Callee
//| x10–11  | a0–1    | Function arguments/return values   | Caller
//| x12–17  | a2–7    | Function arguments                 | Caller
//| x18–27  | s2–11   | Saved registers                    | Callee
//| x28–31  | t3–6    | Temporaries                        | Caller
//|---------|---------|------------------------------------|----------------
//| f0–7    | ft0–7   | FP temporaries                     | Caller
//| f8–9    | fs0–1   | FP saved registers                 | Callee
//| f10–11  | fa0–1   | FP arguments/return values         | Caller
//| f12–17  | fa2–7   | FP arguments                       | Caller
//| f18–27  | fs2–11  | FP saved registers                 | Callee
//| f28–31  | ft8–11  | FP temporaries                     | Caller
//--------------------------------------------------------------------------
reg [31:0] rv32_register[0:31];
reg [31:0] wb_comp_pc_plus4_id_r;

//--------------------------------------------------------------------------
// Design: register file read opeartion
//--------------------------------------------------------------------------
assign id_inst_read_1_data = rv32_register[id_inst_read_1_src];
assign id_inst_read_2_data = rv32_register[id_inst_read_2_src];

//--------------------------------------------------------------------------
// Design: register file writen operation
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rv32_register[0] <= 32'h0000_0000;
        rv32_register[1] <= 32'h0000_0000;
        rv32_register[2] <= 32'h0000_0000;
        rv32_register[3] <= 32'h0000_0000;
        rv32_register[4] <= 32'h0000_0000;
        rv32_register[5] <= 32'h0000_0000;
        rv32_register[6] <= 32'h0000_0000;
        rv32_register[7] <= 32'h0000_0000;
        rv32_register[8] <= 32'h0000_0000;
        rv32_register[9] <= 32'h0000_0000;
        rv32_register[10] <= 32'h0000_0000;
        rv32_register[11] <= 32'h0000_0000;
        rv32_register[12] <= 32'h0000_0000;
        rv32_register[13] <= 32'h0000_0000;
        rv32_register[14] <= 32'h0000_0000;
        rv32_register[15] <= 32'h0000_0000;
        rv32_register[16] <= 32'h0000_0000;
        rv32_register[17] <= 32'h0000_0000;
        rv32_register[18] <= 32'h0000_0000;
        rv32_register[19] <= 32'h0000_0000;
        rv32_register[20] <= 32'h0000_0000;
        rv32_register[21] <= 32'h0000_0000;
        rv32_register[22] <= 32'h0000_0000;
        rv32_register[23] <= 32'h0000_0000;
        rv32_register[24] <= 32'h0000_0000;
        rv32_register[25] <= 32'h0000_0000;
        rv32_register[26] <= 32'h0000_0000;
        rv32_register[27] <= 32'h0000_0000;
        rv32_register[28] <= 32'h0000_0000;
        rv32_register[29] <= 32'h0000_0000;
        rv32_register[30] <= 32'h0000_0000;
        rv32_register[31] <= 32'h0000_0000;
        wb_comp_pc_plus4_id_r <= 32'h0000_0000;
    end else begin
        case ({wb_inst_write_en, wb_inst_write_dest})
            6'b100000:
                rv32_register[0] <= 32'h0000_0000;
            6'b100001:
                rv32_register[1] <= wb_inst_write_data;
            6'b100010:
                rv32_register[2] <= wb_inst_write_data;
            6'b100011:
                rv32_register[3] <= wb_inst_write_data;
            6'b100100:
                rv32_register[4] <= wb_inst_write_data;
            6'b100101:
                rv32_register[6] <= wb_inst_write_data;
            6'b100110:
                rv32_register[7] <= wb_inst_write_data;
            6'b100111:
                rv32_register[8] <= wb_inst_write_data;
            6'b101001:
                rv32_register[9] <= wb_inst_write_data;
            6'b101010:
                rv32_register[10] <= wb_inst_write_data;
            6'b101011:
                rv32_register[11] <= wb_inst_write_data;
            6'b101100:
                rv32_register[12] <= wb_inst_write_data;
            6'b101101:
                rv32_register[13] <= wb_inst_write_data;
            6'b101110:
                rv32_register[14] <= wb_inst_write_data;
            6'b101111:
                rv32_register[15] <= wb_inst_write_data;
            6'b110000:
                rv32_register[16] <= wb_inst_write_data;
            6'b110001:
                rv32_register[17] <= wb_inst_write_data;
            6'b110010:
                rv32_register[18] <= wb_inst_write_data;
            6'b110011:
                rv32_register[19] <= wb_inst_write_data;
            6'b110100:
                rv32_register[20] <= wb_inst_write_data;
            6'b110101:
                rv32_register[21] <= wb_inst_write_data;
            6'b110110:
                rv32_register[22] <= wb_inst_write_data;
            6'b110111:
                rv32_register[23] <= wb_inst_write_data;
            6'b111000:
                rv32_register[24] <= wb_inst_write_data;
            6'b111001:
                rv32_register[25] <= wb_inst_write_data;
            6'b111010:
                rv32_register[26] <= wb_inst_write_data;
            6'b111011:
                rv32_register[27] <= wb_inst_write_data;
            6'b111100:
                rv32_register[28] <= wb_inst_write_data;
            6'b111101:
                rv32_register[29] <= wb_inst_write_data;
            6'b111110:
                rv32_register[30] <= wb_inst_write_data;
            6'b111111:
                rv32_register[31] <= wb_inst_write_data;
            default:
                rv32_register[0] <= 32'h0000_0000;
        endcase
        // next pc plus 4
        wb_comp_pc_plus4_id_r <= wb_comp_pc_plus4_id;
    end
end
endmodule
//--------------------------------------------------------------------------
