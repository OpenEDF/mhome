    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_sll
	.globl  _start
_start:
rv32mi_sll:
    lui a0, 0x00000001
    lui a1, 0x00000005
    sll a3, a0, a1
    .end
