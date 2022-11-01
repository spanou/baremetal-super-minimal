
##
## Options are:
## o - qemu (Net Duino Plus 2)   => [0]
## o - sam4 (SAM4L XPlained Pro) => [1]
##
BOARD?= qemu
##
## Options are:
## o - dev
## o - rel
##
BUILD?= dev

PROJECT="BareMetal Super Minimal"

ifeq ($(BOARD), qemu)
	C_PLATFORM_FLAGS= -DPLATFORM=0
	ASM_PLATFORM_FLAGS=--defsym PLATFORM=0
	CPU_FLAGS=-mthumb -mcpu=cortex-m4
else ifeq ($(BOARD), sam4)
	C_PLATFORM_FLAGS= -DPLATFORM=1
	ASM_PLATFORM_FLAGS=--defsym PLATFORM=1
	CPU_FLAGS=-mthumb -mcpu=cortex-m4
endif


ifeq ($(BUILD), rel)
	C_BUILD_FLAGS=
	ASM_BUILD_FLAGS=
else ifeq ($(BUILD), dev)
	C_BUILD_FLAGS=-g -O0
	ASM_BUILD_FLAGS=-g
endif 

INCLUDES=-I./src -I./include
CLIB_FLAGS=-nostdlib -nostartfiles -ffreestanding


ASM_SRCS= $(wildcard src/*.s)
ASM_OBJS= $(subst .s,.o,$(ASM_SRCS))
C_SRCS= $(wildcard src/*.c)
C_OBJS= $(subst .c,.o,$(C_SRCS))
AUTOGENS= include/$(BOARD).h.inc include/$(BOARD).s.inc 
OBJS= $(C_OBJS) $(ASM_OBJS)
SRCS= $(ASM_SRCS) $(C_SRCS)
GNU_PREFIX= arm-none-eabi
GNU_ARM_AS= $(GNU_PREFIX)-as
GNU_ARM_GCC= $(GNU_PREFIX)-gcc
GNU_ARM_LINKER= $(GNU_PREFIX)-ld
GNU_ARM_OBJDUMP= $(GNU_PREFIX)-objdump
GNU_ARM_OBJCOPY= $(GNU_PREFIX)-objcopy
GNU_ARM_NM= $(GNU_PREFIX)-nm
QEMU_BASE=
QEMU_BIN= $(QEMU_BASE)qemu-system-arm
TARGET= startup
TARGET_ELF= $(TARGET).elf
ECHO=@echo
PYTHON3=python3
REGPARSER=scripts/regParser.py
REGPARSER_OPTS_ASM=--output=s
REGPARSER_OPTS_C=--output=c 
REGPARSER_CSV=scripts/$(BOARD).csv
GNU_ASM_FLAGS= $(ASM_BUILD_FLAGS) $(INCLUDES) $(ASM_PLATFORM_FLAGS)

#
# TODO: Need to set up the right flags for the gcc compiler
#
GNU_GCC_FLAGS= $(C_BUILD_FLAGS) $(INCLUDES) $(CPU_FLAGS) $(CLIB_FLAGS) $(C_PLATFORM_FLAGS) -c

%.h.inc: scripts/$(BOARD).csv
	$(PYTHON3) $(REGPARSER) --output=c $< > $@

%.s.inc: scripts/$(BOARD).csv
	$(PYTHON3) $(REGPARSER) --output=s $< > $@

%.o: %.c
	$(GNU_ARM_GCC) $(GNU_GCC_FLAGS) $< -o $@

%.o: %.s
	$(GNU_ARM_AS) $(GNU_ASM_FLAGS) $< -o $@


$(TARGET_ELF): $(AUTOGENS) $(OBJS)
	$(GNU_ARM_LINKER) $(OBJS) -nostartfiles -o $@ -T linker.ld

$(TARGET).lst : $(TARGET_ELF)
	$(GNU_ARM_OBJDUMP) -h -S $(TARGET_ELF) > $(TARGET).lst

$(TARGET).bin : $(TARGET_ELF)
	$(GNU_ARM_OBJCOPY) -O binary $(TARGET_ELF) $(TARGET).bin

$(TARGET).sym : $(TARGET_ELF)
	$(GNU_ARM_NM) -l -n $(TARGET_ELF) > $(TARGET).sym

.PHONY: debug
debug:
	$(QEMU_BIN) -M netduinoplus2 -display none -S -s -serial none -serial none -serial mon:stdio -kernel $(TARGET).bin &


.PHONY: all
all: build_info  $(TARGET_ELF) $(TARGET).bin $(TARGET).lst $(TARGET).sym


.PHONY: build_info
build_info:
	$(ECHO) "==========================================================================================="
	$(ECHO) " Build Date : $(shell TZ='America/Los_Angeles' date)"
	$(ECHO) " Project    : $(PROJECT)"
	$(ECHO) " Board      : $(BOARD)"
	$(ECHO) " Build      : $(BUILD)"
	$(ECHO) ""
	$(ECHO) " For Help type 'make help'"
	$(ECHO) "==========================================================================================="


.PHONY:clean
clean:
	$(RM) $(OBJS)
	$(RM) *.elf
	$(RM) *.lst
	$(RM) *.bin
	$(RM) *.sym
	$(RM) include/sam4.s.inc
	$(RM) include/sam4.h.inc
	$(RM) include/qemu.s.inc
	$(RM) include/qemu.h.inc

.PHONY: rebuild
rebuild: clean all

.PHONY: inspect
inspect:
	$(ECHO) "BOARD is...................: $(BOARD)"
	$(ECHO) "BUILD is...................: $(BUILD)"
	$(ECHO) "INCLUDES are...............: $(INCLUDES)"
	$(ECHO) "CLIB_FLAGS are.............: $(CLIB_FLAGS)"
	$(ECHO) "C_PLATFORM_FLAGS are.......: $(C_PLATFORM_FLAGS)"
	$(ECHO) "ASM_PLATFORM_FLAGS are.....: $(ASM_PLATFORM_FLAGS)"
	$(ECHO) "CPU_FLAGS are..............: $(CPU_FLAGS)"
	$(ECHO) "ASM_OBJS are...............: $(ASM_OBJS)"
	$(ECHO) "C_SRCS are.................: $(C_SRCS)"
	$(ECHO) "C_OBJS are.................: $(C_OBJS)"
	$(ECHO) "OBJS are...................: $(OBJS)"
	$(ECHO) "SRCS are...................: $(SRCS)"
	$(ECHO) "GNU_PREFIX is..............: $(GNU_PREFIX)"
	$(ECHO) "GNU_ARM_AS is..............: $(GNU_ARM_AS)"
	$(ECHO) "GNU_ARM_GCC is.............: $(GNU_ARM_GCC)"
	$(ECHO) "GNU_ARM_LINKER is..........: $(GNU_ARM_LINKER)"
	$(ECHO) "GNU_ARM_OBJDUMP is.........: $(GNU_ARM_OBJDUMP)"
	$(ECHO) "GNU_ARM_OBJCOPY is.........: $(GNU_ARM_OBJCOPY)"
	$(ECHO) "GNU_ARM_NM is..............: $(GNU_ARM_NM)"
	$(ECHO) "QEMU_BASE is...............: $(QEMU_BASE)"
	$(ECHO) "QEMU_BIN is................: $(QEMU_BIN)"
	$(ECHO) "TARGET are.................: $(TARGET)"
	$(ECHO) "TARGET_ELF are.............: $(TARGET_ELF)"
	$(ECHO) "ECHO is....................: $(ECHO)"
	$(ECHO) "GNU_ASM_FLAGS are..........: $(GNU_ASM_FLAGS)"
	$(ECHO) "REGPARSER_OPTS_ASM are.....: $(REGPARSER_OPTS_ASM)"
	$(ECHO) "REGPARSER_OPTS_C are.......: $(REGPARSER_OPTS_C)"
	$(ECHO) "REGPARSER_SAM4_CSV is......: $(REGPARSER_SAM4_CSV)"
# 	$(ECHO) "AUTOGENS are...............: $(AUTOGENS)"



.PHONY: help
help:
	$(ECHO) "=========================================================================================="
	$(ECHO) "Usage:"
	$(ECHO) ""
	$(ECHO) " make <options> <target>"
	$(ECHO) ""
	$(ECHO) "  options: BOARD=[qemu|sam4] BUILD=[debug|release]"
	$(ECHO) ""
	$(ECHO) "     qemu    -> build for a QEMU's Netduino Plus 2 Virtual Board (default)"
	$(ECHO) "     sam4    -> build for a SAM4 XPlained Pro Board"
	$(ECHO) "     dev     -> full development build, all debug symbols and drops optimization to 0"
	$(ECHO) "     rel     -> rull release build, the production build no debug symbols and optimization"
	$(ECHO) ""
	$(ECHO) "  target: [all|debug|clean|rebuild|help]"
	$(ECHO) ""
	$(ECHO) "     all     -> builds all artifacts such as the *.elf, *.bin, *.sym and *.lst files"
	$(ECHO) "     debug   -> loads the executable binary and attaches the debugger"
	$(ECHO) "     clean   -> removes all build artifacts inlcuding object files"
	$(ECHO) "     rebuild -> removes all build artifacts and rebuilds the from scratch"
	$(ECHO) "     help    -> prints this message"
	$(ECHO) "=========================================================================================="

