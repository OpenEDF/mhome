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
module single_port_ram #(
    parameter RAM_SIZE = 1024
)
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire        clk,
    input wire        rst_n,
    input wire [31:0] ram_addr_in,
    input wire [31:0] ram_data_in,
    input wire        ram_write_en,  //high is writen, low rd
    input wire [1:0]  read_write_size,

    // outputs
    output reg [31:0] ram_data_out
);

//--------------------------------------------------------------------------
// Design: memory model array
//--------------------------------------------------------------------------
reg [7:0] memory_model[0:RAM_SIZE-1];

//--------------------------------------------------------------------------
// Design: memoory wirte operation, only clock rising edge
//         resove the address, analysis operation is BYTE/HALFWORLD/WORD
//         00: word
//         01: halfword
//         10: byte
//         11: invalid
//--------------------------------------------------------------------------
//always @(posedge clk or negedge rst_n) begin: write //TODO: deleted rst_n
always @(posedge clk) begin: write
    case ({read_write_size, ram_write_en})
        3'b001: begin
            memory_model[ram_addr_in]   <= ram_data_in[7:0];
            memory_model[ram_addr_in+1] <= ram_data_in[15:8];
            memory_model[ram_addr_in+2] <= ram_data_in[23:16];
            memory_model[ram_addr_in+3] <= ram_data_in[31:24];
        end
        3'b011: begin
            memory_model[ram_addr_in]   <= ram_data_in[7:0];
            memory_model[ram_addr_in+1] <= ram_data_in[15:8];
        end
        3'b101:
            memory_model[ram_addr_in]   <= ram_data_in[7:0];
        default:
            memory_model[ram_addr_in]   <= memory_model[ram_addr_in];
    endcase
end

//--------------------------------------------------------------------------
// Design: memoory read operation
//         resove the address, analysis operation is BYTE/HALFWORLD/WORD
//         00: word
//         01: halfword
//         10: byte
//         11: invalid
//--------------------------------------------------------------------------
always @(read_write_size or ram_addr_in or ram_write_en) begin: read
    case ({read_write_size, ram_write_en})
        3'b000:
            ram_data_out <= {memory_model[ram_addr_in+3], memory_model[ram_addr_in+2],
                            memory_model[ram_addr_in+1], memory_model[ram_addr_in]};
        3'b010:
            ram_data_out <= {16'b0, memory_model[ram_addr_in+1], memory_model[ram_addr_in]};
        3'b100:
            ram_data_out <= {24'b0, memory_model[ram_addr_in]};
        default:
            ram_data_out <= 32'h0000_0000;
    endcase
end

endmodule
//--------------------------------------------------------------------------
