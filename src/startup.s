@
@ Start Up Assembler to Learn GCC ASM for ARM M4
@
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

    @ Zeroize the BSS segment
    BL initBss

    @ Call in the startMain
    BL startMain

    @ Spin Around endlessly
    _endlessLoop:
        NOP
        B _endlessLoop


.type initBss, %function
initBss:
    LDR R0, =_bssStart
    LDR R1, =_bssEnd
    SUB R2, R1, R0
    LDR R3, =0
    _zeroBssLoop:
        STR R3, [R0]
        ADD R0, #4
        CMP R0, R1
        BNE _zeroBssLoop
    BX LR
