# Baremetal Super Minimal ASM Project

This is an example of a very simple ASM application to get you started on developing on the docker's [spanou/qemu-m4](https://hub.docker.com/r/spanou/qemu-m4) image with Netduino Plus 2 and ARM's tool chain arm-none-eabi- started.

For more information on the docker image click [here](https://hub.docker.com/r/spanou/qemu-m4)

For more information about this simple baremetal ASM example click [here](https://github.com/spanou/baremetal-super-minimal/blob/main/docs/running-on-qemu.md)


## First thing first

Once you have your docker image up and running (see instructions [here](https://hub.docker.com/r/spanou/qemu-m4) on how to do that) then from the command line go to the ```development``` directory and then do the following

```
mkdir sample
cd sample
git clone https://github.com/spanou/baremetal-super-minimal.git
cd baremetal-super-minimal
make all 
```
