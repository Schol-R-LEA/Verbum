#!/bin/bash
# Start the Raspberry Pi in fully functional mode!
 
qemu-system-i386
 -m 256 \
 -fda "boot.img",id=fd0,raw \
 -device virtio-blk-device,drive=hd0 \
 -device virtio-net-device,netdev=net0 \
-serial stdio
 


