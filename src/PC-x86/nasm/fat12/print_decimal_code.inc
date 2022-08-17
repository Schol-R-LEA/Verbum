;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing integer values in hex

%ifndef PRINT_DEC_CODE__INC
%define PRINT_DEC_CODE__INC

bits 16

%include "consts.inc"
%include "macros.inc"
%include "simple_text_print_code.inc"


;;; convert_decimal_word - convert one word to decimal value   
;;; Input:
;;;      AX = word to convert
;;;      ES = segment where buffer resides
;;;      SI = buffer to write to
;;; Output:
;;;      [SI] = written buffer
;;; Clobbers:
;;;      AX, SI
convert_decimal_word:
        push bx
        push cx
        push dx
        mov bx, 10
        mov cx, si
        mov es:[si+6], byte 0
        add si, 6
    .loop:
        zero(dx)
        idiv bx
        add dl, ascii_zero
        dec si
        mov es:[si], dl
        cmp ax, 0     ; if the quotient is zero, there are no more digits
        je short .finish
        cmp cx, si
        jle short .loop
    .finish:
        pop dx
        pop cx
        pop bx
        ret

;;; print_decimal_word - convert a word to hex and print it to console
;;; Input:
;;;      AX = word to print
;;;      ES = segment where buffer resides
;;;      SI = buffer to print
;;; Output:
;;;      screen
;;; Clobbers:
;;;      AX, SI
print_decimal_word:
        call convert_decimal_word
        call print_str
        ret

%endif
