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
	lw	a4, x
	lw	a5, y
	add	a3, a4, a5
    sw  a3, 0x108(x0)
    .end
