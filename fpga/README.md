## mhome riscv soc impletment on FPGA（xc7k325tffg676-2）

### Install the design source file into the fpga/src floder

```shell
$make install
/home/macro/github/mhome/fpga/src
├── ex_mem_stage.v
├── hazard_unit.v
├── id_ex_stage.v
├── if_id_stage.v
├── mem_wb_stage.v
├── mhome_defines.v
├── mhome_soc_top.v
├── pc_gen.v
├── pc_if_stage.v
├── pipeline_ctrl.v
├── register_file.v
└── riscv_pipeline.v
```

### Start vivado to synthesize and generate .bit fille

```shell
$make bit
vivado -mode tcl -source script/nonproject_mode_build.tcl

****** Vivado v2019.2 (64-bit)
  **** SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
  **** IP Build 2700528 on Thu Nov  7 00:09:20 MST 2019
    ** Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.

source script/nonproject_mode_build.tcl
# synth_design -top $top_module_name -part $xilinx_fpga_chip -include_dirs { src/ }
Command: synth_design -top mhome_fpga_top -part xc7k325tffg676-2 -include_dirs { src/ }
Starting synth_design
...
Bitstream compression saved 84630304 bits.
Writing bitstream ./output/mhome_soc.bit...
INFO: [Vivado 12-1842] Bitgen Completed Successfully.
INFO: [Project 1-118] WebTalk data collection is enabled (User setting is ON. Install Setting is ON.).
INFO: [Common 17-186] '/home/macro/github/mhome/fpga/usage_statistics_webtalk.xml' has been successfully sent to Xilinx on Sun Apr 16 14:41:47 2023. For additional details about this file, please refer to the WebTalk help file at /home/macro/xilinx/Vivado/2019.2/doc/webtalk_introduction.html.
INFO: [Common 17-83] Releasing license: Implementation
10 Infos, 0 Warnings, 0 Critical Warnings and 0 Errors encountered.
```

### Program the .bit file into the FPGA development board

**Note: Before staring, you need to connect the FPGA development board to the computer and power in on**

```shell
$make load
vivado -mode tcl -source script/load_bit.tcl

****** Vivado v2019.2 (64-bit)
  **** SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
  **** IP Build 2700528 on Thu Nov  7 00:09:20 MST 2019
    ** Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.

source script/load_bit.tcl
# set bitfile_path output/mhome_soc.bit
# set hw_fpga "xc7k325t_0"
# open_hw_manager
# connect_hw_server -allow_non_jtag
INFO: [Labtools 27-2285] Connecting to hw_server url TCP:localhost:3121
INFO: [Labtools 27-2222] Launching hw_server...
INFO: [Labtools 27-2221] Launch Output:
...
```

### Generate the .mcs file and download it to the FPGA development board

```shell
$make mcs
...
Creating config memory files...
Creating bitstream load up from address 0x00000000
Loading bitfile output/mhome_soc.bit
Writing file ./build/mhome_soc.mcs
Writing log file ./build/mhome_soc.prm
===================================
Configuration Memory information
===================================
File Format        MCS
Interface          SPIX4
Size               256M
Start Address      0x00000000
End Address        0x0FFFFFFF
Checksum           0xE37E5365
Fill Value         0xFF

Addr1         Addr2         Date                    File(s)                 Checksum
0x00000000    0x000D3233    Apr 16 14:41:42 2023    output/mhome_soc.bit    0x00A35531
File Checksum Total                                                         0x00A35531
...
```

### FPGA development board

![k325tfpgadev](https://github.com/OpenEDF/mhome/blob/main/doc/pic/k325tfpga_dev.jpg)