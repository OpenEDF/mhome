    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_sub
	.globl  _start
_start:
rv32mi_sub:
    lui a0, 0x00000001
    lui a1, 0x00000002
    sub a2, a1, a0
    lui a3, 0x00000005
    sub a4, a3, a1
    .end