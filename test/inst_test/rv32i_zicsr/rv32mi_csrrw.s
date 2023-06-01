    .data
	.align 2
x:  .word 0x12345678
y:  .word 0x00abcdef

	.text
	.align	2
	.globl	rv32mi_csrrw
	.globl  _start
_start:
rv32mi_csrrw:
    li a0, 0x12345678 
    csrr  a1, mstatus
    csrrw a2, mstatus, a0
    csrr  a3, mstatus
    csrr  a4, mstatus
    .end
