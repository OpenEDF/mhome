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
// Brief:i multipiler is use shif-add algorithm and sequential circuits
/*
*     10111 [23]
*     x
*     10011 [19]
*     -----------------
*     10111
*    10111
*   00000
*  00000
* 10111
* ------------------
* 110110101 [437]
*
*     10111
*    10111
* 10111
* ------------------
* 110110101
*/
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "mhome_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module sequ_multi
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,
    input wire [31:0]  multiplier,
    input wire [31:0]  multiplicand,
    input wire         start,

    // outputs
    output reg [31:0]  product,
    output reg         ready
);

//--------------------------------------------------------------------------
// Design:temp register 
//--------------------------------------------------------------------------
reg [63:0] partial_product;
reg [31:0] multipiler_copy;
reg [63:0] multipilcand_copy;
reg [5:0]  shift_count;

//--------------------------------------------------------------------------
// Design: sequential multiplier shift version of multiplier and 
//         multoplicand
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        product           <= 32'h0000_0000;
        ready             <= 1'b0;
        partial_product   <= 64'h0000_0000_0000_0000;
        multiplier_copy   <= 32'h0000_0000;
        multipilcand_copy <= 32'h0000_0000;
        shift_count       <= 6'd32;
    end else begin
        if (start || ~ready) begin
            multipilcand_copy <= {32'h0000_0000, multoplicand};
            multiplier_copy   <= multiplier;
            shift_count       <= 6'd32;
            ready   <= 1'b1;
        end else if (shift_count == 5'b00000) begin
            product <= partial_product[31:0];    
            ready   <= 1'b0;
        end else begin
            if (multiplier_copy[0] == 1'b1) begin
                partial_product <= partial_product + multipilcand_copy;
            end
            multipilcand_copy <= multipilcand_copy << 1;
            multiplier_copy <= multiplier_copy >> 1;
            shift_count     <= shift_count - 1;
        end
    end
end
endmodule
//--------------------------------------------------------------------------
