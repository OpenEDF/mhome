    .data
	.align 2
x:  .word 1
y:  .word 2

	.text
	.align	2
	.globl	rv32mi_sll
	.globl  _start
_start:
rv32mi_sll:
    addi a0, zero, 0x00000002
    addi a1, zero, 0x00000001
    sll a2, a1, a0
    addi a3, zero, 0x00000005
    sll a4, a1, a3
    .end
