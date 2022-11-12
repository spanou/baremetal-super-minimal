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
    MOVS R0, #'H'
    LDR R1, ='e'
    LDR R2, ='l'
    LDR R3, ='l'
    MOVS R4, #'o'
    LDR R5, =' '
    LDR R6, = 'W'
    LDR R7, = 'o'
    LDR R8, = 'r'
    LDR R9, = 'l'
    LDR R10, = 'd'

    @ Zeroize the BSS segment
    BL initBss

    @ Setup SysTick
    BL setupSysTick

    @ Call in the startMain
    BL startMain

    @ Spin Around endlessly
    LDR R0, =SYST_CVR
_endlessLoop:
    LDR R1, [R0]
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


.type setupSysTick, %function
setupSysTick:
    PUSH {R0-R2, LR}
    LDR R0, =SYST_CSR
    LDR R1, =SYST_CSR_CLKS   @ Set CLKSOURCE to 1 = SysTick Processor Clock
    LDR R2, [R0]
    ORR R2, R1
    STR R2, [R0]
    LDR R1, =SYST_CSR_TCKI   @ Clear TICKINT to 0 = Count to 0 does not affect the SysTick exception status.
    @ MVN R1, R1

    LDR R2, [R0]
    ORR R2, R1
    STR R2, [R0]

    LDR R0, =SYST_RVR      @ Setup the Reload register to reload from 10000
    LDR R1, =SYST_RELOAD_VAL
    STR R1, [R0]

    LDR R0, =SYST_CSR      @ Set ENABLE to 1 = Counter is operating.
    LDR R1, =SYST_CSR_ENBL
    LDR R2, [R0]
    ORR R2, R1
    STR R2, [R0]

    POP {R0-R2, LR}
    BX LR

.global sysTickHandler
.type sysTickHandler, %function
sysTickHandler:
    NOP
    B sysTickHandler

.end
