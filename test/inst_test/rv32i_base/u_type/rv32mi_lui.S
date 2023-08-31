   .data
	.align	2
x:  .word 10
y:  .word 20

	.text
	.align	2
	.globl	rv32mi_lui
	.globl  _start	
_start:
rv32mi_lui:
    lui zero, 0x000FFF00
    lui ra, 0x000FFF01
    lui ra, 0x000FFFF1
    lui sp, 0x000FFF02
    lui sp, 0x000FFFF2
    lui gp, 0x000FFF03
    lui gp, 0x000FFFF3
    lui tp, 0x000FFF04
    lui tp, 0x000FFFF4
    lui t0, 0x000FFF05
    lui t0, 0x000FFFF5
    lui t1, 0x000FFF06
    lui t1, 0x000FFFF6
    lui t2, 0x000FFF07
    lui t2, 0x000FFFF7
    lui fp, 0x000FFF08
    lui fp, 0x000FFFF8
    lui s1, 0x000FFF09
    lui s1, 0x000FFFF9
    lui a0, 0x000FFF0A
    lui a0, 0x000FFFFA
    lui a1, 0x000FFF0B
    lui a1, 0x000FFFFB
    lui a2, 0x000FFF0C
    lui a2, 0x000FFFFC
    lui a3, 0x000FFF0D
    lui a3, 0x000FFFFD
    lui a4, 0x000FFF0E
    lui a4, 0x000FFFFE
    lui a5, 0x000FFF0F
    lui a5, 0x000FFFFF
    lui a6, 0x000FFF10
    lui a6, 0x000FFF20
    lui a7, 0x000FFF11
    lui a7, 0x000FFF21
    lui s2, 0x000FFF12
    lui s2, 0x000FFF22
    lui s3, 0x000FFF13
    lui s3, 0x000FFF23
    lui s4, 0x000FFF14
    lui s4, 0x000FFF24
    lui s5, 0x000FFF15
    lui s5, 0x000FFF25
    lui s6, 0x000FFF16
    lui s6, 0x000FFF26
    lui s7, 0x000FFF17
    lui s7, 0x000FFF27
    lui s8, 0x000FFF18
    lui s8, 0x000FFF28
    lui s9, 0x000FFF19
    lui s9, 0x000FFF29
    lui s10, 0x000FFF1A
    lui s10, 0x000FFF2A
    lui s11, 0x000FFF1B
    lui s11, 0x000FFF2B
    lui t3, 0x000FFF1C
    lui t3, 0x000FFF2C
    lui t4, 0x000FFF1D
    lui t4, 0x000FFF2D
    lui t5, 0x000FFF1E
    lui t5, 0x000FFF2E
    lui t6, 0x000FFF1F
    lui t6, 0x000FFF2F
    .end
