    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_sltiu
	.globl  _start
_start:
rv32mi_sltiu:
    lui a0, 0x00000001
    sltiu a1, a0, 10
    lui a2, 0x00000002
    sltiu a3, a2, 0x00000002
    .end
