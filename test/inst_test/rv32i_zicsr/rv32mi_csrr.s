    .data
	.align 2
x:  .word 0x12345678
y:  .word 0x00abcdef

	.text
	.align	2
	.globl	rv32mi_csrr
	.globl  _start
_start:
rv32mi_csrr:
    csrr a0, mvendorid
    csrr a1, marchid
    csrr a2, mimpid
    csrr a3, mhartid
    csrr a4, mstatus
    .end
