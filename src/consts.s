#
# Consts for the project
#
.syntax unified
.cpu cortex-m4
.thumb

# Check if the Platform is QEMU = 0, SAM4 = 1
.if PLATFORM == 1

	.include "sam4.s.inc"

.elseif PLATFORM == 0

	.include "qemu.s.inc"

.else

	.error "Unrecognized Platform Selected"

.endif

.end
