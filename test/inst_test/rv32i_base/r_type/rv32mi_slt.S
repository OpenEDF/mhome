    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_slt
	.globl  _start
_start:
rv32mi_slt:
    addi a0, zero, 0x00000005
    addi a1, zero, 0x00000008
    slt a2, a0, a1
    slt a3, a1, a2
    .end
