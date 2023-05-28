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
// Brief: Debug Module
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "debug_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module dm_csrs #(
    parameter DMI_ABITIS = 8
)
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs from dmi interface
    input wire                   tck,
    input wire                   trst_n,
    input wire [DMI_ABITIS-1:0]  dmi_addr_dm,
    input wire [31:0]            dmi_write_data_dm,
    input wire                   dmi_write_en_dm,
    input wire                   dmi_request_dm,
    input wire [31:0]            hart_result_read_gprs_dm,
    input wire                   dmi_dtm_response_ready_dm,

    // outputs to dmi interface
    output reg                   dm_dmi_response_dmi,
    output reg [1:0]             dm_dmi_op_dmi,
    output reg [31:0]            dm_dmi_read_data_dmi,
    output reg                   dm_dmi_request_ready_dmi,

    // output to hart
    output reg                   dm_haltreq_hart,
    output reg                   dm_hartreset_hart,
    output reg [4:0]             dm_access_gprs_index_hart,
    output reg [31:0]            dm_write_gprs_data_hart,
    output reg                   dm_write_gprs_en_hart
);

//--------------------------------------------------------------------------
// Design: debug module internal signal
//--------------------------------------------------------------------------
reg         dm_dmi_response_dmi_r;
reg [1:0]   dm_dmi_op_dmi_r;
reg [31:0]  dm_dmi_read_data_dmi_r;
reg         abstract_cmd_read_gprs;
reg         dm_write_gprs_en_hart_r;
reg [31:0]  dm_write_gprs_data_hart_r;
reg [4:0]   dm_access_gprs_index_hart_r;

//--------------------------------------------------------------------------
// Design: debug module csrs
//--------------------------------------------------------------------------
reg [31:0] data0; //must impletement for regiuster access
reg [31:0] data1;
reg [31:0] data2;
reg [31:0] data3;
reg [31:0] dmcontrol;
reg [31:0] dmstatus;
reg [31:0] hardinfo;
reg [31:0] haltsum1;
reg [31:0] hawindowsel;
reg [31:0] hawindow;
reg [31:0] abstractcs;
reg [31:0] command;
reg [31:0] abstractauto;
reg [31:0] confstrptr0;
reg [31:0] confstrptr1;
reg [31:0] confstrptr2;
reg [31:0] confstrptr3;
reg [31:0] nextdm;
reg [31:0] custom;
reg [31:0] progbuf0;
reg [31:0] progbuf1;
reg [31:0] progbuf2;
reg [31:0] progbuf3;
reg [31:0] progbuf4;
reg [31:0] progbuf5;
reg [31:0] progbuf6;
reg [31:0] progbuf7;
reg [31:0] progbuf8;
reg [31:0] progbuf9;
reg [31:0] progbuf10;
reg [31:0] progbuf11;
reg [31:0] progbuf12;
reg [31:0] progbuf13;
reg [31:0] progbuf14;
reg [31:0] progbuf15;
reg [31:0] authdata;
reg [31:0] dmcs2;
reg [31:0] haltsum2;
reg [31:0] haltsum3;
reg [31:0] sbaaddress3;
reg [31:0] sbcs;
reg [31:0] sbaaddress0;
reg [31:0] sbaaddress1;
reg [31:0] sbaaddress2;
reg [31:0] sbdata0;
reg [31:0] sbdata1;
reg [31:0] sbdata2;
reg [31:0] sbdata3;
reg [31:0] haltsum0;
reg [31:0] customs0;
reg [31:0] customs1;
reg [31:0] customs2;
reg [31:0] customs3;
reg [31:0] customs4;
reg [31:0] customs5;
reg [31:0] customs6;
reg [31:0] customs7;
reg [31:0] customs8;
reg [31:0] customs9;
reg [31:0] customs10;
reg [31:0] customs11;
reg [31:0] customs12;
reg [31:0] customs13;
reg [31:0] customs14;
reg [31:0] customs15;

//--------------------------------------------------------------------------
// Design: debug module csrs local address
//--------------------------------------------------------------------------
localparam DATA0        = 8'h04;
localparam DATA1        = 8'h05;
localparam DATA2        = 8'h06;
localparam DATA3        = 8'h07;
localparam DMCONTROL    = 8'h10;
localparam DMSTATUS     = 8'h11;
localparam HARDINFO     = 8'h12;
localparam HALTSUM1     = 8'h13;
localparam HAWINDOWSEL  = 8'h14;
localparam HAWINDOW     = 8'h15;
localparam ABSTRACTCS   = 8'h16;
localparam COMMAND      = 8'h17;
localparam ABSTRACTAUTO = 8'h18;
localparam CONFSTRPTR0  = 8'h19;
localparam CONFSTRPTR1  = 8'h1A;
localparam CONFSTRPTR2  = 8'h1B;
localparam CONFSTRPTR3  = 8'h1C;
localparam NEXTDM       = 8'h1D;
localparam CUSTOM       = 8'h1F;
localparam PROGBUF0     = 8'h20;
localparam PROGBUF1     = 8'h21;
localparam PROGBUF2     = 8'h22;
localparam PROGBUF3     = 8'h23;
localparam PROGBUF4     = 8'h24;
localparam PROGBUF5     = 8'h25;
localparam PROGBUF6     = 8'h26;
localparam PROGBUF7     = 8'h27;
localparam PROGBUF8     = 8'h28;
localparam PROGBUF9     = 8'h29;
localparam PROGBUF10    = 8'h2A;
localparam PROGBUF11    = 8'h2B;
localparam PROGBUF12    = 8'h2C;
localparam PROGBUF13    = 8'h2D;
localparam PROGBUF14    = 8'h2E;
localparam PROGBUF15    = 8'h2F;
localparam AUTHDATA     = 8'h30;
localparam DMCS2        = 8'h32;
localparam HALTSUM2     = 8'h34;
localparam HALTSUM3     = 8'h35;
localparam SBAADDRESS3  = 8'h37;
localparam SBCS         = 8'h38;
localparam SBAADDRESS0  = 8'h39;
localparam SBAADDRESS1  = 8'h3A;
localparam SBAADDRESS2  = 8'h3B;
localparam SBDATA0      = 8'h3C;
localparam SBDATA1      = 8'h3D;
localparam SBDATA2      = 8'h3E;
localparam SBDATA3      = 8'h3F;
localparam HALTSUM0     = 8'h40;
localparam CUSTOMS0     = 8'h70;
localparam CUSTOMS1     = 8'h71;
localparam CUSTOMS2     = 8'h72;
localparam CUSTOMS3     = 8'h73;
localparam CUSTOMS4     = 8'h74;
localparam CUSTOMS5     = 8'h75;
localparam CUSTOMS6     = 8'h76;
localparam CUSTOMS7     = 8'h77;
localparam CUSTOMS8     = 8'h78;
localparam CUSTOMS9     = 8'h79;
localparam CUSTOMS10    = 8'h7A;
localparam CUSTOMS11    = 8'h7B;
localparam CUSTOMS12    = 8'h7C;
localparam CUSTOMS13    = 8'h7D;
localparam CUSTOMS14    = 8'h7E;
localparam CUSTOMS15    = 8'h7F;
localparam ACCESS_REGISTER = 8'h00;
localparam QUICK_ACCESS    = 8'h01;
localparam ACCESS_MEMORY   = 8'h02;

//--------------------------------------------------------------------------
// Design: dm module inteal control signal
//--------------------------------------------------------------------------
wire abstractcs_busy;
wire [2:0] abstractcs_cmderr;
wire cur_cmd_exe_busy;
wire haltreq;
wire hartreset;
wire resumereq;
wire ackhaverset;
wire [2:0] aarsize;
wire write;
wire transfer;
wire [15:0] regno;
wire [7:0] cmdtype;
assign abstractcs_busy   = abstractcs[12];
assign abstractcs_cmderr = abstractcs[10:8];
assign cur_cmd_exe_busy  = abstractcs[12];
assign haltreq     = dmcontrol[31];
assign resumereq   = dmcontrol[30];
assign ackhaverset = dmcontrol[28];
assign hartreset   = dmcontrol[29];
reg abstract_cmd_exe;   /* abstract command will be executed */
assign aarsize  = command[22:20];
assign write    = command[16];
assign transfer = command[17];
assign regno    = command[15:0];
assign cmdtype  = command[31:24];

//--------------------------------------------------------------------------
// Design: dtm wirte and read dm csrs sequential circuit
//         When read, unimplemented or non-existent Debug Module DMI
//         Registers return 0. Writing them has no effect.
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        data0 <= 32'h0000_0000;
        data1 <= 32'h0000_0000;
        data2 <= 32'h0000_0000;
        data3 <= 32'h0000_0000;
        dmcontrol <= 32'h0000_0000;
        /* dmi response data */
        dm_dmi_response_dmi_r  <= 1'b0;
        dm_dmi_read_data_dmi_r <= 32'h0000_0000;
        dm_dmi_op_dmi_r        <= `DMI_OP_SUCCESS;
    end else begin
        if (dmi_request_dm & dmi_write_en_dm) begin: write_dm_csrs /* write */
            /* common */
            dm_dmi_response_dmi_r  <= 1'b1;
            dm_dmi_read_data_dmi_r <= 32'h0000_0000;
            case (dmi_addr_dm)
                DATA0: begin
                    if (abstractcs_busy) begin
                        dm_dmi_op_dmi_r <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        data0 <= dmi_write_data_dm;
                        dm_dmi_op_dmi_r <= `DMI_OP_SUCCESS;
                    end
                end
                DATA1: begin
                    if (abstractcs_busy) begin
                        dm_dmi_op_dmi_r <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        data1 <= dmi_write_data_dm;
                        dm_dmi_op_dmi_r <= `DMI_OP_SUCCESS;
                    end
                end
                DATA2: begin
                    if (abstractcs_busy) begin
                        dm_dmi_op_dmi_r <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        data2 <= dmi_write_data_dm;
                        dm_dmi_op_dmi_r <= `DMI_OP_SUCCESS;
                    end
                end
                DATA3: begin
                    if (abstractcs_busy) begin
                        dm_dmi_op_dmi_r <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        data3 <= dmi_write_data_dm;
                        dm_dmi_op_dmi_r <= `DMI_OP_SUCCESS;
                    end
                end
                DMCONTROL:begin
                    if (abstractcs_busy) begin
                        dm_dmi_op_dmi_r <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        dmcontrol       <= dmi_write_data_dm;
                        dm_dmi_op_dmi_r <= `DMI_OP_SUCCESS;
                    end
                end
                COMMAND: begin
                    if ((abstractcs_cmderr == `CMDERR_NONE) & !cur_cmd_exe_busy & !haltreq & !resumereq & !ackhaverset) begin
                        command          <= dmi_write_data_dm;
                        abstractcs[10:8] <= `CMDERR_BUSY;   /* TODO: error, only output signal  */
                        abstractcs[12]   <= 1'b1;
                        abstract_cmd_exe <= 1'b1;
                        dm_dmi_op_dmi_r <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        abstract_cmd_exe <= 1'b0;
                        command          <= command;
                        abstractcs[10:8] <= abstractcs[10:8];
                        dm_dmi_op_dmi_r <= `DMI_OP_SUCCESS;
                    end
                end
                default: begin
                    dm_dmi_op_dmi_r        <= `DMI_OP_FAILED;
                end
            endcase
        end else if (dmi_request_dm & !dmi_write_en_dm) begin: read_dm_csrs   /* read */
            /* common */
            dm_dmi_response_dmi_r  <= 1'b1;
            dm_dmi_read_data_dmi_r <= 32'h0000_0000;
            case (dmi_addr_dm)
                DATA0: begin
                    if (abstractcs_cmderr == `CMDERR_BUSY) begin
                        dm_dmi_op_dmi_r        <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        if (abstract_cmd_read_gprs) begin
                            /* copy data from the register specified by regno into the
                             * arg0 region of data
                             */
                            dm_dmi_read_data_dmi_r <= hart_result_read_gprs_dm;
                            dm_dmi_op_dmi_r        <= `DMI_OP_SUCCESS;
                         end else begin
                            dm_dmi_read_data_dmi_r <= data0;
                            dm_dmi_op_dmi_r        <= `DMI_OP_SUCCESS;
                         end
                    end
                end
                DATA1: begin
                    if (abstractcs_cmderr == `CMDERR_BUSY) begin
                        dm_dmi_op_dmi_r        <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        dm_dmi_read_data_dmi_r <= data1;
                        dm_dmi_op_dmi_r        <= `DMI_OP_SUCCESS;
                    end
                end
                DATA2: begin
                    if (abstractcs_cmderr == `CMDERR_BUSY) begin
                        dm_dmi_op_dmi_r        <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        dm_dmi_read_data_dmi_r <= data2;
                        dm_dmi_op_dmi_r        <= `DMI_OP_SUCCESS;
                    end
                end
                DATA3: begin
                    if (abstractcs_cmderr == `CMDERR_BUSY) begin
                        dm_dmi_op_dmi_r        <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        dm_dmi_read_data_dmi_r <= data3;
                        dm_dmi_op_dmi_r        <= `DMI_OP_SUCCESS;
                    end
                end
                DMCONTROL: begin
                    if (abstractcs_cmderr == `CMDERR_BUSY) begin
                        dm_dmi_op_dmi_r        <= `DMI_OP_IN_PROGRESS;
                    end else begin
                        dm_dmi_read_data_dmi_r <= dmcontrol;
                        dm_dmi_op_dmi_r        <= `DMI_OP_SUCCESS;
                    end
                end
                default: begin
                    /* When read, unimplemented or non-existent Debug Module DMI
                    * Registers return 0. Writing them has no effect.
                    * */
                    dm_dmi_op_dmi_r        <= `DMI_OP_FAILED;
                end
            endcase
        end else begin
            /* TODO: internal register self update */
            dm_dmi_response_dmi_r  <= dm_dmi_response_dmi_r;
            dm_dmi_read_data_dmi_r <= dm_dmi_read_data_dmi_r;
            dm_dmi_op_dmi_r        <= dm_dmi_op_dmi_r;
        end
    end
end

//--------------------------------------------------------------------------
// Design: dm update the result and status to dmi interface
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        dm_dmi_response_dmi   <= 1'b0;
        dm_dmi_op_dmi         <= 2'b00;
        dm_dmi_read_data_dmi  <= 32'h0000_0000;
    end else if (dmi_dtm_response_ready_dm) begin
        dm_dmi_response_dmi   <= dm_dmi_response_dmi_r;
        dm_dmi_op_dmi         <= dm_dmi_op_dmi_r;
        dm_dmi_read_data_dmi  <= dm_dmi_read_data_dmi_r;
    end else begin
        dm_dmi_response_dmi   <= dm_dmi_response_dmi;
        dm_dmi_op_dmi         <= dm_dmi_op_dmi;
        dm_dmi_read_data_dmi  <= dm_dmi_read_data_dmi;
    end
end

//--------------------------------------------------------------------------
// Design: dm csrs control halt hart
//--------------------------------------------------------------------------
always @(haltreq) begin
    if (haltreq) begin
        dm_haltreq_hart <= 1'b1;
    end else begin
        dm_haltreq_hart <= 1'b0;
    end
end

//--------------------------------------------------------------------------
// Design: dm csrs control reset hart
//--------------------------------------------------------------------------
always @(hartreset) begin
    if (hartreset) begin
        dm_hartreset_hart = 1'b1;
    end else begin
        dm_hartreset_hart = 1'b0;
    end
end

//--------------------------------------------------------------------------
// Design: dtm can initiate a new request
//--------------------------------------------------------------------------
always @(abstractcs_cmderr) begin
    if (abstractcs_cmderr != `CMDERR_NONE) begin
        dm_dmi_request_ready_dmi <= 1'b0;
    end else begin
        dm_dmi_request_ready_dmi <= 1'b1;
    end
end

//--------------------------------------------------------------------------
// Design: dm paraes abstract commands to get specific access signals
//--------------------------------------------------------------------------
always @(abstract_cmd_exe or cmdtype or aarsize or write or transfer or regno or data0 or command) begin
    dm_write_gprs_en_hart_r     <= 1'b0;
    abstract_cmd_read_gprs      <= 1'b0;
    dm_write_gprs_data_hart_r   <= 32'h0000_0000;
    dm_access_gprs_index_hart_r <= 5'b00000;
    if (abstract_cmd_exe) begin
        case(cmdtype)
            ACCESS_REGISTER: begin /* access GPRs and CSRs FGPRs */
                if (aarsize != `ACCESS_32BIT_GPRS) begin
                    //abstractcs[10:8] <= `CMDERR_NOT_SUPPORT; TODO: macro
                    //modify output control change conift
                end else if (write & transfer) begin /* cp data0 to regno */
                    /* TODO: impletemnet access CSRs Floating GPRs*/
                    /* GPRs */
                    if ((regno >= 16'h1000) && (regno <= 16'h101F)) begin
                        dm_write_gprs_en_hart_r     <= 1'b1;
                        dm_write_gprs_data_hart_r   <= data0;
                        dm_access_gprs_index_hart_r <= command[4:0];
                    end else begin
                    /* other */
                        dm_write_gprs_en_hart_r     <= 1'b0;
                        dm_write_gprs_data_hart_r   <= 32'h0000_0000;
                        dm_access_gprs_index_hart_r <= 5'b00000;
                    end
                end else if (!write & transfer) begin /* cp regno to data0 */
                    /* GPRs */
                    if ((regno >= 16'h1000) && (regno <= 16'h101F)) begin
                        dm_write_gprs_en_hart_r     <= 1'b0;
                        dm_access_gprs_index_hart_r <= command[4:0];
                        abstract_cmd_read_gprs      <= 1'b1;
                    end else begin
                    /* other */
                        dm_write_gprs_en_hart_r     <= 1'b0;
                        dm_access_gprs_index_hart_r <= 5'b00000;
                        abstract_cmd_read_gprs      <= 1'b0;
                    end
                end else begin
                    //abstractcs[10:8] <= `CMDERR_NONE;
                    dm_write_gprs_en_hart_r     <= 1'b0;
                    dm_write_gprs_data_hart_r   <= 32'h0000_0000;
                    dm_access_gprs_index_hart_r <= 5'b00000;
                end
            end
            QUICK_ACCESS: begin
            end
            ACCESS_MEMORY: begin
            end
            default: begin
            end
        endcase
    end else begin
        abstract_cmd_read_gprs      <= 1'b0;
        dm_write_gprs_en_hart_r     <= 1'b0;
    end
end

//--------------------------------------------------------------------------
// Design: dm access register file
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        dm_write_gprs_en_hart     <= 1'b0;
        dm_write_gprs_data_hart   <= 32'h0000_0000;
        dm_access_gprs_index_hart <= 5'b00000;
    end else begin
        dm_write_gprs_en_hart     <= dm_write_gprs_en_hart_r;
        dm_write_gprs_data_hart   <= dm_write_gprs_data_hart_r;
        dm_access_gprs_index_hart <= dm_access_gprs_index_hart_r;
    end
end

//--------------------------------------------------------------------------
// Design: dm access hart csrs
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Design: dm access system memory by ahb master port
//--------------------------------------------------------------------------

endmodule
//--------------------------------------------------------------------------
