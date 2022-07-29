;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing integer values in hex

%ifndef PRINT_DEC_CODE__INC
%define PRINT_DEC_CODE__INC

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
convert_decimal_word:


        ret

;;; print_decimal_word - convert a word to hex and print it to console
;;; Input:
;;;      AX = word to print
;;;      ES = segment where buffer resides
;;;      SI = buffer to print
;;; Output:
;;;      screen
;;; Clobbers:
;;;      AL, SI
print_decimal_word:
        
        ret

%endif
