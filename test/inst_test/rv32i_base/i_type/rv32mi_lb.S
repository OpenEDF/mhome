    .data
	.align 2
x:  .word 10
y:  .word 20

	.text
	.align 2
	.globl _start
    .globl rv32mi_lb
_start:
rv32mi_jal:
    lb a0, 0(zero)
    lb a1, 1(zero)
    lb a2, 2(zero)
    lb a3, 3(zero)
    lb a4, 4(zero)
    lb a5, 5(zero)
    lb a6, 6(zero)
    lb a7, 7(zero)
    .end
