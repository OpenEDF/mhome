    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_rem
	.globl  _start
_start:
rv32mi_rem:
    li  a0, 0x81234567
    li  a1, 0x12345012
    rem a2, a1, a0
    li  a3, 0x01B514E9
    li  a4, 0x00000007
    .end
