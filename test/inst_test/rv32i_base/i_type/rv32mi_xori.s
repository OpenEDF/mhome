    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_xori
	.globl  _start
_start:
rv32mi_xori:
    lui a0, 0x00001111
    xori a1, a0, -20
    lui a2, 0x00002222
    xori a3, a2, -15
    .end
