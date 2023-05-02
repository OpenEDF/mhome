    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl func2
    .globl func1
    .globl rv32mi_jal
_start:
rv32mi_jal:
    lui zero, 0x000FFF00
    lui a0, 0x000FFF01
    lui a1, 0x000FFF02
    lui a2, 0x000FFF03
    jal ra, func2

func1:
    lui a3, 0x000FFF04
    lui a4, 0x000FFF05
    lui a5, 0x000FFF06
    lui a6, 0x000FFF07
    lui a7, 0x000FFF08

func2:
    lui s0, 0x000FFF09
    lui s1, 0x000FFF0A
    jal ra, func1
    .end
