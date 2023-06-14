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
`include "amba_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module amba3_ahb_decoder
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input  wire [31:0]  HADDR,

    // outputs
    output wire         HSEL_S0,
    output wire         HSEL_S1,
    output wire         HSEL_S2,
    output wire         HSEL_NOMAP,
    output reg  [3:0]   MUX_HSELX
);

//--------------------------------------------------------------------------
// Design: slave mapping start address
//--------------------------------------------------------------------------
localparam  ROM_BASEADDR = 24'h000800;
localparam  RAM_BASEADDR = 24'h000840;
localparam  AHB_BASEADDR = 24'h000900;
localparam  APB_BASEADDR = 24'h000908;

//--------------------------------------------------------------------------
// Design: one hot decoder for slave select signal 
//--------------------------------------------------------------------------
reg [7:0] dec_one_hot;
assign HSEL_S0    = dec_one_hot[0];  /* 32K ROM: 0x00080000 - 0x00083FFF */ 
assign HSEL_S1    = dec_one_hot[1];  /* 64K RAM: 0x00084000 - 0x0008BFFF */
assign HSEL_S2    = dec_one_hot[2];  /* 4K  AHB: 0x00090000 - 0x000907FF */
assign HSEL_S2    = dec_one_hot[2];  /* 4K  APB: 0x00090800 - 0x00090BFF */
assign HSEL_NOMAP = dec_one_hot[7];  /* no map */

//--------------------------------------------------------------------------
// Design: system address mapping, align 4K aligned
//--------------------------------------------------------------------------
always @(HADDR) begin
    case (HADDR[31:8])
        ROM_BASEADDR: begin
            dec_one_hot = 8'b0000_0001;
            MUX_HSELX   = 4'h0;
        end
        RAM_BASEADDR: begin
            dec_one_hot = 8'b0000_0010;
            MUX_HSELX   = 4'h1;
        end
        AHB_BASEADDR: begin
            dec_one_hot = 8'b0000_0100;
            MUX_HSELX   = 4'h2;
        end
        APB_BASEADDR: begin
            dec_one_hot = 8'b0000_1000;
            MUX_HSELX   = 4'h3;
        end
        default: begin
            dec_one_hot = 8'b1000_0000;
            MUX_HSELX   = 4'h8;
        end
    endcase
end

endmodule
//--------------------------------------------------------------------------
