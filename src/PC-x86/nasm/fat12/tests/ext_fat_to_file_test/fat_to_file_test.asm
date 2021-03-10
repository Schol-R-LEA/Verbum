;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test second stage reading routines


;;; data structure definitions
%include "bios.inc"
%include "consts.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "fat-12.inc"
%include "macros.inc"


;; ensure that there is no segment overlap
stack_segment    equ 0x1000  
stack_top        equ 0xFFFE


        
[bits 16]
[org boot_offset]
[section .text]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; entry - the entrypoint to the code. Make a short jump past the BPB.
entry:
        jmp short start
        nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT12 Boot Parameter Block - required by FAT12 filesystem

boot_bpb:
%include "fat-12-data.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; start
;;; This is the real begining of the code. The first order of
;;; business is clearing the interrupts, then setting the
;;; segment registers and the stack pointer.  

start:
        mov ax, stack_segment
        cli                     ;  ints out of an abundance of caution
        mov ss, ax              ; set to match the code segment
        ;; set up a stack frame for the disk info
        ;;  and other things passed by the boot sector
        mov ax, stack_top
        mov sp, ax
        mov bp, sp
        sti                     ; reset ints so BIOS calls can be used

        ;; set the remaining segment registers to match CS
        mov ax, cs
        mov ds, ax


        ;; any other housekeeping that needs to be done at the start
        cld

;;; reset the disk drive
        call near reset_disk

        mov ax, Reserved_Sectors          ; get location of the first FAT sector
        mov bx, fat_buffer
        call read_fat

        mov ax, dir_sectors
        mov bx, dir_buffer
        call near read_root_directory

        mov si, snd_stage_file
        mov di, dir_buffer
        mov cx, Root_Entries
        mov bx, dir_entry_size
        call near seek_directory_entry
        cmp bx, word 0
        je .no_file

        call read_directory_details

        mov di, fat_buffer
        mov si, stage2_buffer
        call fat_to_file
;        call print_hex_word
        
        mov bx, stage2_buffer
        mov cx, 16
    .test_loop:
        push cx
        mov cx, 8
        mov ah, 0
    .inner_loop:
        mov ax, word [bx]
        call print_hex_word
        add bx, 2
        loop .inner_loop
        pop cx
        loop .test_loop

    .no_file:
        write failed
        jmp short halted

halted:
        hlt
        jmp short halted


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "simple_text_print_code.inc"
%include "print_hex_code.inc"
%include "dir_entry_seek_code.inc"
%include "simple_disk_handling_code.inc"
%include "read_fat_code.inc"
%include "read_root_dir_code.inc"
%include "dir_entry_seek_code.inc"
%include "fat_to_file_code.inc"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
     
;;[section .rodata]      

snd_stage_file      db 'STAGE2  SYS', NULL
failed              db 'x', NULL
nl                  db CR,LF, NULL
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
