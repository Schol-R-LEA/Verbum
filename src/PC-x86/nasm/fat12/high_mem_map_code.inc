%ifndef HIGH_MEM_MAP__INC
%define HIGH_MEM_MAP__INC

%include "macros.inc"

struc High_Mem_Map
    .base   resq 1
    .length resq 1
    .type   resd 1
    .ext    resd 1
endstruc

mmap_size         equ 20
ext_mmap_size     equ High_Mem_Map_size

SMAP_Text         equ 0x0534D4150
mem_map_buffer_size          equ 16 * ext_mmap_size


bits 16

;;; get_hi_mem_map - collects the memory table
;;; Inputs:
;;;       ES:DI   = the location to write the table to
;;;       ES:SI   = the location to write the size to
;;; Outputs:
;;;       ES:DI = the memory map table
;;; Clobbers:
;;;       AX, CX, SI
get_hi_memory_map:
; use the INT 0x15, eax= 0xE820 BIOS function to get a memory map
; note: initially di is 0, be sure to set it to a value so that the BIOS code will not be overwritten. 
;       The consequence of overwriting the BIOS code will lead to problems like getting stuck in `int 0x15`
; inputs: es:di -> destination buffer for 24 byte entries
; outputs: bp = entry count, trashes all registers except esi
; based on code from the OSDev.org wiki (https://wiki.osdev.org/Detecting_Memory_(x86)#Getting_an_E820_Memory_Map)
        zero(ebp)               ; use BP to hold count of the entries
        zero(ebx)               ; ebx must be 0 to start

        memset_rm 0, 2, si
        memset_rm 0, mem_map_buffer_size, di
    .mem_map_init:
        mov edx, SMAP_Text	    ; Place "SMAP" into edx for later comparison on eax
        mov es:[di + mmap_size], dword 1          ; force a valid ACPI 3.X entry
        mov ecx, ext_mmap_size
        mov eax, mem_map
        int HMBIOS
        jc short .failed        ; carry set on first call means "unsupported function"
        mov edx, SMAP_Text 	    ; Some BIOSes apparently trash this register?
        cmp eax, edx		    ; on success, eax must have been reset to "SMAP"
        jne short .failed
        test ebx, ebx		    ; ebx = 0 implies list is only 1 entry long (worthless)
        je short .failed
        jmp short .jmpin

    .loop:
        mov es:[di + mmap_size], dword 1          ; force a valid ACPI 3.X entry
        mov ecx, ext_mmap_size
        mov eax, mem_map
        int HMBIOS
        jc short .finish        ; carry set means "end of list already reached"
        mov edx, SMAP_Text	    ; repair potentially trashed register
    .jmpin:
        jcxz .skip_entry	    ; skip any 0 length entries
        cmp cl, mmap_size	    ; got a 24 byte ACPI 3.X response?
        jbe short .no_text
        test byte es:[di + mmap_size], 1	      ; if so: is the "ignore this data" bit clear?
        je short .skip_entry
    .no_text:
        mov ecx, es:[di + High_Mem_Map.length]	  ; get lower uint32_t of memory region length
        or ecx, es:[di + High_Mem_Map.length + 4] ; "or" it with upper uint32_t to test for zero
        jz .skip_entry	        ; if length uint64_t is 0, skip entry
        inc bp			        ; got a good entry: ++count, move to next storage spot
        add di, ext_mmap_size
    .skip_entry:
        test ebx, ebx    		; if ebx resets to 0, list is complete
        jne short .loop

    .finish:
        mov es:[si], bp     	; store the entry count
        clc		             	; there is "jc" on end of list to this point, so the carry must be cleared
        ret

    .failed:
        stc
        ret


;;; print_hi_mem_map - prints the memory table
;;; Inputs:
;;;       BP      = the number of entries found
;;;       ES:[DI] = the memory map table
;;; Outputs:
;;;       screen
;;; Clobbers:
;;;       AX, CX, SI
print_hi_mem_map:
        jc near .failed                  ; if the interrupt isn't supported, fail
        cmp bp, 0
        jz near .failed                  ; if there are no valid entries, fail
        push es
        mov ax, ds
        mov es, ax
        write mmap_prologue
        mov si, print_buffer        ; print the description of the section...
        mov ax, bp
        call print_decimal_word     ; including the number of entries found...
        write mmap_entries_label
        write mmap_headers          ; and the headers for the columns.
        write mmap_separator
        mov cx, bp                  ; set the # of entries as the loop index
        pop es
        push si
        push di

    .print_loop:
        ; write each of the structure fields with a spacer separating them
        push di
        add di, High_Mem_Map.base   ; print the base value
        call print_hex_qword
        push es
        mov ax, ds
        mov es, ax
        write mmap_space
        pop es
        pop di
        push di
        add di, High_Mem_Map.length ; print the length value
        call print_hex_qword
        push es
        mov ax, ds
        mov es, ax
        write mmap_space
        pop es
        pop di
        push di
        add di, High_Mem_Map.type   ; use the type value as an index into the array of strings
        mov si, mmap_types          ; get the array head
        mov ax, es:[di]             ; get the offset
        mov bl, mmap_types_size     ; multiply the offset by the size of the array elements
        imul bl
        add si, ax                  ; print the appropriate array element
        push es
        mov ax, ds
        mov es, ax
        call print_str
        write lparen                ; print the actual value of the type in parentheses
        mov si, print_buffer
        pop es
        mov ax, es:[di]
        call print_decimal_word
        push es
        mov ax, ds
        mov es, ax
        write rparen
        write mmap_space
        pop es
        pop di
        push di
        add di, High_Mem_Map.ext    ; print the extended ACPI 3.x value 
        mov ax, es:[di]
        push es
        mov ax, ds
        mov es, ax
        mov si, print_buffer
        call print_decimal_word
        write newline
        pop es
        pop di
        add di, ext_mmap_size       ; advance to the next entry
        dec cx
        cmp cx, 0
        jnz .print_loop

    .finish:
        pop di
        pop si
        ret

    .failed:
        write mmap_failed
        ret



%include "simple_text_print_code.inc"
%include "print_hex_code.inc"
%include "print_hex_long_code.inc"
%include "print_decimal_code.inc"

mmap_prologue                db 'High memory map (', NULL
mmap_entries_label           db ' entries):', CR,LF,NULL
mmap_headers                 db 'Base Address       | Length             | Type                  | Ext.', CR, LF, NULL
mmap_separator               db '----------------------------------------------------------------------------', CR,LF, NULL
mmap_space                   db '     ', NULL

mmap_types                   db '                ', NULL
                             db 'Free Memory     ', NULL
                             db 'Reserved Memory ', NULL
                             db 'ACPI Reclaimable', NULL
                             db 'ACPI NVS        ', NULL
                             db 'Bad Memory      ', NULL
mmap_types_size              equ 17

%endif