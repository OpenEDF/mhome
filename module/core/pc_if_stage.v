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
module pc_if_stage
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [31:0]  pc_gen_start_cycle_count_if,
    input wire [31:0]  pc_source_pc_gen_if,

    // outputs
    output reg [31:0]  if_cycle_count_id,
    output reg [31:0]  if_instruction_id
);

//--------------------------------------------------------------------------
// Design: instruction fetch signal
//--------------------------------------------------------------------------
wire [31:0] if_instruction_id_w;

//--------------------------------------------------------------------------
// Design: pipeline cycle counter logic
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        if_cycle_count_id <= `CYCLE_COUNT_RST;
    end else begin
        if_cycle_count_id <= pc_gen_start_cycle_count_if;
    end
end

//--------------------------------------------------------------------------
// Design: instantiate a ram model
// TODO: use the ram ip on xilinx FPGA
//--------------------------------------------------------------------------
single_port_ram #(.RAM_SIZE(1024)) single_port_ram_u (
    .clk   (clk),
    .rst_n (rst_n),
    .ram_addr_in     (pc_source_pc_gen_if),
    .ram_data_in     (),
    .ram_write_en    (1'b1),  //high is writen, low rd
    .read_write_size (2'b00),

    .ram_data_out    (if_instruction_id_w)
);

//--------------------------------------------------------------------------
// Design: send data to the left of IF/DE stage register in one cycle
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        if_instruction_id <= `RV32I_NOP;
    end
    else begin
        if_instruction_id <= if_instruction_id_w;
    end
end

endmodule
//--------------------------------------------------------------------------
