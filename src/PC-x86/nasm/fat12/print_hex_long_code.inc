;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing doubleword and quadword integer values in hex

%ifndef PRINT_HEX_LONG_CODE__INC
%define PRINT_HEX_LONG_CODE__INC

bits 16

%include "consts.inc"
%include "macros.inc"
%include "simple_text_print_code.inc"
%include "print_hex_code.inc"



print_hex_dword:
;;; print_hex_dword - convert a doubleword to hex and print it to console
;;; Input:
;;;      [DI] = word to print
;;;      ES   = segment where buffer resides
;;;      SI   = buffer to print
;;; Output:
;;;      screen
;;; Clobbers:
;;;      AX, SI
        mov ax, es:[di+2]
        call print_hex_word
        mov ax, es:[di]
        call print_hex_word
        ret

print_hex_qword:
;;; print_hex_qword - convert a quad word to hex and print it to console
;;; Input:
;;;      [DI] = word to print
;;;      ES   = segment where buffer resides
;;;      SI   = buffer to print
;;; Output:
;;;      screen
;;; Clobbers:
;;;      AX, SI
        mov ax, es:[di+6]
        call print_hex_word
        mov ax, es:[di+4]
        call print_hex_word
        mov ax, es:[di+2]
        call print_hex_word
        mov ax, es:[di]
        call print_hex_word
        ret

%endif
