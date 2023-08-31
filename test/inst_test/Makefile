#=======================================================================
# brief: Makefile for riscv instruction test
# author: macro
# date: 2023/04/20
# changelog:
#-----------------------------------------------------------------------
# all src file dir
SRC_BASE_B_DIR = rv32i_base/b_type
SRC_BASE_I_DIR = rv32i_base/i_type
SRC_BASE_J_DIR = rv32i_base/j_type
SRC_BASE_R_DIR = rv32i_base/r_type
SRC_BASE_S_DIR = rv32i_base/s_type
SRC_BASE_U_DIR = rv32i_base/u_type
SRC_M_DIR = rv32i_m
SRC_ZICSR_DIR = rv32i_zicsr

SRC_DIRS := $(SRC_BASE_B_DIR) $(SRC_BASE_I_DIR) $(SRC_BASE_J_DIR) \
	        $(SRC_BASE_R_DIR) $(SRC_BASE_S_DIR) $(SRC_BASE_U_DIR) \
			$(SRC_M_DIR) $(SRC_ZICSR_DIR)

# include other makefile
include $(SRC_BASE_B_DIR)/Makefile
include $(SRC_BASE_I_DIR)/Makefile
include $(SRC_BASE_J_DIR)/Makefile
include $(SRC_BASE_R_DIR)/Makefile
include $(SRC_BASE_S_DIR)/Makefile
include $(SRC_BASE_U_DIR)/Makefile
include $(SRC_M_DIR)/Makefile
include $(SRC_ZICSR_DIR)/Makefile

# toolchaina
RISCV_PREFIX ?= riscv64-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump -d --section=.text --section=.text.init --section=.data
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O verilog
RISCV_CFLAGS ?= -march=rv32im -mabi=ilp32 -T env/link.ld -Imacros

rv32mi_test_inst_verilog = $(addsuffix .verilog, $(rv32mi_test_inst))
rv32mi_test_inst_elf = $(addsuffix .elf, $(rv32mi_test_inst))
rv32mi_test_inst_dump = $(addsuffix .dump, $(rv32mi_test_inst))

build_inst += $(rv32mi_test_inst_verilog) \
	          $(rv32mi_test_inst_elf)  \
			  $(rv32mi_test_inst_dump) \

# build
build: $(build_inst)
	@ echo "generate file finish!"

define execute-command
%.elf : $(1)/%.S
	@$(RISCV_GCC) $(RV32_OPTS) $(RISCV_GCC_OPTS) $(RISCV_CFLAGS) $$< -o $$@
	@echo [CE] $$@
endef

$(foreach prog, $(SRC_DIRS), $(eval $(call execute-command, $(prog))))

%.dump : %.elf
	@$(RISCV_OBJDUMP) $< >$@
	@echo [CM] $@

%.verilog : %.elf
	@$(RISCV_OBJCOPY) $< $@
	@echo [CV] $@

# clean up
clean:
	@rm -rf *.dump *.elf *.verilog
	@echo clean temp file ...

#=======================================================================
