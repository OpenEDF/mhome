    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_auipc
	.globl  _start	
_start:
rv32mi_auipc:
    auipc zero, 0x000FFF00
    auipc ra, 0x000FFF01
    auipc sp, 0x000FFF02
    auipc gp, 0x000FFF03
    auipc tp, 0x000FFF04
    auipc t0, 0x000FFF05
    auipc t1, 0x000FFF06
    auipc t2, 0x000FFF07
    auipc fp, 0x000FFF08
    auipc s1, 0x000FFF09
    auipc a0, 0x000FFF0A
    auipc a1, 0x000FFF0B
    auipc a2, 0x000FFF0C
    auipc a3, 0x000FFF0D
    auipc a4, 0x000FFF0E
    auipc a5, 0x000FFF0F
    auipc a6, 0x000FFF10
    auipc a7, 0x000FFF11
    auipc s2, 0x000FFF12
    auipc s3, 0x000FFF13
    auipc s4, 0x000FFF14
    auipc s5, 0x000FFF15
    auipc s6, 0x000FFF16
    auipc s7, 0x000FFF17
    auipc s8, 0x000FFF18
    auipc s9, 0x000FFF19
    auipc s10, 0x000FFF1A
    auipc s11, 0x000FFF1B
    auipc t3, 0x000FFF1C
    auipc t4, 0x000FFF1D
    auipc t5, 0x000FFF1E
    auipc t6, 0x000FFF1F
    .end
