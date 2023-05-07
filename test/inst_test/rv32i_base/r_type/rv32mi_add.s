    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_add
	.globl  _start
_start:
rv32mi_add:
    lui a0, 0x00000001
    lui a1, 0x00000002
    add a2, a0, a1
    lui a3, 0x00000010
    add a4, a2, a3
    .end
