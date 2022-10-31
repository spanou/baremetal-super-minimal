#
# Start Up Assembler to Learn GCC ASM for ARM M4
#
.syntax unified
.cpu cortex-m4
.thumb

.text
.global resetHandler

.type resetHandler, %function
resetHandler:
    B _start

_start:
    NOP @Do Nothing
    MRS R0, BASEPRI
    MRS R0, PRIMASK
    MRS R0, FAULTMASK
    MRS R0, PSR
    MRS R0, CONTROL
    LDR R0, ='H'
    LDR R1, ='e'
    LDR R2, ='l'
    LDR R3, ='l'
    LDR R4, ='o'
    LDR R5, =' '
    LDR R6, = 'W'
    LDR R7, = 'o'
    LDR R8, = 'r'
    LDR R9, = 'l'
    LDR R10, = 'd'
    _endlessLoop:
    NOP
    B _endlessLoop
