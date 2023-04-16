###-----------------------------------------------------------------
### vivado tcl file for Non-Project mode
### Author: Macro
### Resources: Vivado Design Suite User Guide Design Flows Overview
### 
###-----------------------------------------------------------------
# set design top file
set top_module_name "mhome_fpga_top"

# set constrs file
set constrs_name "kintex325t_mhome_soc"

# set the FPGA chip
set xilinx_fpga_chip xc7k325tffg676-2

# set the output path
set outputDir ./output
file mkdir $outputDir

# set the bitfile name
set bitfilename "mhome_soc"

# set bit file path
set bit_output_path $outputDir/$bitfilename.bit

# setup design sources and constraints
# add sources
read_verilog src/mhome_defines.v
read_verilog top/mhome_fpga_top.v
read_verilog src/mhome_soc_top.v
read_verilog src/riscv_pipeline.v
read_verilog src/ex_mem_stage.v
read_verilog src/id_ex_stage.v
read_verilog src/if_id_stage.v
read_verilog src/mem_wb_stage.v
read_verilog src/pc_gen.v
read_verilog src/pc_if_stage.v

# add constrs 
read_xdc constrs/$constrs_name.xdc

# set thread number
set_param general.maxThreads 2

# Run synthesis, report utilization and timing estimates, write checkpoint design
synth_design -top $top_module_name -part $xilinx_fpga_chip -include_dirs { src/ }
write_checkpoint -force $outputDir/post_synth
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_power -file $outputDir/post_synth_power.rpt

# Run placement and logic optimzation, report utilization and timing estimates, write checkpoint design
opt_design
place_design
phys_opt_design
write_checkpoint      -force $outputDir/post_place
report_timing_summary -file  $outputDir/post_place_timing_summary.rpt

# Run router, report actual utilization and timing, write checkpoint design, run drc, write verilog and xdc out
route_design
write_checkpoint -force $outputDir/post_route
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/bft_impl_netlist.v
write_xdc -no_fixed_only -force $outputDir/bft_impl.xdc

# Generate a timing and power reports and write to disk
report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file $outputDir/syn_timing.rpt
report_power -file $outputDir/syn_power.rpt

# Generate a bitstream
write_bitstream -force $bit_output_path

# quit tcl
quit

###-----------------------------------------------------------------
