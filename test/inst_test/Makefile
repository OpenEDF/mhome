#=======================================================================
# brief: Makefile for riscv instruction test
# author: macro
# date: 2023/04/20
# changelog:
#-----------------------------------------------------------------------

# src file
SRC ?= rv32i_base/s_type/rv32mi_add.s
TAR ?= inst_test
ELF ?= $(TAR).elf

# toolchaina
RISCV_PREFIX ?= riscv64-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.init --section=.data
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O verilog
RISCV_CFLASG ?= -march=rv32im -mabi=ilp32 -T env/link.ld

# build
all:
	@$(RISCV_GCC) $(RV32_OPTS) $(RISCV_GCC_OPTS) $(RISCV_CFLAGS) $(SRC) -o $(ELF) 
	@echo Generate file $(ELF) ...
	@$(RISCV_OBJDUMP) $(ELF) >$(TAR).dump
	@echo Generate file $(TAR).dump ...
	@$(RISCV_OBJCOPY) $(ELF) $(TAR).verilog
	@echo Generate file $(TAR).verilog ...

# clean up
clean:
	@rm -rf $(ELF) *.dump *.verilog *.elf
	@echo clean temp file ... 

#=======================================================================
