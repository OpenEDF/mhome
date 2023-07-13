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
module div
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         clk,
    input wire         rst_n,

    // outputs
);

//--------------------------------------------------------------------------
// Design:
//--------------------------------------------------------------------------

endmodule
//--------------------------------------------------------------------------
