    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl rv32mi_lh
_start:
rv32mi_lh:
    lh a0, 0(zero)
    lh a1, 2(zero)
    lh a2, 4(zero)
    lh a3, 6(zero)
    lh a4, 8(zero)
    lh a5, 10(zero)
    lh a6, 12(zero)
    lh a7, 14(zero)
    .end
