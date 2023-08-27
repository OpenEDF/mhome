    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_mulh
	.globl  _start
_start:
rv32mi_mulh:
    li  a0, 0x81234567
    li  a1, 0XFFFFFFFF
    mulh a2, a0, a1
    li  a3, 0x7edcba99
    li  a4, 0x81234566
    .end
