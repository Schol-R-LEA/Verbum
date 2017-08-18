#!/bin/bash
# Start the Raspberry Pi in fully functional mode!
 
qemu-system-i386 -boot order=a  -fda "boot.img",raw 
 


