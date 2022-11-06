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
    LDR R0, =10
    LDR R1, =20
    BL addTwo
    BX LR
