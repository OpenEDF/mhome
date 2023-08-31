    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_srl
	.globl  _start
_start:
rv32mi_srl:
    li a0, 0x00000800
    li a1, 0x00000008
    srl a2, a0, a1
    li a3, 0x00000010
    li a4, 0x00000004
    srl a5, a3, a4
    .end
