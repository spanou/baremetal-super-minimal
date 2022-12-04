# Make Basic Tutorial

- [Home](../README.md)
    + [What Is Make](#what-is-make)
    + [Example: The Simplest Makefile Ever](#the-simplest-makefile-ever)
        + [Building the Application](#building-the-application)
        + [Generating the Binary Image](#generating-the-binary-image)
        + [Generating the Symbols and Listings](#generating-the-symbols-and-listings)
        + [Phony Targets](#phony-targets)
        + [Summary](#summary)
    + [Further Reading](#further-reading)


## What is Make

[make](https://www.gnu.org/software/make/) is an open source tool that controls the generation of executables, and other non executable files, it does so through a configuration file called Makefile. The make tool is released and managed by the [GNU project](https://gnu.org/). 

By itself ```make``` is not particularly useuful, it needs a configuration file as an input, typically named ```Makefile```. By default ```make``` will look for a ```Makefile``` in the current directory. If you name your makefile into something different, which is perfectly ok, you need to call ```make``` with the ```-f``` flag and the make of the makefile. For instance: 


```bash
make -f project.mk
```

The Makefile is something a developer writes, think of it as a collection of rules and dependencies that specify how a target application should be compiled and linked into an executable.


### The Simplest Makefile Ever

Let's start with a very simple assembly file, called ```simple.s```. We will create a Makefile to compile and link the file into an executable. 

simple.s
----

```asm
[ 1]  @
[ 2]  @ Start Up Assembler to Learn GCC ASM for ARM M4
[ 3]  @
[ 4]  .syntax unified
[ 5]  .cpu cortex-m4
[ 6]  .thumb
[ 7]  
[ 8]  .text
[ 9]  .global resetHandler
[10]  .word 0x20000400
[11]  .word resetHandler
[12]  .space 0x17C
[13]  .align 4
[14]  
[15]  .global _start
[16]  .type resetHandler, %function
[17]  resetHandler:
[18]      B _start
[19]  
[20]  _start: 
[21]      NOP
[22]      B . 
```
Now let's create a simple ```Makefile``` that will build an executable called simple.elf.

Makefile
---
```make
[1]  simple.o : simple.s
[2] 	arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 $< -o $@
[3] 
[4]  simple.elf: simple.o
[5] 	arm-none-eabi-ld simple.o -o $@ -Ttext=0x00000000
[6] 

```
Let's start breaking down the ```Makefile``` line by line. 

```
[1]  simple.o : simple.s
[2] 	arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 $< -o $@
```
Line [1] says, to build a simple.o, the object file of simple.c, I need to run the command on line [2] _(we'll examine line [2] more indepth in a second)_. In the ```make``` nomenclature, in the statement ```simple.o : simple.c``` simple.o is the **target** and simple.c is the **dependency**. The format that every **rule** follows is: 

```
    target: dependencies ...
            commands
            ...
```
Line [2] outlines what command needs to be executed to generate **simple.o** from a **simple.c**. The command itself is calling the assembler ```arm-none-eabi-as``` with the options ```-g``` to generate debug symbols, ```-mthumb``` to indicate we want to generate code for the ARM thumb instruction set, and ```-mpu=cortex-m4``` specifies that we want to generate code for the specific cortex M core. ```$<``` is a build in make variable to matches the name of the dependency, in this case **simple.c**. ```-o``` specifies that the output of the assembler should be an object file named **simple.o** as is specified by the build in make variable ```$@``` that matches the **target** in this case, **simple.o**. 

```make
[4]  simple.elf: simple.o
[5] 	arm-none-eabi-ld simple.o  -nostartfiles -o $@ -Ttext=0x00000000
```


Taking a step back, line [1] and [2] are effectively telling make what commands to invoke in order to build a **simple.o** from a **simple.s**. This is a key step in building our executable. However, that in itself is not enough. In order to build an executable we need to convert the object file **simple.o** into an ```*.elf``` file. As you can tell lines [4] and [5] are "telling" make what commands to invoke in order to build a **simple.elf** from a **simple.o**. Just like previously, in make parlance, **simple.elf** is the target, while now **simple.o** is the dependency.

So as you can see the order of dependency is:
```
simple.elf --> depends on simple.o --> which in turn depends on simple.s.
```
Line [5] outlines that in order to build an **simple.elf** we need to invoke the linker (arm-none-eabi-ld) passing in the **simple.o**, with the option ```-o``` to specify the output file with the name ```simple.elf``` as given by the build in make variable ```$@``` that matches the **target** in this case ```simple.elf```. The ```-Ttext=0x00000000``` is an instruction to the linker to force the ```.text``` region to start at location 0x00000000, which is the start of flash for the Netduinio Plus 2. We'll see the significance of this further on.

#### Building the Application
To build the application we will call make with the required target from the command line, like so: 

```make 
$ make simple.elf 
arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 simple.s -o simple.o
arm-none-eabi-ld simple.o  -o simple.elf -Ttext=0x00000000
```
A few things happened here, calling ```make``` from the command line without specifying the name of the makefile worked because by default make will look for a file named ```Makefile``` in the current directory. Furthermore, we caled it with the target ```simple.elf```, effectively asking make to build ```simple.elf``` the target. Make followed the dependency we referred to earlier and as you can see from the output, it executed the order of the dependency to build the desired target. Since ```simple.elf``` depends on ```simple.o``` which in turn depends on ```simple.s```, make first built ```simple.o``` by executing the command ```arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 simple.s -o simple.o``` and then executed the command ```arm-none-eabi-ld simple.o  -o simple.elf -Ttext=0x00000000``` to finally build ```simple.elf```. 

Now let's call the same command from the command line: 
```
$ make simple.elf
make: 'simple.elf' is up to date.
```
This output is not surprising, given that none of the files changed, make knowns that since none of the dependencies in the dependency graph changed then there is no need to build it again. That is super useful feature of make, althought it doesn't matter much for our simple little project, imagine one with 100s of dependencies, it will be rather inefficient to build everything again from scratch, especially since nothing changed. We therefore cut down our build time by a few orders of magnitude. 


Now let's play a bit. Let's "touch" ```simple.s```, you don't need to actually change the content of the file, simply type the following, 

```
$ touch simple.s
```
Effectively, all we did was to update the file timestamp of the source file. Now let's run ```make simple.elf``` again and see what happens, when we try to build our ```simple.elf``` again: 

```
$ make simple.elf
arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 simple.s -o simple.o
arm-none-eabi-ld simple.o  -o simple.elf -Ttext=0x00000000
```
Again, this is not suprising, given our dependency graph, since ```simple.s``` has changed, then it follows that ```simple.o``` needs to be assembled again and thus ```simple.elf``` needs to be rebuild. This makes perfect sense. Now, let's examine what will happen if we "touch" simple.o, and let's try to build ```simple.elf``` again immediately: 

```
$ touch simple.o
$ make simple.elf 
arm-none-eabi-ld simple.o  -o simple.elf -Ttext=0x00000000
```
Again, this makes perfect sense, given that only ```simple.o``` got "updated" but not ```simple.s``` it follows that we only need to rebuild ```simple.elf``` which is why we only see the command ```arm-none-eabi-ld simple.o  -o simple.elf -Ttext=0x00000000``` being executed. 

As you might have guessed already, make looks at the timestamp of each file in the dependency graph and only builds what it must in order to satisfy the dependency graph. So now, every time you modify your source file you can guarantee that the right calls will be made to suitably update the final ```simple.elf``` file.

### Generating the Binary Image

Now that we have the elf file ```simple.elf``` what can we actually do with it? We can do a number of things, however, we still cannot download it and run it. We need to further post-process it. Let's invoke the ```arm-none-eabi-objcopy``` from the command line to generate a binary file ```simple.bin```

```
$ arm-none-eabi-objcopy -O binary simple.elf simple.bin
$ ls -alh simple.bin
-rwxr-xr-x 1 spanou root 396 Dec  4 05:42 simple.bin
```
This ```simple.bin``` file is actually the binary image of the executable we have created and it can be donwloaded as is in the target device's flash memory for execution. However, let's not do this step manually, let's update our Makefile to do that for us.

```
[1]  simple.o : simple.s
[2] 	arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 $< -o $@
[3] 
[4]  simple.elf : simple.o
[5] 	arm-none-eabi-ld simple.o  -o $@ -Ttext=0x00000000
[6] 
[7]  simple.bin : simple.elf
[8] 	arm-none-eabi-objcopy -O binary simple.elf simple.bin
```

Once again, we will define a new target, that of ```simple.bin``` which itself now depends on ```simple.elf``` effectively we added another dependency in the dependency graph. To run this target we will first clean up the current build files and invoke make again but this time with the target ```simple.bin``` instead of ```simple.elf```. 

```
$ rm simple.bin simple.elf simple.o
$ make simple.bin
arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 simple.s -o simple.o
arm-none-eabi-ld simple.o  -o simple.elf -Ttext=0x00000000
arm-none-eabi-objcopy -O binary simple.elf simple.bin
```

Looking at the directory right now we can see all our generated files, including our newly created ```simple.bin```
```
$ ls -alh simple.*
-rwxr-xr-x 1 spanou root  396 Dec  4 05:49 simple.bin
-rwxr-xr-x 1 spanou root  66K Dec  4 05:49 simple.elf
-rw-r--r-- 1 spanou root 1.9K Dec  4 05:49 simple.o
-rw-r--r-- 1 spanou root  268 Dec  4 05:13 simple.s
```

#### Generating the Symbols and Listings 

Another couple of useful outputs will be to see the symbols we have generated and their absolute memory locations, as well as, the dissassembly of our application, let's do that by typing the following on the command line: 

```
$ arm-none-eabi-nm -l -n simple.elf
00000184 T resetHandler	simple.s:17
00000188 T _start	simple.s:20
0001018c T __bss_end__
0001018c T _bss_end__
0001018c T __bss_start
0001018c T __bss_start__
0001018c T __data_start
0001018c T _edata
0001018c T __end__
0001018c T _end
00080000 T _stack


$ arm-none-eabi-objdump -h -S simple.elf

simple.elf:     file format elf32-littlearm

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00000198  00000000  00000000  00010000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .debug_aranges 00000020  00000000  00000000  00010198  2**3
                  CONTENTS, READONLY, DEBUGGING
  2 .debug_info   00000026  00000000  00000000  000101b8  2**0
                  CONTENTS, READONLY, DEBUGGING
  3 .debug_abbrev 00000014  00000000  00000000  000101de  2**0
                  CONTENTS, READONLY, DEBUGGING
  4 .debug_line   0000003a  00000000  00000000  000101f2  2**0
                  CONTENTS, READONLY, DEBUGGING
  5 .debug_str    0000004f  00000000  00000000  0001022c  2**0
                  CONTENTS, READONLY, DEBUGGING
  6 .ARM.attributes 00000021  00000000  00000000  0001027b  2**0
                  CONTENTS, READONLY

Disassembly of section .text:

00000000 <resetHandler-0x190>:
   0:	20000400 	.word	0x20000400
   4:	00000191 	.word	0x00000191
	...
 184:	f3af 8000 	nop.w
 188:	f3af 8000 	nop.w
 18c:	f3af 8000 	nop.w

00000190 <resetHandler>:
.align 4

.global _start
.type resetHandler, %function
resetHandler:
    B _start
 190:	f000 b800 	b.w	194 <_start>

00000194 <_start>:

_start:
    NOP
 194:	bf00      	nop
    B .
 196:	e7fe      	b.n	196 <_start+0x2>

```

Now let's add both of those in our Makefile: 

```
[ 1]  simple.o : simple.s
[ 2]  	arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 $< -o $@
[ 3]  
[ 4]  simple.elf : simple.o
[ 5]  	arm-none-eabi-ld simple.o  -o $@ -Ttext=0x00000000
[ 6]  
[ 7]  simple.bin : simple.elf
[ 8]  	arm-none-eabi-objcopy -O binary simple.elf simple.bin
[ 9]  
[10]  simple.sym : simple.elf
[11]  	arm-none-eabi-nm -l -n simple.elf > simple.sym
[12]  
[13]  simple.lst : simple.elf
[14]  	arm-none-eabi-objdump -h -S simple.elf > simple.lst
[15]
```


#### Phony Targets
So now every time we want to build any of the ```lst``` and ```sym``` files all we need to do is to invoke make with those targets. However, that sounds tedious, wouldn't it be nice if we can say to make, make all these for me in one command? Turns out we can. We need to introduce the concept of a .PHONY target. A phony target doesn't really have the name of a file associated with it. Simply speaking, think of it as a name for a recipe to execute. Let's try to introduce one. We'll start with a phony target called **clean**. This target will remove all the generated files in one fell swoop! No more ```rm``` file by file.

```
[ 1]  simple.o : simple.s
[ 2]  	arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 $< -o $@
[ 3]  
[ 4]  simple.elf : simple.o 
[ 5]  	arm-none-eabi-ld simple.o  -o $@ -Ttext=0x00000000
[ 6]  
[ 7]  simple.bin : simple.elf
[ 8]  	arm-none-eabi-objcopy -O binary simple.elf simple.bin
[ 9]  
[10]  simple.sym : simple.elf 
[11]  	arm-none-eabi-nm -l -n simple.elf > simple.sym
[12]  
[13]  simple.lst : simple.elf
[14]  	arm-none-eabi-objdump -h -S simple.elf > simple.lst
[15]  
[16]  .PHONY: clean
[17]  clean:
[18]  	rm simple.elf
[19]  	rm simple.o
[20]  	rm simple.bin
[21]  	rm simple.sym
[22]  	rm simple.lst
```

Invoking clean can be done line so: 

```
$ make clean
rm simple.elf
rm simple.o
rm simple.bin
rm simple.sym
rm simple.lst
```

As you can see, we can now remove all the generated files with one command instead of 5. But let's see if we can extend it to build us all the targets in one go. 

```
[ 1]  simple.o : simple.s
[ 2]  	arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 $< -o $@
[ 3]  
[ 4]  simple.elf : simple.o 
[ 5]  	arm-none-eabi-ld simple.o  -o $@ -Ttext=0x00000000
[ 6]  
[ 7]  simple.bin : simple.elf
[ 8]  	arm-none-eabi-objcopy -O binary simple.elf simple.bin
[ 9]  
[10]  simple.sym : simple.elf 
[11]  	arm-none-eabi-nm -l -n simple.elf > simple.sym
[12]  
[13]  simple.lst : simple.elf
[14]  	arm-none-eabi-objdump -h -S simple.elf > simple.lst
[15]  
[16]  .PHONY: all 
[17]  all: simple.bin simple.sym simple.lst
[18]  
[19]  .PHONY: clean
[20]  clean:
[21]  	rm simple.elf
[22]  	rm simple.o
[23]  	rm simple.bin
[24]  	rm simple.sym
[25]  	rm simple.lst
```
Notice how phony ```clean``` is fundamentally different from phony ```all```. Whereas ```clean``` executes a bunch of commands to clean the generated files, ```all``` specifies dependencys of all the other targets, bin, sym, lst. Now let's see what this now looks in action: 

```
$ make all
arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 simple.s -o simple.o
arm-none-eabi-ld simple.o  -o simple.elf -Ttext=0x00000000
arm-none-eabi-objcopy -O binary simple.elf simple.bin
arm-none-eabi-nm -l -n simple.elf > simple.sym
arm-none-eabi-objdump -h -S simple.elf > simple.lst
```

#### Summary
As we have seen, make is a very useful tool, it is used widely in our industry and it is still one of the tools that most of us have come to rely upon. The basic concept is the ability to define a set of inter-dependencies in a Makefile in order to produce your desired output. That's pretty much the core concept, naturally we have omitted a whole bunch of seriously cool, tips and tricks. We have barely scratched the surface. Over the next section we will take our main Makefile and we'll break it down to show you some cool enhancements that will make your life a whole lot easier.


## Further Reading
TBA
