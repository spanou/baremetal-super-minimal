# Baremetal Super Minimal ASM Project

This is an example of a very simple baremetal ASM (can add C as needed) application to get you started on developing on ARM M4 from the ground up. To save you time and effort, I've put together a docker image [spanou/qemu-m4](https://hub.docker.com/r/spanou/qemu-m4) which contains a fully functioning QEMU image with support for Netduino's Plus 2 virtual board and a fully functioning GCC ARM toolchain (arm-none-eabi-...).


## Step 1 - Download and Run the docker image 
A quick introduction on how to download and launch the docker image can be found  [here](https://hub.docker.com/r/spanou/qemu-m4). You must complete this step before doing anything else.

## Step 2 - Clone and Build this example

Once you have your docker image up and running (see Step 1 above) then from the command line go to the ```development``` directory and then do the following:

```
mkdir sample
cd sample
git clone https://github.com/spanou/baremetal-super-minimal.git
cd baremetal-super-minimal
make all 
```

## Step 3 - Running on QEMU

Click [here](https://github.com/spanou/baremetal-super-minimal/blob/main/docs/running-on-qemu.md) for step by step instructions on how to run your simple ASM app on QEMU.

