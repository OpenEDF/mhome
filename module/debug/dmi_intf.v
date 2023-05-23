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
// Brief: Debug Module Interface bus
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "debug_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module dmi_intf #(
    parameter DMI_ABITIS = 6
)
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs from dtm
    input wire [DMI_ABITIS-1:0]  dtm_dmi_addr,
    input wire [31:0]            dtm_dmi_write_data,
    input wire                   dtm_dmi_write_en,
    input wire                   dtm_dmi_request,

    // from dm
    input wire                   dm_dmi_response_dmi,
    input wire [1:0]             dm_dmi_op_dmi,
    input wire [31:0]            dm_dmi_read_data_dmi,

    // outputs to dm
    output wire [DMI_ABITIS-1:0] dmi_addr_dm,
    output wire [31:0]           dmi_write_data_dm,
    output wire                  dmi_write_en_dm,
    output wire                  dmi_request_dm,

    // to dtm
    output wire                  dmi_response_dtm,
    output wire [1:0]            dmi_op_dtm,
    output wire [31:0]           dmi_read_data_dtm
);

//--------------------------------------------------------------------------
// Design: dmi intergace is only one master and slave
//--------------------------------------------------------------------------
assign dmi_addr_dm       = dtm_dmi_addr;
assign dmi_write_data_dm = dtm_dmi_write_data;
assign dmi_write_en_dm   = dtm_dmi_write_en;
assign dmi_request_dm    = dtm_dmi_request;
assign dmi_response_dtm  = dm_dmi_response_dmi;
assign dmi_op_dtm        = dm_dmi_op_dmi;
assign dmi_read_data_dtm = dm_dmi_read_data_dmi;

endmodule
//--------------------------------------------------------------------------
