    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl rv32mi_lw
_start:
rv32mi_lw:
    lw a0, 0(zero)
    lw a1, 4(zero)
    lw a2, 8(zero)
    lw a3, 12(zero)
    lw a4, 16(zero)
    lw a5, 20(zero)
    lw a6, 24(zero)
    lw a7, 28(zero)
    .end
