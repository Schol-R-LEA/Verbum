#!/bin/bash

 
qemu-system-x86_64 -boot order=a -fda "boot.qcow2" \
 -enable-kvm                                       \
 -vga virtio -display sdl,gl=on                    \
 -serial stdio                                     \
 -smp 1                                            \
 -usb

