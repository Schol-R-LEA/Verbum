;;; Constants related to the text console

%ifndef CONSTS__INC
%define CONSTS__INC


;;; character constants
NULL            equ 0x00        ;; end of string marker
CR              equ 0x0D        ;; carriage return
LF              equ 0x0A        ;; line feed 

ascii_zero      equ 0x30
ascii_upper_A   equ 0x41
ascii_lower_a   equ 0x61

upper_numerals  equ ascii_upper_A - 10

%endif
