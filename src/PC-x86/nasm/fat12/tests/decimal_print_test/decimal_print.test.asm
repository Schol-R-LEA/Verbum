;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test hexidecimal printing routines


;;; data structure definitions
%include "../../bios.inc"
%include "../../consts.inc"
%include "../../bpb.inc"
%include "../../dir_entry.inc"
%include "../../macros.inc"


;;; constants
boot_base        equ 0x0000      ; the segment base:offset pair for the
boot_offset      equ 0x7C00      ; boot code entrypoint

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
        mov es, ax

        ;; any other housekeeping that needs to be done at the start
        cld

        mov cx, 0xffff
        mov ax, 0
.word_countdown:
        push ax
        push cx
        mov si, decimal_buffer
        call print_decimal_word
        mov si, comma
        call print_str
        pop cx
        pop ax
        inc ax
        loop .word_countdown
        call print_decimal_word

halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "../../simple_text_print_code.inc"
%include "../../print_decimal_code.inc"
%include "../../print_hex_code.inc"        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
comma     db ', ', NULL

decimal_buffer resb 8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
