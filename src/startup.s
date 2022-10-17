#
# Start Up Assembler to Learn GCC ASM for ARM M4
#
.syntax unified
.cpu cortex-m4
.thumb 

.include "consts.s"

.section ._strs, "a"
greeting:   .byte 'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd', 0x00
ending:     .asciz "Good Bye Cruel World"


.extern addTwo

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
    LDR R1, =ending
    LDR R2, =MEM_MONITOR_ADDR
    MOV R3, #12
    BL copyString
    MOV R0, #10
    MOV R1, #31
    BL addTwo
    _endlessLoop:
    NOP
    B _endlessLoop

.type copyString, %function
copyString: @ R1(src), R2(dst)
    copyStringStart:
        # Load a byte from the string greetings (pointed to by R1) into R4
        LDRB R4, [R1]
        # Compare the character for 0
        CMP R4, #0
        # If 0 means we reached the end of the string drop to the exit
        BEQ copyStringExit
        # Copy the greetings character to the Memory Monitor
        STRB R4, [R2]
        # Increment both the source(R1) and destination(R2) pointers
        ADD R1, R1, #1
        ADD R2, R2, #1
        B copyStringStart
    copyStringExit:
        # Copy the zero itself
        STRB R4, [R2]
        BX LR

