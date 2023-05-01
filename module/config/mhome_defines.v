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
// Brief: mhome design define and config file
// Change Log:
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// config define
//--------------------------------------------------------------------------
`define MHOME_START_PC     32'h0000_0000
`define RV32I_NOP          32'h0000_0013      // ADDI x0, x0, 0
`define CYCLE_COUNT_RST    32'h0000_0000

// pipeline memory read and write operation size
`define MEM_OPER_WORD      2'b00
`define MEM_OPER_HALFWORD  2'b01
`define MEM_OPER_BYTE      2'b00
`define MEM_READ           1'b0
`define MEM_WRITE          1'b1

// pipeline write back data select source
`define WB_SEL_ALU_RESULT   2'b00
`define WB_SEL_MEM_RESULT   2'b01
`define WB_SEL_PCP4_RESULT  2'b10

// pipeline execute select immediate or rs2 data as alu module input 2
`define ALU_SEL_RS2DATA_INPUT  1'b0
`define ALU_SEL_IMM_INPUT      1'b1

// produce immediates by base instruction formats
`define R_TYPE_INST      3'b000
`define I_TYPE_INST      3'b001
`define S_TYPE_INST      3'b010
`define B_TYPE_INST      3'b011
`define U_TYPE_INST      3'b100
`define J_TYPE_INST      3'b101

// RISC-V instruction opcode, inst[1:0] = 2'b11
`define OPCODE_LUI_U         7'b0110111
`define OPCODE_AUIPC_U       7'b0010111
`define OPCODE_JAL_J         7'b1101111
`define OPCODE_JALR_I        7'b1100111
`define OPCODE_BRANCH_B      7'b1100011
`define OPCODE_LOAD_I        7'b0000011
`define OPCODE_STORE_S       7'b0100011
`define OPCODE_ALU_I         7'b0010011
`define OPCODE_ALU_R         7'b0110011
`define OPCODE_FENCE_I       7'b0001111
`define OPCODE_EXTEN_I       7'b1110011    // ECALL EBREAK CSRRXX

// RV32I Base Instruction Set, Reserve 256 instruction
`define RV32_BASE_INST_LUI               8'h01
`define RV32_BASE_INST_AUIPC             8'h02
`define RV32_BASE_INST_JAL               8'h03
`define RV32_BASE_INST_JALR              8'h04
`define RV32_BASE_INST_BEQ               8'h05
`define RV32_BASE_INST_BNE               8'h06
`define RV32_BASE_INST_BLT               8'h07
`define RV32_BASE_INST_BGE               8'h08
`define RV32_BASE_INST_BLTU              8'h09
`define RV32_BASE_INST_BGEU              8'h0A
`define RV32_BASE_INST_LB                8'h0B
`define RV32_BASE_INST_LH                8'h0C
`define RV32_BASE_INST_LW                8'h0D
`define RV32_BASE_INST_LBU               8'h0E
`define RV32_BASE_INST_LHU               8'h0F
`define RV32_BASE_INST_SB                8'h10
`define RV32_BASE_INST_SH                8'h11
`define RV32_BASE_INST_SW                8'h12
`define RV32_BASE_INST_ADDI              8'h13
`define RV32_BASE_INST_SLTI              8'h14
`define RV32_BASE_INST_SLTIU             8'h15
`define RV32_BASE_INST_XORI              8'h16
`define RV32_BASE_INST_ORI               8'h17
`define RV32_BASE_INST_ANDI              8'h18
`define RV32_BASE_INST_SLLI              8'h19
`define RV32_BASE_INST_SRLI              8'h1A
`define RV32_BASE_INST_SRAI              8'h1B
`define RV32_BASE_INST_ADD               8'h1C
`define RV32_BASE_INST_SUB               8'h1D
`define RV32_BASE_INST_SLL               8'h1E
`define RV32_BASE_INST_SLT               8'h1F
`define RV32_BASE_INST_SLTU              8'h20
`define RV32_BASE_INST_XOR               8'h21
`define RV32_BASE_INST_SRL               8'h22
`define RV32_BASE_INST_SRA               8'h23
`define RV32_BASE_INST_OR                8'h24
`define RV32_BASE_INST_AND               8'h25
`define RV32_BASE_INST_FENCE             8'h26
`define RV32_BASE_INST_ECALL             8'h27
`define RV32_BASE_INST_EBREAK            8'h28
`define RV32_ZIFEN_STAND_INST_FENCE_I    8'h29
`define RV32_ZICSR_STAND_INST_CSRRW      8'h2A
`define RV32_ZICSR_STAND_INST_CSRRS      8'h2B
`define RV32_ZICSR_STAND_INST_CSRRC      8'h2C
`define RV32_ZICSR_STAND_INST_CSRRWI     8'h2D
`define RV32_ZICSR_STAND_INST_CSRRSI     8'h2E
`define RV32_ZICSR_STAND_INST_CSRRCI     8'h2F
`define RV32_ILLEGAL_INST                8'hFF

//RV32/RV64 Zicsr Standard Extension
`define RV32_ZICSR_INST_CSRRW     3'b001
`define RV32_ZICSR_INST_CSRRS     3'b010
`define RV32_ZICSR_INST_CSRRC     3'b011
`define RV32_ZICSR_INST_CSRRWI    3'b101
`define RV32_ZICSR_INST_CSRRSI    3'b110
`define RV32_ZICSR_INST_CSRRCI    3'b111

// RISC-V write back to register from different source
`define WB_FROM_ALU_RESULT        2'b00
`define WB_FROM_READ_MEM          2'b01
`define WB_FROM_PLUS_PC4          2'b10
`define WB_FROM_DONT_CARE         2'b11

// RISC-V load instruct width
`define LOAD_WIDTH_BYTE           2'b00
`define LOAD_WIDTH_HALF           2'b01
`define LOAD_WIDTH_WORD           2'b10

// RISC-V store instruct width
`define STORE_WIDTH_BYTE          2'b00
`define STORE_WIDTH_HALF          2'b01
`define STORE_WIDTH_WORD          2'b10

// Currently allocated RISC-V machine-level CSR address
// Machine Information Register
`define M_CSR_MVENDORID_ADDR      12'hF11
`define M_CSR_MARCHID_ADDR        12'hF12
`define M_CSR_MIMPID_ADDR         12'hF13
`define M_CSR_MHARTID_ADDR        12'hF14
`define M_CSR_MCONFIGPTR_ADDR     12'hF15

// Machine Trap Setup
`define M_CSR_MSTATUS_ADDR        12'h300
`define M_CSR_MISA_ADDR           12'h301
`define M_CSR_MEDELEG_ADDR        12'h302
`define M_CSR_MIDELEG_ADDR        12'h303
`define M_CSR_MIE_ADDR            12'h304
`define M_CSR_MTVEC_ADDR          12'h305
`define M_CSR_MCOUNTEREN_ADDR     12'h306
`define M_CSR_MSTATUSH_ADDR       12'h310

// Machine Trap Handing
`define M_CSR_MSCRATCH_ADDR       12'h340
`define M_CSR_MEPC_ADDR           12'h341
`define M_CSR_MCAUSE_ADDR         12'h342
`define M_CSR_MTVAL_ADDR          12'h343
`define M_CSR_MIP_ADDR            12'h344
`define M_CSR_MTINST_ADDR         12'h34A
`define M_CSR_MTVAL2_ADDR         12'h34B

// Machine Configuration
`define M_CSR_MENVCFG_ADDR        12'h30A
`define M_CSR_MENVCFGH_ADDR       12'h31A
`define M_CSR_MSECCFG_ADDR        12'h747
`define M_CSR_MSECCFGH_ADDR       12'h757

// Machine Memory Protection
`define M_CSR_PMPCFG0_ADDR        12'h3A0
`define M_CSR_PMPCFG1_ADDR        12'h3A1
`define M_CSR_PMPCFG2_ADDR        12'h3A2
`define M_CSR_PMPCFG3_ADDR        12'h3A3
`define M_CSR_PMPCFG4_ADDR        12'h3A4
`define M_CSR_PMPCFG5_ADDR        12'h3A5
`define M_CSR_PMPCFG6_ADDR        12'h3A6
`define M_CSR_PMPCFG7_ADDR        12'h3A7
`define M_CSR_PMPCFG8_ADDR        12'h3A8
`define M_CSR_PMPCFG9_ADDR        12'h3A9
`define M_CSR_PMPCFG10_ADDR       12'h3AA
`define M_CSR_PMPCFG11_ADDR       12'h3AB
`define M_CSR_PMPCFG12_ADDR       12'h3AC
`define M_CSR_PMPCFG13_ADDR       12'h3AD
`define M_CSR_PMPCFG14_ADDR       12'h3AE
`define M_CSR_PMPCFG15_ADDR       12'h3AF

`define M_CSR_PMPADDR0_ADDR       12'h3B0
`define M_CSR_PMPADDR1_ADDR       12'h3B1
`define M_CSR_PMPADDR2_ADDR       12'h3B2
`define M_CSR_PMPADDR3_ADDR       12'h3B3
`define M_CSR_PMPADDR4_ADDR       12'h3B4
`define M_CSR_PMPADDR5_ADDR       12'h3B5
`define M_CSR_PMPADDR6_ADDR       12'h3B6
`define M_CSR_PMPADDR7_ADDR       12'h3B7
`define M_CSR_PMPADDR8_ADDR       12'h3B8
`define M_CSR_PMPADDR9_ADDR       12'h3B9
`define M_CSR_PMPADDR10_ADDR      12'h3BA
`define M_CSR_PMPADDR11_ADDR      12'h3BB
`define M_CSR_PMPADDR12_ADDR      12'h3BC
`define M_CSR_PMPADDR13_ADDR      12'h3BD
`define M_CSR_PMPADDR14_ADDR      12'h3BE
`define M_CSR_PMPADDR15_ADDR      12'h3BF
// ...
`define M_CSR_PMPADDR63_ADDR      12'h3EF

// Machine Counter/Timer
`define M_CSR_MCYCLE_ADDR         12'hB00
`define M_CSR_MINSTRET_ADDR       12'hB02
`define M_CSR_MHPMCOUNTER3_ADDR   12'hB03
`define M_CSR_MHPMCOUNTER4_ADDR   12'hB04
// ...
`define M_CSR_MHPMCOUNTER31_ADDR  12'hB1F
`define M_CSR_MCYCCLEH_ADDR       12'hB80
`define M_CSR_MINSTRETH_ADDR      12'hB82
`define M_CSR_MHPMCOUNTER3H_ADDR  12'hB83
`define M_CSR_MHPMCOUNTER4H_ADDR  12'hB84
// ...
`define M_CSR_MHPMCOUNTER31H_ADDR 12'hB9F

// Machine Counter Setup
`define M_CSR_MCOUNTINHBIT_ADDR   12'h320
`define M_CSR_MHPMEVENT3_ADDR     12'h323
`define M_CSR_MHPMEVENT4_ADDR     12'h324
// ...
`define M_CSR_MHPMEVENT31_ADDR    12'h33F

// Debug/Trace Registers
`define M_CSR_TSELECT_ADDR        12'h7A0
`define M_CSR_TDARA1_ADDR         12'h7A1
`define M_CSR_TDATA2_ADDR         12'h7A2
`define M_CSR_TDATA3_ADDR         12'h7A3
`define M_CSR_MCONTEXT_ADDR       12'h7A8

// Debug Mode Registers
`define M_CSR_DCSR_ADDR           12'h7B0
`define M_CSR_DPC_ADDR            12'h7B1
`define M_CSR_DSCRATCH0_ADDR      12'h7B2
`define M_CSR_DSCRATCH1_ADDR      12'h7B3

// Write back to register file control source
`define WB_TO_REG_CTRL_ALU        2'b00
`define WB_TO_REG_RD_MEM          2'b01
`define WB_TO_REG_PC_PLUS4        2'b10
//--------------------------------------------------------------------------
