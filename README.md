# Baremetal Super Minimal

**Baremetal Super Minimal** is a project that enables you to learn embedded programming on the popular ARM Cortex M cores from the ground up. All the tools we will use are completely open source and at either no cost or minimal one. We will not use vendor tools, ever. 



## Why Baremetal Super Minimal
There are plenty of projects that abstract some of the inherant difficulties of embedded programming. Projects such as Arduino and Raspberry Pi are some of the most widely used ones. Their aim is to simplify and accelerate your development efforts, to focus on the task at hand rather than having to deal with the tools, the project structure and other salient details that, quite frankly, distract you from the problem you are trying to solve. 

But what happens when you want to squeeze the last drop of performance? What happens if you want to do something outside of the norm? More importantly what happens when things go wrong and you have to dig deep? 

The answer to these questions typically lay outside the normal flow of operation. Where you need to really know your tools. It takes time, effort, dedication and experience to build that knowledge from the ground up. 

For this project we are going to focus on the ARM Cortex M architecture. We will go from the very low ASM start up code setting up the MCU core to handing over control to C modules without any C Runtime support. 

Going along we will touch upon all our tools and how to master their functionality.


## Do I need a board?

No! The simple answer is you don't need a board, we will provide you with a Docker image that contains all the tools you need - compilers, debuggers, utility tools and an emulation platform to run your code. 

I don't believe installing the tools is particularly challenging or noteworthy exercise, so we are going to save ourselves sometime and we'll make sure all the steps we outline here are 100% reproducible.  

**Note:** _We will still let you know where to get the tools and how to install them. We'll do that by sharing our docker build file that contains all the installation commands in great detail._

Althrough we are providing an emulation platform (QEMU), we will still provide a board based build that you can run on a board. Our board is an old SAM4 XPlain Pro. We'll try to get a new more popular low cost board to help you follow along, this will be coming soon.

## Getting More Info

All documentation resides in the ```docs/``` folder located at the root of the project. The folder structure looks like so: 

```
./docs/
├── NOTES.md
├── img
└── pdf
```

- [README.md](./README.md) - The main README file (i.e. this file).
- [docs/NOTES.md](./docs/NOTES.md) - Notes


## Next Steps

Let's keep this simple: 

1. Install Docker & Docker image
2. Clone & Build  
3. Load, Run & Debug
