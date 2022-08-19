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

        mov cx, 3
        mov di, doubles
        mov si, print_buffer
.dword_tests:
        call print_hex_dword
        push si
        mov si, comma
        call print_str
        pop si
        add di, 4
        loop .dword_tests
        call print_hex_dword
      
        mov si, nl
        call print_str

        mov cx, 3
        mov di, quads
        mov si, print_buffer
.qword_tests:
        call print_hex_qword
        push si
        mov si, comma
        call print_str
        pop si
        add di, 8
        loop .qword_tests
        call print_hex_qword




halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "../../simple_text_print_code.inc"
%include "../../print_hex_long_code.inc"
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
     
;;[section .rodata]
comma     db ', ', NULL
nl        db CR,LF, NULL

doubles   dd 0x00000000
          dd 0xffffffff
          dd 0x01234567
          dd 0x000055AA   

quads     dq 0x0000000000000000
          dq 0xffffffffffffffff
          dq 0x0123456789abcdef
          dq 0x00000000000055AA 


print_buffer resb 17

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
