simple.o : simple.s
	arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 $< -o $@

simple.elf : simple.o 
	arm-none-eabi-ld simple.o  -o $@ -Ttext=0x00000000

simple.bin : simple.elf
	arm-none-eabi-objcopy -O binary simple.elf simple.bin

simple.sym : simple.elf 
	arm-none-eabi-nm -l -n simple.elf > simple.sym

simple.lst : simple.elf
	arm-none-eabi-objdump -h -S simple.elf > simple.lst

.PHONY: all 
all: simple.bin simple.sym simple.lst

.PHONY: clean
clean:
	rm simple.elf
	rm simple.o
	rm simple.bin
	rm simple.sym
	rm simple.lst
