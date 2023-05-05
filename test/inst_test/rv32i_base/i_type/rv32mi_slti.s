    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_slti
	.globl  _start
_start:
rv32mi_slti:
    lui a0, 0x00000001
    slti a1, a0, -10
    lui a2, 0x00000002
    slti a3, a2, -10
    .end
