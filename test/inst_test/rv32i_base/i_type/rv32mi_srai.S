    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_srai
	.globl  _start
_start:
rv32mi_srai:
    lui a0, 0x00000001
    srai a1, a0, 4
    lui a2, 0x00000005
    srai a3, a2, 2
    .end
