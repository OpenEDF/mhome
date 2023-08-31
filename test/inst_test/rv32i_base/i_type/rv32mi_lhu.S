    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl rv32mi_lhu
_start:
rv32mi_lhu:
    lhu a0, 0(zero)
    lhu a1, 2(zero)
    lhu a2, 3(zero)
    lhu a3, 4(zero)
    lhu a4, 8(zero)
    lhu a5, 10(zero)
    lhu a6, 12(zero)
    lhu a7, 14(zero)
    .end
