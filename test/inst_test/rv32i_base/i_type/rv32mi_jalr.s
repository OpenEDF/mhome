    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl func1
    .globl rv32mi_jalr
_start:
rv32mi_jal:
    lui zero, 0x000FFF00
    lui a0, 0x000000
    lui a1, 0x000FFF02
    jalr ra, a0, 0x14 
    lui a2, 0x000FFF03

func1:
    lui a3, 0x000FFF04
    lui a4, 0x000FFF05
    lui a5, 0x000FFF06
    lui a6, 0x000FFF07
    lui a7, 0x000FFF08
    .end
