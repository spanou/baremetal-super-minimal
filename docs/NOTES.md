# SAM4 XPlained Pro (ATSAM4LC4CA - 256k Flash, 32K RAM)

IDCODE = 0x2BA01477
CHIPID_CIDR = 0xAB0A09E1 (@ 0x400A30F0)
CHIPID_EXID = 0x0400000F (@ 0x400A30F4)

Described in: Atmel-42023-ARM-Microcontroller-ATSAM4L-Low-Power-LCD_Datasheet.pdf - section 9.2

Chip Name: ATSAM4LC4C (Rev B?)
Family: ATSAM4LC
Flash/RAM: 256K/32K
Package: 100-pin
CHIPID_CIDR: 0xAB0A09E0 (in our case it was -> 0xAB0A09E1 - Probably Rev B)
CHIPID_EXID: 0x0400000F

## Memory Map

- FLASH @0x00000000 - 0x007FFFFF (256k)
- SRAM  @0x20000000 - 0x2007FFFF (32k)
- CACHE @0x21000000 - 0x21000FFF (4k)
- PRPHA @0x40000000 - 0x4000FFFF (64k)
- PRPHB @0x400A0000 - 0x400AFFFF (64k)
- AESA  @0x400B0000 - 0x400B00FF (256)
- PRPHC @0x400E0000 - 0x400EFFFF (64k)
- PRPHD @0x400F0000 - 0x400FFFFF (64k)


## Building The ASM Project
1. Starting the container:
    
    `Sakiss-MacBook-Pro:~ spanou$ ./development/containers/prj-qemu/qemu-dev.sh -r`


2. Navigating to the project folder 

    `spanou@qemu-arm-m4-dev:~$ cd development/sam4-xplainpro/bluepin_asm/`


3. Building the project
    
    `spanou@qemu-arm-m4-dev:~/development/sam4-xplainpro/bluepin_asm$ make all`


The output will look something like: 

>     arm-none-eabi-as -g consts.s -o consts.o
>     arm-none-eabi-as -g startup.s -o startup.o
>     arm-none-eabi-as -g vector_table.s -o vector_table.o
>     arm-none-eabi-ld consts.o startup.o vector_table.o -o startup.elf -T linker.ld
>     arm-none-eabi-objcopy -O binary startup.elf startup.bin
>     arm-none-eabi-objdump -h -S startup.elf > startup.lst
>     arm-none-eabi-nm -l -n startup.elf >  startup.sym
>     spanou@qemu-arm-m4-dev:~/development/sam4-xplainpro/bluepin_asm$


## Running The ASM Project In QEMU

    `spanou@qemu-arm-m4-dev:~/development/sam4-xplainpro/bluepin_asm$ make run`

1. The output will look something like: 

    `/home/spanou/development/qemu-m4/qemu/build/arm-softmmu/qemu-system-arm -M netduinoplus2 -display none -S -s -serial none -serial none -serial mon:stdio  -kernel startup.bin &`
    
    * `-M netduinoplus2` selects the netduinoplus2 board
    * `-display none` specifies there is not visual display
    * `-S` Stops the QEMU at start waiting for a debugger to be attached.
    * `-s` Specifies the debug server to listen to localhost:1234
    * `-serial none` specifies there is no serial port 
    * `-serial mon:stdio` put the monitor in the standard output
    * `-kernel` specifies which image to select to start from


## Debugging The ASM Project In QEMU

1. Make sure you have a `.gdbinit` the content of the file should look like:

>     add-auto-load-safe-path /home/spanou/development/sam4-xplainpro/bluepin_asm/.gdbinit
>     set architecture arm
>     target remote localhost:1234
    
2. Connect to the debugger

    `spanou@qemu-arm-m4-dev:~/development/sam4-xplainpro/bluepin_asm$ gdb-multiarch startup.elf` 
    
3. The output should look something like: 
> 
>     GNU gdb (Debian 8.2.1-2+b3) 8.2.1
>     
>     Copyright (C) 2018 Free Software Foundation, Inc.
>     
>     License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
>     
>     This is free software: you are free to change and redistribute it.
>     There is NO WARRANTY, to the extent permitted by law.
>     Type "show copying" and "show warranty" for details.
>     This GDB was configured as "x86_64-linux-gnu".
>     Type "show configuration" for configuration details.
>     For bug reporting instructions, please see:
>     <http://www.gnu.org/software/gdb/bugs/>.
>     Find the GDB manual and other documentation resources online at:
>         <http://www.gnu.org/software/gdb/documentation/>.
>         
> 
>     For help, type "help".
>     Type "apropos word" to search for commands related to "word"...
>     Reading symbols from startup.elf...done.
>     The target architecture is assumed to be arm
>     
>     resetHandler () at startup.s:19
>     19	    B _start


## Debuggin The ASM on the SAM4 X Plained Pro
 1. Make sure you have open-ocd installed if not and on MacOS then type ```brew instal open-ocd```
 
    Pleaes note your openocd installation can be found in ```/usr/local/Cellar/open-ocd/``` under that directory 
    ```
    /usr/local/Cellar/open-ocd
    └── 0.11.0
        ├── bin
        └── share
            ├── info
            ├── man
            │   └── man1
            └── openocd
                ├── OpenULINK
                ├── contrib
                │   └── libdcc
                └── scripts
                    ├── board
                    │   └── gti
                    ├── chip
                    │   ├── atmel
                    │   │   └── at91
                    │   ├── st
                    │   │   ├── spear
                    │   │   └── stm32
                    │   └── ti
                    │       └── lm3s
                    ├── cpld
                    ├── cpu
                    │   ├── arc
                    │   └── arm
                    ├── fpga
                    ├── interface
                    │   └── ftdi
                    ├── target
                    │   ├── infineon
                    │   └── marvell
                    ├── test
                    └── tools
    ```

 2. Create a ```openofc.cfg``` with the following content:
     ```
     # Atmel SAM4L xPlained Pro
     interface cmsis-dap
     cmsis_dap_vid_pid 0x03eb 0x2111
     
     # Chip Info 
     set CHIPNAME ATSAM4LC4C
     source [find target/at91sam4lXX.cfg]
     ```
 3. On the command line type ```openocd -f openofc.cfg``` the following should appear on your screen:

     ```
     Sakiss-MacBook-Pro:sam4-xplainpro spanou$ openocd -f openofc.cfg
     Open On-Chip Debugger 0.11.0
     Licensed under GNU GPL v2
     For bug reports, read
     	http://openocd.org/doc/doxygen/bugs.html
     DEPRECATED! use 'adapter driver' not 'interface'
     Info : auto-selecting first available session transport "swd". To override use 'transport select <transport>'.
     adapter srst delay: 0
     
     Info : Listening on port 6666 for tcl connections
     Info : Listening on port 4444 for telnet connections
     Info : CMSIS-DAP: SWD  Supported
     Info : CMSIS-DAP: FW Version = 03.25.01B6
     Info : CMSIS-DAP: Serial# = ATML1783020200001808
     Info : CMSIS-DAP: Interface Initialised (SWD)
     Info : SWCLK/TCK = 1 SWDIO/TMS = 1 TDI = 1 TDO = 1 nTRST = 0 nRESET = 1
     Info : CMSIS-DAP: Interface ready
     Info : clock speed 50 kHz
     Info : SWD DPIDR 0x2ba01477
     Info : ATSAM4LC4C.cpu: hardware has 6 breakpoints, 4 watchpoints
     Info : starting gdb server for ATSAM4LC4C.cpu on 3333
     Info : Listening on port 3333 for gdb connections
     ```
 4. At this point you are ready to connect your gdb, do the following: 
    ```
    gdb-mutliarch <name of your elf>
    target remote localhost:3333
    ```
