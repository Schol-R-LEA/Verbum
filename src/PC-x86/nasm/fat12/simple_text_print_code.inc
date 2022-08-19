;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing strings

%ifndef SIMPLE_TEXT_PRINT_CODE__INC
%define SIMPLE_TEXT_PRINT_CODE__INC

bits 16

%include "macros.inc"

;;; print_str - prints the string point to by SI
;;; Inputs:
;;;        ES:SI - string to print
print_str:
        pusha
        mov ah, ttype       ; set function to 'teletype mode'
        zero(bx)
        mov cx, 1
        jmp short .print_start    ; skip the interrupt once
    .print_char:
        int  VBIOS          ; put character in AL at next cursor position
    .print_start:
        lodsb               ; update byte to print
        cmp al, NULL        ; test that it isn't NULL
        jnz short .print_char

        popa
        ret

%endif
