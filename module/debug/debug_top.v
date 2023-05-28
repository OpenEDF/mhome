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
module debug_top #(
    parameter DMI_ABITIS = `DMI_ABITIS_WIDTH,
    parameter IR_BITS = `IR_BITS_WIDTH
)
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         tck_pad,
    input wire         trst_n_pad,
    input wire         tdi_pad,
    input wire         tms_pad,
    input wire [31:0]  hart_result_read_gprs_dm,  // from register file resutlt read data

    // outputs
    output reg         tdo_pad,
    output wire        dm_haltreq_hart,           // halt hart
    output wire        dm_hartreset_hart,         // reset hart
    output wire [4:0]  dm_access_gprs_index_hart, // access register file number
    output wire [31:0] dm_write_gprs_data_hart,   // write data to register file
    output wire        dm_write_gprs_en_hart      // setup write enable
);

//--------------------------------------------------------------------------
// Design: jtag tap module signal
//--------------------------------------------------------------------------
wire tdo_en_w;
wire tdo_w;
wire [DMI_ABITIS-1:0] dmi_addr_w;
wire [31:0] dmi_write_data_w;
wire dmi_write_en_w;
wire dmi_request_w;
wire dtm_request_ready_dmi_w;
wire dtm_response_ready_dmi_w;

//--------------------------------------------------------------------------
// Design: dmi interface signal
//--------------------------------------------------------------------------
wire [DMI_ABITIS-1:0] dmi_addr_dm_w;
wire [31:0] dmi_write_data_dm_w;
wire dmi_write_en_dm_w;
wire dmi_request_dm_w;

wire dm_dmi_response_w;
wire [1:0]  dm_dmi_op_w;
wire [31:0] dm_dmi_read_data_w;
wire dmi_request_ready_dm_w;
wire dmi_response_ready_dm_w;

//--------------------------------------------------------------------------
// Design: dm csrs signal
//--------------------------------------------------------------------------
wire dm_dmi_response_dmi_w;
wire [1:0]  dm_dmi_op_dmi_w;
wire [31:0] dm_dmi_read_data_dmi_w;

//--------------------------------------------------------------------------
// Design: assign tdo_pad = tdo & tdo_en
//--------------------------------------------------------------------------
always @(tdo_en_w or tdo_w) begin
    if (tdo_en_w) begin
        tdo_pad <= tdo_w;
    end else begin
        tdo_pad <= 1'b0;
    end
end
//--------------------------------------------------------------------------
// Design: instdantiated jtag tap module
//--------------------------------------------------------------------------
jtag_tap #(
    .DMI_ABITS (`DMI_ABITIS_WIDTH),
    .IR_BITS   (`IR_BITS_WIDTH)
) jtag_tap_u (
    .tck              (tck_pad),
    .trst_n           (trst_n_pad),
    .tdi              (tdi_pad),
    .tms              (tms_pad),
    .dm_dmi_response  (dm_dmi_response_w),
    .dm_dmi_request_ready       (dtm_request_ready_dmi_w),
    .dm_dmi_op        (dm_dmi_op_w),
    .dm_dmi_read_data (dm_dmi_read_data_w),

    .tdo_en           (tdo_en_w),
    .tdo              (tdo_w),
    .dmi_dtm_response_ready     (dtm_response_ready_dmi_w),
    .dmi_addr         (dmi_addr_w),
    .dmi_write_data   (dmi_write_data_w),
    .dmi_write_en     (dmi_write_en_w),
    .dmi_request      (dmi_request_w)
);

//--------------------------------------------------------------------------
// Design: instdantiated dm crs module
//--------------------------------------------------------------------------
dm_csrs #(
    .DMI_ABITIS  (`DMI_ABITIS_WIDTH)
) dm_csrs_u (
    .tck                         (tck_pad),
    .trst_n                      (trst_n_pad),
    .dmi_addr_dm                 (dmi_addr_dm_w),
    .dmi_write_data_dm           (dmi_write_data_dm_w),
    .dmi_write_en_dm             (dmi_write_en_dm_w),
    .dmi_request_dm              (dmi_request_dm_w),
    .hart_result_read_gprs_dm    (hart_result_read_gprs_dm ), //I from register file
    .dmi_dtm_response_ready_dm   (dmi_response_ready_dm_w),

    .dm_dmi_response_dmi         (dm_dmi_response_dmi_w),
    .dm_dmi_op_dmi               (dm_dmi_op_dmi_w),
    .dm_dmi_read_data_dmi        (dm_dmi_read_data_dmi_w),
    .dm_haltreq_hart             (dm_haltreq_hart            ), // O to hart
    .dm_hartreset_hart           (dm_hartreset_hart          ), // o to hart
    .dm_access_gprs_index_hart   (dm_access_gprs_index_hart  ), // O to register file
    .dm_write_gprs_data_hart     (dm_write_gprs_data_hart    ), // O
    .dm_write_gprs_en_hart       (dm_write_gprs_en_hart      ), // O
    .dm_dmi_request_ready_dmi    (dmi_request_ready_dm_w     )  // 0
);

//--------------------------------------------------------------------------
// Design: instdantiated dmi interface
//--------------------------------------------------------------------------
dmi_intf #(
    .DMI_ABITIS (`DMI_ABITIS_WIDTH)
) dmi_intf_u(
    .dtm_dmi_addr         (dmi_addr_w),
    .dtm_dmi_write_data   (dmi_write_data_w),
    .dtm_dmi_write_en     (dmi_write_en_w),
    .dtm_dmi_request      (dmi_request_w),
    .dtm_response_ready   (dtm_response_ready_dmi_w),

    .dm_dmi_response_dmi  (dm_dmi_response_dmi_w),
    .dm_dmi_op_dmi        (dm_dmi_op_dmi_w),
    .dm_dmi_read_data_dmi (dm_dmi_read_data_dmi_w),
    .dm_request_ready     (dmi_request_ready_dm_w),

    .dmi_addr_dm          (dmi_addr_dm_w),
    .dmi_write_data_dm    (dmi_write_data_dm_w),
    .dmi_write_en_dm      (dmi_write_en_dm_w),
    .dmi_request_dm       (dmi_request_dm_w),
    .dmi_response_ready_dm (dmi_response_ready_dm_w),

    .dmi_response_dtm     (dm_dmi_response_w),
    .dmi_op_dtm           (dm_dmi_op_w),
    .dmi_read_data_dtm    (dm_dmi_read_data_w),
    .dmi_request_ready_dtm (dtm_request_ready_dmi_w)
);

endmodule
//--------------------------------------------------------------------------
