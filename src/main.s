@
@ Start Main for ASM
@
.syntax unified
.cpu cortex-m4
.thumb

@
@ Make the C method addTwo visible to
@ this file for calling it.
@
.extern addTwo

.text
.global startMain


@ Parameters: R0 = (a) first number to be added
@ Parameters: R1 = (b) second number to be added
@ Return: R2 = the result of (a) + (b)
.type startMain, %function
startMain:
    PUSH {R0-R10, LR}
    LDR R0, =10
    LDR R1, =20
    BL addTwo
    BL theMoves
    POP {R0-R10, LR}
    BX LR

.type theMoves, %function
theMoves:
    LDR R1, =0xAA55AA55
    LDR R0, =0xAA55AA55
    NOP
    NOP
    MOVW R2, #0x16FF
    MOVT R2, #0x31FF
    BX LR

.end