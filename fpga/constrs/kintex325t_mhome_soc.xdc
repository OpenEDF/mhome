#Copyright (c) 2019 Alibaba Group Holding Limited
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#===========================================================
# macro
# Xilinx Kinext 325t, system clock 50M
# Pin assignment constraint file
#===========================================================

#===========================================
# Create clock: fpga board clock 50MHZ G22 PIN
#===========================================
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports {sys_clk}]
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {sys_clk}]

#===========================================
# Global reset sourcei: FPGA Board KEY1
#===========================================
set_property PACKAGE_PIN D26  [get_ports sys_rst_n]

#===========================================
# system state led: FPGA Board LED1
#===========================================
set_property PACKAGE_PIN A23  [get_ports sys_led]

#===========================================
# set io standard
#===========================================
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_led]

#===========================================
# FPGA configuration properties
#===========================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
