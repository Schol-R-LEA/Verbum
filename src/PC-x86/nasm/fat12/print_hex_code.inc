;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing integer values in hex

%ifndef PRINT_HEX_CODE__INC
%define PRINT_HEX_CODE__INC

bits 16

%include "consts.inc"
%include "macros.inc"
%include "simple_text_print_code.inc"

;;; convert_hex - convert one byte to hexidecimal value   
;;; Based on code from the _AMD Athlon Optimization Guide_, p. 84 
;;; (http://www.bartol.udel.edu/mri/sam/Athlon_code_optimization_guide.pdf)
;;; Input:
;;;      AL = byte to convert
;;;      ES = segment where buffer resides
;;;      SI = buffer to write to
;;; Output:
;;;      [SI] = written buffer
convert_hex:
        push bx
        mov bl, al
.hi_nibble:
        shr al, 4               ; convert the high nibble first
        cmp al, 10              ; if x is less than 10, set carry flag
        sbb al, 0x69            ; 0..9 –> 96h, Ah..Fh –> A1h...A6h
        das                     ;0..9: subtract 66h, Ah..Fh: Sub. 60h
        mov [si], al         ;save conversion in SI
.lo_nibble:
        inc si
        mov al, bl
        and al, 0x0F            ; clear high nibble
        cmp al, 10              ; if x is less than 10, set carry flag
        sbb al, 0x69            ; 0..9 –> 96h, Ah..Fh –> A1h...A6h
        das                     ;0..9: subtract 66h, Ah..Fh: Sub. 60h
        mov [si], al         ;save conversion in SI
        pop bx
        ret

;;; print_hex_byte - convert a byte to hex anbd print it to console
;;; convert_hex - convert one byte to hexidecimal value                    ;
;;; Input:
;;;      AL = byte to print
;;;      ES = segment where buffer resides
;;;      SI = buffer to print
;;; Output:
;;;      screen
;;; Clobbers:
;;;      AL, SI
print_hex_byte:
        mov si, word hex_buffer
        call near convert_hex
        mov si, word hex_buffer
        call near print_str
        ret

;;; print_hex_word - convert a word to hex and print it to console
;;; Input:
;;;      AX = word to print
;;;      ES = segment where buffer resides
;;;      SI = buffer to print
;;; Output:
;;;      screen
;;; Clobbers:
;;;      AL, SI
print_hex_word:
        xchg ah, al
        call near print_hex_byte
        xchg ah, al
        call near print_hex_byte
        ret


;;; print_hex_seg_offset - print a segment:offset pair
;;; Input:
;;;      GS = segment
;;;      AX = offset
;;; Clobbers:
;;;      AL, SI
print_hex_seg_offset:
        push ax
        mov ax, gs
        call near print_hex_word
        mov si, colon
        call near print_str
        pop ax
        call near print_hex_word
        ret

hex_buffer   db 0, 0, NULL      ; two bytes, plus null delim
colon        db ':', NULL

align 4 

%endif
