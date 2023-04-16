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
// Signal
//--------------------------------------------------------------------------
reg sys_clk;
reg sys_rst_n;
reg sys_led;

//--------------------------------------------------------------------------
// Design: mhome soc instaniate 
//--------------------------------------------------------------------------
mhome_soc_top mhome_soc_top_u(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
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
// Design: load hex file to memory
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Design: system run and check 
//--------------------------------------------------------------------------
initial begin
    $display("[mhome OK]: start running...");
    #10
    sys_rst_n = 1'b1;
    #1000
    $display("[mhome OK]: end running...");
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
    end
    $finish(); 
end

//--------------------------------------------------------------------------
// Design: generate wave file, use verdi debug
//--------------------------------------------------------------------------
initial begin
    $fsdbDumpfile("mhome_soc_tb.fsdb");
    $fsdbDumpvars(0, mhome_soc_tb);
    $fsdbDumpMDA;
end

endmodule
//--------------------------------------------------------------------------
