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
    input wire [4:0]   dm_access_gprs_index_hart,
    input wire [31:0]  dm_write_gprs_data_hart,
    input wire         dm_write_gprs_en_hart,

    // outputs
    output wire [31:0] id_inst_read_1_data,
    output wire [31:0] id_inst_read_2_data,
    output wire [31:0] hart_result_read_gprs_dm
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

//--------------------------------------------------------------------------
// Design: register file read opeartion
//--------------------------------------------------------------------------
assign id_inst_read_1_data = rv32_register[id_inst_read_1_src];
assign id_inst_read_2_data = rv32_register[id_inst_read_2_src];
// debug system read register file
assign hart_result_read_gprs_dm = rv32_register[dm_access_gprs_index_hart];

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
    end else if (wb_inst_write_en) begin
        case (wb_inst_write_dest)
            5'b00000:
                rv32_register[0]  <= 32'h0000_0000;
            5'b00001:
                rv32_register[1]  <= wb_inst_write_data;
            5'b00010:
                rv32_register[2]  <= wb_inst_write_data;
            5'b00011:
                rv32_register[3]  <= wb_inst_write_data;
            5'b00100:
                rv32_register[4]  <= wb_inst_write_data;
            5'b00101:
                rv32_register[5]  <= wb_inst_write_data;
            5'b00110:
                rv32_register[6]  <= wb_inst_write_data;
            5'b00111:
                rv32_register[7]  <= wb_inst_write_data;
            5'b01000:
                rv32_register[8]  <= wb_inst_write_data;
            5'b01001:
                rv32_register[9]  <= wb_inst_write_data;
            5'b01010:
                rv32_register[10] <= wb_inst_write_data;
            5'b01011:
                rv32_register[11] <= wb_inst_write_data;
            5'b01100:
                rv32_register[12] <= wb_inst_write_data;
            5'b01101:
                rv32_register[13] <= wb_inst_write_data;
            5'b01110:
                rv32_register[14] <= wb_inst_write_data;
            5'b01111:
                rv32_register[15] <= wb_inst_write_data;
            5'b10000:
                rv32_register[16] <= wb_inst_write_data;
            5'b10001:
                rv32_register[17] <= wb_inst_write_data;
            5'b10010:
                rv32_register[18] <= wb_inst_write_data;
            5'b10011:
                rv32_register[19] <= wb_inst_write_data;
            5'b10100:
                rv32_register[20] <= wb_inst_write_data;
            5'b10101:
                rv32_register[21] <= wb_inst_write_data;
            5'b10110:
                rv32_register[22] <= wb_inst_write_data;
            5'b10111:
                rv32_register[23] <= wb_inst_write_data;
            5'b11000:
                rv32_register[24] <= wb_inst_write_data;
            5'b11001:
                rv32_register[25] <= wb_inst_write_data;
            5'b11010:
                rv32_register[26] <= wb_inst_write_data;
            5'b11011:
                rv32_register[27] <= wb_inst_write_data;
            5'b11100:
                rv32_register[28] <= wb_inst_write_data;
            5'b11101:
                rv32_register[29] <= wb_inst_write_data;
            5'b11110:
                rv32_register[30] <= wb_inst_write_data;
            5'b11111:
                rv32_register[31] <= wb_inst_write_data;
            default:
                rv32_register[0]  <= 32'h0000_0000;
        endcase
    end else if (dm_write_gprs_en_hart) begin
        case (dm_access_gprs_index_hart)
            5'b00000:
                rv32_register[0]  <= 32'h0000_0000;
            5'b00001:
                rv32_register[1]  <= dm_write_gprs_data_hart;
            5'b00010:
                rv32_register[2]  <= dm_write_gprs_data_hart;
            5'b00011:
                rv32_register[3]  <= dm_write_gprs_data_hart;
            5'b00100:
                rv32_register[4]  <= dm_write_gprs_data_hart;
            5'b00101:
                rv32_register[5]  <= dm_write_gprs_data_hart;
            5'b00110:
                rv32_register[6]  <= dm_write_gprs_data_hart;
            5'b00111:
                rv32_register[7]  <= dm_write_gprs_data_hart;
            5'b01000:
                rv32_register[8]  <= dm_write_gprs_data_hart;
            5'b01001:
                rv32_register[9]  <= dm_write_gprs_data_hart;
            5'b01010:
                rv32_register[10] <= dm_write_gprs_data_hart;
            5'b01011:
                rv32_register[11] <= dm_write_gprs_data_hart;
            5'b01100:
                rv32_register[12] <= dm_write_gprs_data_hart;
            5'b01101:
                rv32_register[13] <= dm_write_gprs_data_hart;
            5'b01110:
                rv32_register[14] <= dm_write_gprs_data_hart;
            5'b01111:
                rv32_register[15] <= dm_write_gprs_data_hart;
            5'b10000:
                rv32_register[16] <= dm_write_gprs_data_hart;
            5'b10001:
                rv32_register[17] <= dm_write_gprs_data_hart;
            5'b10010:
                rv32_register[18] <= dm_write_gprs_data_hart;
            5'b10011:
                rv32_register[19] <= dm_write_gprs_data_hart;
            5'b10100:
                rv32_register[20] <= dm_write_gprs_data_hart;
            5'b10101:
                rv32_register[21] <= dm_write_gprs_data_hart;
            5'b10110:
                rv32_register[22] <= dm_write_gprs_data_hart;
            5'b10111:
                rv32_register[23] <= dm_write_gprs_data_hart;
            5'b11000:
                rv32_register[24] <= dm_write_gprs_data_hart;
            5'b11001:
                rv32_register[25] <= dm_write_gprs_data_hart;
            5'b11010:
                rv32_register[26] <= dm_write_gprs_data_hart;
            5'b11011:
                rv32_register[27] <= dm_write_gprs_data_hart;
            5'b11100:
                rv32_register[28] <= dm_write_gprs_data_hart;
            5'b11101:
                rv32_register[29] <= dm_write_gprs_data_hart;
            5'b11110:
                rv32_register[30] <= dm_write_gprs_data_hart;
            5'b11111:
                rv32_register[31] <= dm_write_gprs_data_hart;
            default:
                rv32_register[0]  <= 32'h0000_0000;
        endcase
    end else begin
        rv32_register[0]   <= 32'h0000_0000;
        rv32_register[1]   <= rv32_register[1];
        rv32_register[2]   <= rv32_register[2];
        rv32_register[3]   <= rv32_register[3];
        rv32_register[4]   <= rv32_register[4];
        rv32_register[5]   <= rv32_register[5];
        rv32_register[6]   <= rv32_register[6];
        rv32_register[7]   <= rv32_register[7];
        rv32_register[8]   <= rv32_register[8];
        rv32_register[9]   <= rv32_register[9];
        rv32_register[10]  <= rv32_register[10];
        rv32_register[11]  <= rv32_register[11];
        rv32_register[12]  <= rv32_register[12];
        rv32_register[13]  <= rv32_register[13];
        rv32_register[14]  <= rv32_register[14];
        rv32_register[15]  <= rv32_register[15];
        rv32_register[16]  <= rv32_register[16];
        rv32_register[17]  <= rv32_register[17];
        rv32_register[18]  <= rv32_register[18];
        rv32_register[19]  <= rv32_register[19];
        rv32_register[20]  <= rv32_register[20];
        rv32_register[21]  <= rv32_register[21];
        rv32_register[22]  <= rv32_register[22];
        rv32_register[23]  <= rv32_register[23];
        rv32_register[24]  <= rv32_register[24];
        rv32_register[25]  <= rv32_register[25];
        rv32_register[26]  <= rv32_register[26];
        rv32_register[27]  <= rv32_register[27];
        rv32_register[28]  <= rv32_register[28];
        rv32_register[29]  <= rv32_register[29];
        rv32_register[30]  <= rv32_register[30];
        rv32_register[31]  <= rv32_register[31];
    end
end

endmodule
//--------------------------------------------------------------------------
