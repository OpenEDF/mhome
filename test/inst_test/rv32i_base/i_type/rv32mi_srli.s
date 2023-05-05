    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_srli
	.globl  _start
_start:
rv32mi_srli:
    lui a0, 0x00000001
    srli a1, a0, 3
    lui a2, 0x00000002
    srli a3, a2, 5
    .end
