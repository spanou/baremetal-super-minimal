BUILD?= debug

GNU_PREFIX?= arm-none-eabi
AS= $(GNU_PREFIX)-as
LL= $(GNU_PREFIX)-ld
OBJCOPY= $(GNU_PREFIX)-objcopy
NM= $(GNU_PREFIX)-nm
OBJDUMP= $(GNU_PREFIX)-objdump
ASFLAGS= -mthumb -mcpu=cortex-m4

ifeq ($(BUILD), debug)
	AS_BUILD_FLAGS= -g --fatal-warnings
else ifeq ($(BUILD), release)
	AS_BUILD_FLAGS= --fatal-warnings
endif

ASFLAGS+= $(AS_BUILD_FLAGS)

simple.o : simple.s
	$(AS) $(ASFLAGS) $< -o $@

simple.elf : simple.o 
	$(LL) simple.o  -o $@ -Ttext=0x00000000

simple.bin : simple.elf
	$(OBJCOPY) -O binary simple.elf simple.bin

simple.sym : simple.elf 
	$(NM) -l -n simple.elf > simple.sym

simple.lst : simple.elf
	$(OBJDUMP) -h -S simple.elf > simple.lst

.PHONY: all
all: simple.bin simple.sym simple.lst

.PHONY: clean
clean:
	rm simple.elf
	rm simple.o
	rm simple.bin
	rm simple.sym
	rm simple.lst

.PHONY: print-vars
print-vars:
	@echo "GNU_PREFIX = $(GNU_PREFIX)"
	@echo "CC = $(CC)"
	@echo "LL = $(LL)"
	@echo "OBJCOPY = $(OBJCOPY)"
	@echo "OBJDUMP = $(OBJDUMP)"
	@echo "NM = $(NM)"
	@echo "AS = $(AS)"
	@echo "BUILD = $(BUILD)"
	@echo "AS_BUILD_FLAGS = $(AS_BUILD_FLAGS)"
	@echo "ASFLAGS = $(ASFLAGS)"
