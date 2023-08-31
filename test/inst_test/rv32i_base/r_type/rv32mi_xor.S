    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_xor
	.globl  _start
_start:
rv32mi_xor:
    lui a0, 0x00001110
    lui a1, 0x00000100
    xor a2, a0, a1
    lui a3, 0x00001110
    lui a4, 0x00001111
    xor a5, a3, a4
    .end
