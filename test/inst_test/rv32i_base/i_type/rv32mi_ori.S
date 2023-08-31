    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_ori
	.globl  _start
_start:
rv32mi_ori:
    lui a0, 0x00000001
    ori a1, a0, -10
    lui a2, 0x00001111
    ori a3, a2, -55
    .end
