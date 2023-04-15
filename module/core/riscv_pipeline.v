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
module riscv_pipeline
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         sys_clk,
    input wire         sys_rst_n,

    // outputs
    output reg         sys_led
);

//--------------------------------------------------------------------------
// Design: pipeline test signal
//--------------------------------------------------------------------------
// instruction fetch stage
wire [31:0] pc_pc_if;           /* pc register to IF/ID stage*/

// decoder stage
wire [31:0] if_pc_id;           /* IF/ID stage register to ID/EX stage */

// execute stage
wire [31:0] id_pc_ex;           /* ID/EX stage register to EX/MEM stage */

// access memory stage
wire [31:0] ex_pc_mem;          /* EX/MEM stage register to MEM/WB stage */

// write back stage
wire [31:0] mem_pc_wb;          /* MEM/WB to other  */
reg  [31:0] mem_pc_wb_check;    /* MEM/WB output pc check */

//--------------------------------------------------------------------------
// Design: led test logic show core state
//--------------------------------------------------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        sys_led <= 1'b0;
    end else begin
        sys_led <= 1'b1;
    end
end

//--------------------------------------------------------------------------
// Design: generate program counter instaniate 
//--------------------------------------------------------------------------
pc_gen pc_gen_u(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),

    .ori_pc     (pc_pc_if)
);

//--------------------------------------------------------------------------
// Design: instruction fetch instaniate 
//--------------------------------------------------------------------------
pc_if_stage pc_if_stage_u(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .pc_pc      (pc_pc_if),

    .pc_if      (if_pc_id)
);

//--------------------------------------------------------------------------
// Design: instruction decoder instaniate 
//--------------------------------------------------------------------------
if_id_stage if_id_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .if_pc     (if_pc_id),

    .pc_id     (id_pc_ex)
);

//--------------------------------------------------------------------------
// Design: execute instaniate 
//--------------------------------------------------------------------------
id_ex_stage id_ex_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .id_pc     (id_pc_ex),    

    .pc_ex     (ex_pc_mem)
);

//--------------------------------------------------------------------------
// Design: access instaniate 
//--------------------------------------------------------------------------
ex_mem_stage ex_mem_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .ex_pc     (ex_pc_mem),

    .pc_mem    (mem_pc_wb)
);

//--------------------------------------------------------------------------
// Design: write back instaniate 
//--------------------------------------------------------------------------
mem_wb_stage mem_wb_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .mem_pc    (mem_pc_wb),

    .pc_wb     (mem_pc_wb_check)
);

endmodule
//--------------------------------------------------------------------------
