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
// Brief: Debug transport Module
// Change Log:
// Design think:
//       cur_satte--->state output--->tdo update state ---> tdo
//                                        |
//                                        |
//                                  dmi  <-
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Include File
//--------------------------------------------------------------------------
`include "debug_defines.v"

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module jtag_tap #(
    parameter DMI_ABITS = 8,
    parameter IR_BITS = 5
)
//--------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------
(
    // inputs
    input wire         tck,
    input wire         trst_n,
    input wire         tdi,
    input wire         tms,
    input wire         dm_dmi_response,
    input wire         dm_dmi_request_ready,
    input [1:0]        dm_dmi_op,
    input [31:0]       dm_dmi_read_data,

    // outputs
    output reg                  tdo_en,
    output reg                  tdo,
    output reg                  dmi_dtm_response_ready,
    output reg [DMI_ABITS-1:0]  dmi_addr,
    output reg [31:0]           dmi_write_data,
    output reg                  dmi_write_en,
    output reg                  dmi_request
);

//--------------------------------------------------------------------------
// Design: TAP controller register bit width
//--------------------------------------------------------------------------
parameter DMI_OP_BITS = 2;
parameter DMI_DATA_BITS = 32;
parameter DMI_BITS = DMI_ABITS + DMI_DATA_BITS + DMI_OP_BITS;

//--------------------------------------------------------------------------
// Design:DD TAP controller state assignments
//--------------------------------------------------------------------------
localparam EXIT2_DR          = 4'h0;
localparam EXIT1_DR          = 4'h1;
localparam SHIFT_DR          = 4'h2;
localparam PAUSE_DR          = 4'h3;
localparam SELECT_IR_SCAN    = 4'h4;
localparam UPDATE_DR         = 4'h5;
localparam CAPTURE_DR        = 4'h6;
localparam SELECT_DR_SCAN    = 4'h7;
localparam EXIT2_IR          = 4'h8;
localparam EXIT1_IR          = 4'h9;
localparam SHIFT_IR          = 4'hA;
localparam PAUSE_IR          = 4'hB;
localparam RUN_TEST_IDLE     = 4'hC;
localparam UPDATE_IR         = 4'hD;
localparam CAPTURE_IR        = 4'hE;
localparam TEST_LOGIC_RESET  = 4'hF;

//--------------------------------------------------------------------------
// Design: JTAG DTM Register address
//--------------------------------------------------------------------------
localparam BYPASS0_ADDR = 5'b00000;
localparam IDCODE_ADDR  = 5'b00001;
localparam DTMCS_ADDR   = 5'b10000;
localparam DMI_ADDR     = 5'b10001;
localparam BYPASS1_ADDR = 5'b11111;

//--------------------------------------------------------------------------
// Design: Version described in spec versions 0.13 and 1.0.
//--------------------------------------------------------------------------
localparam DTM_VERSION_013_AND_10 = 4'b0001;

//--------------------------------------------------------------------------
// Design: JTAG DTM TAP Register
//--------------------------------------------------------------------------
reg [31:0]         idcode;
reg [31:0]         dtmcs;
reg [DMI_BITS-1:0] dmi;  // ABITS = 8
reg [DMI_BITS-1:0] dmi_neg;
reg [DMI_BITS-1:0] dr_shift;
reg                bypass0; /* addr: 5'b00000 */
reg                bypass1; /* addr: 5'b11111 */
reg [IR_BITS-1:0]  ir_shift;
reg [IR_BITS-1:0]  ir_latched;
reg [IR_BITS-1:0]  ir_latched_neg;
reg                idcode_select;
reg                dtmcs_select;
reg                dmi_select;
reg                dmi_select_neg;
reg                bypass0_select;
reg                bypass1_select;

//--------------------------------------------------------------------------
// Design: JTAG TAP shift output signal
//--------------------------------------------------------------------------
reg idcode_tdo;
reg dtmcs_tdo;
reg dmi_tdo;
reg bypass0_tdo;
reg bypass1_tdo;
reg instruction_tdo;

//--------------------------------------------------------------------------
// Design: TAP state Register
//--------------------------------------------------------------------------
reg test_logic_reset;
reg run_test_idle;
reg select_dr_scan;
reg capture_dr;
reg shift_dr;
reg exit1_dr;
reg pause_dr;
reg exit2_dr;
reg update_dr;
reg update_dr_neg;
reg select_ir_scan;
reg capture_ir;
reg shift_ir;
reg shift_ir_neg;
reg exit1_ir;
reg pause_ir;
reg exit2_ir;
reg update_ir;
reg [3:0] tap_cur_state;
reg [3:0] tap_next_state;

//--------------------------------------------------------------------------
// Design: update the dmi request and write enable signal sccroding dmi
//         op feild
//--------------------------------------------------------------------------
wire [DMI_ABITS-1:0]  dmi_addr_w;
wire [31:0] dmi_write_data_w;
wire [1:0]  dmi_op_w;
wire dmi_write_en_w;
wire dmi_request_w;
assign dmi_addr_w = dmi_neg[DMI_BITS-1:34];  //TODO: spyglass check lint
assign dmi_write_data_w = dmi_neg[33:2];
assign dmi_op_w = dmi_neg[1:0];
assign dmi_write_en_w = (dmi_op_w == 2'b10) ? 1'b1 : 1'b0;
assign dmi_request_w = ((dmi_op_w == 2'b00) && (dmi_op_w == 2'b11)) ? 1'b0 : 1'b1;

//--------------------------------------------------------------------------
// Design: DTM internal control signal
//--------------------------------------------------------------------------
wire dmihardreset;
wire dmireset;
wire [2:0] idle;
wire [1:0] dmistat;
assign dmihardreset = dtmcs[17];
assign dmireset = dtmcs[16];
assign idle = dtmcs[14:12];
assign dmistat = dtmcs[11:10];
reg enter_idle_leave_imm;
reg enter_idle_stay_1_cycle;

//--------------------------------------------------------------------------
// Design: TAP controller state update by clock
// Note:   SYNTH_149 (5) : Only '==' and '!=' binary operators are allowed
//         in validation of the reset/set condition.
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        tap_cur_state <= TEST_LOGIC_RESET;
    end else if (dmihardreset) begin
        tap_cur_state <= TEST_LOGIC_RESET;
    end else begin
        tap_cur_state <= tap_next_state;
    end
end

//--------------------------------------------------------------------------
// Design: TAP controller FSM
//--------------------------------------------------------------------------
always @(*) begin
    case (tap_cur_state)
        TEST_LOGIC_RESET:
            tap_next_state = (tms) ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
        RUN_TEST_IDLE:
            tap_next_state = ((tms) ? SELECT_DR_SCAN : RUN_TEST_IDLE) | enter_idle_leave_imm | enter_idle_stay_1_cycle;
        SELECT_DR_SCAN:
            tap_next_state = (tms) ? SELECT_IR_SCAN : CAPTURE_DR;
        CAPTURE_DR:
            tap_next_state = (tms) ? EXIT1_DR : SHIFT_DR;
        SHIFT_DR:
            tap_next_state = (tms) ? EXIT1_DR : SHIFT_DR;
        EXIT1_DR:
            tap_next_state = (tms) ? UPDATE_DR : PAUSE_DR;
        PAUSE_DR:
            tap_next_state = (tms) ? EXIT2_DR : PAUSE_DR;
        EXIT2_DR:
            tap_next_state = (tms) ? UPDATE_DR : SHIFT_DR;
        UPDATE_DR:
            tap_next_state = (tms) ? SELECT_DR_SCAN : RUN_TEST_IDLE;
        SELECT_IR_SCAN:
            tap_next_state = (tms) ? TEST_LOGIC_RESET : CAPTURE_IR;
        CAPTURE_IR:
            tap_next_state = (tms) ? EXIT1_IR : SHIFT_IR;
        SHIFT_IR:
            tap_next_state = (tms) ? EXIT1_IR : SHIFT_IR;
        EXIT1_IR:
            tap_next_state = (tms) ? UPDATE_IR : PAUSE_IR;
        PAUSE_IR:
            tap_next_state = (tms) ? EXIT2_DR : PAUSE_IR;
        EXIT2_IR:
            tap_next_state = (tms) ? UPDATE_IR : SHIFT_IR;
        UPDATE_IR:
            tap_next_state = (tms) ? SELECT_DR_SCAN : RUN_TEST_IDLE;
        default:
            tap_next_state = tap_next_state;
    endcase
end

//--------------------------------------------------------------------------
// Design: TAP controller FSM output
//         TODO: deleted the unused signal
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        test_logic_reset <= 1'b0;
        run_test_idle    <= 1'b0;
        select_dr_scan   <= 1'b0;
        capture_dr       <= 1'b0;
        shift_dr         <= 1'b0;
        //exit1_dr         <= 1'b0;
        //pause_dr         <= 1'b0;
        //exit2_dr         <= 1'b0;
        update_dr        <= 1'b0;
        select_ir_scan   <= 1'b0;
        capture_ir       <= 1'b0;
        shift_ir         <= 1'b0;
        //exit1_ir         <= 1'b0;
        //pause_ir         <= 1'b0;
        //exit2_ir         <= 1'b0;
        update_ir        <= 1'b0;
    end else if (dmihardreset) begin
        test_logic_reset <= 1'b0;
        run_test_idle    <= 1'b0;
        select_dr_scan   <= 1'b0;
        capture_dr       <= 1'b0;
        shift_dr         <= 1'b0;
        //exit1_dr         <= 1'b0;
        //pause_dr         <= 1'b0;
        //exit2_dr         <= 1'b0;
        update_dr        <= 1'b0;
        select_ir_scan   <= 1'b0;
        capture_ir       <= 1'b0;
        shift_ir         <= 1'b0;
        //exit1_ir         <= 1'b0;
        //pause_ir         <= 1'b0;
        //exit2_ir         <= 1'b0;
        update_ir        <= 1'b0;
    end else begin
        test_logic_reset <= 1'b0;
        run_test_idle    <= 1'b0;
        select_dr_scan   <= 1'b0;
        capture_dr       <= 1'b0;
        shift_dr         <= 1'b0;
        //exit1_dr         <= 1'b0;
        //pause_dr         <= 1'b0;
        //exit2_dr         <= 1'b0;
        update_dr        <= 1'b0;
        select_ir_scan   <= 1'b0;
        capture_ir       <= 1'b0;
        shift_ir         <= 1'b0;
        //exit1_ir         <= 1'b0;
        //pause_ir         <= 1'b0;
        //exit2_ir         <= 1'b0;
        update_ir        <= 1'b0;
        case (tap_cur_state)
            TEST_LOGIC_RESET: test_logic_reset <= 1'b1;
            RUN_TEST_IDLE:    run_test_idle    <= 1'b1;
            SELECT_DR_SCAN:   select_dr_scan   <= 1'b1;
            CAPTURE_DR:       capture_dr       <= 1'b1;
            SHIFT_DR:         shift_dr         <= 1'b1;
            EXIT1_DR:         exit1_dr         <= 1'b1;
            PAUSE_DR:         pause_dr         <= 1'b1;
            EXIT2_DR:         exit2_dr         <= 1'b1;
            UPDATE_DR:        update_dr        <= 1'b1;
            SELECT_IR_SCAN:   select_ir_scan   <= 1'b1;
            CAPTURE_IR:       capture_ir       <= 1'b1;
            SHIFT_IR:         shift_ir         <= 1'b1;
            EXIT1_IR:         exit1_ir         <= 1'b1;
            PAUSE_IR:         pause_ir         <= 1'b1;
            EXIT2_IR:         exit2_ir         <= 1'b1;
            UPDATE_IR:        update_ir        <= 1'b1;
            default:          test_logic_reset <= 1'b1;
        endcase
    end
end

//--------------------------------------------------------------------------
// Design: update the value of instruction register
//         The two least significant instruction register cells (i.e.,
//         those nearest the serial output) shall load a fixed
//         binary “01” pattern (the 1 into the least significant bit
//         location) in the Capture-IR TAP controller state (see
//         7.2) page: 46, 7.1.1 Specifications
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        ir_shift   <= IDCODE_ADDR;
        ir_latched <= ir_shift;    //ir_latched = IDCODE_ADDR
    end else if (dmihardreset) begin
        ir_shift   <= IDCODE_ADDR;
        ir_latched <= ir_shift;    //ir_latched = IDCODE_ADDR
    end else begin
        if (test_logic_reset) begin
            ir_shift   <= IDCODE_ADDR;
            ir_latched <= ir_shift;
            end else if (shift_ir) begin
                ir_shift <= {tdi, ir_shift[IR_BITS-1:1]};
            end else if (capture_ir) begin
                ir_shift <= {{IR_BITS-1{1'b0}}, 1'b1}; /* 7.1.1 Specifications fiex two least "01" */
            end else if (update_ir) begin
                ir_latched <= ir_shift;
            end else begin
                ir_shift   <= ir_shift;
                ir_latched <= ir_latched;
            end
    end
end

//--------------------------------------------------------------------------
// Design: update the data register
//         DTM update dmi op and data register
//         TODO: will DTM wait for data and status adfer read/write request,
//         and the there will be competition
//         dmi_op: 2/3: This status is sticky and can be cleared by writing
//                    dmireset in dtmcs.
//                 0: The previous operation completed successfully
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        idcode <= {`IDCODE_VERSION, `IDCODE_PART_NUMBER, `IDCODE_MANUFID, 1'b1};
        dtmcs  <= {14'b0, 1'b0, 1'b0, 1'b0, 3'b000, 2'b00, DMI_ABITS[5:0], DTM_VERSION_013_AND_10};
        dmi    <= {DMI_BITS{1'b0}};
        bypass0 <= 1'b0;
        bypass1 <= 1'b0;
        dmi_dtm_response_ready <= 1'b0;
    end else if (test_logic_reset | dmihardreset) begin
        idcode <= {`IDCODE_VERSION, `IDCODE_PART_NUMBER, `IDCODE_MANUFID, 1'b1};
        dtmcs  <= {14'b0, 1'b0, 1'b0, 1'b0, 3'b000, 2'b00, DMI_ABITS[5:0], DTM_VERSION_013_AND_10};
        dmi    <= {DMI_BITS{1'b0}};
        bypass0 <= 1'b0;
        bypass1 <= 1'b0;
        dmi_dtm_response_ready <= 1'b0;
    end else begin
        dmi_dtm_response_ready <= 1'b1;
        if (capture_dr) begin
            if (idcode_select) begin
                dr_shift[31:0] <= idcode;
            end else if (dtmcs_select) begin
                dr_shift[31:0] <= dtmcs;
            end else if (dmi_select) begin
                dr_shift       <= dmi;
                dmi_dtm_response_ready <= 1'b0;
            end else if (bypass0_select) begin
                dr_shift[0]    <= bypass0;
            end else if (bypass1_select) begin
                dr_shift[0]    <= bypass1;
            end else begin
                dr_shift       <= dr_shift; // TODO: bypass?
            end
        end else if (shift_dr) begin
            if (idcode_select | dtmcs_select) begin
                dr_shift[31:0] <= {tdi, dr_shift[31:1]};
            end else if (dmi_select) begin
                dr_shift       <= {tdi, dr_shift[DMI_BITS-1:1]};
            end else if (bypass0_select | bypass1_select) begin
                dr_shift[0]    <= tdi;
            end else begin
                dr_shift       <= dr_shift;
            end
        end else if (update_dr) begin
            if (idcode_select) begin
                idcode         <= dr_shift[31:0];
            end else if (dtmcs_select) begin
                dtmcs          <= dr_shift[31:0];
            end else if (dmi_select) begin
                dmi_dtm_response_ready <= 1'b0;
                dmi            <= dr_shift;
             end else if (bypass0_select) begin
                bypass0        <= dr_shift[0];
            end else if (bypass1_select) begin
                bypass1        <= dr_shift[0];
            end else begin
                bypass1        <= dr_shift[0];
            end
        end else begin
            if (dm_dmi_response) begin
                dmi[1:0]     <= dm_dmi_op;
                dtmcs[11:10] <= dmi[1:0];
                if (dm_dmi_op == 2'b00) begin
                    dmi[33:2] <= dm_dmi_read_data;
                end else begin
                    dmi[33:2] <= dmi[33:2];
                end
            end else if (dmireset) begin
                dmi[1:0]     <= 2'b00;
            end else begin
                dr_shift       <= dr_shift;
                idcode         <= idcode;
                dtmcs          <= dtmcs;
                dmi            <= dmi;
                bypass0        <= bypass0;
                bypass1        <= bypass1;
            end
        end
    end
end

//--------------------------------------------------------------------------
// Design: instruction and data serial output
//         The contents of the selected register (instruction or data) are
//         shifted out of TDO on the falling edge of TCK.
//         4.5.1 Specifications
//--------------------------------------------------------------------------
always @(negedge tck) begin
    instruction_tdo <= ir_shift[0];
    idcode_tdo      <= idcode[0];
    dtmcs_tdo       <= dtmcs[0];
    dmi_tdo         <= dmi[0];
    bypass0_tdo     <= bypass0;
    bypass1_tdo     <= bypass1;
end

//--------------------------------------------------------------------------
// Design: select data register active
//--------------------------------------------------------------------------
always @(ir_latched) begin
     idcode_select  <= 1'b0;
    dtmcs_select   <= 1'b0;
    dmi_select     <= 1'b0;
    bypass0_select <= 1'b0;
    bypass1_select <= 1'b0;
    case (ir_latched)
        BYPASS0_ADDR:   bypass0_select <= 1'b1;
        IDCODE_ADDR:    idcode_select  <= 1'b1;
        DTMCS_ADDR:     dtmcs_select   <= 1'b1;
        DMI_ADDR:       dmi_select     <= 1'b1;
        BYPASS1_ADDR:   bypass1_select <= 1'b1;
        default:        bypass0_select <= 1'b1;
    endcase
end

//--------------------------------------------------------------------------
// Design: select output signal
//--------------------------------------------------------------------------
always @(*) begin
    if (shift_ir_neg) begin
        tdo = instruction_tdo;
    end else begin
        case (ir_latched_neg)
            IDCODE_ADDR:    tdo = idcode_tdo;
            DTMCS_ADDR:     tdo = dtmcs_tdo;
            DMI_ADDR:       tdo = dmi_tdo;
            BYPASS0_ADDR:   tdo = bypass0_tdo;
            BYPASS1_ADDR:   tdo = bypass1_tdo;
            default:        tdo = bypass0_tdo;
        endcase
    end
end

//--------------------------------------------------------------------------
// Design: output tdo enable signal
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        tdo_en <= 1'b0;
    end else if (dmihardreset) begin
        tdo_en <= 1'b0;
    end else begin
        tdo_en <= shift_dr | shift_dr;
    end
end

//--------------------------------------------------------------------------
// Design: update the shift_ir_neg and ir_latched_neg
//         select the data register is accroding shift_ir_neg, +1 cycle
//         enable the instruction and data register tdo accroding
//         ir_latched_neg, +1 cycle
//--------------------------------------------------------------------------
always @(negedge tck) begin
    shift_ir_neg   <= shift_ir;
    ir_latched_neg <= ir_latched;
    update_dr_neg  <= update_dr;
    dmi_neg        <= dmi;      //dmi and updater_dr as the dmi bus master
    dmi_select_neg <= dmi_select;
end

//--------------------------------------------------------------------------
// Design: DTM entry idle test status and leave it immediately
//--------------------------------------------------------------------------
always @(idle) begin
    enter_idle_leave_imm     <= 1'b0;  /* InferLatch (3) : Latch inferred */
    enter_idle_stay_1_cycle  <= 1'b0;
    if (idle == 3'b001) begin
        enter_idle_leave_imm     <= 1'b1;  //TODO: spyglass check
    end else if (idle == 3'b010) begin
        enter_idle_stay_1_cycle  <= 1'b1;
    end else begin
        enter_idle_leave_imm     <= 1'b0;
        enter_idle_stay_1_cycle  <= 1'b0;
    end
end

//--------------------------------------------------------------------------
// Design: DTM reset control
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Design: dmi bus master port only active when updater_dr = 1 and slect
//         dmi data register
//--------------------------------------------------------------------------
always @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
        dmi_addr       <= 8'h00;
        dmi_write_data <= 32'h0000_0000;
        dmi_write_en   <= 1'b0;
        dmi_request    <= 1'b0;
    end else if (dmihardreset) begin
        dmi_addr       <= 8'h00;
        dmi_write_data <= 32'h0000_0000;
        dmi_write_en   <= 1'b0;
        dmi_request    <= 1'b0;
    end else begin
        if (update_dr_neg & dmi_select_neg & dm_dmi_request_ready) begin
            dmi_addr       <= dmi_addr_w;
            dmi_write_data <= dmi_write_data_w;
            dmi_write_en   <= dmi_write_en_w;
            dmi_request    <= dmi_request_w;
        end else begin
            dmi_addr       <= 8'h00;
            dmi_write_data <= 32'h0000_0000;
            dmi_write_en   <= 1'b0;
            dmi_request    <= 1'b0;
        end
    end
end

endmodule
//--------------------------------------------------------------------------
