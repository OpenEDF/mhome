#--------------------------------------------------------------------
# @brief: no-project synplify and implement mhome
# @author: macro
# @date: 2023-04-16
#--------------------------------------------------------------------
base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
INSTALL_RTL ?= $(base_dir)/src
MCS_FILE := mhome_soc.mcs
mcs_output_floder := $(shell date +'mhome_soc_%Y_%m_%d_%H_%M_%S')

# install files
install:
	@mkdir -p ${PWD}/src
	@cp ${PWD}/../module/core/*.v 		${INSTALL_RTL} -rf
	@cp ${PWD}/../module/soc/*.v 		${INSTALL_RTL} -rf
	@cp ${PWD}/../module/config/*.v 	${INSTALL_RTL} -rf
	@tree ${INSTALL_RTL}

# generate bit file
bit:
	vivado -mode tcl -source script/nonproject_mode_build.tcl

# generate mcs file
mcs:
	vivado -mode tcl -source script/gen_mcs_flash.tcl

# load bit file to fpga
load:
	vivado -mode tcl -source script/load_bit.tcl

# flash mcs file to fpga
flash:
	vivado -mode tcl -source script/flash_mcs.tcl

# output the msc file to msc floder
outputs:
	@mkdir mcs/$(mcs_output_floder)
	cp build/$(MCS_FILE) mcs/$(mcs_output_floder)

.PHONY: install clean bit mcs load flash outputs
clean:
	rm -rf src *.log *.pb xsim.dir *.html *.xml *.jou output .Xil *.txt build

#--------------------------------------------------------------------
