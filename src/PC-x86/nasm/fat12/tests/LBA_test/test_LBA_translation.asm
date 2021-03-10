;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test for LBA translation routine


;;; data structure definitions
%include "bios.inc"
%include "consts.inc"
%include "macros.inc"


;;; local macros 
%macro write 1
        mov si, %1
        call near print_str
%endmacro

;;; constants
boot_base        equ 0x0000      ; the segment base:offset pair for the
boot_offset      equ 0x7C00      ; boot code entrypoint

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
        mov bx, es              ; save segment part of the PnP ptr
        mov ax, cs
        mov ds, ax
        mov es, ax

        ;; any other housekeeping that needs to be done at the start
        cld

        mov cx, 64
        mov ax, 0       
.test_loop:
        push cx
        mov bx, ax
        write lba
        call print_hex_word
        mov ax, bx 
        call LBA_to_CHS
        write cylinder
        mov al, ch
        call print_hex_byte
        write head
        mov al, dh
        call print_hex_byte
        write sector
        mov al, cl
        call print_hex_byte
        write nl
        mov ax, bx
        inc ax
        pop cx
        loop .test_loop
        
halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "../../simple_text_print_code.inc"
%include "../../print_hex_code.inc"
%include "../../simple_disk_handling_code.inc"


        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
     
;;[section .rodata]
lba           db "Linear Block address ", NULL
cylinder      db " == Cylinder: ", NULL
head          db ", Head: ", NULL
sector        db ", Sector: ", NULL
nl            db CR, LF, NULL

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55



