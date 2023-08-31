    .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_auipc
	.globl  _start	
_start:
rv32mi_auipc:
    auipc zero, 0x0001FF00
    auipc ra, 0x0008FF01
    auipc sp, 0x0008FF02
    auipc gp, 0x0008FF03
    auipc tp, 0x0008FF04
    auipc t0, 0x0008FF05
    auipc t1, 0x0008FF06
    auipc t2, 0x0008FF07
    auipc fp, 0x0008FF08
    auipc s1, 0x0008FF09
    auipc a0, 0x0008FF0A
    auipc a1, 0x0008FF0B
    auipc a2, 0x0008FF0C
    auipc a3, 0x0008FF0D
    auipc a4, 0x0008FF0E
    auipc a5, 0x0008FF0F
    auipc a6, 0x0008FF10
    auipc a7, 0x0008FF11
    auipc s2, 0x0008FF12
    auipc s3, 0x0008FF13
    auipc s4, 0x0008FF14
    auipc s5, 0x0008FF15
    auipc s6, 0x0008FF16
    auipc s7, 0x0008FF17
    auipc s8, 0x0008FF18
    auipc s9, 0x0008FF19
    auipc s10, 0x0008FF1A
    auipc s11, 0x0008FF1B
    auipc t3, 0x0008FF1C
    auipc t4, 0x0008FF1D
    auipc t5, 0x0008FF1E
    auipc t6, 0x0008FF1F
    .end
