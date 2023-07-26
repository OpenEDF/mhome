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
// Brief: this algorithm uses subtraction and shift operation to calculate
//        the quotient and remainder.
/*
*       110
*    --------------
*    111000 [56]
*    /
*    1001 [9]
*    --------------
*    111000
*   -1001
*    --------------
*    010100
*     1001
*    --------------
*     00010
*    remainder = 110
*    quotient  = 10
*--------------------------------
*    111000 [56]
*    /
*    1001
*    --------------
*       111000 > 1001   <---
*        if 0, 0           |
*        else              |
*          quotient  = +1
*          remainder = 111000 - 1001
*
*    --------------
*    1. 111000 > 1001 : 1
*       remainder = 111000 - 1001 = 101111
*       quotient  = 1
*
*    2. 10111 > 1001 : 1
*       remainder = 101111 - 1001 = 100110
*       quotient  = 2
*
*    3. 100110 > 1001 : 1
*       remainder = 100110 - 1001 = 11101
*       quotient  = 3
*
*    ...
*
*    6. 1011 > 1001 : 1
*       remainder = 1011 - 1001 = 0010
*       quotient  = 6
*
*    7. 0010 > 1001 : 0
*       remainder = 0010
*       quotient  = 6
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
module sequ_div
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire        clk,
    input wire        rst_n,
    input wire [31:0] divider,
    input wire [31:0] dividend,
    input wire        start,

    // outputs
    output reg [31:0] quotient,
    output reg [31:0] remainder,
    output reg        ready,
    output reg        illegal_divider_zero 
);

//--------------------------------------------------------------------------
// Design: divider opeartion temp signal
//--------------------------------------------------------------------------
reg [32:0] sub_diff;
reg [63:0] quotient_remainder;
reg [5:0]  shift_count;

//--------------------------------------------------------------------------
// Design: divider opeartion using sequential circuits
//--------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        quotient_remainder <= 64'h0000_0000_0000_0000; 
        shift_count        <= 6'd0;            
        sub_diff           <= 33'b0;
        quotient  <= 32'h0000_0000; 
        remainder <= 32'h0000_0000;
        ready                <= 1'b0;
        illegal_divider_zero <= 1'b0;
    end else begin
        if (start || ~ready) begin
            quotient_remainder <= {32'h0000_0000, dividend};
            shift_count        <= 6'd32;            
            sub_diff           <= 33'b0;
            illegal_divider_zero <= 1'b0;
            reday                <= 1'b1;
        end else if (divider == 32'h0000_0000) begin
            quotient  <= 32'h0000_0000; 
            remainder <= 32'h0000_0000;
            ready     <= 1'b1;
            illegal_divider_zero <= 1'b1;
        end else if (dividend < divider) begin
            quotient  <= 32'h0000_0000; 
            remainder <= dividend;
            ready     <= 1'b1;
        end else if (dividend == divider) begin
            quotient  <= 32'h0000_0001; 
            remainder <= 32'h0000_0000;
            ready     <= 1'b1;
        end else if (shift_count == 6'd0) begin
            quotient  <= quotient_remainder[31:0];
            remainder <= quotient_remainder[63:32];
            ready     <= 1'b1;
        end else  begin
            sub_diff = quotient_remainder[63:31] - {1'b0, divider};
            if (sub_diff[32]) begin
                quotient_remainder = {quotient_remainder[62:0], 1'b0};        
            end else begin
                quotient_remainder = {sub_diff[31:0], quotient_remainder[62:0], 1'b1};        
            end
            shift_count <= shift_count - 1;
        end 
    end
end
endmodule
//--------------------------------------------------------------------------
