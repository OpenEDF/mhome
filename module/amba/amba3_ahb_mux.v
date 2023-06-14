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
// Brief: ahb multiplexor
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "amba_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module amba3_ahb_mux 
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input  wire         HCLK,
    input  wire         HRESETn,
    input  wire [3:0]   MUX_HSELX,
    input  wire [31:0]  HRDATA_S0,
    input  wire         HRESP_S0,
    input  wire         HREADYOUT_S0, 
    input  wire [31:0]  HRDATA_S1,
    input  wire         HRESP_S1,
    input  wire         HREADYOUT_S1, 
    input  wire [31:0]  HRDATA_S2,
    input  wire         HRESP_S2,
    input  wire         HREADYOUT_S2, 
    input  wire [31:0]  HRDATA_S3,
    input  wire         HRESP_S3,
    input  wire         HREADYOUT_S3, 

    // outputs
    output reg  [31:0]  HRDATA,
    output reg          HRESP,
    output reg          HREADY
);

reg [3:0] APHASE_MUX_HSELX;
//--------------------------------------------------------------------------
// Design: latch the muxhsel for address phase 
//--------------------------------------------------------------------------
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        APHASE_MUX_HSELX <= 4'h0;
    end else begin
        APHASE_MUX_HSELX <= MUX_HSELX;
    end
end

//--------------------------------------------------------------------------
// Design: multiplexor the slave data and signal to master
//--------------------------------------------------------------------------
always @(APHASE_MUX_HSELX) begin
    case (APHASE_MUX_HSELX)
        4'h0: begin
            HRDATA <= HRDATA_S0;
            HRESP  <= HRESP_S0;
            HREADY <= HREADYOUT_S0;
        end
        4'h1: begin
            HRDATA <= HRDATA_S1;
            HRESP  <= HRESP_S1;
            HREADY <= HREADYOUT_S1;
        end
        4'h2: begin
            HRDATA <= HRDATA_S2;
            HRESP  <= HRESP_S2;
            HREADY <= HREADYOUT_S2;
        end
        4'h3: begin
            HRDATA <= HRDATA_S3;
            HRESP  <= HRESP_S3;
            HREADY <= HREADYOUT_S3;
        end
        default: begin
            HRDATA <= `HRDATA_NOMAP;
            HRESP  <= `HRESP_NOMAP;
            HREADY <= `HREADYOUT_NOMAP;
        end
    endcase
end

endmodule
//--------------------------------------------------------------------------
