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
// Brief : machine pipeline control and status register
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "mhome_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module rv_csrs
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire          clk,
    input wire          rst_n,
    input wire  [11:0]  id_access_csr_addr_csrs,
    input wire          id_write_en_csrs,
    input wire  [31:0]  id_write_data_csrs,

    // outputs
    output wire [31:0]  csrs_read_csr_data
);

//--------------------------------------------------------------------------
// Design: csrs register
//--------------------------------------------------------------------------
// Machine Information Registers
reg [31:0] mvendorid;   //RO
reg [31:0] marchid;
reg [31:0] mimpid;
reg [31:0] mhartid;
reg [31:0] mconfigptr;

//TODO: add other register

//--------------------------------------------------------------------------
// Design: csrs register address
//--------------------------------------------------------------------------
localparam MVENDORID_ADDR  = 12'hF11;
localparam MARCHID_ADDR    = 12'hF12;
localparam MIMPID_ADDR     = 12'hF13;
localparam MHARTID_ADDR    = 12'hF14;
localparam MCONFIGPTR_ADDR = 12'hF15;

//--------------------------------------------------------------------------
// Design: instruction read csrs register
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        /* default value */
        mvendorid    <= 32'h1234_5678;      /* TODO: modify */
        marchid      <= 32'h0000_0001;
        mimpid       <= 32'h0000_0001;
        mhartid      <= 32'h0000_0001;
        mconfigptr   <= 32'h0000_0000;
    end else if (id_write_en_csrs) begin: write_csrs
        case (id_access_csr_addr_csrs)
            MARCHID_ADDR: mimpid <= id_write_data_csrs;
            default: begin
            end
        endcase
    end else begin
        /* The registers are change and modified according to the signals
        * inside the module */
       // if () mamm = xxx; ?
    end
end

//--------------------------------------------------------------------------
// Design: instruction write csrs register
//--------------------------------------------------------------------------
always @(*) begin: read_csrs
    case(id_access_csr_addr_csrs)
        MVENDORID_ADDR:  csrs_read_csr_data <= mvendorid;
        MARCHID_ADDR:    csrs_read_csr_data <= marchid;
        MIMPID_ADDR:     csrs_read_csr_data <= mimpid;
        MHARTID_ADDR:    csrs_read_csr_data <= mhartid;
        MCONFIGPTR_ADDR: csrs_read_csr_data <= mconfigptr;
        default: begin
            /* but a value of 0 can be returned to indicate that
             * the field is not implemented.*/
            csrs_read_csr_data <= 32'h0000_0000;
        end
    endcase
end

endmodule
//--------------------------------------------------------------------------
