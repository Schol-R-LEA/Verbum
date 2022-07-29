%ifndef BIOS__INC
%define BIOS__INC

;;; Constants related to the BIOS interrupts

VBIOS           equ 0x10        ;; BIOS interrupt vector for video services
GOTO_XY         equ 0x02        ;; VBIOS routine - go to the given x, y coordinates
block_write     equ 0x09        ;; VBIOS routine - write a fixed number of times to the screen
ttype           equ 0x0E        ;; VBIOS routine - print character, teletype mode

DBIOS           equ 0x13        ;; BIOS interrupt vector for disk services
disk_reset      equ 0x00        ;; disk reset service
disk_read       equ 0x02        ;; disk read service

LMBIOS          equ 0x12
HMBIOS          equ 0x15
mem_map         equ 0xE820

A20BIOS         equ 0x15
A20_supported   equ 0x2403
A20_status      equ 0x2402
A20_activate    equ 0x2401

        
;;;BIOS error codes
reset_failure   equ 0x01        ;; error code returned on disk reset failure
read_failure    equ 0x02        ;; error code returned on disk read failure
%endif
