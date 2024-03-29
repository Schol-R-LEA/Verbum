;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; macros
;

%ifndef MACROS__INC
%define MACROS__INC

%define zero(x) xor x, x


%macro write 1
   mov si, %1
   call near print_str
%endmacro


%macro write32 2
   mov esi, %1
   mov al, %2
   call print_string32
%endmacro

%macro memset_rm 3
        push ax
        push cx
        push di
        mov ax, %1
        mov cx, %2
        mov di, %3
        cld
    rep stosb
        pop di
        pop cx
        pop ax
%endmacro

%macro memset32 3
        push eax
        push ecx
        push edi
        mov al, %1
        mov ecx, %2
        mov edi, %3
        cld
    rep stosb
        pop edi
        pop ecx
        pop eax
%endmacro


%macro memcopy_rm 3
       push di
       push si
       push cx
       mov di, %1
       mov si, %2
       mov cx, %3
       cld
   rep movsb
       pop cx
       pop si
       pop di
%endmacro


%macro memcopy_32 3
       push edi
       push esi
       push ecx
       mov edi, %1
       mov esi, %2
       mov ecx, %3
       cld
   rep movsb
       pop ecx
       pop esi
       pop edi
%endmacro



%endif
