;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test for LBA translation routine


;;; data structure definitions
%include "../../bios.inc"
%include "../../consts.inc"
%include "../../bpb.inc"
%include "../../fat_entry.inc"
%include "../../macros.inc"


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

;;;operational constants 
tries            equ 0x03        ; number of times to attempt to access the FDD
high_nibble_mask equ 0x0FFF
mid_nibble_mask  equ 0xFF0F
nibble_shift     equ 4

        
[bits 16]
[org boot_offset]
[section .text]
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
        sub ax, stg2_parameters_size
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




        
halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "../../simple_text_print_code.inc"
%include "../../print_hex.inc"
%include "../../simple_disk_handling_code.inc"


        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
     
;;[section .rodata]

snd_stage_file  db 'STAGE2  SYS'

; reading_fat     db 'Get sector...', NULL
;loading         db 'Load stage 2...', NULL
;separator       db ':', NULL
;comma_done      db ', '
;done            db 'done.', CR, LF, NULL
;failure_state   db 'Unable to ', NULL
;reset_failed    db 'reset,', NULL
;read_failed     db 'read,'
;exit            db ' halted.', NULL
;oops            db 'Oops.', NULL 

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55



