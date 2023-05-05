    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_andi
	.globl  _start
_start:
rv32mi_andi:
    lui a0, 0x00000001
    andi a1, a0, -10
    lui a2, 0x0000AAAA
    andi a3, a2, -100
    .end
