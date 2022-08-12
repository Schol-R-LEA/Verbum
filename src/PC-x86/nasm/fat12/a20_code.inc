%ifndef A20_CODE__INC
%define A20_CODE__INC

bits 16

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

%endif