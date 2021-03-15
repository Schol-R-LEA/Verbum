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


bits 16
org boot_offset
section .text

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
        cmp ax, 0xFFFF
        jne .read_fat_sectors
        write failure_state
        write reset_failed
        jmp halted

    .read_fat_sectors:
        mov ax, Reserved_Sectors          ; get location of the first FAT sector
        mov di, fat_buffer
        call read_fat
        cmp ax, 0xFFFF
        jne .read_root_directory
        jmp halted

    .read_root_directory:
        mov di, dir_buffer
        call near read_root_directory
        cmp ax, 0xFFFF
        jne .read_root_directory
        jmp no_file

        mov si, snd_stage_file
        mov di, dir_buffer
        mov cx, Root_Entries
        mov bx, dir_entry_size
        call near seek_directory_entry
        mov ax, di
        call print_hex_word
        write nl

        cmp di, word 0
        je no_file
        
        call read_directory_details
        mov ax, bx
        call print_hex_word
        write nl
        jmp halted


no_file:
        write failed

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
snd_stage_file  db 'STAGETWOSYS', NULL

;dir_entry_mockup    db 'STAGE2  SYS'
;           times 15 db 0
;                    db 0x03, 00, 0x51, 00

failed              db 'x', NULL
nl                  db CR,LF, NULL
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
