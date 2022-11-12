# Tutorial #02 - Memory & Register Accesses [DRAFT]

In our [Getting Started Example](./getting-started.md) we skipped over many things that happened in the background. In this tutorial we will go over all of the step by step.

- [Home](../README.md)


## Memory Access
The simplest group of instructions is to access memory, either reading from it or writing to it. 

**Please note**: instructions do not operate on the memory directly, all operations need to happen using the registers. *i.e.* If you want to modify a value in memory you need to load it in a register, modify the register value, then write that register value back into memory.


### Load a Literal Value to A Register

Let's start with the most basic of all instructions, load a register with a literal value. 

```asm
LDR R0, =0xAA55AA55
```

This instruction says "load the value of ```0xAA55AA55``` into register ```R0```". Nothing can be simpler than that. LDR stands for **L**oa**D** **R**egister. 

To load a literal value into a register the instruction calculates and address from the PC and an immediate offset, loads the word from memory and then writes it to a register. Since armv7-m supports both T1 and T2


https://developer.arm.com/documentation/ddi0403/d/Application-Level-Architecture/Instruction-Details/Memory-accesses