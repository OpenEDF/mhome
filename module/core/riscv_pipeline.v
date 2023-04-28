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
// Design: pipeline five stage signal
//--------------------------------------------------------------------------
// pc generate stage
wire [31:0] pc_gen_start_cycle_count_if_w; /* pc gen register to IF/ID stage */
wire [31:0] source_pc_gen_if_w;            /* source pc value */

// instruction fetch stage
wire [31:0] if_cycle_count_id_w;           /* IF/ID stage register to ID/EX stage */
wire [31:0] if_instruction_id_w;           /* instruction */
wire [31:0] if_pc_plus4_pc_gen_w;          /* pc pluse 4 to pc gen*/
wire [31:0] if_pc_plus4_id_w;              /* PC plus 4 to next stage */

// decoder stage
wire [31:0] id_cycle_count_ex_w;           /* ID/EX stage register to EX/MEM stage */

// execute stage
wire [31:0] ex_cycle_count_mem_w;          /* EX/MEM stage register to MEM/WB stage */

// access memory stage
wire [31:0] mem_cycle_count_wb_w;          /* MEM/WB to other  */

// write back stage
wire [31:0] mem_cycle_count_end_check_w;   /* MEM/WB output pc check */

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
    .if_pc_plus4_pc_src           (if_pc_plus4_pc_gen_w),

    .cycle_count_pc_gen_start     (pc_gen_start_cycle_count_if_w),
    .source_pc_gen_if             (source_pc_gen_if_w)
);

//--------------------------------------------------------------------------
// Design: instruction fetch instaniate
//--------------------------------------------------------------------------
pc_if_stage pc_if_stage_u(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .pc_gen_start_cycle_count_if  (pc_gen_start_cycle_count_if_w),
    .pc_source_pc_gen_if          (source_pc_gen_if_w),

    .if_cycle_count_id            (if_cycle_count_id_w),
    .if_instruction_id            (if_instruction_id_w),
    .if_pc_plus4_pc_gen           (if_pc_plus4_pc_gen_w),
    .if_pc_plus4_id               (if_pc_plus4_id_w)
);

//--------------------------------------------------------------------------
// Design: instruction decoder instaniate
//--------------------------------------------------------------------------
if_id_stage if_id_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .if_cycle_count_id     (if_cycle_count_id_w),

    .id_cycle_count_ex     (id_cycle_count_ex_w)
);

//--------------------------------------------------------------------------
// Design: execute instaniate
//--------------------------------------------------------------------------
id_ex_stage id_ex_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .id_cycle_count_ex     (id_cycle_count_ex_w),

    .ex_cycle_count_mem    (ex_cycle_count_mem_w)
);

//--------------------------------------------------------------------------
// Design: access instaniate
//--------------------------------------------------------------------------
ex_mem_stage ex_mem_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .ex_cycle_count_mem     (ex_cycle_count_mem_w),

    .mem_cycle_count_wb     (mem_cycle_count_wb_w)
);

//--------------------------------------------------------------------------
// Design: write back instaniate
//--------------------------------------------------------------------------
mem_wb_stage mem_wb_stage_u(
    .clk       (sys_clk),
    .rst_n     (sys_rst_n),
    .mem_cycle_count_wb     (mem_cycle_count_wb_w),

    .wb_cycle_count_end     (mem_cycle_count_end_check_w)
);

endmodule
//--------------------------------------------------------------------------
