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
    li a1, 0x1234abcd
    csrr  a2, mstatus
    csrrw a3, mstatus, a0
    csrrw a4, mstatus, a1
    csrr  a5, mstatus
    csrr  a6, mstatus
    .end
