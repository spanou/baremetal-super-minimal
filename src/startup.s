#
# Start Up Assembler to Learn GCC ASM for ARM M4
#
.syntax unified
.cpu cortex-m4
.thumb

.include "consts.s"

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
    B . @Endless Loop


