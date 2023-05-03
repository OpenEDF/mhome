	.data
    .align 2
x:  .word 10
y:  .word 20

    .globl _start
_start:

    .text
    .align 2
rv32mi_beq:
    lui a0, 0x000FFF08
    lui a1, 0x000FFF01
    beq a0, a1, func2
    
func1:
    lui a3, 0x000FFF03
    lui a4, 0x000FFF04
 
func2:
    lui a5, 0x000FFF05
    lui a6, 0x000FFF06
    
end:
	lui a7, 0x000FFF07
    .end
