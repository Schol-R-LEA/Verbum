%ifndef _PAGING_CODE__INC__
%define _PAGING_CODE__INC__

%line 0, "paging.asm"
bits 32

page_directory           equ 0x0040000
page_table_0             equ page_directory + 0x1000
page_table_768           equ page_table_0   + 0x1000

init_page_directory:
        mov ebx, dword page_directory
        memset32 0, 0x0400, ebx                ; clear the page dir table

        ; start by setting up the base page table
        mov ebx, dword page_table_0            ; get index into the base page table
        memset32 0, 0x0400, ebx                ; clear the table entries
        ; entries 0-1024 - identity mapping the first 1 MiB of memory
        mov ecx, 0x0100                        ; 256 entries * 4KiB = 1 MiB
        mov eax, 0
    .pt_0_fill:
        mov edx, eax
        or edx, PTE_Present
        mov [ebx], dword edx
        add eax, 0x1000
        add ebx, 4
        loop .pt_0_fill

        ; set up the kernel code table
        mov ebx, page_table_768                ; get index into the kernel code page table
        memset32 0, 0x0400, ebx                ; clear the table entries
        ; entries 0-4096 - mapping the start of higher half
        mov ecx, 0x1000                        ; 4096 entries * 4KiB = 4 MiB
        mov eax, 0x00100000                    ; the 1MiB entry point
    .pt_768_fill:
        mov edx, eax
        or edx, PTE_Present
        mov [ebx], dword edx
        add eax, 0x1000
        add ebx, 4
        loop .pt_768_fill


    .setup_directory:
        mov ebx, page_directory
    .pd_fill:
        mov eax, page_table_0
        or eax, PDE_Present
        mov [ebx], eax
        add ebx, 768 * 4
        mov eax, page_table_768
        or eax, PDE_Present
        mov [ebx], eax


        ; set the page directory
        mov eax, page_directory
        mov cr3, eax
        ret


%endif