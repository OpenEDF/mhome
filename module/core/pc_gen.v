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
module pc_gen
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [31:0]  if_pc_plus4_pc_src,
    input wire         ex_pc_jump_en_pc_mux,
    input wire [31:0]  ex_jump_new_pc_pc_mux,
    input wire         hazard_stall_pc_if_reg,
    input wire         hazard_flush_pc_if_reg,

    // outputs
    output reg [31:0]  cycle_count_pc_gen_start,
    output reg [31:0]  source_pc_gen_if
);

reg [31:0] tmp_pc_src;

//--------------------------------------------------------------------------
// Design: Multiplexer selects the source of PC
//         TODO: branch/stall/jtag/interrupt and other, blocking assign
//--------------------------------------------------------------------------
always @(ex_pc_jump_en_pc_mux or ex_jump_new_pc_pc_mux or if_pc_plus4_pc_src) begin
    if (ex_pc_jump_en_pc_mux) begin
        tmp_pc_src = ex_jump_new_pc_pc_mux;
    end
    // end
    // else if () begin
    //
    // end
    // else if () begin
    //
    // end ...
    //
    else begin
        tmp_pc_src = if_pc_plus4_pc_src;
    end
end

//--------------------------------------------------------------------------
// Design: pipeline cycle counter logic
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cycle_count_pc_gen_start <= `CYCLE_COUNT_RST;
    end else begin
        cycle_count_pc_gen_start <= cycle_count_pc_gen_start + 1;
    end
end

//--------------------------------------------------------------------------
// Design: pipeline program counter (PC) generate
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        source_pc_gen_if <= `MHOME_START_PC;
    end else begin
        if (hazard_stall_pc_if_reg) begin
            source_pc_gen_if <= source_pc_gen_if;
        end else if (hazard_flush_pc_if_reg) begin
            source_pc_gen_if <= `MHOME_START_PC;
        end else begin
            source_pc_gen_if <= tmp_pc_src;
        end
   end
end

endmodule
//--------------------------------------------------------------------------
