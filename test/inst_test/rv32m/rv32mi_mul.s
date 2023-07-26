    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_mul
	.globl  _start
_start:
rv32mi_mul:
    li  a0, -100
    li  a1, 1025
    mul a2, a0, a1
    .end
