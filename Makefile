
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

##
## The project name
##
PROJECT="BareMetal Super Minimal"

##
## SRC_DIRS contains a list of space seperated directories that contain source files for either *.c or *.s
## HDR_DIRS contains a list of space seperated directories that contain header files
##
## If you want to add another directory for either type just added it at the end of each list
##
SRC_DIRS=./src
HDR_DIRS=./include
OBJS_DIR=./obj

##
## Build the includes from the Header Directory List $(HDR_DIRS)
##
INCLUDES=$(foreach d, $(HDR_DIRS), -I$(d))

##
## Build the soruces and objects files list
##
S_SRCS=$(foreach d, $(SRC_DIRS), $(notdir $(wildcard $(d)/*.s)))
C_SRCS=$(foreach d, $(SRC_DIRS), $(notdir $(wildcard $(d)/*.c)))
OBJS= $(addprefix $(OBJS_DIR)/, $(subst .s,.o,$(S_SRCS)))
OBJS+=$(addprefix $(OBJS_DIR)/, $(subst .c,.o,$(C_SRCS)))

##
## Add the Sources Directories in the search path for both
## source *.c and *.s files
##
vpath %.s $(SRC_DIRS)
vpath %.c $(SRC_DIRS)


##
## Set up board specific options
##
ifeq ($(BOARD), qemu)
	C_PLATFORM_FLAGS= -DPLATFORM=0
	ASM_PLATFORM_FLAGS=--defsym PLATFORM=0
	CPU_FLAGS=-mthumb -mcpu=cortex-m4
else ifeq ($(BOARD), sam4)
	C_PLATFORM_FLAGS= -DPLATFORM=1
	ASM_PLATFORM_FLAGS=--defsym PLATFORM=1
	CPU_FLAGS=-mthumb -mcpu=cortex-m4
endif

##
## Set up build specific options
##
ifeq ($(BUILD), rel)
	C_BUILD_FLAGS=
	ASM_BUILD_FLAGS=
else ifeq ($(BUILD), dev)
	C_BUILD_FLAGS=-g -O0
	ASM_BUILD_FLAGS=-g
endif

##
## Default goal is all
##
.DEFAULT_GOAL:=all

CLIB_FLAGS=-nostdlib -nostartfiles -ffreestanding
AUTOGENS= include/$(BOARD).h.inc include/$(BOARD).s.inc

GNU_PREFIX= arm-none-eabi
AS= $(GNU_PREFIX)-as
CC= $(GNU_PREFIX)-gcc
LL= $(GNU_PREFIX)-ld
OBJDUMP= $(GNU_PREFIX)-objdump
OBJCOPY= $(GNU_PREFIX)-objcopy
NM= $(GNU_PREFIX)-nm
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

ASFLAGS= $(ASM_BUILD_FLAGS) $(INCLUDES) $(ASM_PLATFORM_FLAGS)
CFLAGS= $(C_BUILD_FLAGS) $(INCLUDES) $(CPU_FLAGS) $(CLIB_FLAGS) $(C_PLATFORM_FLAGS) -c

%.h.inc: scripts/$(BOARD).csv
	$(PYTHON3) $(REGPARSER) --output=c $< > $@

%.s.inc: scripts/$(BOARD).csv
	$(PYTHON3) $(REGPARSER) --output=s $< > $@

$(OBJS_DIR)/%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

$(OBJS_DIR)/%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

$(TARGET_ELF): $(AUTOGENS) $(OBJS)
	$(LL) $(OBJS) -nostartfiles -o $@ -T linker.ld

$(TARGET).lst : $(TARGET_ELF)
	$(OBJDUMP) -h -S $(TARGET_ELF) > $(TARGET).lst

$(TARGET).bin : $(TARGET_ELF)
	$(OBJCOPY) -O binary $(TARGET_ELF) $(TARGET).bin

$(TARGET).sym : $(TARGET_ELF)
	$(NM) -l -n $(TARGET_ELF) > $(TARGET).sym

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
	$(shell if [ ! -d "$(OBJS_DIR)" ]; then mkdir $(OBJS_DIR); fi)


.PHONY:clean
clean:
	$(RM) -rf $(OBJS_DIR)
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
	$(foreach var, $(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, $(origin $(var))), \
			$(info $(var)=$($(var)))\
		) \
	)


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

