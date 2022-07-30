;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing strings

%ifndef SIMPLE_TEXT_PRINT_CODE__INC
%define SIMPLE_TEXT_PRINT_CODE__INC

%include "macros.inc"

;;; print_str - prints the string point to by SI
;;; Inputs:
;;;        ES:SI - string to print
print_str:
        pusha
        mov ah, ttype       ; set function to 'teletype mode'
        zero(bx)
        mov cx, 1
    .print_char:
        lodsb               ; update byte to print
        cmp al, NULL        ; test that it isn't NULL
        jz short .endstr
        int  VBIOS          ; put character in AL at next cursor position
        jmp short .print_char
    .endstr:
        popa
        ret

%endif
