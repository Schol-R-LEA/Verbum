;;;;;;;;;;;;;;;;;
;; stagetwo.asm - second stage boot loader


%include "bios.inc"
%include "consts.inc"
%include "macros.inc"
%include "fat-12.inc"
%include "stage2_parameters.inc"

stage2_base     equ 0x0000            ; the segment:offset to load 
stage2_offset   equ stage2_buffer     ; the second stage into
                        
bits 16
org stage2_offset
section .text
        
entry:
        write success
        write newline

A20_enable:
        write A20_gate_status
        lea di, [bp + stg2_parameters.boot_sig]
        call test_A20
        je .A20_on

    .A20_off:
        write off

    .A20_bios_attempt:
;;; parts of this code based on examples given in the 
;;; A20 page of the OSDev wiki (https://wiki.osdev.org/A20_Line)

;        mov ax, A20_supported  
;        int A20BIOS
;        jb .a20_no_bios_support
;        cmp ah, 0
;        jnz .a20_no_bios_support 
 
;        mov ax, A20_status
;        int A20BIOS
;        jb .a20_no_bios_support     ; couldn't get status
;        cmp ah, 0
;        jnz .a20_no_bios_support    ; couldn't get status
 
 ;       cmp al, 1
 ;       jz .A20_on                   ; A20 is already activated
 
;        mov ax, A20_activate
;        int A20BIOS 
;        jb .a20_no_bios_support     ; couldn't activate the gate
;        cmp ah, 0
;        jz .A20_on                   ; couldn't activate the gate
        
    .a20_no_bios_support:
        call test_A20
        je .A20_on

    .a20_failed:
        write no_A20_Gate
        jmp halted


    .A20_on:
        write newline      
        write on

;;; halt the CPU
halted:
        write newline
        write exit
    .halted_loop:
        hlt
        jmp short .halted_loop
        

;;; test_A20 - check to see if the A20 line is enabled
;;; Inputs:
;;;       SI - effective address to test
;;;       DS - data segment of the tested address
;;; Outputs:
;;;       Zero flag - set = A20 on, clear = A20 off
test_A20:
        push ax
        push bx
        push cx
        push dx
        push es

        mov cx, 2
    .test_loop:
        mov ax, 0xFFFF
        mov es, ax
        mov di, si
        add di, 0x10            ; 16 byte difference due to segment spacing
        mov bx, word [ds:si]
        mov dx, word [es:di]
        cmp bx, dx
        mov [ds:si], word 0xDEAD
        mov [es:di], word 0xBEEF
        loopne .test_loop
    .cleanup:
        pop es
        pop dx
        pop cx
        pop bx
        pop ax
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "simple_text_print_code.inc"
%include "print_hex_code.inc"
%include "simple_disk_handling_code.inc"
%include "read_fat_code.inc"
%include "read_root_dir_code.inc"
%include "dir_entry_seek_code.inc"
%include "fat_to_file_code.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;
;; data
;;         [section .data]

newline           db CR, LF, NULL
exit              db 'Halted.', CR, LF, NULL

success           db 'Control successfully transferred to second stage.', CR, LF, NULL
A20_gate_status   db 'A20 Line Status: ', NULL
on                db 'on.', CR, LF, NULL
off               db 'off, ', CR, LF, NULL
no_A20_Gate       db 'A20 gate not found.', CR, LF, NULL
