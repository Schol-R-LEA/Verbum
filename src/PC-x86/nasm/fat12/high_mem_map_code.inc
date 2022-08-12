%ifndef HIGH_MEM_MAP__INC
%define HIGH_MEM_MAP__INC

bits 16

get_hi_memory_map:
; use the INT 0x15, eax= 0xE820 BIOS function to get a memory map
; note: initially di is 0, be sure to set it to a value so that the BIOS code will not be overwritten. 
;       The consequence of overwriting the BIOS code will lead to problems like getting stuck in `int 0x15`
; inputs: es:di -> destination buffer for 24 byte entries
; outputs: bp = entry count, trashes all registers except esi
; based on code from the OSDev.org wiki (https://wiki.osdev.org/Detecting_Memory_(x86)#Getting_an_E820_Memory_Map)
        zero(bp)                ; use BP to hold count of the entries
        zero(ebx)               ; ebx must be 0 to start
        mov di, mem_map_buffer  ; set the offset for the BIOS to write the list to
        mov eax, stage2_base    
        mov es, eax             ; set the base for the BIOS to write to

    .mem_map_init:
        mov edx, SMAP_Text	; Place "SMAP" into edx for later comparison on eax
        mov [es:di + mmap_size], dword 1 ; force a valid ACPI 3.X entry
        mov ecx, ext_mmap_size
        mov eax, mem_map
        int HMBIOS
        jc short .failed        ; carry set on first call means "unsupported function"
        mov edx, SMAP_Text	; Some BIOSes apparently trash this register?
        cmp eax, edx		; on success, eax must have been reset to "SMAP"
        jne short .failed
        test ebx, ebx		; ebx = 0 implies list is only 1 entry long (worthless)
        je short .failed
        jmp short .jmpin   

    .loop:
        mov [es:di + mmap_size], dword 1 ; force a valid ACPI 3.X entry
        mov ecx, ext_mmap_size
        mov eax, mem_map
        int HMBIOS
        jc short .finish        ; carry set means "end of list already reached"
        mov edx, SMAP_Text	; repair potentially trashed register
    .jmpin:
        jcxz .skip_entry	; skip any 0 length entries
        cmp cl, mmap_size	; got a 24 byte ACPI 3.X response?
        jbe short .no_text
        test byte [es:di + mmap_size], 1	; if so: is the "ignore this data" bit clear?
        je short .skip_entry
    .no_text:
        mov ecx, [es:di + High_Mem_Map.length]	; get lower uint32_t of memory region length
        or ecx, [es:di + High_Mem_Map.length + 4] ; "or" it with upper uint32_t to test for zero
        jz .skip_entry	        ; if length uint64_t is 0, skip entry
        inc bp			; got a good entry: ++count, move to next storage spot
        add di, ext_mmap_size
    .skip_entry:
        test ebx, ebx		; if ebx resets to 0, list is complete
        jne short .loop

    .finish:
        mov [mmap_entries], bp	; store the entry count
        clc			; there is "jc" on end of list to this point, so the carry must be cleared
        ret

    .failed:
        stc
        ret

%line 0 hi_mem_2.asm
;;; print_hi_mem_map - prints the memory table
;;; Inputs:
;;;       BP   = the number of entries found
;;;       [DI] = the memory map table
;;; Outputs:
;;;       screen
;;; Clobbers:
;;;       AX, CX, SI
print_hi_mem_map:
        jc .failed              ; if the interrupt isn't supported, fail
        cmp bp, 0
        jz .failed              ; if there are no valid entries, fail
        write mmap_prologue
        mov si, print_buffer    ; print the description of the section...
        push ax
        mov ax, bp
        call print_decimal_word ; including the number of entries found...
        write mmap_entries_label
        pop ax
        write mmap_headers      ;and the headers for the columns.
        write mmap_separator
        mov cx, bp            ; set the # of entries as the loop index

        push si
        push di

    .print_loop:
        ; write each of the structure fields with a spacer separating them
        push di
        add di, High_Mem_Map.base ; print the base value
        call print_hex_qword
        write mmap_space
        pop di
        push di
        add di, High_Mem_Map.length ; print the length value
        call print_hex_qword
        write mmap_space
        pop di
        push di
        add di, High_Mem_Map.type ; use the type value as an index into the array of strings
        mov si, mmap_types        ; get the array head
        mov ax, [di]              ; get the offset
        mov bl, mmap_types_size   ; multiply the offset by the size of the array elements
        imul bl
        add si, ax              ; print the appropriate array element
        call print_str
        write lparen            ; print the actual value of the type in parentheses
        mov si, print_buffer    
        mov ax, [di]
        call print_decimal_word
        write rparen
        write mmap_space
        pop di
        push di
        add di, High_Mem_Map.ext ; print the extended ACPI 3.x value 
        mov ax, [di]
        mov si, print_buffer
        call print_decimal_word
        write newline
        pop di
        add di, ext_mmap_size ; advance to the next entry
        loop .print_loop

    .finish:
        pop di
        pop si
        ret

    .failed:
        write mmap_failed
        ret


%endif