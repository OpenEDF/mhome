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
`timescale 1ns/10ps

//--------------------------------------------------------------------------
// Module
//--------------------------------------------------------------------------
module mhome_soc_tb();
//--------------------------------------------------------------------------
// Signal for soc top
//--------------------------------------------------------------------------
reg sys_clk;
reg sys_rst_n;
reg tck_pad;
reg trst_n_pad;
reg tdi_pad;
reg tms_pad;
wire tdo_pad;
wire sys_led;

//--------------------------------------------------------------------------
// Design: mhome soc instaniate
//--------------------------------------------------------------------------
mhome_soc_top mhome_soc_top_u(
    //input
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .tck_pad    (tck_pad),
    .trst_n_pad (trst_n_pad),
    .tdi_pad    (tdi_pad),
    .tms_pad    (tms_pad),

    //output
    .tdo_pad    (tdo_pad),
    .sys_led    (sys_led)
);

//--------------------------------------------------------------------------
// Design: system clock and reset signal initial
//--------------------------------------------------------------------------
initial begin
    sys_clk = 1'b1;
    sys_rst_n = 1'b0;
    forever #5 sys_clk = ~sys_clk;
end

//--------------------------------------------------------------------------
// Design: init the jtag signal
//--------------------------------------------------------------------------
initial begin
    tck_pad    = 1'b1;
    trst_n_pad = 1'b0;
    tdi_pad    = 1'b1;
    tms_pad    = 1'b1;
    forever #10 tck_pad = ~tck_pad;
end

//--------------------------------------------------------------------------
// Design: init the data memory
//--------------------------------------------------------------------------
`define DATA_MEM_SIZE 4096
task init_data_mem;
begin: init_mem
    integer index;
    $display("[mhome OK]: inital the data memory...");
    for (index = 0; index < `DATA_MEM_SIZE; index = index + 1) begin
        mhome_soc_top_u.riscv_pipeline_u.ex_mem_stage_u.single_port_ram_u1.memory_model[index] = 8'h55;
    end
end
endtask

//--------------------------------------------------------------------------
// Design: load hex file to memory
//--------------------------------------------------------------------------
`define RAM_SIZE 256
task load_hex_to_mem;
begin: load_hex
    reg [31:0] temp_mem[`RAM_SIZE-1:0];
    integer index;
    integer row;
    $display("[mhome OK]: start loading hex file to memory...");
    $readmemh("inst_test.verilog", mhome_soc_top_u.riscv_pipeline_u.pc_if_stage_u.single_port_ram_u.memory_model);
    row = 0;
    for (index = 0; index < `RAM_SIZE; index = index + 1) begin
        temp_mem[index][7:0] = mhome_soc_top_u.riscv_pipeline_u.pc_if_stage_u.single_port_ram_u.memory_model[row];
        temp_mem[index][15:8] = mhome_soc_top_u.riscv_pipeline_u.pc_if_stage_u.single_port_ram_u.memory_model[row+1];
        temp_mem[index][23:16] = mhome_soc_top_u.riscv_pipeline_u.pc_if_stage_u.single_port_ram_u.memory_model[row+2];
        temp_mem[index][31:24] = mhome_soc_top_u.riscv_pipeline_u.pc_if_stage_u.single_port_ram_u.memory_model[row+3];
        row = row + 4;
    end
    /* dump the memory file */
    for (index = 0; index < `RAM_SIZE; index = index + 8) begin
        $display("0x%H: 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H", index, temp_mem[index], temp_mem[index+1],
                 temp_mem[index+2], temp_mem[index+3], temp_mem[index+4], temp_mem[index+5],temp_mem[index+6],
                 temp_mem[index+7]);
    end
    $display("[mhome OK]: loading hex file to memory end...");
end
endtask

//--------------------------------------------------------------------------
// Design: system run and check
//--------------------------------------------------------------------------
initial begin
    integer fd;
    /* init data memory */
    init_data_mem();
    /* load memory */
    load_hex_to_mem();
    $display("[mhome OK]: start running...");
    #10
    sys_rst_n = 1'b1;
    #1000
    $display("[mhome OK]: end running...");
    /* open the test report */
    fd = $fopen("mhome_inst_test.rpt", "a+b");
    if (sys_led == 1'b1) begin
        $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
        $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
        $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
        $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        /* write the test report */
        $fdisplay(fd, "mhome inst test: %s ... OK", `INST_NAME);
    end else begin
        $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        /* write the test report */
        $fdisplay(fd, "mhome inst test: %s ... FAIL", `INST_NAME);
    end
    /* dump rv32 register file */
    rv32_dump_register_file();

    /* close the test report */
    $fclose(fd);
    $finish();
end

//--------------------------------------------------------------------------
// Design: dump riscv register file
//--------------------------------------------------------------------------
task rv32_dump_register_file;
begin: dump_register
    $display("[mhome OK]: rv32 dump register file...");
    $display("rv32 register[00] zero: 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[0]);
    $display("rv32 register[01] ra  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[1]);
    $display("rv32 register[02] sp  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[2]);
    $display("rv32 register[03] gp  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[3]);
    $display("rv32 register[04] tp  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[4]);
    $display("rv32 register[05] t0  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[5]);
    $display("rv32 register[06] t1  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[6]);
    $display("rv32 register[07] t2  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[7]);
    $display("rv32 register[08] s0  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[8]);
    $display("rv32 register[09] s1  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[9]);
    $display("rv32 register[10] a0  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[10]);
    $display("rv32 register[11] a1  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[11]);
    $display("rv32 register[12] a2  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[12]);
    $display("rv32 register[13] a3  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[13]);
    $display("rv32 register[14] a4  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[14]);
    $display("rv32 register[15] a5  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[15]);
    $display("rv32 register[16] a6  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[16]);
    $display("rv32 register[17] a7  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[17]);
    $display("rv32 register[18] s2  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[18]);
    $display("rv32 register[19] s3  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[19]);
    $display("rv32 register[20] s4  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[20]);
    $display("rv32 register[21] s5  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[21]);
    $display("rv32 register[22] s6  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[22]);
    $display("rv32 register[23] s7  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[23]);
    $display("rv32 register[24] s8  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[24]);
    $display("rv32 register[25] s9  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[25]);
    $display("rv32 register[26] s10 : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[26]);
    $display("rv32 register[27] s11 : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[27]);
    $display("rv32 register[28] t3  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[28]);
    $display("rv32 register[29] t4  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[29]);
    $display("rv32 register[30] t5  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[30]);
    $display("rv32 register[31] t6  : 0x%H", mhome_soc_top_u.riscv_pipeline_u.if_id_stage_u.register_file_u.rv32_register[31]);
    $display("rv32 register pc      : 0x%H", (mhome_soc_top_u.riscv_pipeline_u.mem_wb_stage_u.mem_pc_plus4_wb - 4));
end
endtask

//--------------------------------------------------------------------------
// Design: generate wave file, use verdi debug
//--------------------------------------------------------------------------
`ifndef MHOME_SPYGLASS_RUN
    initial begin
        $fsdbDumpfile("mhome_soc_tb.fsdb");
        $fsdbDumpvars(0, mhome_soc_tb);
        $fsdbDumpMDA;
    end
`endif

endmodule
//--------------------------------------------------------------------------
