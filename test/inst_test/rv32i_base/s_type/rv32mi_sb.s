    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl rv32mi_sb
_start:
rv32mi_sb:
    lui a0, 0x000FFF00
    lui a1, 0x000FFF01
    lui a2, 0x000FFF02
    lui a3, 0x000FFF03
    lui a4, 0x000FFF04
    lui a5, 0x000FFF05
    lui a6, 0x000FFF06
    lui a7, 0x000FFF07
    sb a0, 0(zero)
    sb a1, 1(zero)
    sb a2, 2(zero)
    sb a3, 3(zero)
    sb a4, 4(zero)
    sb a5, 5(zero)
    sb a6, 6(zero)
    sb a7, 7(zero)
    lw s2, 0(zero)
    lw s3, 4(zero)
    lw s4, 8(zero)
    lw s5, 12(zero)
    lw s6, 16(zero)
    lw s7, 10(zero)
    lw s8, 14(zero)
    lw s9, 28(zero)
    .end
