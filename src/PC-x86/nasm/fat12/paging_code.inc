%ifndef _PAGING_CODE__INC__
%define _PAGING_CODE__INC__

%include "paging.inc"

%line 0, "paging.asm"
bits 32

page_directory           equ 0x0040000

; 4 MiB - identity mapping the low memory and kernel
page_table_0x0000        equ page_directory    + 0x1000

; 16 MiB - the page tables
page_table_0x0001        equ page_table_0x0000 + 0x1000
page_table_0x0002        equ page_table_0x0001 + 0x1000
page_table_0x0003        equ page_table_0x0002 + 0x1000
page_table_0x0004        equ page_table_0x0003 + 0x1000

; 20 KiB - the page directory and the kernel stack
page_table_0x0005        equ page_table_0x0004 + 0x1000

; 3MiB - high-half mapping of the kernel
page_table_0x0300        equ page_table_0x0005 + 0x1000

; 4MiB - system tables
page_table_0x0301        equ page_table_0x0300 + 0x1000

; 16 KiB - virtual address of the stack
page_table_0x0304        equ page_table_0x0301 + 0x1000


init_page_directory:
        mov ebx, dword page_directory
        memset32 0, 0x1000, ebx              ; clear the page dir table

        ; 4 MiB - identity mapping the low memory and kernel 
        populate_pte page_table_0x0000, 0x1000, 0x00000000, PTE_Present

        ; 16 MiB - the page tables
        populate_pte page_table_0x0001, 0x1000, 0x00400000, PTE_Present
        populate_pte page_table_0x0002, 0x1000, 0x00800000, PTE_Present
        populate_pte page_table_0x0003, 0x1000, 0x00C00000, PTE_Present
        populate_pte page_table_0x0004, 0x1000, 0x01000000, PTE_Present

        ; 20 KiB - the page directory and the kernel stack 
        populate_pte page_table_0x0005, 0x1000, 0x01400000, PTE_Present
        
        ; 3MiB - high-half mapping of the kernel
        populate_pte page_table_0x0300, 0x0C00, 0x00100000, PTE_Present

        ; 4MiB - system tables
        populate_pte page_table_0x0301, 0x1000, 0x01400000, PTE_Present

        ; 16 KiB - virtual address of the stack
        populate_pte page_table_0x0304, 0x0010, 0x01800000, PTE_Present


    .setup_directory:
        populate_pde page_table_0x0000, 0x0000, PDE_Present
        populate_pde page_table_0x0001, 0x0001, PDE_Present
        populate_pde page_table_0x0002, 0x0002, PDE_Present
        populate_pde page_table_0x0003, 0x0003, PDE_Present
        populate_pde page_table_0x0004, 0x0004, PDE_Present
        populate_pde page_table_0x0005, 0x0005, PDE_Present
        populate_pde page_table_0x0300, 0x0300, PDE_Present
        populate_pde page_table_0x0301, 0x0301, PDE_Present
        populate_pde page_table_0x0304, 0x0304, PDE_Present


        ; set the page directory
        mov eax, page_directory
        mov cr3, eax
        ret


%endif