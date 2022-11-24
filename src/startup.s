@
@ Start Up Assembler to Learn GCC ASM for ARM M4
@
.syntax unified
.cpu cortex-m4
.thumb


@
@ Local variables for this module
@
.data
sysTickCount: .word 0x00000000
endlessLoopCount: .word 0x00000000
.align 4


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

    @ Call in the startMain
    BL startMain

    @ Setup SysTick
    BL setupSysTick

    @ Increment the endlessLoopCount
    @ variable for ever. We don't care
    @ about rounding over the variable
_endlessLoop:
    LDR R0, =endlessLoopCount
    LDR R1, =0
    LDR R1, [R0]
    ADD R1, #1
    STR R1, [R0]
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
    PUSH {R0-R2}
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

    LDR R0, =SYST_RVR      @ Setup the Reload register
    LDR R1, =SYST_RELOAD_VAL
    STR R1, [R0]

    LDR R0, =SYST_CSR      @ Set ENABLE to 1 = Counter is operating.
    LDR R1, =SYST_CSR_ENBL
    LDR R2, [R0]
    ORR R2, R1
    STR R2, [R0]

    POP {R0-R2}
    BX LR


.text
.global sysTickHandler
.type sysTickHandler, %function
sysTickHandler:
    @ Increment the sysTickCount
    LDR R1, =sysTickCount
    LDR R0, [R1]
    ADD R0, #1
    STR R0, [R1]

    @ Clear the current value to
    @ clear reload the CVR with the RVR
    @ and clear the COUNTFLAG
    LDR R1, =SYST_CVR
    LDR R0,=0
    STR R0, [R1]

    @ Return and run
    BX LR

.end
