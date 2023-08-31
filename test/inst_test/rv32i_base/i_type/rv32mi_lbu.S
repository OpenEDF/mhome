    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl rv32mi_lbu
_start:
rv32mi_lbu:
    lbu a0, 0(zero)
    lbu a1, 1(zero)
    lbu a2, 2(zero)
    lbu a3, 3(zero)
    lbu a4, 4(zero)
    lbu a5, 5(zero)
    lbu a6, 6(zero)
    lbu a7, 7(zero)
    .end
