#
# Consts for the project
#
.syntax unified
.cpu cortex-m4
.thumb

##
## Common Section
##

# Memory Monitor Address and Size
.equ MEM_MONITOR_ADDR, 0x20001000
.equ MEM_MONITOR_SZ, 256

# Check if the Platform is QEMU = 0, SAM4 = 1
.if PLATFORM == 1
	.include "sam4.s.inc"
.elseif PLATFORM == 0
	.include "qemu.s.inc"
.else
	.error "Unrecognized Platform Selected"
.endif
