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
// Brief: debug system top
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "debug_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module debug_top
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         tck_pad,
    input wire         trst_n_pad,
    input wire         tdi_pad,
    input wire         tms_pad,

    // outputs
    output wire        tdo_pad,
);

//--------------------------------------------------------------------------
// Design: jtag tap module signal
//--------------------------------------------------------------------------
wire tdo_en_w;
wire tdo_w;
wire dmi_addr_w;
wire dmi_write_data_w;
wire dmi_write_en_w;
wire dmi_request_w;

//--------------------------------------------------------------------------
// Design: dmi interface signal
//--------------------------------------------------------------------------
wire dmi_addr_dm_w;
wire dmi_write_data_dm_w;
wire dmi_write_en_dm_w;
wire dmi_request_dm_w;

wire dm_dmi_response_w;
wire dm_dmi_op_w;
wire dm_dmi_read_data_w;

//--------------------------------------------------------------------------
// Design: dm csrs signal
//--------------------------------------------------------------------------
wire dm_dmi_response_dmi_w;
wire dm_dmi_op_dmi_w;
wire dm_dmi_read_data_dmi_w;

//--------------------------------------------------------------------------
// Design: assign tdo_pad = tdo & tdo_en
//--------------------------------------------------------------------------
assign tdo_pad = tdo_w & tdo_en_w;

//--------------------------------------------------------------------------
// Design: instdantiated jtag tap module
//--------------------------------------------------------------------------
jtag_tap jtag_tap_u #(
    DMI_ABITS = 6,
    IR_BITS = 5
)
(
    .tck              (tck_pad),
    .trst_n           (trst_n_pad),
    .tdi              (tdi_pad),
    .tms              (tms_pad),
    .dm_dmi_response  (dm_dmi_response_w),
    .dm_dmi_op        (dm_dmi_op_w),
    .dm_dmi_read_data (dm_dmi_read_data_w),

    .tdo_en           (tdo_en_w),
    .tdo              (tdo_w),
    .dmi_addr         (dmi_addr_w),
    .dmi_write_data   (dmi_write_data_w),
    .dmi_write_en     (dmi_write_en_w),
    .dmi_request      (dmi_request_w)
);

//--------------------------------------------------------------------------
// Design: instdantiated dm crs module
//--------------------------------------------------------------------------
dm_csrs dm_csrs_u #(
    DMI_ABITIS = 6
)
(
    .tck                    (tck_pad),
    .trst_n                 (trst_n_tap),
    .dmi_addr_dm            (dmi_addr_dm_w),
    .dmi_write_data_dm      (dmi_write_data_dm_w),
    .dmi_write_en_dm        (dmi_write_en_dm_w),
    .dmi_request_dm         (dmi_request_dm_w),

    .dm_dmi_response_dmi    (dm_dmi_response_dmi_w),
    .dm_dmi_op_dmi          (dm_dmi_op_dmi_w),
    .dm_dmi_read_data_dmi   (dm_dmi_read_data_dmi_w),
);

//--------------------------------------------------------------------------
// Design: instdantiated dmi interface
//--------------------------------------------------------------------------
dmi_intf dmi_intf_u #(
    DMI_ABITIS = 6
)
(
    .dtm_dmi_addr         (dmi_addr_w),
    .dtm_dmi_write_data   (dmi_write_data_w),
    .dtm_dmi_write_en     (dmi_write_en_w),
    .dtm_dmi_request      (dmi_request_w),

    .dm_dmi_response_dmi  (dm_dmi_response_dmi_w),
    .dm_dmi_op_dmi        (dm_dmi_op_dmi_w),
    .dm_dmi_read_data_dmi (dm_dmi_read_data_dmi_w),

    .dmi_addr_dm          (dmi_addr_dm_w),
    .dmi_write_data_dm    (dmi_write_data_dm_w),
    .dmi_write_en_dm      (dmi_write_en_dm_w),
    .dmi_request_dm       (dmi_request_dm_w),

    .dmi_response_dtm     (dm_dmi_response_w),
    .dmi_op_dtm           (dm_dmi_op_w),
    .dmi_read_data_dtm    (dm_dmi_read_data_w)
);

endmodule
//--------------------------------------------------------------------------
