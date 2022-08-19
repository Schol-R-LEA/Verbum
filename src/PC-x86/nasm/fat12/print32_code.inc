;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing strings

%ifndef PRINT32_CODE__INC
%define PRINT32_CODE__INC

bits 32

Text_Base     equ 0x000b8000

horizontal_size equ 80
vertical_size   equ 25

;;; print_char32 - prints the character and attribute
;;; Inputs:
;;;        AH - character
;;;        AL - attribute
print_char32:
        push esi
        ; test whether the cursor horizontal component is in range
        ; if so, automatically go to the start of the next line
        cmp dword [Print32_X], horizontal_size - 1
        jle .test_scrolling
        mov dword [Print32_X], 0
        inc dword [Print32_Y]
        ; test whether the cursor vertical component is in range
        ; if so, scroll down once and print to the last line
    .test_scrolling:
        cmp dword [Print32_Y], vertical_size - 1
        jle .display
        push eax
        mov eax, 1
        call scroll
        pop eax
    .display:
        ; set the cursor pointer
        mov esi, [Print32_X]
        shl esi, 1
        add esi, Text_Base
        push eax
        push edx
        mov edx, horizontal_size
        mov eax, [Print32_Y]
        mul edx                ; y * the row size
        add esi, eax
        pop edx
        pop eax
        ; write to the selected text location
        mov [esi], byte ah     ; set the character
        inc esi
        mov [esi], byte al     ; set the attribute
        inc dword [Print32_X]
        pop esi
        ret


;;; print_string32 - prints the string point to by SI
;;; Inputs:
;;;        ESI - string pointer
;;;        AL  - atribute
print_string32:
        push esi
    .print_char:
        mov ah, byte [esi]
        call print_char32
        inc esi
        cmp byte [esi], NULL
        loopnz .print_char
        pop esi
        ret

scroll:
        
        ret


gotoxy:
        mov dword [Print32_X], eax
        mov dword [Print32_Y], edx
        cmp dword [Print32_X], horizontal_size - 1
        jle .test_scrolling
        mov dword [Print32_X], 0
        inc dword [Print32_Y]
        ; test whether the cursor vertical component is in range
        ; if so, scroll down once and print to the last line
    .test_scrolling:
        cmp dword [Print32_Y], vertical_size - 1
        jle .finish
        mov eax, 1
        call scroll
    .finish:
        ret


clear_screen:
        ; clear the video screen
        memset32 0, 80 * 25 * 2, Text_Base
        ret


Print32_X         dd 0
Print32_Y         dd 0


%endif
