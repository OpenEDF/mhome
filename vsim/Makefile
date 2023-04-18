### ------------------------------------------------------------------------------------------
##
## Brief: makefile file for vcs and verdi
## Author: Macro
## Email: makermuyi@gmail.com
## Run:
##
### ------------------------------------------------------------------------------------------
# Project output target
OUTPUT = mhome_soc_tb
TOP_MODULE = mhome_soc_tb
SPYGLASS_PRJ = mhome_spy.prj

# Set the debug GUI (verdi or dve)
DEBUG_GUI = verdi

# module file list
MODULE_FLIES = module.list

# output log file
COM_LOG_FILE = complier_log
SIM_LOG_FILE = simlution_log
COV_LOG_FILE = coverage_log

# fsdb dump file for verdi
WAVEFORM = $(OUTPUT).fsdb

# Coverage command and flags
COV_FLAGS = -cm line+cond+fsm+tgl+branch+assert
COV_NAME = -cm_name $(OUTPUT).cov
COV_DIR = -cm_dir ./$(OUTPUT).vdb

# Dve and Verdi Coverage command
DVE_COV_CMD = dve -full64 -covdir $(OUTPUT).vdb &

# Compile command and flags
VCS_FLAGS = -f $(MODULE_FLIES) -sverilog \
            -full64                      \
            +lint=all                    \
            +warn=noVPI-CT-NS            \
            +v2k                         \
            -override_timescale=1ns/1ns  \
            -debug_access+all            \
            -debug_acc+dmptf             \
            -debug_region+cell+encrypt   \
            -cpp g++-4.8                 \
            -cc  gcc-4.8 			     \
            -LDFLAGS -Wl,--no-as-needed  \
            -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab                         \
            $(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a -load libnovas.so:FSDBDumpCmd  \
            $(COV_FLAGS)                 \
            $(COV_DIR)                   \
			+incdir+${PWD}/src           \
            -Mupdate                     \
            -o $(OUTPUT)                 \
            -l $(COM_LOG_FILE).log

# Simulation command
SIM_FLAGS = +fsdb+autoflush              \
            $(COV_FLAGS)                 \
            -cm_log $(COV_LOG_FILE).log  \
            -l $(SIM_LOG_FILE).log

# Debug command and flags
DEBUG_FLAGS = -f $(MODULE_FLIES)         \
		      +incdir+${PWD}/src         \
              -top $(TOP_MODULE)         \
              -ssf $(WAVEFORM)           \
              -nologo

# Formality Flags

# PeimrTime Flags

# Spyglass Flags
SPY_FLAGS = -project $(SPYGLASS_PRJ)

# Design Compiler Flags

### ------------------------------------------------------------------------------------------
# all run
all: clean install com sim wave

# install file
VSIM_DIR = src

install:
	@mkdir -p ${PWD}/${VSIM_DIR}
	@cp ${PWD}/../module/core/*                 ${VSIM_DIR}/
	@cp ${PWD}/../module/config/*               ${VSIM_DIR}/
	@cp ${PWD}/../module/soc/*                  ${VSIM_DIR}/
#	@cp ${PWD}/../module/memory/*               ${VSIM_DIR}/
	@cp ${PWD}/../tb/mhome_soc_tb.v             ${VSIM_DIR}/mhome_soc_tb.v
	@cp ${PWD}/../tb/moduel_tb.list             module.list
#	@cp ${PWD}/../tb/inst.hex                   mem.hex
	@tree ${VSIM_DIR}

# only com and sim
com_sim: com sim

# compiler verilog module file
com:
	vcs $(VCS_FLAGS)

# VCS -R FLAG will start simv sutomatic
sim:
	./$(OUTPUT) $(SIM_FLAGS)

# coverage the verilog module
cov:
	$(DVE_COV_CMD)

# debug the model via verdi
wave:
	verdi $(DEBUG_FLAGS) &

# spyglass lint and check design
spy:
	spyglass $(SPY_FLAGS)

# show coverage by html
html:
	urg -dir $(OUTPUT).vdb -dbname merge &

# clean the compiler-time file
.PHONY: clean all com_sim com sim cov wave html install spy
clean:
	rm -rf csrc *simv *.daidir *.log *.key $(OUTPUT) *.vpd DVEfiles *.fsdb \
	verdiLog novas.* *.vdb urgReport vdCovLog output $(VSIM_DIR) \
	build usage_statistics_webtalk.* *.jou *.log rtl module.list inst.hex \
	mhome_spy *.out xsim.dir *.pb

### ------------------------------------------------------------------------------------------
# display the help information
help:
	@echo
	@echo --------------------------------- Help  ---------------------------------
	@echo "command     : descript"
	@echo "make clean  : clean the temp file."
	@echo "make install: install file for stage x simulator."
	@echo "make spy    : spyglass lint the verilog format and pre-check."
	@echo "make all    : execute the compile simluation and open verdi debug."
	@echo "make com    : only execute compile the verilog module."
	@echo "make sim    : only execute simulation the model."
	@echo "make cov    : only execute coverage."
	@echo "make wave   : start the verdi and execute debug the waveform."
	@echo "make html   : view coverage report by html file."
	@echo "make help   : print the all command and use method."
	@echo --------------------------------- Help  ---------------------------------
### ------------------------------------------------------------------------------------------
