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



.type startMain, %function
startMain:
    PUSH {R0-R5, LR}

    @ Parameters: R0 = (a) first number to be added
    @ Parameters: R1 = (b) second number to be added
    @ Return: R2 = the result of (a) + (b)
    LDR R0, =10
    LDR R1, =20
    BL addTwo

    @ Clear the contents pointed to by MEMORY_MONITOR
    LDR R0, =MEMORY_MONITOR
    LDR R1, =MEMORY_MONITOR_SZ
    BL clearMemoryMonitorAsm

    @ Print the contents of the DEBUG_STR into the
    @ address pointed to by MEMORY_MONITOR
    LDR R0, =DEBUG_STR
    LDR R1, =MEMORY_MONITOR
    BL strCopyAsm

    POP {R0-R5, LR}
    BX LR

.end
