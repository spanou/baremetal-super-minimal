# Baremetal Super Minimal

- [Introduction](#Introduction)
	+ [Next Steps](#next-steps)
	+ [Getting More Info](#getting-more-info)
	+ [Can I Contribute?](#can-i-contribute)
- [Background](#background)
	+ [Why Baremetal Super Minimal?](#why-baremetal-super-minimal)
	+ [Do I need a board to get started?](#do-i-need-a-board-to-get-started)

# Introduction

**Baremetal Super Minimal** is a project that enables you to learn embedded programming on the popular ARM Cortex M cores from the ground up. All the tools we will use are completely open source and at no cost _(you don't even need a board to get started)_. We are committing to using Open Source tools only, thereby avoiding any dependencies on vendor tools.


## Next Steps

Let's keep this simple with the following 3 simple steps:

1. [Install the Tools](./docs/getting-started.md#step-1---installing-the-tools)
2. [Clone & Build the Code](./docs/getting-started.md#step-2---clone--build-the-code)
3. [Load, Run & Debug](./docs/getting-started.md#step-3---load-debug--run-the-code)

Once we have you up and running we will go through a series of in-depth tutorials to help build your knowledge. That being said, even for the very simple example we have going there is a lot that has happened already, so let's get start with [The Basics](./docs/the-basics.md) before we jump on the first tutorial.

## Getting More Info

All documentation resides in the ```docs/``` folder located at the root of the project.

## Can I Contribute?

Absolutely yes!

Fork the project, make your changes, test them, send me a pull request. 

We'll streamline the contribution process a bit further down the line. For now, we are keeping things very simple. 

I would encourage you to keep in mind that the goal of this project is for people to learn, that means at times, we may not choose the best possible implementation, but one that helps share knowledge most efficiently. As our audience's knowledge matures through the tutorials, we can start to introduce more optimal ways of doing things. 

>**Note:** every submission must be licensed under the BSD-3 license model.

# Background

## Why Baremetal Super Minimal?
There are plenty of projects that abstract some of the inherant difficulties of embedded programming. Projects such as Arduino and Raspberry Pi are some of the most widely used ones. Their aim is to simplify and accelerate your development efforts, to focus on the task at hand rather than having to deal with the tools, configurations, setups..etc.

But what happens when you want to squeeze the last drop of performance? What happens if you want to do something outside of the norm? More importantly what happens when things go wrong and you have to dig deep?

The answer to these questions typically lay outside the normal flow of operation. Where you need to really know your tools. It takes time, effort, dedication and experience to build that knowledge from the ground up.

For this project we are going to focus on the ARM Cortex M architecture. We will go from the very low ASM start up code setting up the MCU core to handing over control to C modules. Eventually we will introduce the C runtime support and even port a Zephyr RTOS on this project. 

Going along we will touch upon all our tools and how to master their functionality.


## Do I need a board to get started?

No!

The simple answer is you don't need a board, we will provide you with a Docker image that contains all the tools you need - compilers, debuggers, utility tools and a QEMU emulation platform to run your code. In particular we provide a QEMU model for [QEMU's - Netduino Plus 2](https://qemu.readthedocs.io/en/latest/system/arm/stm32.html).

I don't believe installing the tools is particularly challenging or noteworthy exercise, so we are going to save ourselves some time and we'll make sure all the steps we outline here are 100% reproducible.

>**Note:** _We will still let you know where to get the tools and how to install them. We'll do that by sharing our docker build file that contains all the installation commands in great detail._

Although we are providing an emulation platform [(QEMU) - Netduino Plus 2](https://qemu.readthedocs.io/en/latest/system/arm/stm32.html), we will still provide a physical board based build that you can run on an actual board so you can connect up your own hardware. Our current board is a discontinued SAM4 XPlained Pro. We will aim to provide support for a newer more popular low cost board to help you follow along.
