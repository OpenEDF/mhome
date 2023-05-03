    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl rv32mi_sw
_start:
rv32mi_sw:
    lui a0, 0x000FFF00
    lui a1, 0x000FFF01
    lui a2, 0x000FFF02
    lui a3, 0x000FFF03
    lui a4, 0x000FFF04
    lui a5, 0x000FFF05
    lui a6, 0x000FFF06
    lui a7, 0x000FFF07
    sw a0, 0(zero)
    sw a1, 4(zero)
    sw a2, 8(zero)
    sw a3, 12(zero)
    sw a4, 16(zero)
    sw a5, 20(zero)
    sw a6, 24(zero)
    sw a7, 28(zero)
    lw s2, 0(zero)
    lw s3, 4(zero)
    lw s4, 8(zero)
    lw s5, 12(zero)
    lw s6, 16(zero)
    lw s7, 20(zero)
    lw s8, 24(zero)
    lw s9, 28(zero)
    .end
