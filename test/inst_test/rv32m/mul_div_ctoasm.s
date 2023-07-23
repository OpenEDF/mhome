	.file	"mul_div_ctoasm.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	divu_c_to_asm_test
	.type	divu_c_to_asm_test, @function
divu_c_to_asm_test:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,100
	sw	a5,-20(s0)
	li	a5,25
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	divu	a5,a4,a5
	sw	a5,-28(s0)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	divu_c_to_asm_test, .-divu_c_to_asm_test
	.align	2
	.globl	div_c_to_asm_test
	.type	div_c_to_asm_test, @function
div_c_to_asm_test:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,100
	sw	a5,-20(s0)
	li	a5,25
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	div	a5,a4,a5
	sw	a5,-28(s0)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	div_c_to_asm_test, .-div_c_to_asm_test
	.align	2
	.globl	remu_c_to_asm_test
	.type	remu_c_to_asm_test, @function
remu_c_to_asm_test:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,100
	sw	a5,-20(s0)
	li	a5,25
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	remu	a5,a4,a5
	sw	a5,-28(s0)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	remu_c_to_asm_test, .-remu_c_to_asm_test
	.align	2
	.globl	rem_c_to_asm_test
	.type	rem_c_to_asm_test, @function
rem_c_to_asm_test:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,100
	sw	a5,-20(s0)
	li	a5,25
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	rem	a5,a4,a5
	sw	a5,-28(s0)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	rem_c_to_asm_test, .-rem_c_to_asm_test
	.align	2
	.globl	mul_c_to_asm_test
	.type	mul_c_to_asm_test, @function
mul_c_to_asm_test:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,100
	sw	a5,-20(s0)
	li	a5,25
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	mul	a5,a4,a5
	sw	a5,-28(s0)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	mul_c_to_asm_test, .-mul_c_to_asm_test
	.align	2
	.globl	mulu_c_to_asm_test
	.type	mulu_c_to_asm_test, @function
mulu_c_to_asm_test:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,100
	sw	a5,-20(s0)
	li	a5,25
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	mul	a5,a4,a5
	sw	a5,-28(s0)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	mulu_c_to_asm_test, .-mulu_c_to_asm_test
	.ident	"GCC: (T-HEAD RISCV Tools V2.0.1 B20210512) 10.2.0"
