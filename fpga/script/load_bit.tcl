###-----------------------------------------------------------------
### vivado tcl Create a configuration file to program the device
### Author: Macro
### Reference: Vivado Design Suite User Guide Using Tcl Scripting(ug894)
### 
###-----------------------------------------------------------------

# set the bit file file path, accroding the project setup
set bitfile_path output/mhome_soc.bit

# target device info
set hw_fpga "xc7k325t_0"

# open and connect device
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices $hw_fpga]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $hw_fpga] 0]

# write the bit file to device
set_property PROGRAM.FILE $bitfile_path [get_hw_devices $hw_fpga]
program_hw_devices [get_hw_devices $hw_fpga]
refresh_hw_device [lindex [get_hw_devices $hw_fpga] 0]

# close the connect
close_hw_target
disconnect_hw_server
close_hw_manager

# quit the tcl
quit
###-----------------------------------------------------------------
