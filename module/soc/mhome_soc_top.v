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
`include "mhome_defines.v"
`include "debug_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module mhome_soc_top
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         sys_clk,
    input wire         sys_rst_n,
    // debug jtag port
    input wire         tck_pad,
    input wire         trst_n_pad,
    input wire         tdi_pad,
    input wire         tms_pad,

    // outputs
    output wire        tdo_pad,
    output wire        sys_led
);

//--------------------------------------------------------------------------
// Design: mhome riscv soc internal signal
//--------------------------------------------------------------------------
wire        dm_haltreq_hart_w;           // halt hart
wire        dm_hartreset_hart_w;         // reset hart
wire [4:0]  dm_access_gprs_index_hart_w; // access register file number
wire [31:0] dm_write_gprs_data_hart_w;   // write data to register file
wire        dm_write_gprs_en_hart_w;     // setup write enable
wire [31:0] hart_result_read_gprs_dm_w;  // register return data

//--------------------------------------------------------------------------
// Design: mhome riscv soc
//--------------------------------------------------------------------------
riscv_pipeline riscv_pipeline_u(
    .sys_clk         (sys_clk),
    .sys_rst_n       (sys_rst_n),
    .dm_access_gprs_index_hart   (dm_access_gprs_index_hart_w),
    .dm_write_gprs_data_hart     (dm_write_gprs_data_hart_w),
    .dm_write_gprs_en_hart       (dm_write_gprs_en_hart_w),

    .hart_result_read_gprs_dm    (hart_result_read_gprs_dm_w),
    .sys_led                     (sys_led)
);

//--------------------------------------------------------------------------
// Design: mhome instantiated debug system module
//--------------------------------------------------------------------------
debug_top #(
    .DMI_ABITIS  (`DMI_ABITIS_WIDTH),
    .IR_BITS     (`IR_BITS_WIDTH)
) debug_top_u (
    .tck_pad                    (tck_pad                     ), // I
    .trst_n_pad                 (trst_n_pad                  ), // I
    .tdi_pad                    (tdi_pad                     ), // I
    .tms_pad                    (tms_pad                     ), // I
    .hart_result_read_gprs_dm   (hart_result_read_gprs_dm_w  ), // I

    .tdo_pad                    (tdo_pad                     ), // O
    .dm_haltreq_hart            (dm_haltreq_hart_w           ), // O halt hart
    .dm_hartreset_hart          (dm_hartreset_hart_w         ), // O reset hart
    .dm_access_gprs_index_hart  (dm_access_gprs_index_hart_w ), // O access register file number
    .dm_write_gprs_data_hart    (dm_write_gprs_data_hart_w   ), // O write data to register file
    .dm_write_gprs_en_hart      (dm_write_gprs_en_hart_w     ) // O setup write enable
);

endmodule
//--------------------------------------------------------------------------
