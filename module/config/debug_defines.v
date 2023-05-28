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
// Brief: debug sysytm config macros
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// debug system config define
//--------------------------------------------------------------------------
`define IDCODE_VERSION        4'b1101
`define IDCODE_PART_NUMBER    16'b1101011011010010
`define IDCODE_MANUFID        11'b10110101100

// dmi and ir width
`define DMI_ABITIS_WIDTH      8
`define IR_BITS_WIDTH         5

// cmderr
`define CMDERR_NONE           3'b000
`define CMDERR_BUSY           3'b001
`define CMDERR_NOT_SUPPORT    3'b010
`define CMDERR_EXCEPTION      3'b011
`define CMDERR_HALT_RESUME    3'b100
`define CMDERR_BUS            3'b101
`define CMDERR_RES            3'b110
`define CMDERR_OTHER          3'b111

// command aarize
`define ACCESS_32BIT_GPRS     3'b010
`define ACCESS_64BIT_GPRS     3'b011
`define ACCESS_128BIT_GPRS    3'b100

// op code
`define DMI_OP_SUCCESS         2'b00
`define DMI_OP_FAILED          2'b01
`define DMI_OP_IN_PROGRESS     2'b11

//--------------------------------------------------------------------------
