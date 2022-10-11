
ASM_SRCS= $(wildcard src/*.s)
ASM_OBJS= $(subst .s,.o,$(ASM_SRCS))
C_SRCS= $(wildcard src/*.c)
C_OBJS= $(subst .c,.o,$(C_SRCS))
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
GNU_ASM_FLAGS= -g -I./src -I./include

#
# TODO: Need to set up the right flags for the gcc compiler
#
GNU_GCC_FLAGS= -g -I./src -I./include -mthumb -mcpu=cortex-m4 -nostdlib -nostartfiles -ffreestanding -c

%.o: %.c
	$(GNU_ARM_GCC) $(GNU_GCC_FLAGS) $< -o $@

%.o: %.s
	$(GNU_ARM_AS) $(GNU_ASM_FLAGS) $< -o $@

$(TARGET_ELF): $(OBJS)
	$(GNU_ARM_LINKER) $(OBJS) -nostartfiles  -o $@ -T linker.ld


$(TARGET).lst : $(TARGET_ELF)
	$(GNU_ARM_OBJDUMP) -h -S $(TARGET_ELF) > $(TARGET).lst

$(TARGET).bin : $(TARGET_ELF)
	$(GNU_ARM_OBJCOPY) -O binary $(TARGET_ELF) $(TARGET).bin

$(TARGET).sym : $(TARGET_ELF)
	$(GNU_ARM_NM) -l -n $(TARGET_ELF) >  $(TARGET).sym

.PHONY: run
run: 
	$(QEMU_BIN) -M netduinoplus2 -display none -S -s -serial none -serial none -serial mon:stdio  -kernel startup.bin &


.PHONY: all
all: $(TARGET_ELF) $(TARGET).bin $(TARGET).lst $(TARGET).sym

.PHONY: clean
clean:
	$(RM) $(OBJS)
	$(RM) *.elf
	$(RM) *.lst
	$(RM) *.bin
	$(RM) *.sym


.PHONY: rebuild
rebuild: clean all

.PHONY: debug
debug:
	$(info SRCS are $(SRCS))
	$(info OBJS are $(OBJS))
	$(info TARGET_ELF is $(TARGET_ELF))

