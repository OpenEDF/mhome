   .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_lui
	.globl  _start	
_start:
rv32mi_lui:
    lui zero, 0x000FFF00
    lui ra, 0x000FFF01
    lui sp, 0x000FFF02
    lui gp, 0x000FFF03
    lui tp, 0x000FFF04
    lui t0, 0x000FFF05
    lui t1, 0x000FFF06
    lui t2, 0x000FFF07
    lui fp, 0x000FFF08
    lui s1, 0x000FFF09
    lui a0, 0x000FFF0A
    lui a1, 0x000FFF0B
    lui a2, 0x000FFF0C
    lui a3, 0x000FFF0D
    lui a4, 0x000FFF0E
    lui a5, 0x000FFF0F
    lui a6, 0x000FFF10
    lui a7, 0x000FFF11
    lui s2, 0x000FFF12
    lui s3, 0x000FFF13
    lui s4, 0x000FFF14
    lui s5, 0x000FFF15
    lui s6, 0x000FFF16
    lui s7, 0x000FFF17
    lui s8, 0x000FFF18
    lui s9, 0x000FFF19
    lui s10, 0x000FFF1A
    lui s11, 0x000FFF1B
    lui t3, 0x000FFF1C
    lui t4, 0x000FFF1D
    lui t5, 0x000FFF1E
    lui t6, 0x000FFF1F
    auipc a0, 0x00010104
    .end
