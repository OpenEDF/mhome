    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_slt
	.globl  _start
_start:
rv32mi_slt:
    li a0, 0x00000005
    li a1, 0x00000088
    or a2, a0, a1
    li a3, 0x00000004
    li a4, 0x00000010
    or a5, a3, a4
    .end
