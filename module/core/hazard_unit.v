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
// Brief: control pipeline flush and stall
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "mhome_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module hazard_unit
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // Inputs
    input wire        ex_pc_jump_en_pc_mux,

    // Outputs
    output reg        hazard_flush_if_id_reg,
    output reg        hazard_flush_id_ex_reg
);

//--------------------------------------------------------------------------
// Design: when flush is enable, if_id_register and id_ex register will
//         flush
//--------------------------------------------------------------------------
//assign hazard_flush_if_id_reg = ex_pc_jump_en_pc_mux ? `PP_FLUSH_IF_ID_REG_ENABLE : `PP_FLUSH_IF_ID_DISABLE;
//assign hazard_flush_id_ex_reg = ex_pc_jump_en_pc_mux ? `PP_FLUSH_ID_EX_REG_ENABLE : `PP_FLUSH_IF_ID_DISABLE;
always @(ex_pc_jump_en_pc_mux) begin
    if (ex_pc_jump_en_pc_mux) begin
        hazard_flush_if_id_reg <= `PP_FLUSH_IF_ID_REG_ENABLE;
        hazard_flush_id_ex_reg <= `PP_FLUSH_ID_EX_REG_ENABLE;
    end else begin
        hazard_flush_if_id_reg <= `PP_FLUSH_IF_ID_REG_DISABLE;
        hazard_flush_id_ex_reg <= `PP_FLUSH_ID_EX_REG_DISABLE;
    end
end

endmodule
//--------------------------------------------------------------------------
