@
@ Start Up Assembler to Learn GCC ASM for ARM M4
@
.syntax unified
.cpu cortex-m4
.thumb

.text
.global resetHandler
.word 0x20000400
.word resetHandler
.space 0x17C
.align 4

.global _start
.type resetHandler, %function
resetHandler:
    B _start

_start: 
    NOP
    B . 
